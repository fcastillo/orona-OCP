/**
 * @author: fer : 11/04/14 - 20:15
 */
package components
{
import flash.events.Event;

public class ComponentLoaderEvent extends Event
{
    public static const LOAD_COMPLETE:String = "components.ComponentLoaderEvent.LOAD_COMPLETE";

    public function ComponentLoaderEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
    {
        super(type, bubbles, cancelable);
    }
}
}
