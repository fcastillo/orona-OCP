/**
 * Elemento del menú default.
 *
 * @author: fer : 03/05/14 - 11:27
 * @extends MovieClip
 */
package components.dir
{
import com.greensock.TweenMax;
import com.greensock.easing.Linear;
import com.greensock.easing.Quad;
import com.greensock.easing.Strong;

import components.Directory;

import flash.display.MovieClip;
import flash.events.Event;
import flash.geom.ColorTransform;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.utils.setTimeout;

import utils.StringUtils;

public class DefaultItem extends MovieClip
{
    // elementos gráficos
    public var bar:MovieClip;
    public var top:MovieClip;
    public var bottom:MovieClip;
    public var floorTxt:TextField;

    private const PADDING:uint = 10;
    private var baseY:Number = 0;
    private var active:Boolean = false;
    private var inTransit:Boolean = false;
    private var maxItems:uint = 0;

    private var _dir:Directory;
    public function set dir(value:Directory):void
    {
        _dir = value;
    }
    private var _index:uint = 0;
    public function set index(value:uint):void
    {
        _index = value;
    }
    private var _gap:int = 0;
    public function set gap(value:int):void
    {
        _gap= value;
    }
    private var _numFloorsPerPage:int = 0;
    public function set numFloorsPerPage(value:int):void
    {
        _numFloorsPerPage= value;
    }
    private var _colorTransUp:ColorTransform;
    public function set colorTransUp(value:ColorTransform):void
    {
        _colorTransUp = value;
    }
    private var _colorTransBottom:ColorTransform;
    public function set colorTransBottom(value:ColorTransform):void
    {
        _colorTransBottom = value;
    }
    private var _txtFormat:TextFormat;
    public function set txtFormat(value:TextFormat):void
    {
        _txtFormat = value;
    }
    private var _txtFormat2:TextFormat;
    public function set txtFormat2(value:TextFormat):void
    {
        _txtFormat2 = value;
    }
    private var _txtFormat3:TextFormat;
    public function set txtFormat3(value:TextFormat):void
    {
        _txtFormat3 = value;
    }
    private var _txtFormatDescription:TextFormat;
    public function set txtFormatDescription(value:TextFormat):void
    {
        _txtFormatDescription = value;
    }

    // elemento siguiente
    private var _prevItem:DefaultItem = null;
    public function set prevItem(value:DefaultItem):void
    {
        _prevItem = value;
        _prevItem.addEventListener(DefaultItemEvent.MOVED, handle_prevMoved);
        _prevItem.addEventListener(DefaultItemEvent.OPENING, handle_prevItemChangeUp);
        _prevItem.addEventListener(DefaultItemEvent.CLOSING, handle_prevItemChangeDown);
        _prevItem.addEventListener(DefaultItemEvent.ACTIVE_ITEM_HIDDEN, handle_prevItemHidden);
    }

    private function handle_prevItemChangeUp(e:DefaultItemEvent):void
    {
        if(e.y + e.height + PADDING >= this.y) TweenMax.to(this, .1, {y: e.y + e.height + PADDING, onUpdate: handle_moved, ease: Linear.easeNone});
    }

    private function handle_prevItemChangeDown(e:DefaultItemEvent):void
    {
        TweenMax.to(this, .2, {y: baseY, onUpdate: handle_moved, ease: Strong.easeIn});
    }

    private function handle_prevMoved(e:DefaultItemEvent):void
    {
        var newY:Number = e.y + 70 + PADDING;
        TweenMax.to(this, .1, {y: newY >= baseY ? newY : baseY, onUpdate: handle_moved, ease: Strong.easeOut});
    }

    private function handle_moved():void
    {
        var event:DefaultItemEvent = new DefaultItemEvent(DefaultItemEvent.MOVED, this.bar.y+this.bar.bg.height+PADDING, this.y);
        dispatchEvent(event);
    }

    private function handle_prevItemHidden(e:DefaultItemEvent):void
    {
        TweenMax.to(this, .1, {y: baseY, onUpdate: handle_moved, ease: Linear.easeNone});
    }

    // datos xml
    private var _data:XML;
    public function set data(value:XML):void
    {
        _data = value;
    }

    public function DefaultItem()
    {
        TweenMax.to(this, 0, {alpha: 0});

        addEventListener(Event.REMOVED_FROM_STAGE, handle_removedFromStage);
    }

    private function handle_removedFromStage(event:Event):void
    {
        removeEventListener(Event.REMOVED_FROM_STAGE, handle_removedFromStage);
        TweenMax.killTweensOf(this);
        TweenMax.killTweensOf(top.bg);
        TweenMax.killTweensOf(bar);
        TweenMax.killTweensOf(bar.bg);
        TweenMax.killTweensOf(bar.txt);
        TweenMax.killTweensOf(bottom);
        TweenMax.killTweensOf(floorTxt);
        TweenMax.killDelayedCallsTo(onBlinkComplete);
        TweenMax.killDelayedCallsTo(handle_sizeChangeUp);
        TweenMax.killDelayedCallsTo(handle_sizeChangeDown);
        TweenMax.killDelayedCallsTo(onHidden);
    }

    public function init(maxItems:uint):void
    {
        this.maxItems = maxItems-1;

        baseY = (this.maxItems-_index)*_gap;

        x = 339;
        y = baseY;

        TextField(top.num).defaultTextFormat = _txtFormat;
        top.num.text = _data.@showPosition;
        TextField(top.num).setTextFormat(_txtFormat);

        TextField(floorTxt).autoSize = TextFormatAlign.RIGHT;
        TextField(floorTxt).text = _data.@nombre;
        TextField(floorTxt).setTextFormat(_txtFormat2); // color_directorio_sup

        TextField(top.num).setTextFormat(_txtFormat3); // color_directorio_texto
        top.bg.transform.colorTransform = _colorTransUp;
        bottom.bg.transform.colorTransform = _colorTransBottom;
        bar.bg.transform.colorTransform = _colorTransUp;

        TweenMax.to(this, .1, {alpha: 1});
    }

    public function show(inTransit:Boolean = false):void
    {
        if(!inTransit)
        {
            activateItem();
        }else{
            showInTransit();
        }

        var event:DefaultItemEvent = new DefaultItemEvent(DefaultItemEvent.ACTIVE, this.height, this.y);
        dispatchEvent(event);
    }

    public function stopBlinking():void
    {
        TweenMax.killTweensOf(top.bg);
        TweenMax.killDelayedCallsTo(onBlinkComplete);
        TweenMax.to(top.bg, 0, { alpha:1, onComplete: onBlinkComplete});
    }

    private function showInTransit():void
    {
        if(!inTransit)
        {
            TweenMax.to(top.bg, 1, { alpha:.4, yoyo: true, repeat: 10, ease: Quad.easeInOut, onComplete: onBlinkComplete});
            active = true;
            inTransit = true;
        }
    }

    private function onBlinkComplete():void
    {
        active = false;
        inTransit = false;
    }

    private function activateItem():void
    {
        TweenMax.killTweensOf(top.bg);
        TweenMax.killDelayedCallsTo(onBlinkComplete);
        TweenMax.to(top.bg, .2, { alpha: 1, ease: Quad.easeInOut});

        TextField(bar.txt).width = 325;
        TextField(bar.txt).multiline = true;
        TextField(bar.txt).wordWrap = true;
        TextField(bar.txt).autoSize = TextFormatAlign.LEFT;
        TextField(bar.txt).htmlText = StringUtils.parseDirText(_data.@descripcion);
        TextField(bar.txt).setTextFormat(_txtFormat);  // color_directorio_inf
        TweenMax.to(TextField(bar.txt), 0, {alpha: 0});

        active = true;

        var delay:Number = .3;

        // IN  - Animación de apertura
        TweenMax.to(bar, 0, { delay: delay, alpha: 0});
        TweenMax.to(bar.bg, 0, { delay: delay, scaleX: 0});

        TweenMax.to(this, 1, {delay: delay, x: 5, ease: Quad.easeInOut});
        TweenMax.to(floorTxt, 1, { delay: delay, alpha: 0, ease: Quad.easeInOut});

        delay += .9;
        TweenMax.to(floorTxt, 0, { delay: delay, x: 47, y: 38});
        delay += .3;
        TweenMax.to(floorTxt, .4, {delay: delay, alpha: 1, ease: Quad.easeInOut});
        TweenMax.to(bottom,.5, { delay: delay, y: 70, ease: Quad.easeIn, onUpdate: handle_sizeChangeUp});
        delay += .6;
        TweenMax.to(bar, 0, { delay: delay, y: 70, alpha: 1});
        TweenMax.to(bar.bg, .5, { delay: delay, scaleX: 1, alpha: 1, ease: Quad.easeOut, onUpdate: handle_sizeChangeUp});

        delay += .5;
        var txtDiff:Number = bar.txt.htmlText != "" ? 15: 0;
        bar.txt.height = bar.txt.height + txtDiff;
        TweenMax.to(bar.bg, .3, {delay: delay, height: bar.txt.textHeight+txtDiff, ease: Quad.easeOut, onUpdate: handle_sizeChangeUp});

        delay += .7;
        TweenMax.to(TextField(bar.txt), .3, {delay: delay, alpha:1, ease: Quad.easeInOut});

        setTimeout(hide, 7000);
    }

    private function hide():void
    {
        // OUT  - Animación de cierre
        TweenMax.to(floorTxt, .4, {alpha: 0});
        var finalTxtX:int = int(-15-floorTxt.textWidth);
        TweenMax.to(TextField(bar.txt), .5, {alpha:0, ease: Quad.easeInOut});
        TweenMax.to(bar.bg, .5, {delay:.3, scaleY: 1, ease: Quad.easeInOut, onUpdate: handle_sizeChangeDown});
        TweenMax.to(bar.bg, .6, { delay:.5, scaleX: 0, alpha: 0, ease: Quad.easeIn});
        TweenMax.to(bottom, .8, { delay:1.2, y: 38, ease: Quad.easeOut, onUpdate: handle_sizeChangeDown});
        TweenMax.to(floorTxt,.8, {delay:1.5, alpha: 0, ease: Quad.easeOut});
        TweenMax.to(floorTxt, 0, {delay:1, x: finalTxtX, y: 5});
        TweenMax.to(floorTxt, .7, {delay:1.6, alpha: 1, ease: Quad.easeInOut});
        TweenMax.to(this, 1.1, {delay:1.5, x: 339, ease: Quad.easeOut, onComplete: onHidden});
    }

    private function onHidden():void
    {
        active = false;
        inTransit = false;
        dispatchEvent(new DefaultItemEvent(DefaultItemEvent.ACTIVE_ITEM_HIDDEN, this.bar.y+this.bar.height, this.y));
    }

    // el elemento se abre y crece
    private function handle_sizeChangeUp():void
    {
        try{
            if(this.active)
            {
                var event:DefaultItemEvent = new DefaultItemEvent(DefaultItemEvent.OPENING, this.bar.y+this.bar.bg.height+PADDING, this.y );
                dispatchEvent(event);
            }
        }   catch(e:Error){}
    }

    // el elemento se cierra y decrece
    private function handle_sizeChangeDown():void
    {
        try{
            if(this.active)
            {
                var event:DefaultItemEvent = new DefaultItemEvent(DefaultItemEvent.CLOSING, this.bar.y+24+PADDING, this.y );
                event.index = _index;
                event.maxItems = maxItems;
                dispatchEvent(event);
            }
        }   catch(e:Error){}

    }


}
}
