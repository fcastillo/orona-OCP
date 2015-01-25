/**
 * Elemento del menú neutro.
 *
 * @author: fer : 03/05/14 - 18:13
 * @extends MovieClip
 */
package components.dir
{
import com.greensock.TweenMax;
import com.greensock.easing.Quad;

import components.Directory;

import flash.display.MovieClip;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.utils.setTimeout;

import utils.StringUtils;

public class NeutralItem extends MovieClip
{
    public var floor_txt:TextField;
    public var floorTitle_txt:TextField;
    public var description_txt:TextField;

    private var _dir:Directory;
    public function set dir(value:Directory):void
    {
        _dir = value;
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

    public function NeutralItem()
    {
        super();
    }

    public function init():void
    {
    }

    public function show():void
    {
        TweenMax.to(floor_txt, 0, {alpha: 0, scaleX: 5, scaleY: 5});
        floor_txt.text = _data.@nombre;
        floor_txt.width =  parent.width;
        floorTitle_txt.text = _data.@aditional_info;
        floor_txt.setTextFormat(_txtFormat);

        TweenMax.to(floorTitle_txt, 0, {alpha: 0, scaleX: 5, scaleY: 5});
        _txtFormatDescription.bold = true;
        _txtFormatDescription.leading = -2;
        floorTitle_txt.width = parent.width;
        floorTitle_txt.wordWrap = true;
        floorTitle_txt.autoSize = TextFormatAlign.LEFT;
        floorTitle_txt.htmlText = StringUtils.parseDirText(_data.@descripcion);
        floorTitle_txt.setTextFormat(_txtFormatDescription);

        var txtFormat2:TextFormat = floorTitle_txt.getTextFormat();
        txtFormat2.bold = false;
        txtFormat2.size = 12;

        TweenMax.to(description_txt, 0, {alpha: 0});

        description_txt.wordWrap = true;
        description_txt.autoSize = TextFormatAlign.LEFT;
        description_txt.htmlText = StringUtils.parseDirText(_data.@aditional_info);
        description_txt.setTextFormat(txtFormat2);
        description_txt.textColor = 0x000000;

        TweenMax.to(floor_txt, 2, {alpha: 1, scaleX: 1, scaleY: 1, ease: Quad.easeInOut});
        TweenMax.to(floorTitle_txt, 2.5, {alpha: 1, scaleX: 1, scaleY: 1, ease: Quad.easeInOut});
        TweenMax.to(description_txt, .5, {delay:2.5, alpha: 1, ease: Quad.easeInOut});
        setTimeout(hide, 5000);
    }

    public function hide():void
    {
        _dir.hide();
    }
}
}
