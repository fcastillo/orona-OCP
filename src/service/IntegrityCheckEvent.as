/**
 * @author: fer : 12/05/14 - 13:26
 */
package service
{
import flash.events.Event;

public class IntegrityCheckEvent extends Event
{
    public static const INVALID_SOURCES:String = "service.IntegrityCheckEvent.INVALID_SOURCES";

    public function IntegrityCheckEvent(type:String)
    {
        super(type, false, false);
    }
}
}
