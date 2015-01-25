/**
 * Clase principal del player (OCP).
 *
 * @author: fer : 31/03/14 - 13:01
 */
package
{
import areas.Area;
import areas.AreaManager;

import controller.OCPController;
import controller.OCPControllerEvent;

import flash.display.LoaderInfo;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;
import flash.geom.ColorTransform;
import flash.text.TextField;
import flash.utils.getDefinitionByName;

import service.LiftGateway;
import service.LiftGatewayEvent;

import utils.XMLData;
import service.IsAlive;

public class OCP extends MovieClip
{
    public static const DEBUG:Boolean = false;
    public static const OCP_VDAP:String = "OCP_VDAP";
    public static const OCP_PREVIEW:String = "OCP_PREVIEW";

    public static var OCP_TYPE:String = "";
    public static var LOG:TextField;

    public var clearLog_btn:MovieClip;
    public var log_txt:TextField;

    private var liftGateway:LiftGateway;      // comunicaciones con la maniobra del ascensor
    private var areaManager:AreaManager;      // gestor de areas
    private var ocpController:OCPController;  // controlador del player
    private var spacerClip:MovieClip;         // gráfica de lineas separadoras de areas

    public function OCP()
    {
        var paramObj:Object = LoaderInfo(this.root.loaderInfo).parameters;

        ExternalInterface.call("flashLog", "[OCP] preview -> "+paramObj.preview);

        if(paramObj.preview != undefined)
        {
            OCP_TYPE = parseInt(paramObj.preview) == 1 ? OCP_PREVIEW : OCP_VDAP;
        }  else {
            OCP_TYPE = OCP_VDAP;
        }

        ExternalInterface.call("flashLog", "[OCP] OCP_TYPE -> "+OCP_TYPE);

        clearLog_btn.visible = false;
        if(OCP.DEBUG)
        {
            OCP.LOG = log_txt;
            OCP.log("[OCP]");
            clearLog_btn.visible = true;
            clearLog_btn.addEventListener(MouseEvent.CLICK, handle_clearLogClick);
        }

        liftGateway = new LiftGateway();
        liftGateway.addEventListener(LiftGatewayEvent.READY, handle_liftReady);
		
		var isAlive:IsAlive = new IsAlive();
    }

    private function handle_clearLogClick(event:MouseEvent):void
    {
        LOG.htmlText = "";
    }

    /**
     * Las comunicaciones con la maniobra están disponibles.
     * Iniciamos la dinámica del OCP.
     *
     * @param event
     */
    private function handle_liftReady(event:LiftGatewayEvent):void
    {
        ExternalInterface.call("flashLog", "[OCP] handle_liftReady");
        areaManager = new AreaManager(this.stage, liftGateway);
        ocpController = new OCPController(liftGateway, areaManager);
        ocpController.addEventListener(OCPControllerEvent.DATA_LOADED, initUI);

        ExternalInterface.call("getXmlData");
    }

    private function initUI(event:OCPControllerEvent):void
    {
        ExternalInterface.call("flashLog", "[OCP] initUI");

        initAreas();

        var colorTransform:ColorTransform = new ColorTransform();
        colorTransform.color = XMLData.xmlTemplate.@color_fondo;

        var colorTransform2:ColorTransform = new ColorTransform();
        colorTransform2.color = XMLData.xmlTemplate.@color_bordes;

        var background:Sprite = new Sprite();
        background.graphics.beginFill(0xffffff);
        background.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
        background.graphics.endFill();
        background.transform.colorTransform = colorTransform;

        spacerClip.transform.colorTransform = colorTransform2;
        spacerClip.alpha = 1;

        addChild(background);

        this.setChildIndex(background, 0);
    }

    /**
     * Creamos las areas contenedoras de componentes.
     */
    private function initAreas():void
    {
        var area1:Area = new Area("area1");
        area1.index = 1;
        area1.x = 0;
        area1.y = 0;
        area1.width = 375;
        area1.height = 800;

        var area2:Area = new Area("area2");
        area2.index = 2;
        area2.x = 375;
        area2.y = 0;
        area2.width = 225;
        area2.height = 365;

        var area3:Area = new Area("area3");
        area3.index = 3;
        area3.x = 375;
        area3.y = 365;
        area3.width = 225;
        area3.height = 265;

        var area4:Area = new Area("area4");
        area4.index = 4;
        area4.x = 375;
        area4.y = 630;
        area4.width = 225;
        area4.height = 170;

        areaManager.addArea(area1);
        areaManager.addArea(area2);
        areaManager.addArea(area3);
        areaManager.addArea(area4);

        var area1Sprite:Sprite = area1.init();
        var area2Sprite:Sprite = area2.init();
        var area3Sprite:Sprite = area3.init();
        var area4Sprite:Sprite = area4.init();

        this.addChild(area1Sprite);
        this.addChild(area2Sprite);
        this.addChild(area3Sprite);
        this.addChild(area4Sprite);

        var spacer:Class = getDefinitionByName("area_spacer") as Class;
        spacerClip = new spacer as MovieClip;
        spacerClip.alpha = 0;
        spacerClip.x = 375;
        this.addChild(spacerClip);

        areaManager.initAreas();
    }

    static public function log(msg:String, clear:Boolean = false):void
    {
        if(OCP.DEBUG)
        {
            if(clear) LOG.htmlText = "";
            LOG.htmlText = LOG.htmlText+msg;
        }
    }
}
}
