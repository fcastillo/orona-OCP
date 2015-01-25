/**
 * Componente de reloj.
 *
 * @author: fer : 22/04/14 - 13:24
 * @extends AbstractComponent
 * @implements IComponent
 *
 *
 * <ELEMENTO alto="0.065" ancho="0.432" tipo="reloj" tipo_reloj="digital" color_agujas="0" alpha_agujas="1" color_marcas="0" alpha_marcas="1" color_sombra="13027014" alpha_sombra="0.28"
 * color_fondo="6250335" alpha_fondo="1" color_marco="0" alpha_marco="1" color_remarco="13027014" alpha_remarco="0.28" color_numeros="9944589" alpha_numeros="1" color_mes="9944589"
 * color_dia="9944589" color_numDia="9944589" alpha_mes="1" alpha_dia="1" alpha_numDia="1" profundidad="1" transparencia="1" cY="0.72625" cX="0.2853333333333333" path="reloj_digital_v2.swf"/>
 */
package components
{
import com.greensock.TweenLite;
import com.greensock.easing.Quad;

import flash.display.MovieClip;
import flash.geom.ColorTransform;
import flash.text.TextFormat;
import flash.utils.clearInterval;
import flash.utils.getDefinitionByName;
import flash.utils.setInterval;

public class Clock extends AbstractComponent implements IComponent
{
    private static var DIGITAL:String = "digital";
    private static var ANALOG:String = "analog";

    private var clockType:String = "";

    private var clockClip:MovieClip = null;

    private var date:Date;
    private var itv:int;

    private var weekDayNames:Array = ["domingo", "lunes", "martes", "miércoles", "jueves", "viernes", "sabado"];
    private var monthNames:Array = ["enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"];

    public function Clock()
    {
        super();
        _type = AbstractComponent.CLOCK;
    }

    public function init():void
    {
        this.alpha = parseFloat(data.@transparencia);

        var w:Number = _area.width * data.@ancho;
        var h:Number = _area.height * data.@alto;

        var xPos:Number = _area.width * data.@cX;
        var yPos:Number = _area.height * data.@cY;

        this.x = xPos;
        this.y = yPos;

        clockType = data.@tipo_reloj == "analog" ? Clock.ANALOG : Clock.DIGITAL;

        addClockView(w, h);
    }

    private function addClockView(w:Number, h:Number):void
    {
        if(clockType == Clock.DIGITAL)
        {
            try{
                var ClockRef:Class = getDefinitionByName("DigitalClock") as Class;
                clockClip = new ClockRef() as MovieClip;
                clockClip.width = w;
                clockClip.height = h;
                startTimeCount();

                TweenLite.to(clockClip, 0, {alpha: 0});

                addChild(clockClip);
            }catch(e:Error)
            {
            }
        } else {
            var size:Number = Math.min(w,h);
            try{
                var ClockRef2:Class = getDefinitionByName("AnalogClock") as Class;
                clockClip = new ClockRef2() as MovieClip;
                clockClip.width = clockClip.height = size;
                startTimeCount();

                TweenLite.to(clockClip, 0, {alpha: 0});

                addChild(clockClip);
            }catch(e:Error)
            {
            }
        }
        if(clockClip != null) TweenLite.to(clockClip,.5, {alpha: 1, ease: Quad.easeOut});
    }

    private function startTimeCount():void
    {
        onSecond();
        itv = setInterval(onSecond, 1000);
    }

    private function onSecond():void
    {
        date = new Date();

        var hours = date.getHours();
        var minutes = date.getMinutes();
        var monthName = monthNames[date.getMonth()];
        var day = date.getDate();
        var dayName = weekDayNames[date.getDay()];

        var bgTransform:ColorTransform = new ColorTransform();
        bgTransform.color = parseInt(data.@color_fondo);
        var numsTransform:ColorTransform = new ColorTransform();
        numsTransform.color = parseInt(data.@color_numeros);

        if(clockType == Clock.DIGITAL)
        {
            clockClip.bg.fill.transform.colorTransform = bgTransform;
            clockClip.bg.fill.alpha = Number(data.@alpha_fondo);

            clockClip.numbers.hours_txt.text = hours < 10 ? "0" + hours : hours;
            clockClip.numbers.minutes_txt.text = minutes < 10 ? "0" + minutes : minutes;
            clockClip.month.text = String(monthName).substr(0, 3);
            clockClip.day.text = String(dayName).substr(0, 3);
            clockClip.dayNum.text = day;

            clockClip.numbers.transform.colorTransform = numsTransform;
            clockClip.numbers.alpha = Number(data.@alpha_numeros);

            var monthFormat:TextFormat = new TextFormat();
            monthFormat.color = parseInt(data.@color_mes);
            clockClip.month.setTextFormat(monthFormat);
            clockClip.month.alpha = Number(data.@alpha_mes);

            var dayFormat:TextFormat = new TextFormat();
            dayFormat.color = parseInt(data.@color_dia);
            clockClip.day.setTextFormat(dayFormat);
            clockClip.day.alpha = Number(data.@alpha_dia);

            var dayNumFormat:TextFormat = new TextFormat();
            dayNumFormat.color = parseInt(data.@color_numDia);
            clockClip.dayNum.setTextFormat(dayNumFormat);
            clockClip.dayNum.alpha = Number(data.@alpha_numDia);

        } else {
            var marksTransform:ColorTransform = new ColorTransform();
            marksTransform.color = parseInt(data.@color_marcas);
            var needleTransform:ColorTransform = new ColorTransform();
            needleTransform.color = parseInt(data.@color_agujas);
            var marcoTransform:ColorTransform = new ColorTransform();
            marcoTransform.color = parseInt(data.@color_marco);
            var remarcoTransform:ColorTransform = new ColorTransform();
            remarcoTransform.color = parseInt(data.@color_remarco);
            var sombraTransform:ColorTransform = new ColorTransform();
            sombraTransform.color = parseInt(data.@color_sombra);

            clockClip.sombra.alpha = Number(data.@alpha_sombra);
            clockClip.marco.alpha = Number(data.@alpha_marco);
            clockClip.remarco.alpha = Number(data.@alpha_remarco);
            clockClip.mcMinutos.alpha = Number(data.@alpha_agujas);
            clockClip.mcHoras.alpha = Number(data.@alpha_agujas);
            clockClip.centro.alpha = Number(data.@alpha_agujas);
            clockClip.marks.alpha = Number(data.@alpha_marcas);
            clockClip.nums.alpha = Number(data.@alpha_numeros);
            clockClip.bg.alpha = Number(data.@alpha_fondo);

            clockClip.sombra.transform.colorTransform = sombraTransform;
            clockClip.marco.transform.colorTransform = marcoTransform;
            clockClip.remarco.transform.colorTransform = remarcoTransform;
            clockClip.mcMinutos.transform.colorTransform = needleTransform;
            clockClip.mcHoras.transform.colorTransform = needleTransform;
            clockClip.centro.transform.colorTransform = needleTransform;
            clockClip.marks.transform.colorTransform = marksTransform;
            clockClip.nums.transform.colorTransform = numsTransform;
            clockClip.bg.fill.transform.colorTransform = bgTransform;

            clockClip.mcHoras.rotation = 30 * hours + minutes / 2;
            clockClip.mcMinutos.rotation = 6 * minutes;
        }
    }

    override public function destroy():void
    {
        clearInterval(itv);

        while(this.numChildren) this.removeChildAt(0);
    }
}
}
