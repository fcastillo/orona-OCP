/**
 * @author: fer : 07/04/14 - 12:14
 */
package controller
{
import areas.AreaManager;

import components.ComponentFactory;

import flash.events.EventDispatcher;
import flash.external.ExternalInterface;

import service.IntegrityCheck;
import service.IntegrityCheckEvent;

import service.LiftGateway;
import service.LiftGatewayEvent;

import utils.XMLData;
import utils.XMLDataEvent;

public class OCPController extends EventDispatcher
{
    public static const APP_VALID:String = "controller.OCPController.APP_VALID";
    public static const APP_INVALID:String = "controller.OCPController.APP_INVALID";
    public static var APP_MODE:String = APP_VALID;

    public static var logicalFloor:int = 0; // piso lógico de acceso global

    private var xmlData:XMLData;               // gestiona las cargas de xml de datos
    private var integrityCheck:IntegrityCheck; // verifica la integridad de ls recursos
    private var areaManager:AreaManager;       // gestor de areas
    private var liftGateway:LiftGateway;       // canal de mensajería con la maniobra

    private var listeningToLiftGateway:Boolean = false;

    public function OCPController(liftGateway:LiftGateway, areaManager:AreaManager)
    {
        OCP.log("[OCPController]");
        this.liftGateway = liftGateway;
        this.areaManager = areaManager;

        xmlData = new XMLData();
        xmlData.addEventListener(XMLDataEvent.CONFIG_LOADED, handle_xmlConfigLoaded);
        xmlData.addEventListener(XMLDataEvent.CONFIG_LOAD_ERROR, handle_xmlConfigError);
        xmlData.addEventListener(XMLDataEvent.CHANGED, handle_xmlDataChanged);
        xmlData.addEventListener(XMLDataEvent.LOAD_ERROR, handle_xmlDataLoadError);
        ComponentFactory.getInstance().addXMLDataReference(xmlData);

        if(OCP.OCP_TYPE == OCP.OCP_VDAP)
        {
            xmlData.loadConfig();
            integrityCheck = new IntegrityCheck();
            integrityCheck.xmlData = xmlData;
            integrityCheck.addEventListener(IntegrityCheckEvent.INVALID_SOURCES, handle_invalidSources);
        } else {
            this.liftGateway.addEventListener(LiftGatewayEvent.PREVIEW_DATA_READY, handle_previewDataReady);
        }
    }

    /**
     * Callback en caso de previsualización de contenidos.
     *
     * @param event
     */
    private function handle_previewDataReady(event:LiftGatewayEvent):void
    {
        ExternalInterface.call("flashLog", "[OCPController] handle_previewDataReady");

        xmlData.setPreviewData(event.xmlConfig, event.xmlVersion);
        xmlData.loadAlarmsData();
    }

    /**
     * Los recursos han sido modificados sin permiso.
     * Se pone la aplicación en modo sólo directorio.
     *
     * @param event
     */
    private function handle_invalidSources(event:IntegrityCheckEvent):void
    {
        // TODO
        //OCPController.APP_MODE = APP_INVALID;  // Descomentar esta línea en versión de producción
        OCPController.APP_MODE = OCPController.APP_VALID; // eliminar esta línea en producción

        //areaManager.clearAreas(true);
    }

    private function handle_xmlConfigLoaded(event:XMLDataEvent):void
    {
        xmlData.removeEventListener(XMLDataEvent.CONFIG_LOADED, handle_xmlConfigLoaded);
        xmlData.removeEventListener(XMLDataEvent.CONFIG_LOAD_ERROR, handle_xmlConfigError);

        loadXMLData(XMLData.contentsURL+XMLData.contentsURLSeparator+XMLData.xmlConfig.VERSION.@FILE);

        xmlData.loadAlarmsData();

        integrityCheck.init();
    }

    private function handle_xmlConfigError(event:XMLDataEvent):void
    {
        // Error al cargar el xml de configuración del player
        xmlData.removeEventListener(XMLDataEvent.CONFIG_LOADED, handle_xmlConfigLoaded);
        xmlData.removeEventListener(XMLDataEvent.CONFIG_LOAD_ERROR, handle_xmlConfigError);
    }

    private function handle_xmlDataLoadError(event:XMLDataEvent):void
    {
    }

    private function handle_xmlDataChanged(event:XMLDataEvent):void
    {
        ExternalInterface.call("flashLog", "[OCPController] handle_xmlDataChanged");

        if(!listeningToLiftGateway) setLiftgatewayListeners();
        dispatchEvent(new OCPControllerEvent(OCPControllerEvent.DATA_LOADED));
    }

    private function setLiftgatewayListeners():void
    {
        listeningToLiftGateway = true;
        liftGateway.addEventListener(LiftGatewayEvent.DIRECTION_CHANGE, handle_directionChange);
        liftGateway.addEventListener(LiftGatewayEvent.SHOW_FLOOR_STRING, handle_showFloorString);
        liftGateway.addEventListener(LiftGatewayEvent.SET_LIFT_STATE, handle_setLiftState);
        liftGateway.addEventListener(LiftGatewayEvent.SET_LOGICAL_POSITION, handle_setLogicalPosition);
        liftGateway.addEventListener(LiftGatewayEvent.SET_TEXT, handle_setText);
        liftGateway.addEventListener(LiftGatewayEvent.SHOW_FLOOR, handle_showFloor);
    }

    private function loadXMLData(xmlPath:String):void
    {
        xmlData.load(xmlPath);
    }

    private function handle_showFloor(event:LiftGatewayEvent):void
    {
        areaManager.showFloor();
    }

    private function handle_setText(event:LiftGatewayEvent):void
    {
        areaManager.setText(event.text);
    }

    private function handle_setLogicalPosition(event:LiftGatewayEvent):void
    {
        OCPController.logicalFloor = event.logicalPosition;
        areaManager.setLogicalPosition(event.logicalPosition);
    }

    private function handle_setLiftState(event:LiftGatewayEvent):void
    {
        switch(event.liftState)
        {
            case 0:   // NINGUNO
                areaManager.setNormalMode();
                break;
            case 1:   // AVERIADO
                areaManager.setDamagedMode();
                break;
            case 2:   // CONECTADO AL SERVICIO DE EMERGENCIAS
                areaManager.setConnectedMode();
                break;
            case 3:   // CONECTANDO AL SERVICIO DE EMERGENCIAS
                areaManager.setConnectingMode();
                break;
            case 4:   // BOMBEROS
                areaManager.setFiremenMode();
                break;
            case 5:   // FUERA DE SERVICIO
                areaManager.setOutOfServiceMode();
                break;
            case 6:   // MINUSVÁLIDOS
                areaManager.setHandicappedMode();
                break;
            case 7:   // MODO SALIDA
                areaManager.setExitMode();
                break;
            case 8:   // SOBRECARGA
                areaManager.setOverloadMode();
                break;
        }
    }

    private function handle_showFloorString(event:LiftGatewayEvent):void
    {
        var floorString = event.floorName.substr(0,2) // máximo 2 caracteres
        areaManager.showFloorString(floorString);
    }

    private function handle_directionChange(event:LiftGatewayEvent):void
    {
        switch(event.direction)
        {
            case 0: // SUBIENDO
                areaManager.goingUpMode();
                break;
            case 1: // BAJANDO
                areaManager.goingDownMode();
                break;
            case 3: // PARADO
                areaManager.stopMode();
                break;
        }
    }
}
}
