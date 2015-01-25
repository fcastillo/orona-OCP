/**
 * Clase principal del componente de visualización de pisos.
 *
 * @extends AbstractComponent
 * @implements IComponent
 * @author: fer : 01/04/14 - 17:00
 */
package components
{
import flash.display.MovieClip;
import flash.events.Event;
import flash.geom.ColorTransform;
import flash.text.TextField;
import flash.text.TextFormat;

import utils.XMLData;

public class FloorCounter extends AbstractComponent implements IComponent
{
    // elementos gráficos en el escenario
    public var arrowUp:MovieClip;   // flecha sentido subida
    public var arrowDown:MovieClip; // flecha sentido bajada
    public var floor:TextField;     // campo de texto con el nombre del piso
    //--

    public function FloorCounter()
    {
        super();
        _type = AbstractComponent.FLOOR_COUNTER;
        addEventListener(Event.ADDED_TO_STAGE, handle_added);

        arrowUp.bg.gotoAndStop(1);
        arrowDown.bg.gotoAndStop(1);
    }

    public function reset():void
    {
        arrowUp.bg.gotoAndStop(1);
        arrowDown.bg.gotoAndStop(1);
    }

    private function handle_added(e:Event):void
    {
        removeEventListener(Event.ADDED_TO_STAGE, handle_added);

        var textformat:TextFormat = new TextFormat();
        textformat.color = XMLData.xmlTemplate.@color_textos;

        floor.defaultTextFormat = textformat;
        floor.setTextFormat(textformat);

        var colorTransform:ColorTransform = new ColorTransform();
        colorTransform.color = XMLData.xmlTemplate.@color_bordes;

        arrowUp.border.transform.colorTransform = colorTransform;
        arrowDown.border.transform.colorTransform = colorTransform;
        arrowDown.bg.transform.colorTransform = colorTransform;
        arrowUp.bg.transform.colorTransform = colorTransform;
    }

    public function init():void
    {
    }

    /**
     * El contador de pisos se para.
     */

    public function stopMode():void
    {
        arrowUp.bg.gotoAndStop(1);
        arrowDown.bg.gotoAndStop(1);
    }

    /**
     * El ascensor sube.
     */
    public function goingUp():void
    {
        arrowDown.bg.gotoAndStop(1);
        arrowUp.bg.play();
    }

    /**
     * El ascensor baja.
     */
    public function goingDown():void
    {
        arrowUp.bg.gotoAndStop(1);
        arrowDown.bg.play();
    }

    /**
     * Se muestra el piso.
     *
     * @param floorName  Nombre a mostrar (2 caracteres máx.)
     */
    public function showFloor(floorName:String):void
    {
        floor.text = floorName;
    }

}
}
