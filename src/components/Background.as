/**
 * Componente de imagen de fondo
 *
 * @author: fer : 22/04/14 - 13:17
 * @extends AbstractComponent
 * @implements IComponent
 *
 * <AREA tipo="1" pathfondo="background.jpg" ID="256">
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

public class Background extends AbstractComponent implements IComponent
{
    private var loader:Loader;
    private var w:Number;
    private var h:Number;

    public function Background()
    {
        super();
        _type = AbstractComponent.BACKGROUND;
        TweenLite.to(this, 0, {alpha: 0});
    }

    public function init():void
    {
        w = _area.width;
        h = _area.height;

        var xPos:Number = 0;
        var yPos:Number = 0;

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

        addChild(loader);
    }

    private function handle_loadError(event:IOErrorEvent):void
    {
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

        loader = null;
    }
}
}
