import org.openkinect.processing.*;
import java.nio.*;
PGraphics canvas;
//SyphonServer server;

//kinect
Kinect2 kinect2A;
Kinect2 kinect2B;

//depth range
int minThresh;
int maxThresh;

int totalDepth = 0;
boolean doScreenClean = false;
int normalCleanAlpha = 10;
int skipFrames = 4;

void settings(){
  size(1024, 848, P3D);
  PJOGL.profile = 1;
  
}

void setup() {

  kinect2A = new Kinect2(this);
  kinect2A.initDepth();

  kinect2B = new Kinect2(this);
  kinect2B.initDepth();

  //Start tracking each kinect
  kinect2A.initDevice(0);
  kinect2B.initDevice(1);

  minThresh= 320;
  maxThresh= 2200;
  
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
    // displayDepth(depthB, colorB, false); 
    
  }
  canvas.endDraw();
  
  image(canvas,0,0);
  //server.sendImage(canvas);
}

void displayDepth(int[] depthArr, int[] rgb, boolean soundControl) {
  
  for ( int y = 0; y < kinect2A.depthHeight; y++) {
    
    int[] line = new int[96];

    for (int x = 64; x < kinect2A.depthWidth - 64; x++) {

      int offset = x + kinect2A.depthWidth * y;
      int depthData = depthArr[offset];
      
      
      if ( depthData > minThresh && depthData < maxThresh ) {
        int displayVal = round(
          map(depthData, maxThresh, minThresh, 255, 5)
        );
        
        stroke(rgb[0], rgb[1], rgb[2], displayVal);
        strokeWeight(displayVal/36);
        
        point(2 * x, 2 * y, 255 - displayVal);
      }
      
      line[x/4-16] = depthData;
    } // x
    // cliffMapper( line, y);
  } // y
  
}

void cliffMapper(int[] line, int y){
  // int[] borderRecord = {};
  for(int i = 1; i < line.length; i++){
    int depthLeft = line[i-1];
    int depthRight = line[i];
    
    int deltaDepth = depthRight - depthLeft;
    int screenPos = i * 8 + 128;
    
    if(abs(deltaDepth) > 960 && depthRight <= maxThresh){
      int displayVal = round(map(depthLeft, maxThresh, minThresh, 255, 5));
      stroke(255, 0, 0, displayVal);
      point(screenPos, 2 * y);
    }
    
  }
}

boolean animatedCleanScreen(int timing){
  int currentTime = second();

  if( currentTime % timing == 0){
    int animatedCleanAlpha = int ( 255 * skipFrames * 2/frameRate );
    fill(0,0,0,animatedCleanAlpha);
    return true;
  }
  else{
    fill(0,0,0,normalCleanAlpha);
    return false;
  }
}
