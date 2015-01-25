/**
 * @author: fer : 01/04/14 - 12:25
 */
package utils {

	import flash.external.ExternalInterface;
	import flash.text.Font;
	import flash.utils.describeType;

	/**
	 * Firebug adds a global variable named "console" to all web pages loaded in Firefox.
	 * This object contains many methods that allow you to write to the Firebug console to expose information that is flowing through your scripts.
	 * */

	public class Console {

		public static var enabled:Boolean = true;
		public static var _isExternalInterfaceAvailable:Boolean;
		public static var isInit:Boolean;

		public static function get isExternalInterfaceAvailable():Boolean{
			if(!isInit){
				_isExternalInterfaceAvailable = ExternalInterface.available;
				isInit = true;
			}
			return _isExternalInterfaceAvailable;
		}
		/**
		 * Writes a message to the console.
		 * You may pass as many arguments as you'd like, and they will be
		 * joined together in a space-delimited line.
		 * */
		public static function log(...rest):void{
			send("log",rest);
		}
		/**
		 * Writes a message to the console, including a hyperlink to the
		 * line where it was called.
		 * */
		public static function debug(...rest):void{
			send("debug",rest);
		}
		/**
		 * Writes a message to the console with the visual "warning" icon and
		 * color coding and a hyperlink to the line where it was called.
		 * */
		public static function warn(...rest):void{
			send("warn",rest);
		}
		/**
		 * Writes a message to the console with the visual "info" icon and
		 * color coding and a hyperlink to the line where it was called.
		 * */
		public static function info(...rest):void{
			send("info",rest);
		}
		/**
		 * Writes a message to the console with the visual "error" icon and
		 * color coding and a hyperlink to the line where it was called.
		 * */
		public static function error(...rest):void{
			send("error",rest);
		}
		/**
		 * Tests that an expression is true.
		 * If not, it will write a message to the console and throw an exception.
		 * */
		public static function assert(...rest):void{
			send("assert",rest);
		}
		/**
		 * 	Prints an interactive listing of all properties of the object.
		 * 	This looks identical to the view that you would see in the DOM tab.
		 * */
		public static function dir(object:Object):void{
		  send("dir", [object]);
		}
		/**
		 * 	Prints the XML source tree of an HTML or XML element.
		 * 	This looks identical to the view that you would see in the HTML tab.
		 * 	You can click on any node to inspect it in the HTML tab.
		 * */
		public static function dirxml(object:XML):void{
		  send("dirxml", [object]);
		}
		/**
		 * Prints an interactive stack trace of JavaScript execution at the
		 * point where it is called.
		 * The stack trace details the functions on the stack, as well as the values
		 * that were passed as arguments to each function. You can click each function
		 * to take you to its source in the Script tab, and click each argument value
		 * to inspect it in the DOM or HTML tabs.
		 * */
		public static function traceStack():void{
		  send("trace");
		}
		/**
		* Writes a message to the console and opens a nested block to indent all future messages sent to the console.
		* Call console.groupEnd() to close the block.
		* */
		public static function group(...rest):void{
		  send("group", rest);
		}
		/**
		 * Closes the most recently opened block created by a call to console.group.
		 * */
		public static function groupEnd():void{
		  send("groupEnd", []);
		}
		/**
		 * Creates a new timer under the given name.
		 * Call console.timeEnd(name) with the same name to stop the timer and print the time elapsed..
		 * */
		public static function time(name:String):void{
		  send("time", [name]);
		}
		/**
		 * Stops a timer created by a call to console.time(name) and writes the time elapsed.
		 * */
		public static function timeEnd(name:String):void{
		  send("timeEnd", [name]);
		}
		/**
		 * Turns on the JavaScript profiler.
		 * The optional argument title would contain the text to be printed in the header of the profile report.
		 * */
		public static function profile(title:String):void{
		  send("profile", [title]);
		}
		/**
		 * Turns off the JavaScript profiler and prints its report.
		 * */
		public static function profileEnd():void{
		  send("profileEnd", []);
		}
		/**
		 * Writes the number of times that the line of code where count was called was executed.
		 * The optional argument title will print a message in addition to the number of the count.
		 * */
		public static function count(name:String=null):void{
		  send("count", name ? [name] : []);
		}

		public static function dumpAvailableFonts():void{
			debug("--- < Available Fonts > ---");
			var embeddedFonts:Array = Font.enumerateFonts(false);
			for (var i:uint = 0; i < embeddedFonts.length; i++){
			     var f : Font  = embeddedFonts[i];
			     debug(f.fontName);
			}
			debug("--- </Available Fonts > ---");
		}
		/**
		* makes the call to console
		* */
		private static function send(level:String,...rest):void{
			//var val:* = cleanXML(rest[0]);
			//try{
			if(enabled){
				if( isExternalInterfaceAvailable) {
					ExternalInterface.call("console."+level,rest[0]);//[0][0]);
				}
				trace(rest);
			}
			//} catch (any:*){

			//}
		}

		public static function describeObject(obj:Object):String{
			return describeType(obj).@name.toString();//.split("::")[1];
		}

		public static function logDescribe(obj:Object,...rest):void{
			log(describeObject(obj),rest);
		}

		public static function disable():void{
			enabled = false;
		}

		public static function enable():void{
			enabled = true;
		}

		private static function cleanXML(o:Object):Object{
			if(o is XML){
				o = o.toString();
			} else {
				for (var n:* in o){
					return cleanXML(o[n]);
				}
			}
			return o
		}
	}
}