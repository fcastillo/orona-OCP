/**
 * Funcionalidad básica común a todos los componentes.
 * Cada componentes debe extender esta clase.
 * Clase asbtracta, no instanciar directamente.
 *
 * @author: fer : 03/04/14 - 16:59
 * @extends MovieClip
 */
package components
{
import areas.IArea;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;

public class AbstractComponent extends MovieClip
{
    public static const FLOOR_COUNTER:String = "floorCounter";
    public static const SLIDESHOW:String = "slideShow";
    public static const CLOCK:String = "clock";
    public static const WEATHER:String = "weather";
    public static const TICKER:String = "ticker";
    public static const IMAGE:String = "image";
    public static const BACKGROUND:String = "background";
    public static const VIDEO:String = "video";
    public static const TEXT:String = "text";
    public static const DIRECTORY:String = "directory";
    public static const MENU:String = "menu";
    public static const RSS:String = "rss";
    public static const ADVERTISEMENT:String = "advertisement";

    private var _cleanable:Boolean = true; // flag para saber si puede ser eliminado

    protected var _type:String = "";
    public function get type():String
    {
        return _type;
    }

    public function set type(str:String):void
    {
        _type = str;
    }

    private var _data:XML = null;
    public function get data():XML
    {
        return _data;
    }

    public function set data(value:XML):void
    {
        _data = value;
    }

    private var _depth:int = 0;
    public function get depth():int
    {
        if(data == null) return 0;
        return data.@profundidad;
    }

    public function set depth(value:int):void
    {
        _depth = value;
    }

    protected var holder:Sprite = null;
    protected var _area:IArea;

    public function set area(value:IArea):void
    {
        _area = value;
    }

    public function get area():IArea
    {
        return _area;
    }

    public function AbstractComponent()
    {
        addEventListener(Event.ADDED_TO_STAGE, handle_addedToStage, false, 0, true);
    }

    protected function handle_addedToStage(event:Event):void
    {
        removeEventListener(Event.ADDED_TO_STAGE, handle_addedToStage);
    }

    public function destroy():void
    {
        if(holder != null) this.removeChild(holder)
    }

    protected function draw():void
    {
        if (_type != AbstractComponent.FLOOR_COUNTER)
        {
            var w:Number = _area.width * _data.@ancho;
            var h:Number = _area.height * _data.@alto;

            var xPos:Number = _area.width * _data.@cX;
            var yPos:Number = _area.height * _data.@cY;

            this.x = xPos;
            this.y = yPos;

            holder = new Sprite();
            holder.graphics.beginFill(getRandomColor(),.5);
            holder.graphics.drawRect(0,0, w, h);
            holder.graphics.endFill();

            this.addChild(holder);
        }
    }

    private function getRandomColor():uint
    {
        var r:uint = Math.random()*255;
        var g:uint = Math.random()*255;
        var b:uint = Math.random()*255;
        var color:uint = r << 16 | g << 8 | b;

        return color;
    }

    /**
     * Compara dos componentes por su xml de datos.
     *
     * @param component
     * @return
     */
    public function equals(xml:XML):Boolean
    {
        if(data == null) return true;
        delete data.@ID;
        delete xml.@ID;
        return data == xml;
    }

    /**
     * Si es susceptible de ser eliminado en el cambio de estado.
     */
    public function get cleanable():Boolean
    {
        return _cleanable;
    }

    public function set cleanable(value:Boolean):void
    {
        _cleanable = value;
    }
}
}
