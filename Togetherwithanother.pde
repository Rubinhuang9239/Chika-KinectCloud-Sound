import org.openkinect.processing.*;
import java.nio.*;
import processing.sound.*;

//sound
SoundFile myNoise;
SoundFile myBackground;

//kinect
Kinect2 kinect2A;
Kinect2 kinect2B;

//depth range
int minThresh;
int maxThresh;

int totalDepth = 0;
boolean doScreenClean = false;
int normalCleanAlpha = 8;
int skipFrames = 4;

void setup() {


  size(1024, 848, P3D);

  myBackground = new SoundFile(this, "background.mp3");
  myBackground.loop();
  myNoise = new SoundFile(this, "noise.wav");
  myNoise.loop();
  myNoise.amp(0.2);

  kinect2A = new Kinect2(this);
  kinect2A.initDepth();

  kinect2B = new Kinect2(this);
  kinect2B.initDepth();

  //Start tracking each kinect
  kinect2A.initDevice(0);
  kinect2B.initDevice(1);

  minThresh= 600;
  maxThresh= 2150;

  fill(0,0,0,normalCleanAlpha);
  background(0);
}

void draw() {
  
  int[] depthA = kinect2A.getRawDepth();
  int[] depthB = kinect2B.getRawDepth();

  int[] colorA = {255, 187, 80};
  int[] colorB = {0, 255, 225};
  
  if (frameCount % skipFrames == 0) {
    noStroke();
    if( doScreenClean == true && animatedCleanScreen(10) == true){
      //println(false);
      rect(0,0,width,height);
      return;
    }
    else{
      rect(0,0,width,height);
    } 
    displayDepth(depthA, colorA, true); //kinectData, color, control sound//
    displayDepth(depthB, colorB, false); 
  }
}

void displayDepth(int[] depthArr, int[] rgb, boolean soundControl) {
  
  int pixelCoverage = 0; // detect if there is objects in the view.
  
  for ( int y = 0; y < kinect2A.depthHeight; y++) {
    for (int x = 0; x < kinect2A.depthWidth; x++) {
      
      if( x <= 64 || x >= kinect2A.depthWidth - 64 ){
        continue;
      }

      int offset = x + kinect2A.depthWidth * y;
      int depthData = depthArr[offset];
      int displayVal = 0;
      
      if(soundControl == true){
        totalDepth += depthData;
      }

      if ( depthData > minThresh && depthData < maxThresh ) {
        displayVal = round(map(depthData, maxThresh, minThresh, 255, 10));
        //blendMode(ADD);
        stroke(rgb[0], rgb[1], rgb[2], displayVal);
        point(2 * x, 2 * y, 255 - displayVal);
        
        if(displayVal > 50){
          pixelCoverage++;
        }
      }
    }
  }
  
  if(soundControl == true){
    int avgDepth = int(totalDepth/217088);
    //println(pixelCoverage);
    if( avgDepth > 1200 || avgDepth < 32 || pixelCoverage <= 10000){ 
      myNoise.amp(0);
      return;
    }
    
    float noiseVolume = map(avgDepth, 32, 1024, 0, 1.5);
    myNoise.amp(noiseVolume);
    totalDepth = 0;  
  }
}

boolean animatedCleanScreen( int timing){
  int currentTime = second();
  println(currentTime);
  if( currentTime % timing == 0){
    
    int animatedCleanAlpha = int ( 255 * skipFrames/frameRate );
    fill(0,0,0,animatedCleanAlpha);
    return true;
  }
  else{
    fill(0,0,0,normalCleanAlpha);
    return false;
  }
}