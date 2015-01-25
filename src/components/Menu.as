/**
 * Componente de menú.
 *
 * @author: fer : 22/04/14 - 13:23
 * @extends AbstractComponent
 * @implements IComponent
 *
 * <ELEMENTO alto="0.248" ancho="0.248" tipo="menu" estilo="Estilo4" url_fondo="" color_fondo="16555215" hayColorFondo="false" existe_fondo="true"
   cabecera_txt="CABECERA"
   tituloP_txt="TÍTULO PRINCIPAL&#xA;MENÚ DE FIN DE SEMANA"
   titulo1_txt="Entrantes - Título 1"
   titulo2_txt="Plato principal - Título 2"
   titulo3_txt="Postre - Título 3"
   texto1_txt="Plato1&#xA;Plato 2&#xA;Plato 3&#xA;Plato 4&#xA;Plato 5&#xA;Plato 6"
   texto2_txt="Plato1&#xA;Plato 2&#xA;Plato 3&#xA;Plato 4&#xA;Plato 5&#xA;Plato 6"
   texto3_txt="Plato1&#xA;Plato 2&#xA;Plato 3&#xA;Plato 4&#xA;Plato 5&#xA;Plato 6"
   pie_txt="PIE"
   cabecera_visible="true" tituloP_visible="true" titulo1_visible="true" titulo2_visible="true" titulo3_visible="true" texto1_visible="true" texto2_visible="true" texto3_visible="true" pie_visible="true"
   cabecera_color="0" tituloP_color="3342336" titulo1_color="3342336" titulo2_color="3342336" titulo3_color="3342336" texto1_color="0" texto2_color="0" texto3_color="0" pie_color="0"
   cabecera_fuente="TriplexLight" tituloP_fuente="TriplexLight" titulo1_fuente="TriplexLight" titulo2_fuente="TriplexLight" titulo3_fuente="TriplexLight" texto1_fuente="TriplexLight" texto2_fuente="TriplexLight" texto3_fuente="TriplexLight" pie_fuente="TriplexLight"
   cabecera_size="16" tituloP_size="26" titulo1_size="20" titulo2_size="20" titulo3_size="20" texto1_size="18" texto2_size="18" texto3_size="18" pie_size="16"
   cabecera_align="right" tituloP_align="center" titulo1_align="center" titulo2_align="center" titulo3_align="center" texto1_align="center" texto2_align="center" texto3_align="center" pie_align="right"
   cabecera_negrita="false" tituloP_negrita="true" titulo1_negrita="true" titulo2_negrita="true" titulo3_negrita="true" texto1_negrita="false" texto2_negrita="false" texto3_negrita="false" pie_negrita="false"
   cabecera_cursiva="false" tituloP_cursiva="false" titulo1_cursiva="false" titulo2_cursiva="false" titulo3_cursiva="false" texto1_cursiva="false" texto2_cursiva="false" texto3_cursiva="false" pie_cursiva="false"
   cabecera_subrayado="false" tituloP_subrayado="false" titulo1_subrayado="false" titulo2_subrayado="false" titulo3_subrayado="false" texto1_subrayado="false" texto2_subrayado="false" texto3_subrayado="false" pie_subrayado="false"
   cabecera_bullet="false" tituloP_bullet="false" titulo1_bullet="false" titulo2_bullet="false" titulo3_bullet="false" texto1_bullet="false" texto2_bullet="false" texto3_bullet="false" pie_bullet="false"
   profundidad="9" transparencia="1" cY="0.6675" cX="0.6053333333333333" path="control_menu.swf"/>
 */
package components
{

import flash.display.Sprite;
import flash.geom.ColorTransform;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
import flash.utils.getDefinitionByName;
import utils.StringUtils;

public class Menu extends AbstractComponent implements IComponent
{
    private var w:Number = 0;
    private var h:Number = 0;
    private var lastTextYPos:Number = 30;

    private var textContainer:Sprite;
    private var bgImage:Sprite = null;

    public function Menu()
    {
        super();
        _type = AbstractComponent.MENU;
    }

    public function init():void
    {
        this.alpha = parseFloat(data.@transparencia);

        w = _area.width * data.@ancho;
        h = _area.height * data.@alto;

        var xPos:Number = _area.width * data.@cX;
        var yPos:Number = _area.height * data.@cY;

        this.x = xPos;
        this.y = yPos;

        bgImage = new Sprite();
        textContainer = new Sprite();

        createBackground();
        createTextFields();

        addChild(bgImage);
        addChild(textContainer);
        bgImage.width = w;
        bgImage.height = h;

        textContainer.scaleX = w / _area.width;
        textContainer.scaleY = h / _area.height;
        textContainer.x = (w - textContainer.width) / 2;
    }

    private function createBackground():void
    {
        if(data.@existe_fondo)
        {
            var BGClass:Class;

            switch(String(data.@estilo).toLowerCase())
            {
                case "ninguno":
                    if(data.@hayColorFondo) // fondo con color
                    {
                        var background:Sprite = new Sprite();
                        background.graphics.beginFill(0xffffff);
                        background.graphics.drawRect(0, 0, w, h);
                        bgImage = background;

                        var colorTransform:ColorTransform = new ColorTransform();
                        colorTransform.color = data.@color_fondo;

                        background.transform.colorTransform = colorTransform;
                    }
                    break;
                case "estilo1":
                    BGClass = getDefinitionByName("bg1") as Class;
                    bgImage = new BGClass() as Sprite;
                    break;
                case "estilo2":
                    BGClass = getDefinitionByName("bg2") as Class;
                    bgImage = new BGClass() as Sprite;
                    break;
                case "estilo3":
                    BGClass = getDefinitionByName("bg3") as Class;
                    bgImage = new BGClass() as Sprite;
                    break;
                case "estilo4":
                    BGClass = getDefinitionByName("bg4") as Class;
                    bgImage = new BGClass() as Sprite;
                    break;
                case "estilo5":
                    BGClass = getDefinitionByName("bg5") as Class;
                    bgImage = new BGClass() as Sprite;
                    break;
                case "estilo6":
                    BGClass = getDefinitionByName("bg6") as Class;
                    bgImage = new BGClass() as Sprite;
                    break;
            }
        }
    }

    private function createTextFields():void
    {
        if(data.@cabecera_visible == "true")
        {
            var txt1:TextField = createText("cabecera");
            textContainer.addChild(txt1);
           //lastTextYPos += txt1.textHeight;
            lastTextYPos = txt1.textHeight+10;
        }
        if(data.@tituloP_visible == "true")
        {
            var txt2:TextField = createText("tituloP", 0, true);
            textContainer.addChild(txt2);
        }
        lastTextYPos = 175;
        if(data.@titulo1_visible == "true")
        {
            textContainer.addChild(createText("titulo1", 25));
            textContainer.addChild(createText("texto1", 4, true));
        }
        if(data.@titulo2_visible == "true")
        {
            textContainer.addChild(createText("titulo2", 25));
            textContainer.addChild(createText("texto2", 4, true));
        }
        if(data.@titulo3_visible == "true")
        {
            textContainer.addChild(createText("titulo3", 25));
            textContainer.addChild(createText("texto3", 4, true));
        }
        lastTextYPos = 744;
        if(data.@pie_visible == "true")
        {
            textContainer.addChild(createText("pie"));
        }
    }

    private function createText(id:String, marginTop:int = 0, multiline:Boolean = true, leading:int = 0):TextField
    {
        var txt:TextField = new TextField();
        txt.y = lastTextYPos + marginTop;
        txt.wordWrap = true;
        txt.autoSize = multiline ? TextFieldAutoSize.LEFT : TextFieldAutoSize.NONE;
        txt.width = w;
        txt.multiline = multiline;
        txt.text = data["@"+id+"_txt"];
        txt.setTextFormat(getTextFormat(data["@"+id+"_fuente"], data["@"+id+"_color"], data["@"+id+"_size"], getAlignParam(data["@"+id+"_align"]), data["@"+id+"_negrita"] == "true", data["@"+id+"_cursiva"] == "true", data["@"+id+"_subrayado"] == "true", data["@"+id+"_bullet"] == "true", leading));
        lastTextYPos += txt.textHeight + marginTop;
        return txt;
    }

    private function getAlignParam(align:String):String
    {
        var result:String = "";
        switch(StringUtils.trim(align))
        {
            case "right":
                result = TextFormatAlign.RIGHT;
                break;
            case "center":
                result = TextFormatAlign.CENTER;
                break;
            case "left":
            default :
                result = TextFormatAlign.LEFT;
                break;
        }
        return result;
    }

    private function getTextFormat(font:String, color:uint, size:uint, align:String, bold:Boolean, italic:Boolean, underline:Boolean, bullet:Boolean, leading:int = 0):TextFormat
    {
        var txtFormat:TextFormat = new TextFormat();
        txtFormat.font = font;
        txtFormat.color = color;
        txtFormat.size = size;
        txtFormat.align = align;
        txtFormat.bold = bold;
        txtFormat.italic = italic;
        txtFormat.underline = underline;
        txtFormat.bullet = bullet;
        txtFormat.leftMargin = 20;
        txtFormat.rightMargin = 20;
        txtFormat.leading = leading;
        return txtFormat;
    }

    override public function destroy():void
    {
        while(textContainer.numChildren) textContainer.removeChildAt(0);
        while(this.numChildren) this.removeChildAt(0);
    }
}
}
