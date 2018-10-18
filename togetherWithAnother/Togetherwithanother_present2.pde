import org.openkinect.processing.*;
import java.nio.*;
//import processing.sound.*;
//import codeanticode.syphon.*;
PGraphics canvas;
//SyphonServer server;

//sound
//SoundFile myNoise;
//SoundFile myBackground;
//SoundFile myTime;

//kinect
Kinect2 kinect2A;
Kinect2 kinect2B;

//depth range
int minThresh;
int maxThresh;

int totalDepth = 0;
boolean doScreenClean = false;
int normalCleanAlpha = 10;
int skipFrames = 8;

void settings(){
  size(1024, 848, P3D);
  PJOGL.profile = 1;
  
}

void setup() {

  //size(1024, 848, P3D);

  //myBackground = new SoundFile(this, "time_mono2.mp3");
  //myBackground.loop();
  //myBackground.amp(0.5);
  //myNoise = new SoundFile(this, "noise.wav");
  //myNoise.loop();
  //myNoise.amp(0.2);
  //myTime= new SoundFile(this,  "time_mono.mp3");
  //myTime.loop();
  //myTime.amp(0.3);

  kinect2A = new Kinect2(this);
  kinect2A.initDepth();

  kinect2B = new Kinect2(this);
  kinect2B.initDepth();

  //Start tracking each kinect
  kinect2A.initDevice(0);
  kinect2B.initDevice(1);

  minThresh= 600;
  maxThresh= 2150;
  
  canvas = createGraphics(width,height,P3D);
  //create our syphon serever 
  //server = new SyphonServer (this,"Processing Syphon");
  
  canvas.beginDraw();

  canvas.fill(0,0,0,normalCleanAlpha);
  canvas.background(0);
  canvas.endDraw();
}

void draw() {
  
  canvas.beginDraw();
  int[] depthA = kinect2A.getRawDepth();
  int[] depthB = kinect2B.getRawDepth();

  int[] colorB = {230, 120, 255};
  int[] colorA = {109, 192, 244};
  //int[] colorB = {10, 12, 24};
  //int[] colorA = {160, 230, 255};
  
  if (frameCount % skipFrames == 0) {
    noStroke();
    if( doScreenClean == true && animatedCleanScreen(2) == true){
      //println(false);
      canvas.rect(0,0,width,height);
      return;
    }
    else{
      canvas.rect(0,0,width,height);
    } 
    displayDepth(depthA, colorA, true); //kinectData, color, control sound//
    displayDepth(depthB, colorB, false); 
  }
  canvas.endDraw();
  image(canvas,0,0);
  //server.sendImage(canvas);
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
      //int displayVal2 = 0;
      
      if(soundControl == true){
        totalDepth += depthData;
      }

      if ( depthData > minThresh && depthData < maxThresh ) {
        displayVal = round(map(depthData, maxThresh, minThresh, 255, 10));
        //displayVal2 = round(map(depthData, maxThresh, minThresh, 10, 255));
        //blendMode(ADD);
        stroke(rgb[0], rgb[1], rgb[2], displayVal);
        strokeWeight(displayVal/30);
        point(2 * x, 2 * y, 255 - displayVal);       
        if(displayVal > 50){
          pixelCoverage++;
        }
      }
    }
  }
  }
  
  //if(soundControl == true){
  //  int avgDepth = int(totalDepth/217088);
  //  //println(pixelCoverage);
  //  //println(avgDepth);
  //  if( avgDepth > 1200 || avgDepth < 32 || pixelCoverage <= 900){ 
  //    //myNoise.amp(0);
  //    myTime.amp(0);
  //    return;
  //  }
    
    //float noiseVolume = map(avgDepth, 500, 1024, 0.3, 1);
//    float noiseVolume1=0.3;
//    if(avgDepth>800&&avgDepth<1024){
//      noiseVolume1=1;
//    }else if(avgDepth<800&&avgDepth>500){
//      noiseVolume1=1;
//    }
//    //myNoise.amp(noiseVolume);
//    myTime.amp(noiseVolume1);
//    //myTime.amp(noiseVolume);
//    //println(noiseVolume);
//    totalDepth = 0;  
//  }
//}

boolean animatedCleanScreen( int timing){
  int currentTime = second();
  
  if( currentTime % timing == 0){
    int animatedCleanAlpha = int ( 255 * skipFrames * 2/frameRate );
    //println(animatedCleanAlpha);
    fill(0,0,0,animatedCleanAlpha);
    return true;
  }
  else{
    fill(0,0,0,normalCleanAlpha);
    return false;
  }
}
