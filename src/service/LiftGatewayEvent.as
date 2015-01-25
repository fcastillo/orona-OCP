/**
 * @author: fer : 02/04/14 - 11:35
 */
package service
{
import flash.events.Event;

public class LiftGatewayEvent extends Event
{
    public static const XML_DATA_INJECTED:String = "service.LiftGatewayEvent.XML_DATA_INJECTED";
    public var xmlPath:String = "";

    public static const PREVIEW_DATA_READY:String = "service.LiftGatewayEvent.PREVIEW_DATA_READY";
    public static const READY:String = "service.LiftGatewayEvent.READY";
    public static const DIRECTION_CHANGE:String = "service.LiftGatewayEvent.DIRECTION_CHANGE";
    public static const SHOW_FLOOR_STRING:String = "service.LiftGatewayEvent.SHOW_FLOOR_STRING";
    public static const SET_LIFT_STATE:String = "service.LiftGatewayEvent.SET_LIFT_STATE";
    public static const SET_LOGICAL_POSITION:String = "service.LiftGatewayEvent.SET_LOGICAL_POSITION";
    public static const SET_TEXT:String = "service.LiftGatewayEvent.SET_TEXT";
    public static const SHOW_FLOOR:String = "service.LiftGatewayEvent.SHOW_FLOOR";

    private var _direction:int = -1;
    private var _floorName:String = "";
    private var _liftState:int = -1;
    private var _logicalPosition:int = -1;
    private var _text:String = "";
    private var _xmlConfig:XML = null;
    private var _xmlVersion:XML = null;

    public function LiftGatewayEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
    {
        super(type, bubbles, cancelable);
    }

    public function get direction():int
    {
        return _direction;
    }

    public function set direction(value:int):void
    {
        _direction = value;
    }

    public function get floorName():String
    {
        return _floorName;
    }

    public function set floorName(value:String):void
    {
        _floorName = value;
    }

    public function get liftState():int
    {
        return _liftState;
    }

    public function set liftState(value:int):void
    {
        _liftState = value;
    }

    public function get logicalPosition():int
    {
        return _logicalPosition;
    }

    public function set logicalPosition(value:int):void
    {
        _logicalPosition = value;
    }

    public function get text():String
    {
        return _text;
    }

    public function set text(value:String):void
    {
        _text = value;
    }

    public function get xmlConfig():XML
    {
        return _xmlConfig;
    }

    public function set xmlConfig(value:XML):void
    {
        _xmlConfig = value;
    }

    public function get xmlVersion():XML
    {
        return _xmlVersion;
    }

    public function set xmlVersion(value:XML):void
    {
        _xmlVersion = value;
    }
}
}
