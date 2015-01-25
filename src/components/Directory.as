/**
 * Componente de directorio.
 *
 * @author: fer : 24/04/14 - 10:40
 * @extends AbstractComponent
 * @implements IComponent
 */
package components
{
import com.greensock.TweenMax;
import com.greensock.easing.Quad;

import components.dir.DefaultItem;
import components.dir.DefaultItemEvent;
import components.dir.InformalItem;
import components.dir.ModernItem;
import components.dir.NeutralItem;

import controller.OCPController;

import flash.display.Sprite;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import utils.StringUtils;
import utils.XMLData;

public class Directory extends AbstractComponent implements IComponent
{
    // tipos de directorio : "default", "neutro", "informal", "moderno"
    public static const STYLE_1:String = "default";
    public static const STYLE_2:String = "neutro";
    public static const STYLE_3:String = "informal";
    public static const STYLE_4:String = "moderno";
    private var _dirStyle:String = "";
    public function get dirStyle():String
    {
        return _dirStyle;
    }

    private var itemsHolder:Sprite;  // contenedor de los marcadores de directorio
    private var modalBackground:Sprite; // background blanco transparente

    // params
    private var numFloorsPerPage:uint = 10;

    // xml floors
    private var floorsData:XMLList;
    private var maxFloorsNum:uint = 0;
    private var maxItemsPerPage:uint = 0;

    // default items params
    private var itemYDiff:Number = 0;
    private var colorTransUP:ColorTransform;
    private var colorTransBottom:ColorTransform;

    // generic data
    private var txtFormat:TextFormat;
    private var txtFormat2:TextFormat;
    private var txtFormat3:TextFormat;
    private var txtFormatFloorName:TextFormat;
    private var txtFormatDescription:TextFormat;

    private var defaultItemsList:Array = [];
    private var defaultIndexCounter:int;

    private var modernItem:ModernItem = null;
    private var informalItem:InformalItem = null;
    private var neutralItem:NeutralItem = null;

    private var dirShowing:Boolean = false;

    private var recoveryFromAlarm:Boolean = false;

    private var lastItemsHolderYPosition:Number = NaN;

    public function Directory()
    {
        super();
        _type = AbstractComponent.DIRECTORY;
    }

    public function init():void
    {
        visible = false;
        TweenMax.to(this, 0, {alpha: 0});

        var w:Number = _area.width;
        var h:Number = _area.height;

        var xPos:Number = 0;
        var yPos:Number = 0;

        this.x = xPos;
        this.y = yPos;

        modalBackground = new Sprite();
        modalBackground.graphics.beginFill(0xffffff, .9);
        modalBackground.graphics.drawRect(0, 0, w, h);
        addChild(modalBackground);

        itemsHolder = new Sprite();
        addChild(itemsHolder);

        _dirStyle = data.@estilo_directorio;

        colorTransUP = new ColorTransform();
        colorTransUP.color = uint(data.@color_directorio_sup);

        colorTransBottom = new ColorTransform();
        colorTransBottom.color = uint(data.@color_directorio_inf);

        // color dir inf
        txtFormat = new TextFormat();
        txtFormat.size = uint(data.@size);
        txtFormat.color = uint(data.@color_directorio_texto);
        //txtFormat.font = StringUtils.formatFontName(data.@fuente);

        // color dir sup
        txtFormat2 = new TextFormat();
        txtFormat2.size = uint(data.@size);
        txtFormat2.color = uint(data.@color_directorio_sup);
        //txtFormat2.font = StringUtils.formatFontName(data.@fuente);

        txtFormat3 = new TextFormat();
        txtFormat3.size = uint(data.@size);
        txtFormat3.color = uint(data.@color_directorio_texto);
        //txtFormat3.font = StringUtils.formatFontName(data.@fuente);

        txtFormatFloorName = new TextFormat();
        txtFormatFloorName.size = uint(data.@size);
        txtFormatFloorName.color = uint(data.@color_directorio_inf);
        //txtFormatFloorName.font = StringUtils.formatFontName(data.@fuente);
        txtFormatFloorName.align = TextFormatAlign.RIGHT;

        txtFormatDescription = new TextFormat();
        txtFormatDescription.size = uint(data.@size);
        txtFormatDescription.color = uint(data.@color_directorio_sup);
        //txtFormatDescription.font = StringUtils.formatFontName(data.@fuente);

        createMask();
        createDir();
    }

    private function createMask():void
    {
        var maskSprite:Sprite = new Sprite();
        maskSprite.graphics.beginFill(0x00ff00, .8);
        maskSprite.graphics.drawRect(0, 0, area.width, area.height);
        this.mask = maskSprite;
    }

    public function reset():void
    {
        recoveryFromAlarm = true;
        while(itemsHolder.numChildren) itemsHolder.removeChildAt(0);
        createDir();
    }

    public function setFloor(index:int, inTransit:Boolean = false):void
    {
        if(index >= maxFloorsNum || index < 0)
        {
            hide();
            return;
        }
        switch(_dirStyle)
        {
            case STYLE_1:
                for(var i:uint = 0; i < defaultItemsList.length; i++)
                {
                    DefaultItem(defaultItemsList[i]).stopBlinking();
                }
                if(!recoveryFromAlarm) DefaultItem(defaultItemsList[index]).show(inTransit);
                defaultIndexCounter = index;
                recoveryFromAlarm = false;
                break;
            case STYLE_2:
                showNeutralItem(index);
                break;
            case STYLE_3:
                showInformalItem(index);
                break;
            case STYLE_4:
                showModernItem(index);
                break;
        }
    }

    public function show():void
    {
        if(!dirShowing)
        {
            TweenMax.to(this, 0, {alpha: 0});
            dirShowing = true;
            this.visible = true;
            TweenMax.to(this, 1, {alpha: 1, ease: Quad.easeInOut});
        }
    }

    public function hide(force:Boolean = false):void
    {
        if(OCPController.APP_MODE == OCPController.APP_VALID)
        {
            TweenMax.to(this, force ? 0 : .5, {alpha: 0});
            dirShowing = false;
        }
    }

    private function showModernItem(index:int):void
    {
        modernItem.data = floorsData.(@id==index)[0];
        modernItem.show();
    }

    private function showInformalItem(index:int):void
    {
        informalItem.data = floorsData.(@id==index)[0];
        informalItem.show();
    }

    private function showNeutralItem(index:int):void
    {
        neutralItem.data = floorsData.(@id==index)[0];
        neutralItem.show();
    }

    private function createDir():void
    {
        floorsData = XMLData.xmlFloors.PISO;
        maxFloorsNum = floorsData.length();

        switch(_dirStyle)
        {
            case STYLE_1:
                createDefaultDir();
                break;
            case STYLE_2:
                createNeutralDir();
                break;
            case STYLE_3:
                createInformalDir();
                break;
            case STYLE_4:
                createModernDir();
                break;
        }

        TweenMax.to(this, 1, {alpha: 1});
    }

    /**
     * Directorio "default".
     */
    private function createDefaultDir():void
    {
        OCP.log("[Directory createDefaultDir]");
        TweenMax.to(this, 0, {alpha: 0, visible: false});
        while(itemsHolder.numChildren) itemsHolder.removeChildAt(0);
        defaultItemsList = [];
        maxItemsPerPage = maxFloorsNum < numFloorsPerPage ? maxFloorsNum : numFloorsPerPage;
        itemYDiff= area.height / maxItemsPerPage;
        itemYDiff = itemYDiff >= 75 ? itemYDiff : 75;
        for(var i:uint = 0; i < maxFloorsNum; i++)
        {
            var item:DefaultItem = new DefaultItem();
            item.dir = this;
            if(i>0) DefaultItem(defaultItemsList[i-1]).prevItem = item;
            item.gap = itemYDiff;
            item.numFloorsPerPage = numFloorsPerPage;
            item.index = i;
            item.colorTransUp = colorTransUP;
            item.colorTransBottom = colorTransBottom;
            item.data = floorsData.(@id==i)[0];
            item.txtFormat = txtFormat;
            item.txtFormat2 = txtFormat2;
            item.txtFormat3 = txtFormat3;
            item.txtFormatDescription = txtFormatDescription;
            item.init(maxFloorsNum);
            item.addEventListener(DefaultItemEvent.ACTIVE, handle_defaultDirActiveItem);
            item.addEventListener(DefaultItemEvent.OPENING, handle_defaultDirOpening);
            item.addEventListener(DefaultItemEvent.CLOSING, handle_defaultDirClosing);
            item.addEventListener(DefaultItemEvent.ACTIVE_ITEM_HIDDEN, handle_defaultDirFinish);
            defaultItemsList.push(item);
            itemsHolder.addChild(item);
            adjustDirPositon();
        }
    }

    /**
     * Directorio "moderno".
     */
    private function createModernDir():void
    {
        if(modernItem == null)
        {
            var floorMenu:uint = OCPController.logicalFloor >= maxFloorsNum ? maxFloorsNum-1 : OCPController.logicalFloor;

            modernItem = new ModernItem();
            modernItem.x = (_area.width - modernItem.width) / 2;
            modernItem.y = _area.height - modernItem.height - 20;

            modernItem.dir = this;
            modernItem.data = floorsData.(@id==floorMenu)[0];
            modernItem.colorTransUp = colorTransUP;
            modernItem.colorTransBottom = colorTransBottom;
            modernItem.txtFormat = txtFormat;
            modernItem.txtFormatDescription = txtFormatDescription;
            modernItem.init();
            itemsHolder.addChild(modernItem);
        }
    }

    /**
     * Directorio "informal".
     */
    private function createInformalDir():void
    {
        if(informalItem == null)
        {
            informalItem = new InformalItem();
            informalItem.dir = this;
            informalItem.x = (_area.width - informalItem.bottom.width) / 2;
            informalItem.y = _area.height - informalItem.bottom.height - 20;
            informalItem.colorTransUp = colorTransUP;
            informalItem.colorTransBottom = colorTransBottom;
            informalItem.txtFormat = txtFormat;
            informalItem.txtFormatDescription = txtFormatDescription;
            informalItem.init();
            itemsHolder.addChild(informalItem);
        }
    }

    /**
     * Directorio "neutro".
     */
    private function createNeutralDir():void
    {
        if(neutralItem == null)
        {
            neutralItem = new NeutralItem();
            neutralItem.x = 0;
            neutralItem.y = 0;
            neutralItem.dir = this;
            neutralItem.txtFormat = txtFormat;
            neutralItem.txtFormatDescription = txtFormatDescription;
            neutralItem.init();
            itemsHolder.addChild(neutralItem);
        }
    }

    override public function destroy():void
    {
        while(itemsHolder.numChildren) itemsHolder.removeChildAt(0);
    }

    private function handle_defaultDirActiveItem(event:DefaultItemEvent):void
    {
        var localPoint:Point = itemsHolder.localToGlobal(new Point(0, event.y));
        if(localPoint.y < 0)
        {
           TweenMax.to(itemsHolder, .5, {y: -event.y + 50 - itemYDiff / 2, ease: Quad.easeOut});
        }else if(localPoint.y + 75 > 800)
        {
           TweenMax.to(itemsHolder, .5, {y: 800-(event.y+75), ease: Quad.easeOut});
        }
    }

    private function handle_defaultDirOpening(event:DefaultItemEvent):void
    {
        var localPoint:Point = itemsHolder.localToGlobal(new Point(0, event.y));
        if(localPoint.y + event.height > 800)
        {
            if(isNaN(lastItemsHolderYPosition)) lastItemsHolderYPosition = itemsHolder.y;
           TweenMax.to(itemsHolder, .5, {y: 800-(event.y+event.height), ease: Quad.easeOut});
        }
    }

    private function handle_defaultDirClosing(event:DefaultItemEvent):void
    {
        if(!isNaN(lastItemsHolderYPosition)) TweenMax.to(itemsHolder, .5, {y: lastItemsHolderYPosition, ease: Quad.easeOut});
    }

    private function handle_defaultDirFinish(e:DefaultItemEvent):void
    {
        lastItemsHolderYPosition = NaN;
        if(XMLData.areaHasContentForFloor(1, OCPController.logicalFloor)) hide();
    }

    private function adjustDirPositon():void
    {
        itemsHolder.y = itemsHolder.height > _area.height ? -(itemsHolder.height - _area.height) : (_area.height - itemsHolder.height)/2; // centramos el directorio
    }
}
}
