/**
 * Componente de imagen.
 *
 * @author: fer : 22/04/14 - 13:17
 * @extends AbstractComponent
 * @implements IComponent
 *
 * <ELEMENTO alto="0.235" ancho="1" tipo="imagen" ID="4" profundidad="3" transparencia="1" cY="0.04875" cX="0" path="img1.jpg"/>
 */
package components
{

import com.greensock.TweenLite;
import com.greensock.easing.Quad;

import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;

import utils.XMLData;

public class Image extends AbstractComponent implements IComponent
{
    private var loader:Loader;
    private var w:Number;
    private var h:Number;

    public function Image()
    {
        super();
        _type = AbstractComponent.IMAGE;
    }

    public function init():void
    {
        this.alpha = parseFloat(data.@transparencia);

        w = _area.width * data.@ancho;
        h = _area.height * data.@alto;

        var xPos:Number = _area.width * data.@cX;
        var yPos:Number = _area.height * data.@cY;

        this.x = xPos;
        this.y = yPos;

        loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handle_loadComplete, false, 0, true);
        loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handle_loadError, false, 0, true);
        if(OCP.OCP_TYPE == OCP.OCP_PREVIEW)
        {
            loader.load(new URLRequest(data.@path));
        } else {
            loader.load(new URLRequest(XMLData.contentsURL+XMLData.contentsURLSeparator+data.@path));
        }


        TweenLite.to(this, 0, {alpha: 0});

        addChild(loader);
    }

    private function handle_loadError(event:IOErrorEvent):void
    {
        // error en la carga de la imagen
        loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, handle_loadComplete);
        loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, handle_loadError);
    }

    private function handle_loadComplete(event:Event):void
    {
        loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, handle_loadComplete);
        loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, handle_loadError);

        loader.content.width = w;
        loader.content.height = h;

        TweenLite.to(this, .5, {alpha: 1, ease: Quad.easeOut});
    }

    override public function destroy():void
    {
        loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, handle_loadComplete);
        loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, handle_loadError);

        while(this.numChildren) this.removeChildAt(0);
    }
}
}
