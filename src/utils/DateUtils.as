/**
 * @author: fer : 08/05/14 - 15:56
 */
package utils
{
    public class DateUtils
    {
        /**
         * Comprueba si han trascurrido menos de 24 horas desde
         * el timestamp suministrado a la hora de sistema actual.
         *
         * @param timeStamp Marca de tiempo a comprobar
         */
        static public function lessThan24HoursAgo(timeStamp:Number)
        {
            var now:Number = int(new Date().time / 1000);
            var diff:Number = now - timeStamp;
            var hours:uint = diff / 3600;
            return hours < 24;
        }

        /**
         * Devuelve el número de días entre dos fechas.
         *
         * @param date1
         * @param date2
         * @return
         */
        static public function getDaysBetweenDates(date1:Date, date2:Date):int
        {
            var one_day:Number = 1000 * 60 * 60 * 24;
            var date1_ms:Number = date1.getTime();
            var date2_ms:Number = date2.getTime();
            var difference_ms:Number = Math.abs(date1_ms - date2_ms)
            return Math.floor(difference_ms/one_day);
        }
    }
}
