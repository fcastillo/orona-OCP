/**
 * Componente RSS.
 *
 * @author: fer : 23/04/14 - 17:32
 * @extends AbstractComponent
 * @implements IComponent
 *
 * <ELEMENTO alto="0.0464375" ancho="0.43733333333333335" tipo="rss" estilo="estilo1" tiempo_transicion="15" velocidad="100" titulo_activo="false" velocidad_titulo="12" imagen_visible="true"
 * color_superior="39270" alpha_superior="1" color_inferior="39321" alpha_inferior="1" color_titulos="16777215" color_textos="16777215" fuente_titulos="Times New Roman" fuente_textos="Arial"
 * size_titulos="18" size_textos="12" align_titulos="left" align_textos="left" negrita_titulo="false" negrita_texto="false" cursiva_titulo="false" cursiva_texto="false" subrayado_titulo="false"
 * subrayado_texto="false" rss_url="http://feeds.bbci.co.uk/news/world/rss.xml" profundidad="5" transparencia="1" cY="0.2975" cX="0.5333333333333333" />
 */
package components
{

import com.greensock.TweenLite;
import com.greensock.TweenMax;
import com.greensock.easing.Back;

import flash.display.Loader;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.TimerEvent;
import flash.geom.ColorTransform;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.utils.Timer;
import flash.utils.getDefinitionByName;
import flash.utils.setTimeout;

import utils.DateUtils;

import utils.StringUtils;

public class RSS extends AbstractComponent implements IComponent
{
    private static const TYPE_1:String = "rss_type1";
    private static const TYPE_2:String = "rss_type2";
    private static const TYPE_3:String = "rss_type3";

    private var rss_type:String = "";
    private var clip:MovieClip;

    private var w:Number = 0;
    private var h:Number = 0;

    private const UPDATE_readDataTimer:uint = 3600000; // una hora de refresco en la lectura de datos
    private var readDataTimer:Timer = null;
    private var refreshTextTimer:Timer = null;
    private var rssLoader:URLLoader = null;
    private var xmlRssDataLoaded:Boolean = false;
    private var XML_RSS:String = "RSS.xml";
    private var sourceXML:XMLList = null; // XML de la fuente seleccionada para este componente
    private var counter:int = 0;
    private var items:XMLList = null;
    private var media:Namespace;
    private var imageLoader:Loader = null;

    private var topTextInitX:Number = 0;
    private var bottomTextInitY:Number = 0;

    private var textTweenTime:uint = 6;
    private var topTextSpeed:uint = 6;
    private var bottomTextSpeed:uint = 6;

    private var rssType:String = "";
    private var lastItemsNum:uint = 0;

    public function RSS()
    {
        super();
        _type = AbstractComponent.RSS;
    }

    public function init():void
    {
        rssType = StringUtils.trim(data.@estilo).toLowerCase();

        imageLoader = new Loader();
        imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, handle_imageComplete, false, 0, true);
        imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handle_imageError, false, 0, true);

        media = new Namespace("http://search.yahoo.com/mrss/");
        default xml namespace = media;

        this.alpha = parseFloat(data.@transparencia);

        w = _area.width * data.@ancho;
        h = _area.height * data.@alto;

        var xPos:Number = _area.width * data.@cX;
        var yPos:Number = _area.height * data.@cY;

        this.x = xPos;
        this.y = yPos;

        textTweenTime = parseInt(data.@tiempo_transicion);
        topTextSpeed =  .5+textTweenTime - textTweenTime*(uint(data.@velocidad_titulo)/100);
        bottomTextSpeed =  .5+textTweenTime - textTweenTime*(uint(data.@velocidad)/100);

        readDataTimer = new Timer(UPDATE_readDataTimer);
        readDataTimer.addEventListener(TimerEvent.TIMER, handle_readDataTimer, false, 0, true);

        refreshTextTimer = new Timer(parseInt(data.@tiempo_transicion)*1000);
        refreshTextTimer.addEventListener(TimerEvent.TIMER, handle_refreshTextTimer, false, 0, true);

        rssLoader = new URLLoader();
        rssLoader.addEventListener(Event.COMPLETE, handle_rssDataLoad, false, 0, true);
        rssLoader.addEventListener(IOErrorEvent.IO_ERROR, handle_rssDataLoadError, false, 0, true);

        handle_readDataTimer(null);
        readDataTimer.start();
    }

    private function handle_refreshTextTimer(event:TimerEvent):void
    {
        try{
            showNextItem();
        }catch(e:Error){}
    }

    private function handle_rssDataLoad(event:Event):void
    {
        OCP.log("[RSS handle_rssDataLoad]");
        var xml:XML = new XML(rssLoader.data);
        if(DateUtils.lessThan24HoursAgo(xml.@timestamp) || OCP.OCP_TYPE == OCP.OCP_PREVIEW)
        {
            sourceXML =  OCP.OCP_TYPE == OCP.OCP_PREVIEW ? xml.source.(@id=='preview') : xml.source.(@id==data.@rss_url);
            //sourceXML = xml.source.(@id=="http://feeds.bbci.co.uk/news/world/RSS.xml");
            if(sourceXML != null)
            {
                items = sourceXML.rss.channel.item;
                if(lastItemsNum > items.length())
                {
                    counter = 0;
                }
                lastItemsNum = items.length();
                if(!xmlRssDataLoaded) initUI();
                xmlRssDataLoaded = true;

                try{
                    showNextItem();
                } catch(e:Error){}
                if(!refreshTextTimer.running) refreshTextTimer.start();
            } else {
                destroy();
            }
        }  else {
            destroy();
        }
    }

    private function showNextItem():void
    {
        clip.gotoAndPlay(0);
        TweenMax.to(clip.top.txt, 0, {alpha: 0});

        if(clip.bottom!=undefined) TweenMax.to(clip.bottom.txt, 0,  {alpha: 0});

        clip.top.txt.text = items[counter].title+" ";

        if(clip.top.txtMask != undefined) clip.top.txtMask.width = 440;
        TweenLite.to(clip.top.txt, 0, {x: topTextInitX});
        clip.top.txt.x = topTextInitX;
        clip.top.txt.width = clip.top.txt.textWidth + 20;
        clip.top.txt.height = clip.top.txtMask.height = clip.top.txt.textHeight;
        clip.top.txt.y = clip.top.txtMask.y = (clip.top.bg.height - clip.top.txt.height) / 2;

        TweenMax.to(clip.top.txt, .3,  {delay:.5, alpha: 1});
        if(clip.bottom!=undefined) TweenMax.to(clip.bottom.txt,.3,  {delay:.5, alpha: 1});

        if(clip.lightning != undefined)
        {
            TweenMax.to(clip.lightning, 0,  {frame: 0});
            TweenMax.to(clip.lightning, 1,  {frameLabel: "final"});
        }
        if(clip.top.stroke != undefined)
        {
            TweenMax.to(clip.top.stroke, 0, {frame: 0});
            TweenMax.to(clip.top.stroke,.3, {delay: .7, frameLabel: "final"});
        }
        if(clip.top.txtMask != undefined)
        {
            if(clip.top.txt.width > clip.top.txtMask.width)
            {
                var newX:Number = topTextInitX+ clip.top.txtMask.width - clip.top.txt.textWidth - (data.@imagen_visible == "true" ? 80:10);
                TweenLite.to(clip.top.txt, topTextSpeed, {delay:1, x: newX});
            } else{
                TweenLite.to(clip.top.txt, 0, {x: topTextInitX});
            }
        }else{
            if(clip.top.txt.width > clip.top.bg.width)
            {
                var newX2:Number = -2*topTextInitX + clip.top.bg.width - clip.top.txt.textWidth;
                TweenLite.to(clip.top.txt, topTextSpeed, {delay:1, x: newX2});
            } else{
                TweenLite.to(clip.top.txt, 0, {x: topTextInitX});
            }
        }

        if(clip.bottom != undefined)
        {
            clip.bottom.txt.width = 440;
            TweenLite.to(clip.bottom.txt, 0, {y: bottomTextInitY});
            clip.bottom.txt.text = items[counter].description;
            setTimeout(adjustBottomText, 1000);
        }
        if(data.@imagen_visible == "true" && clip.pic != undefined)
        {
            TweenMax.to(clip.pic, 0, {alpha: 0});

            while(clip.pic.content.numChildren) clip.pic.content.removeChildAt(0);
            clip.pic.content.addChild(imageLoader);
            var imageUrl:String = items[counter].media::thumbnail.@url;
            imageLoader.load(new URLRequest(imageUrl));
        }
        nextCounter();
    }

    private function adjustBottomText():void
    {
        clip.bottom.txt.height = 4*bottomTextInitY+clip.bottom.txt.textHeight;
        if(clip.bottom.txt.height > clip.bottom.bg.height)
        {
            var diffY:Number = clip.bottom.txt.height - clip.bottom.bg.height;
            var newY:Number = bottomTextInitY - diffY - 20;
            TweenLite.to(clip.bottom.txt, bottomTextSpeed, {delay: 1, y: newY});
        }
    }

    private function handle_imageError(event:IOErrorEvent):void
    {
        clip.top.txtMask.width = 440;
        clip.bottom.txt.width = 440;
        TweenMax.to(clip.pic, 0, {alpha: 0, scaleX:.2, scaleY: .2, ease: Back.easeInOut});
    }

    private function handle_imageComplete(event:Event):void
    {
        clip.top.txtMask.width = 360;
        clip.bottom.txt.width = 360;
        TweenMax.to(clip.pic, .5, {delay: 1, alpha: 1, scaleX: 1, scaleY: 1, ease: Back.easeInOut});
    }

    private function nextCounter():void
    {
        if(counter < items.length()-1)
        {
            counter++;
        } else {
            counter = 0;
        }
    }

    private function handle_rssDataLoadError(event:IOErrorEvent):void
    {
        //OCP.log("handle_rssDataLoadError");
        destroy();
    }

    private function handle_readDataTimer(event:TimerEvent):void
    {
        var now:Date = new Date();
        if(OCP.OCP_TYPE == OCP.OCP_PREVIEW)
        {
            XML_RSS = "http://5.9.137.10/orona/backend/icm_data/RSS.xml";
        }
        var url:String = XML_RSS+"?"+now.getTime();
        rssLoader.load(new URLRequest(url));
    }

    private function initUI():void
    {
        switch(rssType)
        {
            case "estilo1":
                rss_type = TYPE_1;
                var ClipClass1:Class = getDefinitionByName(TYPE_1) as Class;
                clip = new ClipClass1() as MovieClip;
                clip.width = w;
                clip.height = h*1.7;
                prepareTextFields(clip.top.txt, clip.bottom.txt);
                preparePanel();
                addChild(clip);
                break;
            case "estilo2":
                rss_type = TYPE_2;
                var ClipClass2:Class = getDefinitionByName(TYPE_2) as Class;
                clip = new ClipClass2() as MovieClip;
                clip.width = w;
                clip.height = h;
                prepareTextFields(clip.top.txt, clip.bottom.txt);
                preparePanel();
                addChild(clip);
                break;
            case "estilo3":
                rss_type = TYPE_3;
                var ClipClass3:Class = getDefinitionByName(TYPE_3) as Class;
                clip = new ClipClass3() as MovieClip;
                clip.width = w;
                clip.height = h*1.2;
                clip.top.brightMask.height = clip.height;
                prepareTextFields(clip.top.txt);
                preparePanel();
                addChild(clip);
                break;
        }

        topTextInitX = clip.top.txt.x;
        if(clip.bottom != undefined) bottomTextInitY = clip.bottom.txt.y;
    }

    private function preparePanel():void
    {
        var topTransform:ColorTransform = new ColorTransform();
        topTransform.color = parseInt(data.@color_superior);
        clip.top.bg.transform.colorTransform = topTransform;
        clip.top.bg.alpha = parseFloat(data.@alpha_superior);

        if(clip.bottom != undefined)
        {
            var bottomTransform:ColorTransform = new ColorTransform();
            bottomTransform.color = parseInt(data.@color_inferior);
            clip.bottom.bg.transform.colorTransform = bottomTransform;
            clip.bottom.bg.alpha = parseFloat(data.@alpha_inferior);
        }

        if(clip.pic != undefined) TweenMax.to(clip.pic, 0, {alpha: 0});
    }

    private function prepareTextFields(txtTop:TextField, txtBottom:TextField = null):void
    {
        var txtFormatTop:TextFormat = new TextFormat();
        txtFormatTop.font = StringUtils.formatFontName(data.@fuente_titulos);
        txtFormatTop.bold = data.@negrita_titulo === "true";
        txtFormatTop.italic = data.@cursiva_titulo === "true";
        txtFormatTop.underline = data.@subrayado_titulo === "true";
        txtFormatTop.color = parseInt(data.@color_titulos);
        if(rss_type == TYPE_1) txtFormatTop.size = parseInt(data.@size_titulos) + 10;
        if(rss_type == TYPE_2) txtFormatTop.size = parseInt(data.@size_titulos) + 5;
        if(rss_type == TYPE_3) txtFormatTop.size = parseInt(data.@size_titulos) + 30;
        txtFormatTop.align = TextFormatAlign.LEFT;

        txtTop.wordWrap = false;
        txtTop.embedFonts = true;
        txtTop.defaultTextFormat = txtFormatTop;

        if(txtBottom != null)
        {
            var txtFormatBottom:TextFormat = new TextFormat();
            txtFormatBottom.font = StringUtils.formatFontName(data.@fuente_textos);
            txtFormatBottom.bold = data.@negrita_texto === "true";
            txtFormatBottom.italic = data.@cursiva_texto === "true";
            txtFormatBottom.underline = data.@subrayado_texto === "true";
            txtFormatBottom.color = parseInt(data.@color_textos);
            if(rss_type == TYPE_1) txtFormatBottom.size = parseInt(data.@size_textos)+5;
            if(rss_type == TYPE_2) txtFormatBottom.size = parseInt(data.@size_textos)+5;

            txtBottom.autoSize = TextFieldAutoSize.LEFT;
            txtBottom.wordWrap = true;
            txtBottom.multiline = true;
            txtBottom.embedFonts = true;
            txtBottom.defaultTextFormat = txtFormatBottom;
        }
    }

    override public function destroy():void
    {
        if(refreshTextTimer != null)
        {
            refreshTextTimer.stop();
            refreshTextTimer.removeEventListener(TimerEvent.TIMER, handle_refreshTextTimer);
        }

        if(readDataTimer != null)
        {
            readDataTimer.stop();
            readDataTimer.removeEventListener(TimerEvent.TIMER, handle_readDataTimer);
        }

        if(rssLoader != null)
        {
            rssLoader.removeEventListener(Event.COMPLETE, handle_rssDataLoad);
            rssLoader.removeEventListener(IOErrorEvent.IO_ERROR, handle_rssDataLoadError);

        }

        if(imageLoader != null)
        {
            imageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, handle_imageComplete);
            imageLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, handle_imageError);
        }

        refreshTextTimer = null;
        readDataTimer = null;
        rssLoader = null;
        imageLoader = null;

        while(this.numChildren) this.removeChildAt(0);
    }
}
}
