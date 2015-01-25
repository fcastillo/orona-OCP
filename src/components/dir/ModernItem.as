/**
 * Elemento del menú moderno.
 *
 * @author: fer : 03/05/14 - 18:13
 * @extends MovieClip
 */
package components.dir
{
import com.greensock.TweenMax;

import components.Directory;

import flash.display.MovieClip;
import flash.geom.ColorTransform;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.utils.setTimeout;

import utils.StringUtils;

public class ModernItem extends MovieClip
{
    public var floor_txt:TextField;
    public var floorTitle_txt:TextField;
    public var description_txt:TextField;
    public var bottom:MovieClip;

    private const PADDING:uint = 20;
    private const BOTTOM_HEIGHT_DEFAULT:uint = 214;

    private var _dir:Directory;
    public function set dir(value:Directory):void
    {
        _dir = value;
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
    private var _txtFormatDescription:TextFormat;
    public function set txtFormatDescription(value:TextFormat):void
    {
        _txtFormatDescription = value;
    }

    // datos xml
    private var _data:XML;
    public function set data(value:XML):void
    {
        _data = value;
    }

    public function ModernItem()
    {
        super();
    }

    public function init():void
    {

    }

    private function updatePosition():void
    {
        TweenMax.to(this, .1, {y: 800 - this.height});
    }

    public function show():void
    {

        floor_txt.text = _data.@nombre;
        floorTitle_txt.htmlText = StringUtils.parseDirText(_data.@aditional_info);
        floor_txt.setTextFormat(_txtFormat);

        TweenMax.to(floorTitle_txt, .1, {alpha: 0});
        _txtFormatDescription.bold = true;
        _txtFormatDescription.leading = -2;
        floorTitle_txt.wordWrap = true;
        floorTitle_txt.autoSize = TextFormatAlign.LEFT;
        floorTitle_txt.htmlText = StringUtils.parseDirText(_data.@descripcion);
        floorTitle_txt.setTextFormat(_txtFormatDescription);

        var txtFormat2:TextFormat = floorTitle_txt.getTextFormat();
        txtFormat2.bold = false;
        txtFormat2.size = 12;

        TweenMax.to(description_txt,.1, {alpha: 0});

        bottom.transform.colorTransform = _colorTransBottom;

        description_txt.wordWrap = true;
        description_txt.autoSize = TextFormatAlign.LEFT;
        description_txt.htmlText = StringUtils.parseDirText(_data.@aditional_info);
        description_txt.setTextFormat(txtFormat2);
        description_txt.textColor = 0x000000;


        var txtHeight:Number = floorTitle_txt.textHeight + description_txt.textHeight + 2*PADDING;
        if( txtHeight > BOTTOM_HEIGHT_DEFAULT)
        {
            TweenMax.to(bottom,.2, {height: txtHeight, onUpdate: updatePosition});
        } else {
            TweenMax.to(bottom,.2, {height: BOTTOM_HEIGHT_DEFAULT, onUpdate: updatePosition});
        }

        TweenMax.to(floor_txt,.2, {delay:.1, alpha: 1});
        TweenMax.to(floorTitle_txt,.2, {delay:.2, alpha: 1});
        TweenMax.to(description_txt,.2, {delay:.3, alpha: 1});

        setTimeout(hide, 5000);
    }

    public function hide():void
    {
        _dir.hide();
    }
}
}
