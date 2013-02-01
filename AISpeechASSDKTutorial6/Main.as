package 
{
	import com.adobe.serialization.json.JSONDecoder;
	import com.adobe.serialization.json.JSONEncoder;
	import com.aispeech.events.AIEvent;
	import com.aispeech.events.CoreRequesterEvent;
	import com.aispeech.events.FactoryEvent;
	import com.aispeech.events.MicrophoneDeviceEvent;
	import com.aispeech.events.NetEvent;
	import com.aispeech.events.RecorderEvent;
	import com.aispeech.RecorderLib;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.events.StorageVolumeChangeEvent;
	import flash.events.TouchEvent;
	import flash.media.Microphone;
	import flash.text.TextField;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	
	/**
	 * ...
	 * @author ping.zou
	 */
	public class Main extends Sprite 
	{
		private static const REFTEXT:String = "ni2-hao3";
		private static const CORETYPE:String = "cn.word.score";
		
		public var _recorderLib:RecorderLib;
		private var _logField:TextField;
		
		
		// RecorderLib initialisation parameters
		private static const RECORDERLIB_PARAMS:Object = 
			{
				appKey:"your application ID",
				secretKey:"your security key"
			}
		
		// Default CoreRequester parameters	
		private var _coreRequesterParams:Object = 
			{
				scoreType:100,
				rank:100,
				coreType:CORETYPE,
				userId:"assdkbolierplate.blog.aispeech.com",
				applicationId:"your application Id"
			}
				
		public function Main():void 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.DEACTIVATE, deactivate);
			
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			_logField = new TextField();
			_logField.width = 400;
			_logField.height = 600;
			_logField.text = "log";
			_logField.y = 40;
			_logField.wordWrap = true;
			this.addChild(_logField);
			
			_recorderLib = new RecorderLib();
			// FactoryEvent
			_recorderLib.addEventListener(FactoryEvent.READY, recorderlibEventHandler);
			_recorderLib.addEventListener(FactoryEvent.EXCEPTION_TIMEOUT, recorderlibEventHandler);
			// NetEvent
			_recorderLib.addEventListener(NetEvent.EXCEPTION_CLOSED, recorderlibEventHandler);
			// CoreRequesterEvent
			_recorderLib.addEventListener(CoreRequesterEvent.RESULT, recorderlibEventHandler);
			_recorderLib.addEventListener(CoreRequesterEvent.EXCEPTION_PARAMETERS_ERROR, recorderlibEventHandler);
			_recorderLib.addEventListener(CoreRequesterEvent.EXCEPTION_RESPONSE_ERROR, recorderlibEventHandler);
			_recorderLib.addEventListener(CoreRequesterEvent.EXCEPTION_TIMEOUT, recorderlibEventHandler);
			// MicrophoneDeviceEvent
			_recorderLib.addEventListener(MicrophoneDeviceEvent.MIC_ALLOWED, recorderlibEventHandler);
			_recorderLib.addEventListener(MicrophoneDeviceEvent.EXCEPTION_MIC_NOT_ALLOWED, recorderlibEventHandler);
			_recorderLib.addEventListener(MicrophoneDeviceEvent.EXCEPTION_MIC_NOT_FOUND, recorderlibEventHandler);
			_recorderLib.addEventListener(MicrophoneDeviceEvent.EXCEPTION_MMSCFG_SETTING, recorderlibEventHandler);
			// RecorderEvent
			_recorderLib.addEventListener(RecorderEvent.EXCEPTION_NO_RECORD, recorderlibEventHandler);
			_recorderLib.addEventListener(RecorderEvent.RECORD_STARTED, recorderlibEventHandler);
			_recorderLib.addEventListener(RecorderEvent.RECORD_STOPPED, recorderlibEventHandler);
			_recorderLib.addEventListener(RecorderEvent.RECORDID_GOT, recorderlibEventHandler);
			_recorderLib.addEventListener(RecorderEvent.REPLAY_STARTED, recorderlibEventHandler);
			_recorderLib.addEventListener(RecorderEvent.REPLAY_STOPPED, recorderlibEventHandler);
			_recorderLib.init(RECORDERLIB_PARAMS);						
		}
		
		private function deactivate(e:Event):void 
		{
			// auto-close
			NativeApplication.nativeApplication.exit();
		}
		
		/**
		 * RecorderLib event handlers
		 */
		private function recorderlibEventHandler(event:AIEvent):void
		{
			var eventData:String = new JSONEncoder(event.data).getString();
			_logField.text = event.type + " " + eventData;
			switch (event.type) {
				case FactoryEvent.READY:
					this.stage.addEventListener(TouchEvent.TOUCH_END, touchEventHandler);
					this.stage.addEventListener(MouseEvent.CLICK, mouseEventHandler);
					break;
			}
		}
		
		private function mouseEventHandler(event:MouseEvent):void 
		{
			startRecord();
		}
		
		private function touchEventHandler(event:TouchEvent):void {
			startRecord();
		}
		
		private function startRecord():void {
			_coreRequesterParams.refText = REFTEXT;
			var recorderParams:Object = 
				{
					serverParam:_coreRequesterParams,
					recordLength:5000 // ms
				};
			_recorderLib.startRecord(recorderParams);
		}
	}
}