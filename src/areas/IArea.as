/**
 * @author: fer : 02/04/14 - 11:04
 */
package areas
{
import components.Directory;
import components.IComponent;

public interface IArea
{
    function set x(val:int):void;
    function get x():int;
    function set y(val:int):void;
    function get y():int;
    function set width(w:int):void;
    function get width():int;
    function set height(w:int):void;
    function get height():int;
    function set index(i:int):void;
    function get index():int;
    function getComponents():Array;
    function getComponent(id:String):IComponent;
    function addComponent(component:IComponent):void;
    function draw():void;
    function clear(forceAll:Boolean = false):void;
    function setCleanables(xml:XMLList, background:String):void;
}
}
