using UnityEngine;
using System.Collections;
using System;
using System.Text;
using System.Net;
using System.Net.Sockets;
using System.Threading;


/* A simple class for retreiving an image buffer from a client and pasting it to a texture.
	(Some of the socket code was borrowed from the tinterwebs).
	
	@author Chris Rooney
	@date 18/02/11
*/

public class WebCamServer : MonoBehaviour {
	
	UnityEngine.Color[] c = null;  // The data format Unity needs for the pixels
	int RGBA = 4; // Now many bytes per pixel
	int flip = 1; // Flip the image
	bool first = true;  // Set up the texture object and color array the first time
	bool receiveData= false; // Used to kill the thread 
	int camWidth;  // The width of the incomming pixel buffer
	int camHeight; // the height of the incomming pixel buffer
	Texture2D tex;  // the texture that we modify
	string flashCamPath = "C:\\Program Files\\FlashCam\\FlashCam.exe"; // The location of the air app
	
	
	void openSocket() {
		ThreadStart tDelegate = new ThreadStart(ts);  // Create a new thread
        Thread t = new Thread(tDelegate); 
        t.Start(); // Start the thread
	}
	
	void ts() {
		try {
			
			IPAddress ipAd = IPAddress.Parse("127.0.0.1"); //use local address
			TcpListener listener=new TcpListener(ipAd,801); 
			listener.Start(); // Listen for connections
			Debug.Log("The local End point is: " + listener.LocalEndpoint );
			Debug.Log("Waiting for a connection.....");
			
			System.Diagnostics.Process process= new System.Diagnostics.Process();
			process.StartInfo.FileName = flashCamPath;
			process.StartInfo.WindowStyle = System.Diagnostics.ProcessWindowStyle.Minimized;
			process.Start();  // Start the air webcam app
			
			Socket s = listener.AcceptSocket();  // Accept incomming connection
			Debug.Log("Connection accepted from "+s.RemoteEndPoint);
			
			byte[] b=new byte[sizeof(int)];  
			s.Receive(b); // Receive what we expect to be an integer
			Console.WriteLine("Recieved...");
			camWidth = BitConverter.ToInt32(b, 0);  // Set the width of the image
			Debug.Log("Image width: " + camWidth);
			s.Receive(b); // Receive what we expect to be another integer
			camHeight = BitConverter.ToInt32(b, 0); // Set the height
			Debug.Log("Image height: " + camHeight);
			c = new Color[camWidth*camHeight];  // Create a new Color object
			
			byte[] img=new byte[camWidth * camHeight * RGBA]; // Create a byte array
			Debug.Log("Ready to receive webcam stream");
			while (receiveData) {  // loop around this until we kill the thread
				ASCIIEncoding asen=new ASCIIEncoding();
				s.Send(asen.GetBytes("ready")); // Tell the client we are ready 
				s.Receive(img);  // Receive the pixel buffer
				
				// Convert the pixel buffer into the color object.  I'm too lazy to explain this in detail.
				for (int i = 0; i < camHeight; ++i) {
					for (int j = 0; j < camWidth * RGBA; j += RGBA) {
						c[(i*camWidth) + (j/RGBA)].a = img[(i*camWidth*RGBA) + j] / 255f;
						c[(i*camWidth) + (j/RGBA)].r = img[(i*camWidth*RGBA) + j +1] / 255f;
						c[(i*camWidth) + (j/RGBA)].g = img[(i*camWidth*RGBA) + j + 2] / 255f;
						c[(i*camWidth) + (j/RGBA)].b = img[(i*camWidth*RGBA) + j + 3] / 255f;
					}
				}
				Thread.Sleep(100); // Make sure the thread has a short nap
			}
			s.Close(); // When we exeit the loop, close the connection
			listener.Stop(); // Stop listeneing
			process.Kill(); // Kill the flash app
		} catch (Exception e) {
			Debug.Log("Error..... " + e.StackTrace);
		}	
	}
	
	void Update() {
		if (c != null) { // Wait until we have a color object 
			if (first) {
				tex = new Texture2D(camWidth,camHeight);  // create a texture
				renderer.material.mainTexture = tex; // assign the texture to our object
				first = false;
			}
			tex.SetPixels(c); // Update the pixel on our texture
			tex.Apply( true ); // apply the changes
		}
	}
	
	void OnApplicationQuit()
    {
		receiveData = false; // Kill the thread
    }
	
	void OnGUI() {
		GUILayout.BeginHorizontal ("box");
		GUILayout.Label("Path to FlashCam.exe"); 
		flashCamPath = GUILayout.TextField (flashCamPath, 50); // the location of the air app
		GUILayout.EndHorizontal ();
		if (GUILayout.Button("Start Sending", GUILayout.Width(100)) && !receiveData) { // Open the stocket and start the air app
			receiveData = true;
			openSocket();
		}
		if (GUILayout.Button("Stop Sending", GUILayout.Width(100))) { // Kill the thread
			receiveData = false;
		}
		if (GUILayout.Toggle(false,"Reverse Image")) {
			flip *= -1;
			renderer.material.mainTextureScale = new Vector2 (flip,1); // flip the image
		}
	}
}
	