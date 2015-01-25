/**
 * Factoría de componentes.
 *
 * @author: fer : 04/04/14 - 10:58
 */
package components
{
import components.alarms.*;

import controller.OCPController;

import utils.StringUtils;
import utils.XMLData;
import utils.XMLDataEvent;

public class ComponentFactory
{
    public static const STATE_UP:String   = "STATE_UP";
    public static const STATE_DOWN:String = "STATE_DOWN";
    public static const STATE_STOP:String = "STATE_STOP";

    private static var instance:ComponentFactory = null;

    public static function getInstance():ComponentFactory
    {
        if(instance == null) instance = new ComponentFactory();
        return instance;
    }

    private var _xmlData:XMLData;
    private var xmlUp:XMLList = null;     // datos de subida
    private var xmlDown:XMLList = null;   // datos de bajada
    private var xmlStatic:XMLList = null; // datos de piso
    private var xmlAlarms:XML = null;     // datos de alarmas

    public function ComponentFactory(){}

    public function addXMLDataReference(xmlData:XMLData):void
    {
        _xmlData = xmlData;
        _xmlData.addEventListener(XMLDataEvent.CHANGED, handle_dataChanged);
        _xmlData.addEventListener(XMLDataEvent.ALARMS_LOADED, handle_xmlAlarmsDataLoaded);
        _xmlData.addEventListener(XMLDataEvent.ALARMS_LOAD_ERROR, handle_xmlAlarmsDataLoadError);
    }

    public function getComponentsForState(state:String):Array
    {
        var componentsList:Array = [];
        switch(state)
        {
            case ComponentFactory.STATE_UP:
                componentsList = getComponentsFromXML(xmlUp);
                break;
            case ComponentFactory.STATE_DOWN:
                componentsList = getComponentsFromXML(xmlDown);
                break;
            case ComponentFactory.STATE_STOP:
                componentsList = getComponentsForCurrentFloor();
                break;
        }
        return componentsList;
    }

    public function getComponentsForAlarm(alarmId:int):Array
    {
        var componentsList:Array = [];
        var alarmData:XMLList = xmlAlarms.alarm.(@id==alarmId);
        var alarmAreas:XMLList = alarmData.area;

        for each(var alarmArea in alarmAreas)
        {
            componentsList[alarmArea.@id] = createComponent(alarmArea);
        }
        return componentsList;
    }

    public function getDirectory():Directory
    {
        var dir:Directory = new Directory();
        dir.cleanable = false;
        dir.data = XMLData.xmlTemplate;
        return dir;
    }

    public function getIcons():Icons
    {
        var icons:Icons = new Icons();
        return icons;
    }

    private function getComponentsFromXML(xml:XMLList):Array
    {
        var componentsList:Array = [];
        var floorAreas:XMLList = xml.AREA;
        for each(var floorArea in floorAreas)
        {
            var elements:XMLList = floorArea.ELEMENTO;
            if(floorArea.@tipo != 2)
            {
                if(componentsList[floorArea.@tipo] == undefined) componentsList[floorArea.@tipo] = [];
                if(StringUtils.trim(floorArea.@pathfondo) != "") componentsList[floorArea.@tipo].push(createBackground(floorArea.@pathfondo));
                for each(var element in elements)
                {
                    componentsList[floorArea.@tipo].push(createComponent(element));
                }
            }
        }
        return componentsList;
    }

    private function createBackground(img:String):IComponent
    {
        var back:Background = new Background();
        back.data = new XML("<img profundidad='0' path='"+img+"'/>");
        return back;
    }

    private function getComponentsForCurrentFloor():Array
    {
        var floorToGet:int = OCPController.logicalFloor;
        var componentsList:Array = [];
        if(floorToGet >= xmlStatic.PISO.length())
        {
            floorToGet = xmlStatic.PISO.length()-1;
        }
        if(floorToGet < 0 )
        {
            floorToGet = 0;
        }
        var floorAreas:XMLList = xmlStatic.PISO.(@id==floorToGet).AREA;
        for each(var floorArea in floorAreas)
        {
            var elements:XMLList = floorArea.ELEMENTO;
            if(floorArea.@tipo != 2)
            {
                if(componentsList[floorArea.@tipo] == undefined) componentsList[floorArea.@tipo] = [];
                if(StringUtils.trim(floorArea.@pathfondo) != "") componentsList[floorArea.@tipo].push(createBackground(floorArea.@pathfondo));
                for each(var element in elements)
                {
                    componentsList[floorArea.@tipo].push(createComponent(element));
                }
            }
        }
        return componentsList;
    }

    private function createComponent(xmlData:XML):IComponent
    {
        var comp:IComponent = null;
        var componentType:String = xmlData.@tipo;
        switch(componentType)
        {
            case "pasafotos":
                comp = new Slideshow();
                comp.data = xmlData;
                break;
            case "video" :
                comp = new Video();
                comp.data = xmlData;
                break;
            case "tiempo":
                var weather:Weather = new Weather();
                weather.xmlData = _xmlData;
                weather.data = xmlData;
                comp = weather;
                break;
            case "reloj":
                comp = new Clock();
                comp.data = xmlData;
                break;
            case "imagen":
                comp = new Image();
                comp.data = xmlData;
                break;
            case "texto":
                comp = new Text();
                comp.data = xmlData;
                break;
            case "ticker":
                var ticker:Ticker = new Ticker();
                ticker.xmlData = _xmlData;
                ticker.data = xmlData;
                comp = ticker;
                break;
            case "menu":
                comp = new Menu();
                comp.data = xmlData;
                break;
            case "rss":
                comp = new RSS();
                comp.data = xmlData;
                break;
            case "publicidad":
                var ads:Advertisement = new Advertisement();
                ads.xmlData = _xmlData;
                ads.data = xmlData;
                comp = ads;
                break;
            case "alarm_01_1":
                comp = new alarm_01_1();
                break;
            case "alarm_01_3":
                comp = new alarm_01_3();
                break;
            case "alarm_01_4":
                comp = new alarm_01_4();
                break;
            case "alarm_02_1":
                comp = new alarm_02_1();
                break;
            case "alarm_02_3":
                comp = new alarm_02_3();
                break;
            case "alarm_03_1":
                comp = new alarm_03_1();
                break;
            case "alarm_03_3":
                comp = new alarm_03_3();
                break;
            case "alarm_04_1":
                comp = new alarm_04_1();
                break;
            case "alarm_04_3":
                comp = new alarm_04_3();
                break;
            case "alarm_05_1":
                comp = new alarm_05_1();
                break;
            case "alarm_05_3":
                comp = new alarm_05_3();
                break;
            case "alarm_06_1":
                comp = new alarm_06_1();
                break;
            case "alarm_06_3":
                comp = new alarm_06_3();
                break;
        }
        return comp;
    }

    private function handle_dataChanged(event:XMLDataEvent):void
    {
        xmlUp = event.xmlUp;
        xmlDown = event.xmlDown;
        xmlStatic = event.xmlStatic;
    }

    private function handle_xmlAlarmsDataLoadError(event:XMLDataEvent):void
    {
        _xmlData.removeEventListener(XMLDataEvent.ALARMS_LOADED, handle_xmlAlarmsDataLoaded);
        _xmlData.removeEventListener(XMLDataEvent.ALARMS_LOAD_ERROR, handle_xmlAlarmsDataLoadError);
    }

    private function handle_xmlAlarmsDataLoaded(event:XMLDataEvent):void
    {
        xmlAlarms = event.xmlAlarms;

        _xmlData.removeEventListener(XMLDataEvent.ALARMS_LOADED, handle_xmlAlarmsDataLoaded);
        _xmlData.removeEventListener(XMLDataEvent.ALARMS_LOAD_ERROR, handle_xmlAlarmsDataLoadError);
    }
}
}
