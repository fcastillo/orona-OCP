/**
 * @author: fer : 23/04/14 - 18:12
 */
package utils
{
public class StringUtils
{
    /**
     * Limpia espacios al principio y final de la cadena.
     *
     * @param str
     * @return
     */
    static public function trim(str:String):String
    {
        return str.replace(/^\s*(.*?)\s*$/g, "$1");
    }

    /**
     * Formatea el nombre de la fuente para que se adapte a los nombres establecidos
     * de las fuentes cargadas dinámicamente. Sin espacios y en minúscula.
     *
     * @param name
     * @return
     */
    static public function formatFontName(name:String):String
    {
        if(name == "Comic Sans") name = "Comic Sans MS";
        var str:String = name.split(" ").join("").toLowerCase();
        return str+"_font";
    }

    /**
     * Para formatear el html de datos del ccmponente de texto.
     * Quita los saltos de carro de la estructura html.
     *
     * @param text
     * @return
     */
    static public function formatTextComponentData(text:String):String
    {
        var str:String = text.split("\n").join("");
        str = str.split("\r").join("");
        return str;
    }

    /**
     * Limpia de saltos de carro de tipo \n en los textos del directorio.
     *
     * @param str
     * @return
     */
    static public function parseDirText(str:String):String
    {
        str = StringUtils.trim(str);
        var arr:Array = str.split("\\n");
        if(arr.length == 0) return "";
        return arr.join("<br>");
    }

}
}
