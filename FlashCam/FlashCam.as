package  {
	
	import flash.media.Camera;
	import flash.media.Video;
	import flash.display.MovieClip;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	/* A simple aplication that displays the webcam,
	   captures the video buffer each frame, and 
	   sends the buffer to the socket 
	   
	   @author Chris Rooney
	   @date 18/02/11
	   
	   @updated 04/02/11
	   
	*/
	public class FlashCam extends MovieClip {

		var socket:CustomSocket = null;
		var video:Video;
		var bd:BitmapData;
		var rec:Rectangle;
		var pixels:ByteArray;

		public function FlashCam() {
			button.addEventListener(MouseEvent.CLICK, startUp);  // Call start up when we're ready to send the webcam
		}
		
		// Call this when the button is clicked
		private function startUp(event:MouseEvent) {
			var imgWidth:Number = 160; // The default camera size
			var aspect:Number = Number(AspectRatio.value); // Get the aspect ratio
			
			if (!isNaN(Number(CamWidth.text))) {
				imgWidth = Number(CamWidth.text); // If we have set a number, then assign it to the img width
			}
			var camera:Camera = Camera.getCamera(); // Create a new Camera
			camera.setMode(imgWidth,imgWidth*aspect,15,true); // Set the image size of the camera
			video = new Video(); // Create a new Video clip
			video.attachCamera(camera); // Assign the camera to the clip
			bd = new BitmapData(video.width, video.height, false, 0xFFFFFF); // create some new bitmap data
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);  // Call this function every frame
			socket = new CustomSocket("localhost", 801);  // create a new CustomSocket (see CustomSocket.as)
			socket.sendDimensions(video.width,video.height); // Send the dimentions of the video
			rec = new Rectangle(0,0,video.width,video.height); // Create a rectangle of the same dimensions
			button.label = "Sending Webcam";  // Change the text on the button
			button.removeEventListener(MouseEvent.CLICK, startUp);  // Disable the button
		}
		
		function enterFrameHandler(event:Event) {
			if (socket.isConnected() ) {  // Check if we're connected
   		 		bd.draw(video); // Render the video clip to the BitmapData
				pixels = bd.getPixels(rec); // Get the pixels from the BitmapData
				socket.updateBuffer(pixels); // Update the buffer in the socket
			}
		}
	}
}
