/**
 * Pasarela de comunicaciones con la maniobra del ascensor.
 * Recibe los mensajes de estado enviados por el ascensor al player.
 *
 * @author: fer : 31/03/14 - 14:47
 * @extends EventDispatcher
 */
package service
{
import controller.OCPController;

import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.external.ExternalInterface;
import flash.system.Security;
import flash.utils.Timer;

public class LiftGateway extends EventDispatcher
{
    private var _ready:Boolean = false;

    private var initDirection:int = -1;
    private var initLiftState:int = -1;
    private var initLogicalPosition:int = -1;
    private var initFloorString:String = "";

    public function set ready(value:Boolean):void
    {
        _ready = value;
    }

    public function LiftGateway()
    {
        Security.allowDomain("*");
        var timer:Timer = new Timer(100);
        timer.addEventListener(TimerEvent.TIMER, timerHandler);
        timer.start();
    }

    /**
     * Cuando el player está listo para mostrar elementos.
     */
    public function init():void
    {
        ready = true;

        if(initDirection !=  -1) setDirection(initDirection);
        if(initLiftState !=  -1) setLiftState(initLiftState);
        if(initLogicalPosition !=  -1) setLogicalPosition(initLogicalPosition);
        if(initFloorString !=  "") setFloorString(initFloorString);

        showFloor();
    }

    private function timerHandler(event:TimerEvent):void
    {
        if (ExternalInterface.available)
        {
            var timer:Timer = event.target as Timer;
            timer.stop();
            timer.removeEventListener(TimerEvent.TIMER, timerHandler);
            this.registerMethods();
            dispatchEvent(new LiftGatewayEvent(LiftGatewayEvent.READY));
        }
    }

    /**
     * Métodos visibles desde la capa javascript.
     */
    private function registerMethods():void
    {
        ExternalInterface.addCallback("setXMLData", this.setXMLData);
        ExternalInterface.addCallback("SetDirection", this.setDirection);
        ExternalInterface.addCallback("SetFloorString", this.setFloorString);
        ExternalInterface.addCallback("SetLiftState", this.setLiftState);
        ExternalInterface.addCallback("SetLoad", this.setLoad);
        ExternalInterface.addCallback("SetLogicalPosition", this.setLogicalPosition);
        ExternalInterface.addCallback("SetText", this.setText);
        ExternalInterface.addCallback("ShowFloor", this.showFloor);
    }

    /**
    * En caso de que el player esté en modo previsualizador se utiliza este
    * método para inyectar el xml de contenidos.
    *
    * @param xml
    */
    public function setXMLData(xmlConfig:String, xmlVersion:String):void
    {
        ExternalInterface.call("flashLog", "[LiftGateway] setXMLData");

        var event:LiftGatewayEvent = new LiftGatewayEvent(LiftGatewayEvent.PREVIEW_DATA_READY);
        event.xmlConfig = new XML(xmlConfig);
        event.xmlVersion = new XML(xmlVersion);
        dispatchEvent(event);
    }

    /**
     * El VDAP envía a la UI flash la dirección del ascensor.
     *
     * @param direction   1 - Bajando
     *                    3 - Parado
     *                    0 - Subiendo
     */
    public function setDirection(direction:int)
    {
        //OCP.log("[LiftGateway] setDirection: "+direction);
        if(_ready)
        {
            var event:LiftGatewayEvent = new LiftGatewayEvent(LiftGatewayEvent.DIRECTION_CHANGE);
            event.direction = direction;
            dispatchEvent(event);
        } else {
            initDirection = direction;
        }
    }

    /**
     * El VDAP envía a la UI flash el texto a mostrar asociado al piso.
     *
     * @param floorString
     */
    public function setFloorString(floorString:String):void
    {
        //OCP.log("[LiftGateway] setFloorString: "+floorString);
        if(_ready)
        {
            var event:LiftGatewayEvent = new LiftGatewayEvent(LiftGatewayEvent.SHOW_FLOOR_STRING);
            event.floorName = floorString;
            dispatchEvent(event);
        }else{
            initFloorString = floorString;
        }
    }

    /**
     * El VDAP envía a la UI flash el estado del ascensor para que el UI
     * represente el icono de estado asociado en caso de ser necesario o
     * la alarma correspondiente.
     *
     * @param state  0 - Normal
     *               1 - Averiado
     *               2 - Conectado
     *               3 - Conectando
     *               4 - Bomberos
     *               5 - Fuera de servicio
     *               6 - Minusválidos
     *               7 - Salida
     *               8 - Sobrecarga
     */
    public function setLiftState(liftState:int):void
    {
        //OCP.log("[LiftGateway] setLiftState: "+liftState);
        if(_ready)
        {
            var event:LiftGatewayEvent = new LiftGatewayEvent(LiftGatewayEvent.SET_LIFT_STATE);
            event.liftState = liftState;
            dispatchEvent(event);
        }else{
            initLiftState = liftState;
        }
    }

    /**
     * El VDAP envía a la UI flash la carda del ascensor. -- NO DISPONIBLE --
     *
     * @param load  1, 2, 3, 4, 5, 6 valores de carga
     *              7 (null) No hay pesacargas
     */
    public function setLoad(load:int):void
    {
        // NO DISPONIBLE
    }

    /**
     * El VDAP envía a la UI flash la posición lógica del ascensor, con base 0.
     *
     * @param position Posición lógica
     */
    public function setLogicalPosition(logicalPosition:int):void
    {
        //OCP.log("[LiftGateway] setLogicalPosition: "+logicalPosition);
        OCPController.logicalFloor = logicalPosition;
        if(_ready)
        {
            var event:LiftGatewayEvent = new LiftGatewayEvent(LiftGatewayEvent.SET_LOGICAL_POSITION);
            event.logicalPosition = logicalPosition;
            dispatchEvent(event);
        }else{
            initLogicalPosition = logicalPosition;
        }
    }

    /**
     * El VDAP envía a la UI flash el texto a visualizar en modo mensajería instantánea.
     *
     * @param text
     */
    public function setText(text:String):void
    {
        if(_ready)
        {
            var event:LiftGatewayEvent = new LiftGatewayEvent(LiftGatewayEvent.SET_TEXT);
            event.text = text;
            dispatchEvent(event);
        }
    }

    /**
     * El VDAP envía a la UI flash que muestre el piso.
     */
    public function showFloor():void
    {
        if(_ready)
        {
            var event:LiftGatewayEvent = new LiftGatewayEvent(LiftGatewayEvent.SHOW_FLOOR);
            dispatchEvent(event);
        }
    }
}
}
