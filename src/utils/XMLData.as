/**
 * Gestor de carga de contenidos xml.
 *
 * @author: fer : 04/04/14 - 11:20
 * @extends EventDispatcher
 */
package utils
{

import components.Ticker;
import components.Weather;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.external.ExternalInterface;
import flash.net.URLLoader;
import flash.net.URLRequest;

public class XMLData extends EventDispatcher
{
    static public function floorHasDirectory(logicalPosition:uint):Boolean
    {
        var showDirVal:String = xmlFloors.PISO.(@id==logicalPosition).@showDirectory;
        return showDirVal == "true";
    }

    static public function hasContentGoingUp():Boolean
    {
        var elements1:XMLList = xmlUP.AREA.(@tipo==1).ELEMENTO;
        return elements1.length() > 0;
        //var elements3:XMLList = xmlUP.AREA.(@tipo==3).ELEMENTO;
       // var elements4:XMLList = xmlUP.AREA.(@tipo==4).ELEMENTO;
        //return elements1.length() > 0 || elements3.length() > 0 || elements4.length() > 0;
    }

    static public function hasContentGoingDown():Boolean
    {
        var elements1:XMLList = xmlDOWN.AREA.(@tipo==1).ELEMENTO;
        return elements1.length() > 0;
        //var elements3:XMLList = xmlDOWN.AREA.(@tipo==3).ELEMENTO;
        //var elements4:XMLList = xmlDOWN.AREA.(@tipo==4).ELEMENTO;
        //return elements1.length() > 0 || elements3.length() > 0 || elements4.length() > 0;
    }

    static public function areaHasContentForFloor(areaNum:uint, floorNum:int):Boolean
    {
        var elements:XMLList = xmlFloors.PISO.(@id==floorNum).AREA.(@tipo==areaNum).ELEMENTO;
        return elements.length() > 0;
    }

    static public var contentsURL:String = ""; // url a los contenidos
    static public var contentsURLSeparator:String = ""; // separador de directorio para mac y windows

    static public var xmlConfig:XML = null;   // xml de configuración del player
    static public var xmlTemplate:XML = null; // xml de template
    static public var xmlFloors:XML = null;   // xml de reposo en pisos
    static public var xmlUP:XML = null;       // xml de subida
    static public var xmlDOWN:XML = null;     // xml de bajada

    private var xml:XML; // xml de contenidos principal
    private var CONFIG_URL:String = "config.xml";   // xml de configuración de la app
    private var ALARMS_URL:String = "alarms.xml";   // xml de alarmas
    private var WEATHER_URL:String = "weather.xml"; // xml de tiempo
    private var TICKER_URL:String = "ticker.xml";   // xml de ticker

    public function XMLData()
    {
    }

    /**
     * Carga del xml de configuración
     *
     * @param url
     */
    public function loadConfig():void
    {
        var loader:URLLoader = new URLLoader();
        loader.addEventListener(Event.COMPLETE, handle_configLoadComplete);
        loader.addEventListener(IOErrorEvent.IO_ERROR, handle_configLoadError);
        loader.load(new URLRequest(CONFIG_URL));
    }

    private function handle_configLoadComplete(event:Event):void
    {
        var loader:URLLoader = event.target as URLLoader;
        loader.removeEventListener(Event.COMPLETE, handle_configLoadComplete);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, handle_configLoadError);

        var xmlString:String = event.target.data;
        xml = new XML(xmlString);

        XMLData.xmlConfig = xml;
        XMLData.contentsURL = xml.DATOS.@RUTA;
        XMLData.contentsURLSeparator = String(XMLData.contentsURL).indexOf("C:") != -1 ? "\\" : "/";

        var xmlDataEvent:XMLDataEvent = new XMLDataEvent(XMLDataEvent.CONFIG_LOADED);
        dispatchEvent(xmlDataEvent);
    }

    private function handle_configLoadError(event:IOErrorEvent):void
    {
        var loader:URLLoader = event.target as URLLoader;
        loader.removeEventListener(Event.COMPLETE, handle_configLoadComplete);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, handle_configLoadError);

        var xmlDataEvent:XMLDataEvent = new XMLDataEvent(XMLDataEvent.CONFIG_LOAD_ERROR);
        dispatchEvent(xmlDataEvent);
    }

    /**
     * Recarga del xml de configuración
     *
     * @param url
     */
    public function reloadConfig():void
    {
        var loader:URLLoader = new URLLoader();
        loader.addEventListener(Event.COMPLETE, handle_configReloadComplete);
        loader.addEventListener(IOErrorEvent.IO_ERROR, handle_configReloadError);
        loader.load(new URLRequest(CONFIG_URL));
    }

    private function handle_configReloadComplete(event:Event):void
    {
        var loader:URLLoader = event.target as URLLoader;
        loader.removeEventListener(Event.COMPLETE, handle_configReloadComplete);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, handle_configReloadError);

        var xmlString:String = event.target.data;
        xml = new XML(xmlString);

        /*XMLData.xmlConfig = xml;
        XMLData.contentsURL = xml.DATOS.@RUTA;
        XMLData.contentsURLSeparator = String(XMLData.contentsURL).indexOf("C:") != -1 ? "\\" : "/";*/

        var xmlDataEvent:XMLDataEvent = new XMLDataEvent(XMLDataEvent.CONFIG_RELOADED);
        xmlDataEvent.config = xml;
        dispatchEvent(xmlDataEvent);
    }

    private function handle_configReloadError(event:IOErrorEvent):void
    {
        var loader:URLLoader = event.target as URLLoader;
        loader.removeEventListener(Event.COMPLETE, handle_configReloadComplete);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, handle_configReloadError);

        var xmlDataEvent:XMLDataEvent = new XMLDataEvent(XMLDataEvent.CONFIG_RELOAD_ERROR);
        dispatchEvent(xmlDataEvent);
    }

    /**
     * Inyección de xml de datos en versión preview.
     *
     * @param xmlVersion
     */
    public function setPreviewData(xmlConfig:XML, xmlVersion:XML):void
    {
        ExternalInterface.call("flashLog", "[OCPController] handle_previewDataReady");

        xml = xmlConfig;

        XMLData.xmlConfig = xmlConfig;
        XMLData.contentsURL = "http://5.9.137.10/orona/oce/preview";
        XMLData.contentsURLSeparator = String(XMLData.contentsURL).indexOf("C:") != -1 ? "\\" : "/";


        XMLData.xmlUP = xmlVersion.SUBIDA[0];
        XMLData.xmlDOWN = xmlVersion.BAJADA[0];
        XMLData.xmlTemplate = xmlVersion.PLANTILLA[0];
        XMLData.xmlFloors = xmlVersion.REPOSO[0];

        var xmlDataEvent:XMLDataEvent = new XMLDataEvent(XMLDataEvent.CHANGED, xmlVersion.REPOSO, xmlVersion.SUBIDA, xmlVersion.BAJADA);
        dispatchEvent(xmlDataEvent);
    }

    /**
     * Carga de xml de datos.
     *
     * @param url
     */
    public function load(url:String):void
    {
        var loader:URLLoader = new URLLoader();
        loader.addEventListener(Event.COMPLETE, handle_loadComplete);
        loader.addEventListener(IOErrorEvent.IO_ERROR, handle_loadError);
        loader.load(new URLRequest(url));
    }

    /**
     * Carga de xml de alarmas.
     */
    public function loadAlarmsData():void
    {
        var loader:URLLoader = new URLLoader();
        loader.addEventListener(Event.COMPLETE, handle_alarmsDataLoadComplete);
        loader.addEventListener(IOErrorEvent.IO_ERROR, handle_alarmsDataLoadError);
        loader.load(new URLRequest(ALARMS_URL));
    }

    /**
     * Carga de xml de tiempo.
     */
    public function loadWeatherData(referer:Weather):void
    {
        var now:Date = new Date();
        var loader:URLLoader = new URLLoader();
        loader.addEventListener(Event.COMPLETE, function(event:Event){  handle_weatherDataLoadComplete(event, referer); });
        loader.addEventListener(IOErrorEvent.IO_ERROR, handle_weatherDataLoadError);
        if(OCP.OCP_TYPE == OCP.OCP_PREVIEW)
        {
            WEATHER_URL = "http://5.9.137.10/orona/backend/icm_data/weather.xml";
        }
        loader.load(new URLRequest(WEATHER_URL+"?"+now.getTime()));
    }

    /**
     * Carga de xml de ticker.
     */
    public function loadTickerData(referer:Ticker):void
    {
        var now:Date = new Date();
        var loader:URLLoader = new URLLoader();
        loader.addEventListener(Event.COMPLETE, function(event:Event){  handle_tickerDataLoadComplete(event, referer); });
        loader.addEventListener(IOErrorEvent.IO_ERROR, handle_tickerDataLoadError);

        if(OCP.OCP_TYPE == OCP.OCP_PREVIEW)
        {
            TICKER_URL = "http://5.9.137.10/orona/backend/icm_data/ticker.xml";
        }
        loader.load(new URLRequest(TICKER_URL+"?"+now.getTime()));
    }

    /**
    * Carga de xml de anuncios.
    */
    public function loadAdsData():void
    {
       var adsUrl:String = XMLData.contentsURL+XMLData.contentsURLSeparator+"publicidad"+XMLData.contentsURLSeparator+"parrillas"+XMLData.contentsURLSeparator+XMLData.xmlConfig.PUBLI.@FILE;
       var loader:URLLoader = new URLLoader();
       loader.addEventListener(Event.COMPLETE, handle_adsDataLoadComplete);
       loader.addEventListener(IOErrorEvent.IO_ERROR, handle_adsDataLoadError);
       loader.load(new URLRequest(adsUrl));
    }

    /**
     * Callbacks de carga de datos de anuncios.
     *
     * @param event
     */

    private function handle_adsDataLoadComplete(event:Event):void
    {
        var loader:URLLoader = event.target as URLLoader;
        loader.removeEventListener(Event.COMPLETE, handle_adsDataLoadComplete);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, handle_adsDataLoadError);

        var xmlString:String = loader.data;
        xml = new XML(xmlString);

        var xmlDataEvent:XMLDataEvent = new XMLDataEvent(XMLDataEvent.ADS_LOADED, null, null, null, null, null, xml);
        dispatchEvent(xmlDataEvent);
    }

    private function handle_adsDataLoadError(event:IOErrorEvent):void
    {
        var loader:URLLoader = event.target as URLLoader;
        loader.removeEventListener(Event.COMPLETE, handle_adsDataLoadComplete);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, handle_adsDataLoadError);

        dispatchEvent(new XMLDataEvent(XMLDataEvent.ADS_LOAD_ERROR));
    }

    /**
     * Callbacks de carga de datos de tiempo.
     *
     * @param event
     */

    private function handle_weatherDataLoadComplete(event:Event, referer:Weather):void
    {
        var loader:URLLoader = event.target as URLLoader;
        loader.removeEventListener(Event.COMPLETE, handle_weatherDataLoadComplete);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, handle_weatherDataLoadError);

        var xmlString:String = event.target.data;
        xml = new XML(xmlString);

        var xmlDataEvent:XMLDataEvent = new XMLDataEvent(XMLDataEvent.WEATHER_LOADED, null, null, null, null, xml);
        xmlDataEvent.weatherRef = referer;
        dispatchEvent(xmlDataEvent);
    }

    private function handle_weatherDataLoadError(event:IOErrorEvent):void
    {
        var loader:URLLoader = event.target as URLLoader;
        loader.removeEventListener(Event.COMPLETE, handle_weatherDataLoadComplete);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, handle_weatherDataLoadError);

        dispatchEvent(new XMLDataEvent(XMLDataEvent.WEATHER_LOAD_ERROR));
    }

    /**
     * Callbacks de carga de datos de ticker.
     *
     * @param event
     */

    private function handle_tickerDataLoadComplete(event:Event, referer:Ticker):void
    {
        var loader:URLLoader = event.target as URLLoader;
        loader.removeEventListener(Event.COMPLETE, handle_tickerDataLoadComplete);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, handle_tickerDataLoadError);

        var xmlString:String = event.target.data;
        xml = new XML(xmlString);

        var xmlDataEvent:XMLDataEvent = new XMLDataEvent(XMLDataEvent.TICKER_LOADED, null, null, null, null, null, null, xml);
        xmlDataEvent.tickerRef = referer;
        dispatchEvent(xmlDataEvent);
    }

    private function handle_tickerDataLoadError(event:IOErrorEvent):void
    {
        var loader:URLLoader = event.target as URLLoader;
        loader.removeEventListener(Event.COMPLETE, handle_tickerDataLoadComplete);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, handle_tickerDataLoadError);

        dispatchEvent(new XMLDataEvent(XMLDataEvent.TICKER_LOAD_ERROR));
    }

    /**
     * Callbacks de carga de alarmas.
     *
     * @param event
     */

    private function handle_alarmsDataLoadComplete(event:Event):void
    {
        var loader:URLLoader = event.target as URLLoader;
        loader.removeEventListener(Event.COMPLETE, handle_alarmsDataLoadComplete);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, handle_alarmsDataLoadError);

        var xmlString:String = event.target.data;
        xml = new XML(xmlString);

        var xmlDataEvent:XMLDataEvent = new XMLDataEvent(XMLDataEvent.ALARMS_LOADED, null, null, null, xml);
        dispatchEvent(xmlDataEvent);
    }

    private function handle_alarmsDataLoadError(event:IOErrorEvent):void
    {
        var loader:URLLoader = event.target as URLLoader;
        loader.removeEventListener(Event.COMPLETE, handle_alarmsDataLoadComplete);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, handle_alarmsDataLoadError);

        dispatchEvent(new XMLDataEvent(XMLDataEvent.ALARMS_LOAD_ERROR));
    }

    /**
     * Callbacks de carga de datos.
     *
     * @param event
     */
    private function handle_loadComplete(event:Event):void
    {
        var loader:URLLoader = event.target as URLLoader;
        loader.removeEventListener(Event.COMPLETE, handle_loadComplete);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, handle_loadError);

        var xmlString:String = event.target.data;
        xml = new XML(xmlString);

        XMLData.xmlUP = xml.SUBIDA[0];
        XMLData.xmlDOWN = xml.BAJADA[0];
        XMLData.xmlTemplate = xml.PLANTILLA[0];
        XMLData.xmlFloors = xml.REPOSO[0];

        var xmlDataEvent:XMLDataEvent = new XMLDataEvent(XMLDataEvent.CHANGED, xml.REPOSO, xml.SUBIDA, xml.BAJADA);
        dispatchEvent(xmlDataEvent);
    }

    private function handle_loadError(event:IOErrorEvent):void
    {
        var loader:URLLoader = event.target as URLLoader;
        loader.removeEventListener(Event.COMPLETE, handle_loadComplete);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, handle_loadError);

        dispatchEvent(new XMLDataEvent(XMLDataEvent.LOAD_ERROR));
    }
}
}
