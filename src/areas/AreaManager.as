/**
 * Gestor de areas.
 *
 * @author: fer : 02/04/14 - 11:12
 */
package areas
{
import components.AbstractComponent;
import components.ComponentCleanManager;
import components.ComponentFactory;
import components.ComponentLoaderEvent;
import components.ComponentsLoader;
import components.Directory;
import components.FloorCounter;
import components.Icons;

import controller.OCPController;

import flash.display.Stage;

import service.LiftGateway;

import utils.StringUtils;
import utils.XMLData;

public class AreaManager
{
    public static var defaultFloorString:String = ""; // para almacenar el valor de piso a mostrar si el componente no está todavía disponible

    private var areasCollection:Array = []; // Array de areas
    private var area2:IArea;
    private var floorCounter:FloorCounter = null;
    private var dir:Directory = null; // directorio
    private var icons:Icons = null;   // iconos de estado en area3
    private var stage:Stage;
    private var logicalPosition:int = 0;
    private var liftStatus:uint = 3;
    private var liftLastStatus:uint = 3;
    private var alarmActivated:Boolean = false;
    private var liftGateway:LiftGateway;

    public function AreaManager(stage:Stage, liftGateway:LiftGateway)
    {
        this.stage = stage;
        this.liftGateway = liftGateway;
    }

    public function addArea(area:IArea):void
    {
        areasCollection.push(area);
    }

    public function clearAreas(forceAll:Boolean = false):void
    {
        for(var i:int = 0; i < areasCollection.length; i++)
        {
            if(areasCollection[i].index != 2) areasCollection[i].clear(forceAll);
        }
    }

    public function initAreas():void
    {
        ComponentsLoader.getInstance().addEventListener(ComponentLoaderEvent.LOAD_COMPLETE, handle_areasInitContentLoaded, false, 0, true);
        ComponentCleanManager.getInstance().areas = areasCollection;
    }

    private function handle_areasInitContentLoaded(event:ComponentLoaderEvent):void
    {
        floorCounter = FloorCounter(ComponentsLoader.getInstance().getComponentByType(AbstractComponent.FLOOR_COUNTER));
        area2 = getArea(2);
        area2.addComponent(floorCounter);
        area2.draw();

        var area1:IArea = getArea(1);
        dir = ComponentFactory.getInstance().getDirectory();
        dir.area = area1;
        dir.init();
        stage.addChild(dir);

        var area3:IArea = getArea(3);
        icons = ComponentFactory.getInstance().getIcons();
        icons.area = area3;
        icons.init();
        stage.addChild(icons);

        liftGateway.init();
    }

    public function showFloor():void
    {
        //OCP.log("[AreaManager showFloor]");
        if(XMLData.floorHasDirectory(logicalPosition) && !alarmActivated)
        {
             showDir(false);
             dir.setFloor(logicalPosition, false);
        }
        showFloorContent();
    }

    public function showFloorString(floorStr:String):void
    {
        //OCP.log("[AreaManager showFloorString]");
        AreaManager.defaultFloorString = StringUtils.trim(floorStr);

        if(floorCounter != null)
        {
            var floor:String = StringUtils.trim(floorStr);
            floorCounter.showFloor(floor);
        }
        if(dir.dirStyle == Directory.STYLE_1)
        {
            dir.setFloor(logicalPosition, true);  // parpadeo
        }
    }

    public function setText(text:String):void
    {
    }

    public function setLogicalPosition(logicalPosition:int):void
    {
        if(!alarmActivated && (logicalPosition < this.logicalPosition && !XMLData.hasContentGoingDown() || logicalPosition > this.logicalPosition && !XMLData.hasContentGoingUp()))
        {
            this.logicalPosition = logicalPosition;
            showDir(true);
            dir.setFloor(logicalPosition, true);
        }
        this.logicalPosition = logicalPosition;
    }


    /*****************************************************
     * Estados del ascensor según el tipo de movimiento. *
     *****************************************************/

    /**
     * SUBIENDO.
     */
    public function goingUpMode():void
    {
        //OCP.log("[AreaManager goingUpMode]");
        floorCounter.goingUp();
        if(!alarmActivated)
        {

            if(OCPController.APP_MODE == OCPController.APP_VALID)
            {
                ComponentCleanManager.getInstance().filter(logicalPosition, logicalPosition+1);
                clearAreas();

                liftStatus = 0;

                if(!XMLData.hasContentGoingUp())
                {
                    if(dir.dirStyle == Directory.STYLE_1)
                    {
                        //OCP.log("goingUpMode showDir");
                        showDir(true);
                        dir.setFloor(logicalPosition, true);
                    } // si el directorio es default y no hay contenido de subida
                } else {
                    hideDir();
                }

                var comps:Array = ComponentFactory.getInstance().getComponentsForState(ComponentFactory.STATE_UP);

                for(var i:int = 0; i < comps.length; i++)
                {
                    if(comps[i] != undefined)
                    {
                        var currentArea:IArea = getArea(i);
                        for(var j:int = 0; j < comps[i].length; j++)
                        {
                            comps[i][j].area = currentArea;
                            currentArea.addComponent(comps[i][j]);
                        }
                        currentArea.draw();
                    }
                }
            } else {
                showDir(true);
                dir.setFloor(logicalPosition, true);
            }
        }
    }

    /**
     * BAJANDO.
     */
    public function goingDownMode():void
    {
        //OCP.log("[AreaManager goingDownMode]");
        floorCounter.goingDown();
        if(!alarmActivated)
        {
            if(OCPController.APP_MODE == OCPController.APP_VALID)
            {
                if((logicalPosition-1) < 0) return;
                ComponentCleanManager.getInstance().filter(logicalPosition, logicalPosition-1);
                clearAreas();
                liftStatus = 1;
                if(!XMLData.hasContentGoingDown())
                {
                    if(dir.dirStyle == Directory.STYLE_1)
                    {
                        showDir(true);
                        dir.setFloor(logicalPosition, true);
                    } // si el directorio es default y no hay contenido de bajada
                } else{
                    hideDir();
                }

                var comps:Array = ComponentFactory.getInstance().getComponentsForState(ComponentFactory.STATE_DOWN);

                for(var i:int = 0; i < comps.length; i++)
                {
                    if(comps[i] != undefined)
                    {
                        var currentArea:IArea = getArea(i);
                        for(var j:int = 0; j < comps[i].length; j++)
                        {
                            comps[i][j].area = currentArea;
                            currentArea.addComponent(comps[i][j]);
                        }
                        currentArea.draw();
                    }
                }
            }   else {
                showDir(true);
                dir.setFloor(logicalPosition, true);
            }

        }
    }

    /**
     * PARADO.
     */
    public function stopMode():void
    {
        if(!XMLData.floorHasDirectory(logicalPosition))
        {
            if(!alarmActivated) hideDir();
        }

        if(alarmActivated) floorCounter.reset();
    }

    private function showFloorContent():void
    {
        floorCounter.stopMode();
        if(!alarmActivated)
        {
            if(OCPController.APP_MODE == OCPController.APP_VALID)
            {
                liftStatus = 3;
                ComponentCleanManager.getInstance().filter(logicalPosition, logicalPosition);
                clearAreas();
                var comps:Array = ComponentFactory.getInstance().getComponentsForState(ComponentFactory.STATE_STOP);
                for(var i:int = 0; i < comps.length; i++)
                {
                    if(comps[i] != undefined)
                    {
                        var currentArea:IArea = getArea(i);
                        for(var j:int = 0; j < comps[i].length; j++)
                        {
                            comps[i][j].area = currentArea;
                            currentArea.addComponent(comps[i][j]);
                        }
                        currentArea.draw();
                    }
                }
            }
        }
    }

    private function getArea(index:int):IArea
    {
        var len:uint = areasCollection.length;
        for(var i=0; i < len; i++)
        {
            if(areasCollection[i].index == index) return areasCollection[i];
        }
        return null;
    }

    /**
    * Muestra el directorio.
     * 1 - Bajando
     * 3 - Parado
     * 0 - Subiendo
    */
    private function showDir(inTransit:Boolean = false):void
    {
        //OCP.log("showDir");
        //OCP.log("logicalPosition:" +logicalPosition);
        if(dir != null && !alarmActivated)
        {
            var outOfRange:Boolean = false;
            var floorToShow:int = logicalPosition;
            var floorsData:XMLList = XMLData.xmlFloors.PISO;
            if(logicalPosition > floorsData.length()-1)
            {
                outOfRange = true;
                floorToShow = floorsData.length()-1;
            }
            if(logicalPosition < 0)
            {
                outOfRange = true;
                floorToShow = 0;
            }
            var floorData:XML = floorsData.(@id==floorToShow)[0];
            if(outOfRange)
            {
                hideDir(true);
            } else if(floorData.@showDirectory=="true" || inTransit)
            {
                dir.show();
            }
        }
        liftLastStatus = liftStatus;
    }

    /**
    * Oculta el directorio.
    */
    private function hideDir(force:Boolean = false):void
    {
        //OCP.log("hideDir");
        if(dir != null)
        {
            if(dir.dirStyle == Directory.STYLE_1) dir.hide(force);
        }
    }

    /******************************************
     * Modos de funcionamiento del ascensor   *
     * para mostrar alarmas o el icono        *
     * correspondiente.                       *
     ******************************************/

    /**
     * Ascensor en estado normal.
     */
    public function setNormalMode():void
    {
        if(alarmActivated)
        {
            dir.reset();
            alarmActivated = false;
            if(XMLData.floorHasDirectory(logicalPosition)) showFloor();
        }
        if(icons != null) icons.clear();
        clearAreas(true);
        stopMode();
    }

    /**
     * Ascensor en estado averiado.
     */
    public function setDamagedMode():void
    {
        var comps:Array = ComponentFactory.getInstance().getComponentsForAlarm(1);
        drawAlarms(comps);
    }

    /**
     * Ascensor conectado al servicio de emergencias.
     */
    public function setConnectedMode():void
    {
        var comps:Array = ComponentFactory.getInstance().getComponentsForAlarm(2);
        drawAlarms(comps);
    }

    /**
     * Ascensor conectando al servicio de emergencias.
     */
    public function setConnectingMode():void
    {
        var comps:Array = ComponentFactory.getInstance().getComponentsForAlarm(3);
        drawAlarms(comps);
    }

    /**
     * Ascensor en modo bomberos.
     */
    public function setFiremenMode():void
    {
        var comps:Array = ComponentFactory.getInstance().getComponentsForAlarm(4);
        drawAlarms(comps);
    }

    /**
     * Ascensor fuera de servicio.
     */
    public function setOutOfServiceMode():void
    {
        var comps:Array = ComponentFactory.getInstance().getComponentsForAlarm(5);
        drawAlarms(comps);
    }

    /**
     * Ascensor en modo minusválidos.
     */
    public function setHandicappedMode():void
    {
        icons.show(Icons.HANDICAPPED);
    }

    /**
     * Ascensor en modo salida.
     */
    public function setExitMode():void
    {
        var comps:Array = ComponentFactory.getInstance().getComponentsForAlarm(7);
        drawAlarms(comps);
    }

    /**
     * Ascensor en modo sobrecarga.
     */
    public function setOverloadMode():void
    {
        var comps:Array = ComponentFactory.getInstance().getComponentsForAlarm(8);
        drawAlarms(comps);
    }

    private function drawAlarms(comps:Array):void
    {
        alarmActivated = true;
        clearAreas(true);
        hideDir(true);
        floorCounter.reset();
        for(var i:int = 0; i < comps.length; i++)
        {
            if(comps[i] != undefined)
            {
                var currentArea:IArea = getArea(i);
                comps[i].area = currentArea;
                currentArea.addComponent(comps[i]);
                currentArea.draw();
            }
        }
    }
}
}
