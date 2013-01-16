package pl.mateuszmackowiak.nativeANE.dialogs
{
	import flash.events.ErrorEvent;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.geom.Rectangle;
	
	import mx.utils.StringUtil;

	[Event(name="error", type="flash.events.ErrorEvent")]
	
	public class OpenInApp extends EventDispatcher
	{
	
		public static const Version:String = "1.0";
		
		private static var _instance:OpenInApp;
		
		private var extCtx:ExtensionContext = null;
				
		public function OpenInApp()
		{
			if (!_instance)
			{
				extCtx = ExtensionContext.createExtensionContext("pl.mateuszmackowiak.nativeANE.dialogs.OpenInApp", null);
				if (extCtx != null)
				{
					extCtx.addEventListener(StatusEvent.STATUS, onStatus);
				} 
				else
				{
					trace('[OpenInApp] Error - Extension Context is null.');
				}
				_instance = this;
			}
			else
			{
				throw Error('This is a singleton, use getInstance(), do not call the constructor directly.');
			}
		}
		
		
		
		public static function getInstance() : OpenInApp
		{
			return _instance ? _instance : new OpenInApp();
		}
		
		
		/**
		 * @param filePath the full path to the file.
		 * @param callArea the rectangular area from which the dialog will be shown. (Only on tablets)
		 * @return if the call was sucessfull
		 */
		public function showOpenInAppDialog(filePath:String , callArea:Rectangle = null):Boolean{
			if(!filePath || StringUtil.trim(filePath).length<2){
				// Filepath can't be empty
				return false;
			}
			return extCtx.call("callOpenInApp",filePath,callArea);
		}
		
		/**
		 * If the OpenInApp extension supports this platform
		 */
		public function isSupported() : Boolean
		{
			return extCtx.call('isSupported');
		}
		
		/**
		 * If the OpenInApp extension supports this platform
		 */
		public static function isSupported():Boolean
		{
			return getInstance().isSupported();
		}
		
		
		/**
		 * Status events allow the native part of the ANE to communicate with the ActionScript part.
		 * We use event.code to represent the type of event, and event.level to carry the data.
		 */
		private function onStatus( event : StatusEvent ) : void
		{
			switch(event.code)
			{
				case "LOGGING":
				{
					trace('[OpenInApp] ' + event.level);
					break;
				}
				case "Error":
				{
					dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,event.level));
					break;
				}
					
				default:
				{
					trace('[OpenInApp] ' + event.level);
					break;
				}
			}
			
		}
	}
}
