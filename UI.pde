// INTERFACE/DISPLAY CONTROLS ///////////////////////////////////////////////////////////////////////////////////////////

class DisplayCtrl{
  
  boolean drawToScreen = true;
  boolean showCells = true;
  boolean[] showCellType = {true,true,true};
  int drawOctreeLeafNodes = 0; // 0 = none, 1 = outline, 2 = solid

  float[] cameraPosOrientForReset = {0.0,0.0,36.0,0.0,0.0,0.0}; // 1-3 pos, 4-6 rotations
  
  int[] screensize = {1200,1000};
  int initialCameraDistance = 300;
  int[] spheredetail = {5,5}; // higher numbers give better sphere rendering, but at a high cost in rendering speed 
  
  // DISPLAY PARAMETERS ///////////////////////////////////////////////////////////////////////////////////////////
  float cellRadiusForDrawing = 4;
  int c1col = color(255,0,0,128); // last number is alpha, out of 255
  int c2col = color(0,0,255,255);  
  boolean colourByCluster = true;
  boolean noteBrokenAdhesions = false;
}


// RunCtrl is for options and tracking/debug variables which are not simply about the display,
// but do not impact the actual simulation
// PARTIAL EXCEPTION - "paused" - but note that this pauses the simulation without changing anything 

class RunCtrl{
  boolean lockKeys = false; // can be used to disable keyboard input
  boolean paused = false;
  int targetFrameRate = 100;
  // time tracking variables
  int timeStepCounter = 0; 
  long start_time;
  
  // DATA RECORDING ///////////////////////////////////////////////////////////////////////////////////////////
  boolean recordCellLevelDataTimeSeries = true;
  int num_frames_per_timeseries_save = 1000; 
  ArrayList<Integer> additionalSaveTimes = new ArrayList<Integer>();
  boolean recording = false;
  int frameSampling = 1; // 1 means save screenshot every time step while recording
  // note that pressing 's' gives instant screen shot
  
  // monitoring and debugging ///////////////////////////////////////////////////////////////////////////////////////////
  int num_frames_for_rate_calc = 10; // does frame rate calc after this number of frames
  
  // frame rate timing variables
  long timeAtLastCheck = 0;
  float frame_rate_achieved = 0;
  float frame_rate_achieved_previous = 0;  
  int shotsTakenThisTimeStep = 0; // for uniquely naming screenshots
  
  // debugging - check # pairwise interactions
  int repulsionPairCount;
}


//////////////////   CONTROLS /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void keyPressed()
{
  if (runCtrl.lockKeys) {return; } // lock key controls
  
  // model controls ////////////////////////
  
  if ( key == 'p' ){
    runCtrl.paused = !runCtrl.paused;
    return;
  }

  
  // display controls ////////////////////////
  
  if (key == 'c'){
    displayCtrl.showCells = ! displayCtrl.showCells;
  }

  if (key == '1'){
    displayCtrl.showCellType[1] = ! displayCtrl.showCellType[1];
  }
  if (key == '2'){
    displayCtrl.showCellType[2] = ! displayCtrl.showCellType[2];
  }
  
  if (key == 'o'){
    displayCtrl.drawOctreeLeafNodes = (displayCtrl.drawOctreeLeafNodes+1)%3;
  }
  if (key == 'd'){
    displayCtrl.drawToScreen = !displayCtrl.drawToScreen;
  }
  if (key == 'l'){
    cam.lookAt(displayCtrl.cameraPosOrientForReset[0],displayCtrl.cameraPosOrientForReset[1],displayCtrl.cameraPosOrientForReset[2],0.0);
    cam.setRotations(displayCtrl.cameraPosOrientForReset[3],displayCtrl.cameraPosOrientForReset[4],displayCtrl.cameraPosOrientForReset[5]);
  }
  
  // information commands  ////////////////////////
  
  if (key == ' '){
    cells.printSummary();
  }   
  if (key == 's'){
    saveFrame("ss_ut_"+runCtrl.timeStepCounter + "_n" + cells.cells.size() + "_" + runCtrl.shotsTakenThisTimeStep + ".png");
    runCtrl.shotsTakenThisTimeStep += 1;
  }
  if (key == 'S'){
    runCtrl.recording = !runCtrl.recording;
    println("Recording " + (runCtrl.recording ? "ON" : "OFF"));
  }
  if (key == 'a'){
    saveCellDataOneOff("modelState_"+runCtrl.timeStepCounter + "_" + year()+"-"+month()+"-"+day()+"T"+hour()+":"+minute()+":"+second()+".xls");
  }
  
  
  if (key =='n'){
    countCellsWith012neighbours();
  }
  
  
  
}
