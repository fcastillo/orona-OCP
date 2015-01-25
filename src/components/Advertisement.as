/**
 * Componente de publicidad.
 *
 * @author: fer : 22/04/14 - 13:22
 * @extends AbstractComponent
 * @implements IComponent
 */
package components
{
import flash.events.AsyncErrorEvent;
import flash.events.NetStatusEvent;
import flash.media.SoundTransform;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;

import utils.XMLData;
import utils.XMLDataEvent;

public class Advertisement extends AbstractComponent implements IComponent
{
    private var videoHolder:flash.media.Video;
    private var netConnection:NetConnection;
    private var netStream:NetStream;

    private var currentIndex:int = -1;

    private var xmlAds:XML;
    private var _xmlData:XMLData; // gestor de carga de xml
    public function set xmlData(value:XMLData):void
    {
        _xmlData = value;
        _xmlData.addEventListener(XMLDataEvent.ADS_LOADED, handle_adsDataLoaded, false, 0, true);
        _xmlData.addEventListener(XMLDataEvent.ADS_LOAD_ERROR, handle_adsDataLoadError, false, 0, true);
    }

    public function Advertisement()
    {
        super();
        _type = AbstractComponent.ADVERTISEMENT;

        netConnection = new NetConnection();
        netConnection.connect(null);

        var customClient:Object = new Object();
        customClient.onMetaData = handle_metadata;

        var soundTransform:SoundTransform = new SoundTransform();
        soundTransform.volume = 1;

        netStream = new NetStream(netConnection);
        netStream.client = customClient;
        netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, handle_asyncError, false, 0, true);
        netStream.addEventListener(NetStatusEvent.NET_STATUS, handle_status, false, 0, true);
        netStream.soundTransform = soundTransform;

        videoHolder = new flash.media.Video();

        videoHolder.smoothing = true;
        videoHolder.attachNetStream(netStream);

        addChild(videoHolder);
    }

    public function init():void
    {
        this.alpha = parseFloat(data.@transparencia);

        var w:Number = _area.width * data.@ancho;
        var h:Number = _area.height * data.@alto;

        var xPos:Number = _area.width * data.@cX;
        var yPos:Number = _area.height * data.@cY;

        this.x = xPos;
        this.y = yPos;

        videoHolder.width = w;
        videoHolder.height = h;

        _xmlData.loadAdsData();
    }

    private function handle_adsDataLoaded(event:XMLDataEvent):void
    {
        _xmlData.removeEventListener(XMLDataEvent.ADS_LOADED, handle_adsDataLoaded);
        _xmlData.removeEventListener(XMLDataEvent.ADS_LOAD_ERROR, handle_adsDataLoadError);

        xmlAds = event.xmlAds;

        playNext();
    }

    private function handle_adsDataLoadError(event:XMLDataEvent):void
    {
        _xmlData.removeEventListener(XMLDataEvent.ADS_LOADED, handle_adsDataLoaded);
        _xmlData.removeEventListener(XMLDataEvent.ADS_LOAD_ERROR, handle_adsDataLoadError);
    }

    private function playNext():void
    {
        currentIndex = currentIndex < xmlAds.lista.video.length()-1 ? currentIndex + 1 : 0;
        var videoName:String = xmlAds.lista.video[currentIndex].@hash + "." + xmlAds.lista.video[currentIndex].@EXTENSION;
        var adsUrl:String = XMLData.contentsURL+XMLData.contentsURLSeparator+"publicidad"+XMLData.contentsURLSeparator+"videos"+XMLData.contentsURLSeparator+videoName;
        netStream.play(adsUrl);
    }

    /**
    * En caso de loop aquí se vuelve a ejecutar el video.
    * @param event
    */
    private function handle_status(event:NetStatusEvent):void
    {
        if (event.info.code == "NetStream.Play.Stop" && data.@bucle == "true")
        {
            playNext();
        }
    }

    /**
    * Para evitar que salten errores.
    * @param event
    */
    private function handle_asyncError(event:AsyncErrorEvent):void
    {
    }

    /**
    * Para evitar que salten errores.
    * @param infoObject
    */
    private function handle_metadata(infoObject:Object):void
    {
    }

    /**
     * Destruye el componente.
     */
    override public function destroy():void
    {
        while(this.numChildren) this.removeChildAt(0);

        videoHolder.attachNetStream(null);
        netStream.close();
        netStream.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, handle_asyncError);
        netStream.removeEventListener(NetStatusEvent.NET_STATUS, handle_status);
        netStream = null;

        netConnection.close();
        netConnection = null;

        _xmlData.removeEventListener(XMLDataEvent.ADS_LOADED, handle_adsDataLoaded);
        _xmlData.removeEventListener(XMLDataEvent.ADS_LOAD_ERROR, handle_adsDataLoadError);
        _xmlData = null;

        while(this.numChildren) this.removeChildAt(0);
    }
}
}
