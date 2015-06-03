// adapted from simulation3D_7, with extraneous code removed

import processing.opengl.*;
import peasy.*;
import java.util.Arrays;
import java.io.BufferedWriter;
import java.io.FileWriter;
import processing.video.*;

// GLOBAL OBJECTS///////////////////////////////////
PeasyCam cam;
ModelSpecification m;
DisplayCtrl displayCtrl;
RunCtrl runCtrl;
CellColl cells;
Octree octree; 

// cell type:
//   1 = cap mesenchyme (non-adhesive)
//   2 = dissociated UT cell - clusters
// lack of type 0 cell type means vectors related to cell types are length 3, with dummy first variable (left over from previous implementation)

void setup()
{
  println("INITIALISE MODEL");
  
  displayCtrl = new DisplayCtrl(); // most values can be changed while running, see "UI"
  runCtrl = new RunCtrl(); // most values can be changed while running, see "UI"
  cam = new PeasyCam(this, displayCtrl.initialCameraDistance);

  
  // SET UP SIMULATION ///////////////////////////////////////////////////////////////////////////////////

  m = cellAggregation3d(50,200,200); // toy example for display
  cells = randomCellPositions(m.limit, new int[]{0,500,500});
  

  //m = cellAggregation3d(680,250,200); 
  //cells = randomCellPositions(m.limit, new int[]{0,0,6800}); // last 2 numbers type 1 cells (cap) and type 2 cells (tip) ; 4420 ; 6800 ; 8500 

  displayCtrl.colourByCluster = false; // use random clour map to distinguish clusters rather than just color by cell type
  
  // this is where we specify auto-saving of numerical data
  runCtrl.recordCellLevelDataTimeSeries = false; // change to true to enable auto-saving
  runCtrl.num_frames_per_timeseries_save = 1000000; // use to save at fixed intervals, or set very high and use specified times below instead
  runCtrl.additionalSaveTimes = new ArrayList<Integer>(Arrays.asList(450, 1800, 2700, 5400, 10800, 720, 2880, 4320, 8640, 17280)); // comment out this line if you want to use regular interval method
  
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  println("MODEL INITIALSED - START SETUP");
  size( displayCtrl.screensize[0], displayCtrl.screensize[1], OPENGL); //P3D  OPENGL
  frameRate(runCtrl.targetFrameRate);
  
  
  smooth();
  strokeWeight( 2 );
  ellipseMode( CENTER ); 
  lights();  
  sphereDetail(displayCtrl.spheredetail[0],displayCtrl.spheredetail[1]);

  octree = new Octree(cells);
  runCtrl.start_time = System.currentTimeMillis();
  if (runCtrl.recordCellLevelDataTimeSeries) {
    initialiseCellDataFile(); 
  }
  println("SETUP COMPLETE");  
}
  
void draw()
{
  if (displayCtrl.drawToScreen){ 
    lights();
    ambientLight(255,255,255);
    background( 255 );
    fill( 0 );
    cells.drawCells();
    if (displayCtrl.drawOctreeLeafNodes > 0) {
      octree.drawLeaves(displayCtrl.drawOctreeLeafNodes > 1);
    }
    
    if (runCtrl.recording && !runCtrl.paused && runCtrl.timeStepCounter%runCtrl.frameSampling == 0){
      saveFrame("movieFiles/ts_"+nf(runCtrl.timeStepCounter,6) + "_n" + cells.cells.size() + ".png");
    }
  }
  if (!runCtrl.paused)
  {
    runModelIteration();
  }
}

