/**
 * Gestor de carga de componentes.
 *
 * @author: fer : 11/04/14 - 20:04
 */
package components
{

import br.com.stimuli.loading.BulkLoader;

import flash.events.ErrorEvent;
import flash.events.Event;

import flash.events.EventDispatcher;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;

import utils.XMLData;

public class ComponentsLoader extends EventDispatcher
{
    private static var instance:ComponentsLoader = null;
    private static var created:Boolean = false;

    public static function getInstance():ComponentsLoader
    {
        if(instance == null) instance = new ComponentsLoader();
        return instance;
    }

    private var fontsUrl:String = "fonts/";
    private var alarmsUrl:String = "alarms/";
    private var componentsUrl:String = "components/";

    private var loader:BulkLoader;

    public function ComponentsLoader()
    {
        alarmsUrl     = XMLData.contentsURL+XMLData.contentsURLSeparator+"alarms"+XMLData.contentsURLSeparator;
        fontsUrl      = XMLData.contentsURL+XMLData.contentsURLSeparator+"fonts"+XMLData.contentsURLSeparator;
        componentsUrl = XMLData.contentsURL+XMLData.contentsURLSeparator+"components"+XMLData.contentsURLSeparator;

        if(!ComponentsLoader.created)
        {
            var context:LoaderContext = new LoaderContext(true, ApplicationDomain.currentDomain);
            loader = new BulkLoader("componentsLoader");

            // componentes
            loader.add(componentsUrl+"floorCounter.swf", {id: "floorCounter", context: context});
            loader.add(componentsUrl+"slideshow.swf", {id: "slideShow", context: context});
            loader.add(componentsUrl+"weather.swf", {id: "weather", context: context});
            loader.add(componentsUrl+"video.swf", {id: "video", context: context});
            loader.add(componentsUrl+"image.swf", {id: "image", context: context});
            loader.add(componentsUrl+"background.swf", {id: "background", context: context});
            loader.add(componentsUrl+"clock.swf", {id: "clock", context: context});
            loader.add(componentsUrl+"text.swf", {id: "text", context: context});
            loader.add(componentsUrl+"ticker.swf", {id: "ticker", context: context});
            loader.add(componentsUrl+"menu.swf", {id: "menu", context: context});
            loader.add(componentsUrl+"rss.swf", {id: "rss", context: context});
            loader.add(componentsUrl+"directory.swf", {id: "directory", context: context});
            loader.add(componentsUrl+"advertisement.swf", {id: "advertisement", context: context});
            loader.add(componentsUrl+"icons.swf", {id: "icons", context: context});

            // alarmas
            loader.add(alarmsUrl+"alarm_01_1.swf", {id: "alarm_01_1", context: context});
            loader.add(alarmsUrl+"alarm_01_3.swf", {id: "alarm_01_3", context: context});
            loader.add(alarmsUrl+"alarm_01_4.swf", {id: "alarm_01_4", context: context});

            loader.add(alarmsUrl+"alarm_02_1.swf", {id: "alarm_02_1", context: context});
            loader.add(alarmsUrl+"alarm_02_3.swf", {id: "alarm_02_3", context: context});

            loader.add(alarmsUrl+"alarm_03_1.swf", {id: "alarm_03_1", context: context});
            loader.add(alarmsUrl+"alarm_03_3.swf", {id: "alarm_03_3", context: context});

            loader.add(alarmsUrl+"alarm_04_1.swf", {id: "alarm_04_1", context: context});
            loader.add(alarmsUrl+"alarm_04_3.swf", {id: "alarm_04_3", context: context});

            loader.add(alarmsUrl+"alarm_05_1.swf", {id: "alarm_05_1", context: context});
            loader.add(alarmsUrl+"alarm_05_3.swf", {id: "alarm_05_3", context: context});

            loader.add(alarmsUrl+"alarm_06_1.swf", {id: "alarm_06_1", context: context});
            loader.add(alarmsUrl+"alarm_06_3.swf", {id: "alarm_06_3", context: context});

            // fonts
            loader.add(fontsUrl+"arial.swf", {id: "arial", context: context});
            loader.add(fontsUrl+"arialblack.swf", {id: "arialblack", context: context});
            loader.add(fontsUrl+"comicsans.swf", {id: "comicsans", context: context});
            loader.add(fontsUrl+"courier.swf", {id: "courier", context: context});
            loader.add(fontsUrl+"couriernew.swf", {id: "couriernew", context: context});
            loader.add(fontsUrl+"georgia.swf", {id: "georgia", context: context});
            loader.add(fontsUrl+"impact.swf", {id: "impact", context: context});
            loader.add(fontsUrl+"lucidaconsole.swf", {id: "lucidaconsole", context: context});
            loader.add(fontsUrl+"lucidasans.swf", {id: "lucidasans", context: context});
            loader.add(fontsUrl+"microsoftsansserif.swf", {id: "microsoftsansserif", context: context});
            loader.add(fontsUrl+"modern.swf", {id: "modern", context: context});
            loader.add(fontsUrl+"symbol.swf", {id: "symbol", context: context});
            loader.add(fontsUrl+"tahoma.swf", {id: "tahoma", context: context});
            loader.add(fontsUrl+"timesnewroman.swf", {id: "timesnewroman", context: context});
            loader.add(fontsUrl+"trebuchetms.swf", {id: "trebuchetms", context: context});
            loader.add(fontsUrl+"verdana.swf", {id: "verdana", context: context});


            loader.addEventListener(BulkLoader.COMPLETE, handle_loadComplete);
            loader.addEventListener(BulkLoader.ERROR, handle_loadError);
            loader.start();

            ComponentsLoader.created = true;
        }
    }

    private function handle_loadError(event:ErrorEvent):void
    {
    }

    private function handle_loadComplete(event:Event):void
    {
        dispatchEvent(new ComponentLoaderEvent(ComponentLoaderEvent.LOAD_COMPLETE));
    }

    public function getComponentByType(type:String):IComponent
    {
        return loader.getContent(type) as IComponent;
    }
}
}
