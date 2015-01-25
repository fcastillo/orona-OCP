/**
 * Componente meteorológico.
 *
 * @extends AbstractComponent
 * @implements IComponent
 * @author: fer : 06/04/14 - 19:25
 *
 * <ELEMENTO alto="0.15" ancho=".3" tipo="tiempo" dia="Hoy" ciudad="SPXX0191" pais="España" estilo="cartoon" posicion_textos="Arriba" fecha_formato="dd/mm" fecha_fuente="impact" fecha_color="3355443" fecha_negrita="true" fecha_cursiva="false"
 * fecha_subrayado="false" temp_fuente="impact" temp_color="3355443" temp_negrita="true" temp_cursiva="false" temp_subrayado="false" profundidad="4" transparencia="1" cY=".1" cX=".65"/>-->
 */
package components
{

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.TimerEvent;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.utils.Timer;
import flash.utils.getDefinitionByName;

import utils.DateUtils;
import utils.StringUtils;
import utils.XMLData;
import utils.XMLDataEvent;

public class Weather extends AbstractComponent implements IComponent
{
    private static const VERTICAL:String = "vertical";
    private static const HORIZONTAL:String = "horizontal";
    private var controlType:String = VERTICAL;

    // actualización datos, timer refresco
    private var update_timer:Timer;
    private var UPDATE_CYCLE:Number = 3600000; // 1 hora de refresco de datos
    private var _xmlData:XMLData = null; // gestor de carga de xml
    private var xmlWeather:XML = null;
    private var day:String = "Hoy";
    private var cityCode:String = "";
    private var content:Sprite; // contenedor de clip y txtHolder
    private var clip:Sprite;    // contenedor del elemennto gráfico
    private var txtHolder:Sprite;  // contenedor de los textos
    private var targetDate:Date;
    private var dateFormatString:String = "";

    private var tempText:TextField;
    private var dateText:TextField;

    private var graphStyle:String = "";

    private var PADDING:uint = 20; // distancia del contenido a los bordes de la caja del componente
    private var w:Number = 0;
    private var h:Number = 0;

    private var H_WIDTH:uint = 180;
    private var H_HEIGHT:uint = 130;
    private var V_WIDTH:uint = 130;
    private var V_HEIGHT:uint = 180;

    private var lastYahooCode:uint = 0;

    private var newScale:Number = 1;

    private var monthNames:Array = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"];

    public function Weather()
    {
        super();
        _type = AbstractComponent.WEATHER;

        update_timer = new Timer(UPDATE_CYCLE);
        update_timer.addEventListener(TimerEvent.TIMER, reloadControlFromTimer, false, 0, true);
    }

    public function init():void
    {
        update_timer.start();
        _xmlData.loadWeatherData(this);

        this.alpha = parseFloat(data.@transparencia);

        dateFormatString = data.@fecha_formato;
        controlType = data.@posicion_textos == "Derecha" ? HORIZONTAL : VERTICAL;

        w = _area.width * data.@ancho;
        h = _area.height * data.@alto;

        newScale = controlType == VERTICAL ? Math.min( w / V_WIDTH, h / V_HEIGHT) : Math.min( w / H_WIDTH, h / H_HEIGHT);

        var xPos:Number = _area.width * data.@cX;
        var yPos:Number = _area.height * data.@cY;

        this.x = xPos;
        this.y = yPos;

        content = new Sprite();

        this.addChild(content);

        clip = new Sprite();
        this.addChild(clip);

        drawText();
    }

    private function drawText():void
    {
        // fecha
        var dateFormat:TextFormat = new TextFormat();
        dateFormat.size = 15;
        dateFormat.align = TextFormatAlign.CENTER;
        dateFormat.bold = data.@fecha_negrita == "true";
        dateFormat.color = parseInt(data.@fecha_color);
        dateFormat.font = StringUtils.formatFontName(data.@fecha_fuente);
        dateFormat.italic = data.@fecha_cursiva == "true";
        // temperatura
        var tempFormat:TextFormat = new TextFormat();
        tempFormat.size = 15;
        tempFormat.align = TextFormatAlign.CENTER;
        tempFormat.bold = data.@temp_negrita == "true";
        tempFormat.color = parseInt(data.@temp_color);
        tempFormat.font = StringUtils.formatFontName(data.@temp_fuente);
        tempFormat.italic = data.@temp_cursiva == "true";

        dateText = new TextField();
        tempText = new TextField();
        dateText.x = -100;
        dateText.y =  0;
        tempText.x = -100;
        tempText.y = 25;
        dateText.width = 200;
        tempText.width = 200;

        txtHolder = new Sprite();
        txtHolder.addChild(dateText);
        txtHolder.addChild(tempText);
        txtHolder.scaleX = newScale;
        txtHolder.scaleY = newScale;

        content.addChild(txtHolder);

        dateText.defaultTextFormat = dateFormat;
        tempText.defaultTextFormat = tempFormat;
    }

    /**
     * Referencia al gestor de carga de datos xml.
     * @param value
     */
    public function set xmlData(value:XMLData):void
    {
        if(_xmlData == null)
        {
            _xmlData = value;
            _xmlData.addEventListener(XMLDataEvent.WEATHER_LOADED, handle_weatherDataLoaded, false, 0, true);
            _xmlData.addEventListener(XMLDataEvent.WEATHER_LOAD_ERROR, handle_weatherDataLoadError, false, 0, true);
        }
    }

    private function handle_weatherDataLoadError(event:XMLDataEvent):void
    {
        //OCP.log("[Weather handle_weatherDataLoadError]");
        xmlWeather = null;
    }

    private function handle_weatherDataLoaded(event:XMLDataEvent):void
    {
        //OCP.log("[Weather handle_weatherDataLoaded]");
        if(event.weatherRef == this)
        {
            xmlWeather = event.xmlWeather;
            //OCP.log("[Weather xmlWeather->"+xmlWeather+"]");
            try{
                if(DateUtils.lessThan24HoursAgo(xmlWeather.@timestamp) || OCP.OCP_TYPE == OCP.OCP_PREVIEW)
                {
                    drawWeatherClip();
                } else {
                    destroy();
                }
            }
            catch(e:Error)
            {
            }
        }
    }

    override public function destroy():void
    {
        try{
            update_timer.stop();
            update_timer.reset();
            update_timer.removeEventListener(TimerEvent.TIMER, reloadControlFromTimer);
            update_timer = null;

            _xmlData.removeEventListener(XMLDataEvent.WEATHER_LOADED, handle_weatherDataLoaded);
            _xmlData.removeEventListener(XMLDataEvent.WEATHER_LOAD_ERROR, handle_weatherDataLoadError);
            _xmlData = null;

        } catch(e:Error)
        {
        }

        while(this.numChildren) this.removeChildAt(0);
    }

    /**
     * Posiciones posibles: arriba, derecha
     * Formato texto: 18/04/2014
     * Formato Temp:    7/14 ºC
     */
    private function drawWeatherClip():void
    {
        //OCP.log("[Weather drawWeatherClip]");

        day = String(data.@dia).toLowerCase();
        graphStyle = data.@estilo;
        cityCode = data.@ciudad;

        var dayData:XML = getDataForDay();
        if(dayData != null)
        {
            //OCP.log("[Weather dayData]");
           if(lastYahooCode != uint(dayData.@code))
           {
               while (clip.numChildren){ clip.removeChildAt(0); }
               clip.addChild(getGraphFromCode(dayData.@code));
               clip.scaleX = newScale;
               clip.scaleY = newScale;

               lastYahooCode = uint(dayData.@code);
           }
            dateText.text = getFormattedDate();
            if(OCP.OCP_TYPE == OCP.OCP_PREVIEW)
            {
                tempText.text = "10ºC/25ºC";
            }else{
                tempText.text = String(dayData.@low)+"ºC/"+String(dayData.@high)+"ºC"; //Math.round((Number(dayData.@low)-32)/1.8)+"/"+Math.round((Number(dayData.@high)-32)/1.8)+" ºC";
            }

            if(controlType == VERTICAL)
            {
                txtHolder.x = w / 2;
                txtHolder.y = PADDING*clip.scaleY / 2;
                clip.y = (3*h/4)-PADDING*clip.scaleY;
                clip.x = w/2;

            }else{
                txtHolder.x = w - PADDING*clip.scaleX;
                txtHolder.y = h/2- PADDING*clip.scaleY;
                clip.x = clip.width / 2 + PADDING*clip.scaleX;
                clip.y = h/2;
            }
        }else{
            //OCP.log("[Weather NO dayData]");
        }
    }

    private function getFormattedDate():String
    {
        //OCP.log("[Weather getFormattedDate]");

        if(OCP.OCP_TYPE == OCP.OCP_PREVIEW)
        {
            return "01/01/2014";
        }

        var day:String = targetDate.date < 10 ? "0" + targetDate.date : String(targetDate.date);
        var month:String = targetDate.month + 1 < 10 ? "0" + String(targetDate.month + 1) : String(targetDate.month + 1);
        var year:String = String(targetDate.getFullYear());

        var result:Array = [];
        switch(dateFormatString)
        {
            case "dd/mm":
                result.push(day);
                result.push(month);
                //result.push(String(monthNames[targetDate.month]).substr(0,3));
                break;
            case "mm/dd":
                //result.push(String(monthNames[targetDate.month]).substr(0,3));
                result.push(month);
                result.push(day);
                break;
            case "mm/dd/yy":
            case "MM-DD-YY":
                result.push(month);
                result.push(day);
                result.push(year);
                break;
            case "yy/mm/dd":
            case "YY-MM-DD":
                result.push(year);
                result.push(month);
                result.push(day);
                break;
            case "dd/mm/yy":
            case "DD-MM-YY":
                result.push(day);
                result.push(month);
                result.push(year);
            default:
                result.push(day);
                result.push(String(monthNames[targetDate.month]).substr(0,3));
                break;
        }
        return result.join("/");
    }

    /**
     * hoy, mañana, pasado mañana, a 3 días vista
     * @return
     */
    private function getDataForDay():XML
    {
        //OCP.log("[Weather getDataForDay]");

        if(OCP.OCP_TYPE == OCP.OCP_PREVIEW)
        {
            return getNodeByDate(0);
        }

        var weatherDayNode:XML = null;
        switch (day)
        {
            case "hoy":
                weatherDayNode = getNodeByDate(0);
                break;
            case "mañana":
                weatherDayNode = getNodeByDate(1);
                break;
            case "pasado":
                weatherDayNode = getNodeByDate(2);
                break;
            case "siguiente":
                weatherDayNode = getNodeByDate(3);
                break;
        }

        OCP.log(day+":"+weatherDayNode.toString());
        return weatherDayNode;
    }

    /**
     * Identifica el día solicitado por índice según la fecha de cada nodo día en el xml.
     * @param	dayIndex 	0 -> día en curso ,
     * 						1 -> mañana,
     * 						2 -> pasado mañana,
     * 						3 -> 3 dias vista
     */
    private function getNodeByDate(dayIndex:int):XML
    {
        //OCP.log("[Weather getNodeByDate]");

        if(OCP.OCP_TYPE == OCP.OCP_PREVIEW)
        {
            var days:XMLList = xmlWeather.city.(@id=='preview').day;

            //OCP.log("[Weather getNodeByDate: "+days[0]+"]");

            return days[0];
        }

        var today:Date = new Date();
        var cityWeatherData:XMLList = xmlWeather.city.(@id==cityCode);
        if (cityWeatherData == null)
        {
            return null;
        }

        var baseIndex:int = 0;
        var dayFound:Boolean = false;

        for each(var day:XML in cityWeatherData.day)
        {
            targetDate = new Date();
            targetDate.setTime(Date.parse(day.@date));

            OCP.log(String(DateUtils.getDaysBetweenDates(targetDate, today)));

            if(DateUtils.getDaysBetweenDates(targetDate, today) == 0)
            {
                dayFound = true;
                break;
            }else{
                baseIndex++;
            }
        }

        OCP.log("* baseIndex -> "+baseIndex);
        OCP.log("dayFound->"+dayFound);
        if(!dayFound) return null;

        dayIndex += baseIndex;

        OCP.log("dayIndex->"+dayIndex);

        var counter:int = 0;

        for each(var day0:XML in cityWeatherData.day)
        {
            targetDate = new Date();
            targetDate.setTime(Date.parse(day0.@date));

            if (dayIndex == counter)
            {
                return day0;
            }

            counter++;
        }
        return null;
    }

    private function getGraphFromCode(weatherCode:int):MovieClip
    {
        //OCP.log("[Weather getGraphFromCode]");

        // tipo de gráfico
        var suffix_type = "";
        if(graphStyle == "clasico")
        {
            suffix_type = "_clasico";
        }
        else if(graphStyle == "simple")
        {
            suffix_type = "_simple";
        }

        var GraphClass:Class = null;

        // código de tiempo de Yahoo weather

        switch (weatherCode)
        {
            case 0:
            case 1:
            case 2:
                GraphClass = getDefinitionByName("tornado"+suffix_type) as Class;
                break;
            case 3:
            case 4:
            case 37:
            case 38:
            case 39:
                GraphClass = getDefinitionByName("tormentaElectrica"+suffix_type) as Class;
                break;
            case 5:
            case 6:
            case 7:
            case 8:
            case 10:
            case 18:
                GraphClass = getDefinitionByName("aguanieve"+suffix_type) as Class;
                break;
            case 9:
                GraphClass = getDefinitionByName("llovizna"+suffix_type) as Class;
                break;
            case 11:
            case 12:
            case 40:
                GraphClass = getDefinitionByName("lluvia"+suffix_type) as Class;
                break;
            case 13:
            case 14:
            case 15:
            case 16:
            case 41:
            case 42:
            case 43:
            case 46:
                GraphClass = getDefinitionByName("nieve"+suffix_type) as Class;
                break;
            case 17:
            case 35:
                GraphClass = getDefinitionByName("granizo"+suffix_type) as Class;
                break;
            case 19:
                GraphClass = getDefinitionByName("polvo"+suffix_type) as Class;
                break;
            case 20:
            case 21:
                GraphClass = getDefinitionByName("niebla"+suffix_type) as Class;
                break;
            case 22:
                GraphClass = getDefinitionByName("cargadoDeHumo"+suffix_type) as Class;
                break;
            case 23:
            case 26:
            case 27:
            case 28:
                GraphClass = getDefinitionByName("nublado"+suffix_type) as Class;
                break;
            case 24:
                GraphClass = getDefinitionByName("viento"+suffix_type) as Class;
                break;
            case 25:
                GraphClass = getDefinitionByName("frio"+suffix_type) as Class;
                break;
            case 29:
            case 30:
            case 44:
                GraphClass = getDefinitionByName("parcialmenteNublado"+suffix_type) as Class;
                break;
            case 31:
            case 32:
            case 33:
            case 34:
                GraphClass = getDefinitionByName("soleado"+suffix_type) as Class;
                break;
            case 36:
                GraphClass = getDefinitionByName("caliente"+suffix_type) as Class;
                break;
            case 45:
            case 47:
                GraphClass = getDefinitionByName("tormenta"+suffix_type) as Class;
                break;
            default :
                GraphClass = null;
                break;
        }
        if(GraphClass==null) return null;
        var result:MovieClip = new GraphClass() as MovieClip;
        return result;
    }

    private function reloadControlFromTimer(e:TimerEvent)
    {
        _xmlData.loadWeatherData(this);
    }
}
}
