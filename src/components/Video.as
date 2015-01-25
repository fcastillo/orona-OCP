/**
 * Clase base del componente Video.
 *
 * @author: fer : 12/04/14 - 10:01
 * @extends AbstractComponent
 * @implements IComponent
 */
package components
{
import com.greensock.TweenLite;
import com.greensock.easing.Quad;

import flash.events.AsyncErrorEvent;
import flash.events.NetStatusEvent;
import flash.media.SoundTransform;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;

import utils.XMLData;

public class Video extends AbstractComponent implements IComponent
{
    private var videoHolder:flash.media.Video;
    private var netConnection:NetConnection;
    private var netStream:NetStream;

    public function Video()
    {
        super();

        OCP.log("[Video]");

        _type = AbstractComponent.VIDEO;

        TweenLite.to(this, 0, {alpha: 0});

        netConnection = new NetConnection();
        netConnection.connect(null);

        var customClient:Object = new Object();
        customClient.onMetaData = handle_metadata;

        var soundTransform:SoundTransform = new SoundTransform();
        soundTransform.volume = 0;

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

    /**
     * En caso de loop aquí se vuelve a ejecutar el video.
     * @param event
     */
    private function handle_status(event:NetStatusEvent):void
    {
        OCP.log("[Video status->"+event.info.code+"]");
        if (event.info.code == "NetStream.Play.Stop" && data.@bucle == "true")
        {
            netStream.seek(0);
        }
    }

    /**
     * Para evitar que salten errores.
     * @param event
     */
    private function handle_asyncError(event:AsyncErrorEvent):void
    {
        OCP.log("[Video handle_asyncError]");
    }

    /**
     * Para evitar que salten errores.
     * @param infoObject
     */
    private function handle_metadata(infoObject:Object):void
    {
    }

    /**
     * Ajusta los parámetros de tamaño y posición.
     */
    public function init():void
    {
        OCP.log("[Video init]");

        this.alpha = parseFloat(data.@transparencia);

        var w:Number = _area.width * data.@ancho;
        var h:Number = _area.height * data.@alto;

        var xPos:Number = _area.width * data.@cX;
        var yPos:Number = _area.height * data.@cY;

        this.x = xPos;
        this.y = yPos;

        videoHolder.width = w;
        videoHolder.height = h;

        if(OCP.OCP_TYPE == OCP.OCP_PREVIEW)
        {
            netStream.play(String(data.@path));
            //netStream.play('http://5.9.137.10/orona/backend/icm_data/10044/resources/Secuencia01_3_mp4_encoded.mp4');

        } else {
            netStream.play(XMLData.contentsURL+XMLData.contentsURLSeparator+data.@path);
        }

        TweenLite.to(this, 1, {alpha: 1, ease: Quad.easeOut});
    }

    /**
     * Destruye el componente.
     */
    override public function destroy():void
    {
        videoHolder.attachNetStream(null);

        netStream.close();
        netStream.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, handle_asyncError);
        netStream.removeEventListener(NetStatusEvent.NET_STATUS, handle_status);
        netStream = null;

        netConnection.close();
        netConnection = null;

        while(this.numChildren) this.removeChildAt(0);
    }
}
}
