package service {
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	
	public class IsAlive {
		
		private const IS_ALIVE_URL:String = 'http://localhost/isAlive.php'; // url del php a llamar
		private const INTERVAL:int = 60000; // 60 segundos en milisegundos
		
		private var timer:Timer;
		private var request:URLRequest;
		private var loader:URLLoader;

		public function IsAlive() {
			timer = new Timer(INTERVAL);
			timer.addEventListener(TimerEvent.TIMER, handle_timerEvent);
			timer.start();
			
			request = new URLRequest(IS_ALIVE_URL);
			loader = new URLLoader();
		}
		
		private function handle_timerEvent(e:TimerEvent)
		{
			loader.load(request);
		}
	}
	
}
