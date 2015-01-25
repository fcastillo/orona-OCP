/**
* Eventos despachados al generar un efecto en una imágen
*
* @author fer
*/

package components
{
import flash.display.Sprite;
import flash.events.Event;
	public class ImageEffectEvent extends Event 
	{
		public static const ON_EFFECT_IN:String = "cod.slideshow.ImageEffectEvent.ON_EFFECT_IN";
		public static const ON_EFFECT_OUT:String = "cod.slideshow.ImageEffectEvent.ON_EFFECT_OUT";

		private var _sprite:Sprite;
		
		public function ImageEffectEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new ImageEffectEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("ImageEffectEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get sprite():Sprite
		{
			return _sprite;
		}
		
		public function set sprite(value:Sprite):void
		{
			_sprite = value;
		}
		
	}
	
}