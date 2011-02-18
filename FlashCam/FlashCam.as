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
	   
	*/
	public class FlashCam extends MovieClip {

		var socket:CustomSocket = null;
		var video:Video;
		var bd:BitmapData;
		var rec:Rectangle;
		var pixels:ByteArray;

		public function FlashCam() {
			var camera:Camera = Camera.getCamera(); // Create a new Camera
			video = new Video(); // Create a new Video clip
			video.attachCamera(camera); // Assign the camera to the clip
			bd = new BitmapData(video.width, video.height, false, 0xFFFFFF); // create some new bitmap data
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);  // Call this function every frame
			button.addEventListener(MouseEvent.CLICK, showWebcam); // Don't show the webcam  on the flash client by default
			socket = new CustomSocket("localhost", 801);  // create a new CustomSocket (see CustomSocket.as)
			socket.sendDimensions(video.width,video.height); // Send the dimentions of the video
			rec = new Rectangle(0,0,video.width,video.height); // Create a rectangle of the same dimensions
		}
		
		// Call this when the button is clicked
		function showWebcam(event:MouseEvent) {
			removeChild(button);  // Hide the button 
			addChild(video); // Show the Webcam
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
