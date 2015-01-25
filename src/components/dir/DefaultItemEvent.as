/**
 * Evento que emito el item de tipo default en los cambios de tamaño.
 *
 * @author: fer : 03/05/14 - 12:20
 * @extends Event
 */
package components.dir
{
import flash.events.Event;

public class DefaultItemEvent extends Event
{
    public static const ACTIVE_ITEM_HIDDEN:String = "components.dir.DefaultItemEvent.ACTIVE_ITEM_HIDDEN";
    public static const OUT_OF_BOUNDS_UP:String   = "components.dir.DefaultItemEvent.OUT_OF_BOUNDS_UP";
    public static const OUT_OF_BOUNDS_BOTTOM:String   = "components.dir.DefaultItemEvent.OUT_OF_BOUNDS_BOTTOM";
    public static const CLOSING:String   = "components.dir.DefaultItemEvent.CLOSING";
    public static const OPENING:String   = "components.dir.DefaultItemEvent.OPENING";
    public static const MOVED:String   = "components.dir.DefaultItemEvent.MOVED";
    public static const ACTIVE:String   = "components.dir.DefaultItemEvent.ACTIVE";
    public static const RESIZING_UP:String   = "components.dir.DefaultItemEvent.RESIZING_UP";    // crece
    public static const RESIZING_DOWN:String = "components.dir.DefaultItemEvent.RESIZING_DOWN";  // decrece

    private var _y:Number = 0;
    public function get y():Number
    {
        return _y;
    }
    private var _height:Number = 0;
    public function get height():Number
    {
        return _height;
    }

    private var _index:uint = 0;
    public function get index():uint
    {
        return _index;
    }

    public function set index(value:uint):void
    {
        _index = value;
    }

    private var _maxItems:uint = 0;
    public function get maxItems():uint
    {
        return _maxItems;
    }

    public function set maxItems(value:uint):void
    {
        _maxItems = value;
    }

    public function DefaultItemEvent(type:String, height:Number, y:Number = 0)
    {
        super(type, false, false);

        _y = y;
        _height = height;
    }


}
}
