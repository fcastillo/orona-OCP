/**
 * @author: fer : 12/05/14 - 13:25
 */
package service
{
import com.hurlant.crypto.Crypto;
import com.hurlant.crypto.symmetric.ICipher;
import com.hurlant.crypto.symmetric.IPad;
import com.hurlant.crypto.symmetric.PKCS5;
import com.hurlant.util.Base64;
import com.hurlant.util.Hex;

import controller.OCPController;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.TimerEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.text.TextField;
import flash.utils.ByteArray;
import flash.utils.Timer;

import utils.StringUtils;

import utils.XMLData;
import utils.XMLDataEvent;

public class IntegrityCheck extends EventDispatcher
{
    private const LOCALHOST_PATH:String = "http://localhost/";

    private const TIMER_MS:Number = 24*3600*1000; // intervalo de timer en ms (cada 24 horas)
    private const LOAD_CONFIG_URL:String = "cargar_config.php";
    private const CHECK_VERSION_URL:String = "comprobar_version.php";
    private var loader:URLLoader;

    private var timer:Timer;

    public var txt:TextField;

    private var _xmlData:XMLData;
    private var configReloaded:XML;
    private var timestamp:Number;

    public function set xmlData(value:XMLData):void
    {
        _xmlData = value;
    }

    public function IntegrityCheck()
    {
        timer = new Timer(TIMER_MS, 1);
        timer.addEventListener(TimerEvent.TIMER, handle_timer);

        loader = new URLLoader();
        loader.addEventListener(Event.COMPLETE, handle_configLoadComplete);
        loader.addEventListener(IOErrorEvent.IO_ERROR, handle_configLoadError);
    }

    public function init():void
    {
        //OCP.log(("[IntegrityCheck init]");
        if(!timer.running) timer.start();
    }

    private function handle_timer(event:TimerEvent):void
    {
        OCP.log("[IntegrityCheck handle_timer]");
        check();
    }

    private function check():void
    {
        var now:Number = new Date().getTime();
        loader.load(new URLRequest(LOCALHOST_PATH+LOAD_CONFIG_URL+"?"+now));
    }

    private function handle_configLoadError(event:IOErrorEvent):void
    {
        //OCP.log("[IntegrityCheck handle_configLoadError]");
    }

    /**
     * Si devuelve 0 seguimos con la versión actual.
     * Si devuelve 1 enviamos de vuelta cargado=1
     * @param event
     */
    private function handle_configLoadComplete(event:Event):void
    {
        OCP.log("[IntegrityCheck handle_configLoadComplete]\n");
        if(parseInt(loader.data) == 0)
        {
        } else {
            sendResponseToLoadConfig();
        }
    }

    /**
     * Enviamos de vuelta a cargar_config el parámetro cargado=1
     */
    private function sendResponseToLoadConfig():void
    {
        OCP.log("[IntegrityCheck sendResponseToLoadConfig]\n");
        var urlVars:URLVariables =  new URLVariables();
        urlVars.cargado = 1;

        var request:URLRequest = new URLRequest(LOCALHOST_PATH+CHECK_VERSION_URL);
        request.method = URLRequestMethod.POST;
        request.data = urlVars;

        var loader2:URLLoader = new URLLoader();
        loader2.addEventListener(Event.COMPLETE, handle_load2Complete);
        loader2.addEventListener(IOErrorEvent.IO_ERROR, handle_load2Error);
        loader2.load(request);
    }

    /**
     * Recargamos el xml de configuración.
     *
     * @param event
     */
    private function handle_load2Complete(event:Event):void
    {
        var loader2:URLLoader = event.target as URLLoader;
        loader2.removeEventListener(Event.COMPLETE, handle_load2Complete);
        loader2.removeEventListener(IOErrorEvent.IO_ERROR, handle_load2Error);

        _xmlData.addEventListener(XMLDataEvent.CONFIG_RELOADED, handle_configReloaded);
        _xmlData.addEventListener(XMLDataEvent.CONFIG_RELOAD_ERROR, handle_configReloadError);
        _xmlData.reloadConfig();
    }

    private function handle_load2Error(event:IOErrorEvent):void
    {
        OCP.log("[IntegrityCheck handle_load2Error]\n");
        var loader2:URLLoader = event.target as URLLoader;
        loader2.removeEventListener(Event.COMPLETE, handle_load2Complete);
        loader2.removeEventListener(IOErrorEvent.IO_ERROR, handle_load2Error);
    }

    /**
     * Archivo de configuración recargado.
     *
     * @param event
     */
    private function handle_configReloaded(event:XMLDataEvent):void
    {
        OCP.log("[IntegrityCheck handle_configReloaded]\n");
        _xmlData.removeEventListener(XMLDataEvent.CONFIG_RELOADED, handle_configReloaded);
        _xmlData.removeEventListener(XMLDataEvent.CONFIG_RELOAD_ERROR, handle_configReloadError);

        configReloaded = event.config;

        timestamp = new Date().getTime();

        var variables:URLVariables = new URLVariables();
        variables.nombreVersion = configReloaded.VERSION.@FILE;
        variables.time = timestamp;
        if(configReloaded.PUBLI)
        {
            if(StringUtils.trim(configReloaded.PUBLI.@FILE) != "") variables.nombrePubli = configReloaded.PUBLI.@FILE;
        }

        var request:URLRequest = new URLRequest(LOCALHOST_PATH+CHECK_VERSION_URL);
        request.data = variables;

        var loader3:URLLoader = new URLLoader();
        loader3.addEventListener(Event.COMPLETE, handle_versionCheck);
        loader3.addEventListener(IOErrorEvent.IO_ERROR, handle_versionCheckError);
        loader3.load(request);
    }

    private function handle_configReloadError(event:XMLDataEvent):void
    {
         OCP.log("[IntegrityCheck handle_configReloadError]\n");
        _xmlData.removeEventListener(XMLDataEvent.CONFIG_RELOADED, handle_configReloaded);
        _xmlData.removeEventListener(XMLDataEvent.CONFIG_RELOAD_ERROR, handle_configReloadError);
    }

    /**
     * Comprobamos la integridad de la versión.
     *
     * @param event
     */
    private function handle_versionCheck(event:Event):void
    {
        var loader3:URLLoader = event.target as URLLoader;
        loader3.removeEventListener(Event.COMPLETE, handle_versionCheck);
        loader3.removeEventListener(IOErrorEvent.IO_ERROR, handle_versionCheckError);

        var response:String = loader3.data;
        var responseEval:String = decrypt(response);

        // 'valido=1,time=timestamp'
        var pos:int = responseEval.indexOf("valido");
        var posTime:int = responseEval.indexOf("time");
        var params:Array = responseEval.split(",");

        if ((pos != -1) && (posTime != -1))
        {
            var validVersion:uint = parseInt(params[0].split("=")[1]);
            var timeReceived:Number = parseFloat(params[1].split("=")[1]);
            OCP.log("validVersion="+validVersion+"\n");
            OCP.log("timeReceived="+timeReceived+"\n");
            if(validVersion == 1)
            {
                if (timeReceived == timestamp)
                {
                    OCP.log("VERSIÓN VÁLIDA\n");
                    OCPController.APP_MODE = OCPController.APP_VALID;
                }else{
                    OCP.log("VERSIÓN NO VÁLIDA\n");
                    dispatchEvent(new IntegrityCheckEvent(IntegrityCheckEvent.INVALID_SOURCES));
                }
            }else{
                OCP.log("VERSIÓN NO VÁLIDA\n");
                dispatchEvent(new IntegrityCheckEvent(IntegrityCheckEvent.INVALID_SOURCES));
            }
        }
        else
        {
            OCP.log("VERSIÓN NO VÁLIDA\n");
            dispatchEvent(new IntegrityCheckEvent(IntegrityCheckEvent.INVALID_SOURCES));
        }
    }

    private function handle_versionCheckError(event:IOErrorEvent):void
    {
        var loader3:URLLoader = event.target as URLLoader;
        loader3.removeEventListener(Event.COMPLETE, handle_versionCheck);
        loader3.removeEventListener(IOErrorEvent.IO_ERROR, handle_versionCheckError);
    }

    /**
     * Para desencriptar la respuesta al comprobar la integridad de la versión.
     *
     * @param txt
     * @return
     */
    private function decrypt(txt:String = ''):String
    {
        var data:ByteArray = Base64.decodeToByteArray(txt);
        var pad:IPad = new PKCS5;
        var mode:ICipher = Crypto.getCipher('simple-des-ecb', Hex.toArray(Hex.fromString('TESTTEST')), pad);
        pad.setBlockSize(mode.getBlockSize());
        mode.decrypt(data);
        return Hex.toString(Hex.fromArray(data));
    }


}
}
