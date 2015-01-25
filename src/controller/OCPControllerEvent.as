/**
 * @author: fer : 22/04/14 - 10:48
 */
package controller
{
import flash.events.Event;

public class OCPControllerEvent extends Event
{
    public static const DATA_LOADED:String = "controller.OCPControllerEvent.DATA_LOADED";

    public function OCPControllerEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
    {
        super(type, bubbles, cancelable);
    }
}
}
