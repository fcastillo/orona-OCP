/**
 * @author: fer : 19/04/14 - 21:14
 */
package utils
{
public class ColorConverter
{

    static public function RGBToDecimal(r:uint, g:uint, b:uint):uint
    {
        var color:uint = r << 16 | g << 8 | b;
        return color;
    }

    static public function decimalToRGB(color:uint):uint
    {
        var r:uint = (color >> 16) & 255;
        var g:uint = (color >> 8) & 255;
        var b:uint = color & 255;
        return r | g | b;
    }
}
}
