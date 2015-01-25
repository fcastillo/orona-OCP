/**
 * @author: fer : 04/04/14 - 20:19
 */
package utils
{
import components.Ticker;
import components.Weather;

import flash.events.Event;

public class XMLDataEvent extends Event
{
    public static const CONFIG_LOADED:String = "utils.XMLDataEvent.CONFIG_LOADED";
    public static const CONFIG_RELOADED:String = "utils.XMLDataEvent.CONFIG_RELOADED";
    public static const CONFIG_LOAD_ERROR:String = "utils.XMLDataEvent.CONFIG_LOAD_ERROR";
    public static const CONFIG_RELOAD_ERROR:String = "utils.XMLDataEvent.CONFIG_RELOAD_ERROR";
    public static const CHANGED:String = "utils.XMLDataEvent.CHANGED";
    public static const ALARMS_LOADED:String = "utils.XMLDataEvent.ALARMS_LOADED";
    public static const WEATHER_LOADED:String = "utils.XMLDataEvent.WEATHER_LOADED";
    public static const TICKER_LOADED:String = "utils.XMLDataEvent.TICKER_LOADED";
    public static const ADS_LOADED:String = "utils.XMLDataEvent.ADS_LOADED";
    public static const LOAD_ERROR:String = "utils.XMLDataEvent.LOAD_ERROR";
    public static const ALARMS_LOAD_ERROR:String = "utils.XMLDataEvent.ALARMS_LOAD_ERROR";
    public static const WEATHER_LOAD_ERROR:String = "utils.XMLDataEvent.WEATHER_LOAD_ERROR";
    public static const TICKER_LOAD_ERROR:String = "utils.XMLDataEvent.TICKER_LOAD_ERROR";
    public static const ADS_LOAD_ERROR:String = "utils.XMLDataEvent.ADS_LOAD_ERROR";

    private var _config:XML;
    private var _xmlUp:XMLList;
    private var _xmlDown:XMLList;
    private var _xmlStatic:XMLList;
    private var _xmlAlarms:XML;
    private var _xmlWeather:XML;
    private var _xmlTicker:XML;
    private var _xmlTemplate:XMLList;
    private var _xmlAds:XML;
    private var _weatherRef:Weather;
    private var _tickerRef:Ticker;

    public function XMLDataEvent(type:String, dataStatic:XMLList = null, dataUp:XMLList = null, dataDown:XMLList = null, dataAlarms:XML = null, dataWeather:XML = null, dataAds:XML = null, dataTicker:XML = null)
    {
        super(type, false, false);

        _xmlUp = dataUp;
        _xmlDown = dataDown;
        _xmlStatic = dataStatic;
        _xmlAlarms = dataAlarms;
        _xmlWeather = dataWeather;
        _xmlAds = dataAds;
        _xmlTicker = dataTicker;
    }

    public function get xmlUp():XMLList
    {
        return _xmlUp;
    }

    public function get xmlDown():XMLList
    {
        return _xmlDown;
    }

    public function get xmlStatic():XMLList
    {
        return _xmlStatic;
    }

    public function get xmlAlarms():XML
    {
        return _xmlAlarms;
    }

    public function get xmlWeather():XML
    {
        return _xmlWeather;
    }

    public function get xmlTemplate():XMLList
    {
        return _xmlTemplate;
    }

    public function set xmlTemplate(value:XMLList):void
    {
        _xmlTemplate = value;
    }

    public function get xmlAds():XML
    {
        return _xmlAds;
    }

    public function get config():XML
    {
        return _config;
    }

    public function set config(value:XML):void
    {
        _config = value;
    }

    public function get weatherRef():Weather
    {
        return _weatherRef;
    }

    public function set weatherRef(value:Weather):void
    {
        _weatherRef = value;
    }

    public function get tickerRef():Ticker
    {
        return _tickerRef;
    }

    public function set tickerRef(value:Ticker):void
    {
        _tickerRef = value;
    }

    public function get xmlTicker():XML
    {
        return _xmlTicker;
    }
}
}