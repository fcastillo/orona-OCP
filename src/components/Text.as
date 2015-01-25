/**
 * Componente de texto.
 *
 * @author: fer : 22/04/14 - 13:15
 * @extends AbstractComponent
 * @implements IComponent
 *
 * <ELEMENTO tipo="texto" alto="0.45382352941176474" ancho="1" profundidad="1" transparencia="1" cY="0.29411764705882354" cX="0.022222222222222223" path="ninguno">
       <P ALIGN="LEFT">
         <FONT FACE="Comic Sans MS" SIZE="16" COLOR="#000000">
           Contenido
           <FONT COLOR="#00CC33">para</FONT>
           area
           <FONT COLOR="#990066">4</FONT>
           con diferentes
           <FONT FACE="Symbol">tipografías</FONT>
           y colores
         </FONT>
       </P>
     </ELEMENTO>
 */
package components
{
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import utils.StringUtils;

public class Text extends AbstractComponent implements IComponent
{
    private var txt:TextField;

    public function Text()
    {
        super();
        _type = AbstractComponent.TEXT;
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

        var textData:XML = data.copy();
        var fontTags:XMLList = textData.P..FONT;
        for each(var fontTag in fontTags)
        {
            if(StringUtils.trim(fontTag.@FACE) != "")
            {
                fontTag.@FACE = StringUtils.formatFontName(fontTag.@FACE);
            }
        }

        txt = new TextField();
        txt.wordWrap = true;
        txt.embedFonts = true;
        txt.autoSize = TextFieldAutoSize.LEFT;
        txt.multiline = true;
        txt.htmlText = StringUtils.formatTextComponentData(textData.toString());

        txt.width = w;
        txt.height = h;

        addChild(txt);
    }

    override public function destroy():void
    {
        while(this.numChildren) this.removeChildAt(0);
    }
}
}
