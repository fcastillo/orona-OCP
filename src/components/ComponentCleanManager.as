/**
 * Marca los componentes susceptibles de ser eliminados
 * en los cambios de estado.
 *
 * @author: fer : 25/04/14 - 10:57
 */
package components
{
import areas.IArea;

import controller.OCPController;

import utils.XMLData;

public class ComponentCleanManager
{
    private static var instance:ComponentCleanManager = null;

    private var _areas:Array;
    public function set areas(value:Array):void
    {
       _areas = value;
    }

    public static function getInstance():ComponentCleanManager
    {
        if(instance == null)
        {
            instance = new ComponentCleanManager();
        }
        return instance;
    }

    public function ComponentCleanManager()
    {
    }

    public function filter(from:int, to:int):void
    {
        if(from < to)  // subiendo
        {
            filterUp();
        }
        else if(from > to) // bajando
        {
            filterDown();
        }
        else    // en un piso
        {
            filterFloor(from);
        }
    }

    private function filterUp():void
    {
        var floorsData:XMLList = XMLData.xmlFloors.PISO;
        if(OCPController.logicalFloor > floorsData.length()-1 || OCPController.logicalFloor < 0)
        {
            return;
        }

        var xmlAreas:XMLList = XMLData.xmlUP.AREA;

        for(var i:uint = 1; i <= _areas.length; i++)
        {
            var area:IArea = _areas[i-1];
            if(area.index != 2)
            {
                area.setCleanables(xmlAreas.(@tipo==i)[0].ELEMENTO, xmlAreas.(@tipo==i)[0].@pathfondo);
            }
        }
    }

    private function filterDown():void
    {
        var floorsData:XMLList = XMLData.xmlFloors.PISO;
        if(OCPController.logicalFloor > floorsData.length()-1 || OCPController.logicalFloor < 0)
        {
            return;
        }

        var xmlAreas:XMLList = XMLData.xmlDOWN.AREA;

        for(var i:uint = 1; i <= _areas.length; i++)
        {
            var area:IArea = _areas[i-1];
            if(area.index != 2)
            {
                area.setCleanables(xmlAreas.(@tipo==i)[0].ELEMENTO, xmlAreas.(@tipo==i)[0].@pathfondo);
            }
        }
    }

    private function filterFloor(floor:int):void
    {
        var floorToShow:int = floor;
        var floorsData:XMLList = XMLData.xmlFloors.PISO;
        if(floor > floorsData.length()-1)
        {
            floorToShow = floorsData.length()-1;
        }
        if(floor < 0) floorToShow = 0;

        var xmlAreas:XMLList = XMLData.xmlFloors.PISO.(@id==floorToShow)[0].AREA;

        for(var i:uint = 1; i <= _areas.length; i++)
        {
            var area:IArea = _areas[i-1];
            if(area.index != 2)
            {
                area.setCleanables(xmlAreas.(@tipo==i)[0].ELEMENTO, xmlAreas.(@tipo==i)[0].@pathfondo);
            }
        }
    }
}
}
