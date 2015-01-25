/**
 * Iconos de estado para el area 3.
 *
 * @author: fer : 04/05/14 - 16:27
 * @extends AbstractComponent
 * @implements IComponent
 */
package components
{
import flash.display.Bitmap;
import flash.utils.getDefinitionByName;

public class Icons extends AbstractComponent implements IComponent
{
    public static const HANDICAPPED:String = "Handicapped";

    public function Icons()
    {
        super();
    }

    public function init():void
    {
        this.x = _area.x;;
        this.y = _area.y;
    }

    public function show(type:String):void
    {
        switch(type)
        {
            case HANDICAPPED:
                clear();
                var imgClass:Class = getDefinitionByName(type) as Class;
                var icon:Bitmap = new Bitmap(new imgClass());
                addIcon(icon);
                break;
        }
    }

    private function addIcon(icon:Bitmap):void
    {
        icon.x = _area.width / 2 - icon.width / 2;
        icon.y = _area.height / 2 - icon.height / 2;
        this.addChild(icon);
    }

    public function clear():void
    {
        while(this.numChildren) this.removeChildAt(0);
    }
}
}
