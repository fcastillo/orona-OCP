/**
 * Elemento del menú informal.
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

public class InformalItem extends MovieClip
{
    public var floor_txt:TextField;
    public var floorTitle_txt:TextField;
    public var description_txt:TextField;
    public var top:MovieClip;
    public var bottom:MovieClip;

    private var _dir:Directory;
    public function set dir(value:Directory):void
    {
        _dir = value;
    }
    private const PADDING:uint = 30;
    private const BOTTOM_HEIGHT_DEFAULT:uint = 214;

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

    public function InformalItem()
    {
        super();
    }

    public function init():void
    {
        top.transform.colorTransform = _colorTransUp;
        bottom.transform.colorTransform = _colorTransBottom;
    }

    private function updatePosition():void
    {
        TweenMax.to(this, .1, {y: 800 - this.height});
    }

    public function show():void
    {
        TweenMax.to(description_txt, .1, {alpha: 0});
        floor_txt.embedFonts = true;
        floorTitle_txt.embedFonts = true;
        description_txt.embedFonts = true;

        _txtFormatDescription.bold = true;
        _txtFormatDescription.leading = -2;
        floorTitle_txt.wordWrap = true;
        floorTitle_txt.autoSize = TextFormatAlign.LEFT;

        var txtFormat2:TextFormat = floorTitle_txt.getTextFormat();
        txtFormat2.bold = false;
        txtFormat2.size = 12;

        floor_txt.htmlText = StringUtils.parseDirText(_data.@nombre);
        floorTitle_txt.htmlText = StringUtils.parseDirText(_data.@descripcion);
        description_txt.htmlText = StringUtils.parseDirText(_data.@aditional_info);
        floor_txt.setTextFormat(_txtFormat);
        floorTitle_txt.setTextFormat(_txtFormatDescription);
        description_txt.setTextFormat(txtFormat2);

        description_txt.y = floorTitle_txt.y + floorTitle_txt.textHeight + 20;
        description_txt.wordWrap = true;
        description_txt.autoSize = TextFormatAlign.LEFT;
        description_txt.textColor = 0x000000;

        if(floorTitle_txt.textHeight + description_txt.textHeight >= bottom.height - PADDING)
        {
            TweenMax.to(bottom,.2, {height: floorTitle_txt.textHeight + description_txt.textHeight + 2*PADDING, onUpdate: updatePosition});
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
