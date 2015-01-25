/**
 * @author: fer : 02/04/14 - 20:38
 */
package components
{
import areas.IArea;

public interface IComponent
{
    function get type():String;
    function set type(str:String):void;
    function get depth():int;
    function set depth(value:int):void;
    function get data():XML;
    function set data(xml:XML):void;
    function set area(a:IArea):void;
    function init():void;
    function destroy():void;
}
}
