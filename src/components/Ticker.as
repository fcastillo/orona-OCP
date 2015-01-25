/**
 * Componente Ticker.
 *
 * @author: fer : 22/04/14 - 13:20
 * @extends AbstractComponent
 * @implements IComponent
 *
 * <ELEMENTO alto="0.05" ancho="0.5493333333333333" tipo="ticker" fuente="Arial" size="30" color="0" alineacion="center" negrita="false" cursiva="false" subrayado="false" velocidad="5"
    profundidad="6" transparencia="1" cY="0.585" cX="0.072" path="ticker.swf"/>
 */
package components
{
import com.greensock.TweenMax;
import com.greensock.easing.Linear;

import flash.display.Sprite;

import flash.events.IOErrorEvent;
import flash.events.TimerEvent;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.Timer;

import utils.StringUtils;
import utils.XMLData;
import utils.XMLDataEvent;

public class Ticker extends AbstractComponent implements IComponent
{
    private var update_timer:Timer = null;
    private var UPDATE_CYCLE:Number = 600000; // 10 min de refresco en la lectura de datos
    private var txt:TextField = null;
    private var w:Number;
    private var h:Number;
    private var speed:uint = 0;
    private var textWidth:Number = 0;
    private var _xmlData:XMLData = null; // gestor de carga de xml

    private var PADDING_RIGHT:uint = 10; // para que no se corte el texto cuando está en cursiva

    public function Ticker()
    {
        super();

        _type = AbstractComponent.TICKER;

        update_timer = new Timer(UPDATE_CYCLE);
        update_timer.addEventListener(TimerEvent.TIMER, reloadControlFromTimer, false, 0, true);
    }

    public function init():void
    {
        if(!update_timer.running) update_timer.start();

        reloadControlFromTimer(null);

        this.alpha = parseFloat(data.@transparencia);

        w = _area.width * data.@ancho + PADDING_RIGHT;
        h = _area.height * data.@alto;

        var xPos:Number = _area.width * data.@cX;
        var yPos:Number = _area.height * data.@cY;

        this.x = xPos;
        this.y = yPos;

        _xmlData.loadTickerData(this);

    }
    /**
     * Referencia al gestor de carga de datos xml.
     * @param value
     */
    public function set xmlData(value:XMLData):void
    {
        if(_xmlData == null)
        {
            try{
                _xmlData = value;
                _xmlData.addEventListener(XMLDataEvent.TICKER_LOADED, handle_tickerDataLoad, false, 0, true);
                _xmlData.addEventListener(XMLDataEvent.TICKER_LOAD_ERROR, handle_tickerDataLoadError, false, 0, true);
            }catch(e:Error){}
        }
    }

    private function handle_tickerDataLoad(event:XMLDataEvent):void
    {
        try{
            var xml:XML = event.xmlTicker;
            var expireString:String = xml.ticker.@fecha_caducidad.split("-").join("/");
            var expiringDate:Date = new Date(); // 2013-11-08 00:00:00
            expiringDate.setTime(Date.parse(expireString));
            var now:Date = new Date();
            if(expiringDate > now && xml.ticker.@enable == "true") // si no ha caducado el ticker
            {
                try{
                    initUI(xml);
                    if(!TweenMax.isTweening(txt)) onTickerComplete();
                } catch(e:Error){ destroy(); }
            } else {
               destroy();
            }
        }
        catch(e:Error)
        {
            destroy();
        }
    }

    private function initUI(xml:XML):void
    {
        if(txt == null)
        {
            var textFormat:TextFormat = new TextFormat();
            textFormat.size = uint(data.@size);
            textFormat.color = parseInt(data.@color);
            textFormat.italic = data.@cursiva === "true";
            textFormat.font = StringUtils.formatFontName(data.@fuente);
            textFormat.bold = data.@negrita === "true";
            textFormat.underline = data.@subrayado === "true";
            speed = uint(data.@velocidad);

            txt = new TextField();
            txt.x = w;
            txt.width = w;
            txt.height = h;
            txt.autoSize = "left";
            txt.embedFonts = true;
            txt.cacheAsBitmap = true;
            txt.antiAliasType = AntiAliasType.ADVANCED;
            txt.defaultTextFormat = textFormat;
            addChild(txt);

            var masking:Sprite = new Sprite();
            masking.graphics.beginFill(0xff0000,.5);
            masking.graphics.drawRect(0,0,w,h);
            addChild(masking);

            txt.mask = masking;
        }

        txt.text = xml.ticker.@texto;
        textWidth = txt.textWidth;
    }

    private function onTickerComplete():void
    {
        try{
            if(txt != null)
            {
                txt.x = w;
                TweenMax.to(txt, speed, {x: -textWidth, onComplete: onTickerComplete, ease:Linear.easeNone});
            }
        } catch(e:Error){}
    }

    private function handle_tickerDataLoadError(event:IOErrorEvent):void
    {
        destroy();
    }

    private function reloadControlFromTimer(e:TimerEvent)
    {
        try{
            _xmlData.loadTickerData(this);
        } catch(e:Error){}
    }

    override public function destroy():void
    {
        try{
            txt.mask = null;
            txt = null;

            _xmlData.removeEventListener(XMLDataEvent.WEATHER_LOADED, handle_tickerDataLoad);
            _xmlData.removeEventListener(XMLDataEvent.WEATHER_LOAD_ERROR, handle_tickerDataLoadError);
            _xmlData = null;

            update_timer.stop();
            update_timer.removeEventListener(TimerEvent.TIMER, reloadControlFromTimer);
            update_timer = null;

        } catch(e:Error){}

        TweenMax.killTweensOf(txt);
        TweenMax.killDelayedCallsTo(onTickerComplete);

        while(this.numChildren) this.removeChildAt(0);
    }
}
}
