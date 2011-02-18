package 
{

	import flash.errors.*;
	import flash.events.*;
	import flash.net.Socket;
	import flash.utils.Endian;
	import flash.utils.ByteArray;

	/* A modified version of the CustomSocket example provided by Adobe
	
	   @modified by Chris Rooney
	   @date 18/02/11
	*/
	class CustomSocket extends Socket
	{
		private var response:String; 
		private var isconn:Boolean = false;
		private var ba:ByteArray = null;
		private var readyToSend:Boolean = false;
		
		public function CustomSocket(host:String = null, port:uint = 0)
		{	super();
			configureListeners();
			if (host && port)
			{
				super.connect(host, port);
			}
		}
		
		public function updateBuffer(ba:ByteArray ) {
			this.ba = ba; // Update the ByteArray (the pixel buffer)
			if (response == "ready") { // Have we had the last response?
				sendBuffer(); // Send the updated ByteArray
			}
		}
		
		public function isConnected():Boolean {
			return isconn; // Are we connected?
		}

		private function configureListeners():void
		{
			addEventListener(Event.CLOSE, closeHandler);
			addEventListener(Event.CONNECT, connectHandler);
			addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
		}

		// Send video dimensions to the server
		public function sendDimensions(w:int, h:int) {
			try
			{
				response = "";
				endian = Endian.LITTLE_ENDIAN;
				writeInt(w);
				writeInt(h);
				// We don't flush just in case we're not connected yet
			} catch (e:IOError) {
				trace(e);
			}
		}

		private function readResponse():void {
			var str:String = readUTFBytes(bytesAvailable);
			response +=  str;			
		}
		
		// Send the buffer
		private function sendBuffer() {
			try
			{
				if (ba != null) { // Only send the buffer if we have received one from FlashCam
					writeBytes(ba);
					flush(); // This flushes the data out the socket to the server
				}
				response = "";
			}
			catch (e:IOError)
			{
				trace(e);
			}
		}

		private function closeHandler(event:Event):void
		{
			trace("closeHandler: " + event);
			trace(response.toString());
		}

		private function connectHandler(event:Event):void
		{
			trace("connectHandler: " + event);
			isconn = true;  // Once we're connected, set this to true
			flush(); // This flushes out the dimensions to the server;
		}

		private function ioErrorHandler(event:IOErrorEvent):void
		{
			trace("ioErrorHandler: " + event);
		}

		private function securityErrorHandler(event:SecurityErrorEvent):void
		{
			trace("securityErrorHandler: " + event);
		}

		private function socketDataHandler(event:ProgressEvent):void
		{
			readResponse();
		}
	}
}