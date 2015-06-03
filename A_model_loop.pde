///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Main loop for iteration/update of simulation
// also have peripheral saving and monitoring functions here
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void runModelIteration()
{ 
  runCtrl.shotsTakenThisTimeStep = 0;
  octree = new Octree(cells); // different view of same set of cells
  runCtrl.repulsionPairCount = nearCellInteractionOctreeNodePair(octree, octree);
  cells.addAdhesionImpulses();
  cells.checkType2ClusterConsistency("adhesion",true);
  cells.brownianMotion();
  for (Cell c : cells.cells){
    c.updatePosition();
  }
  cells.calculateClusterIds();
  
  // end of model iteration: following is checks and saving 
  if (runCtrl.timeStepCounter%runCtrl.num_frames_for_rate_calc == 0) {
    upDateFrameRateTiming();
  }

  if (runCtrl.recordCellLevelDataTimeSeries) {
    saveCellData(); 
  }
  runCtrl.timeStepCounter += 1;
}
 
 
 
// saving data at regular intervals, cell level 

void initialiseCellDataFile()
{
  PrintWriter output = createWriter("data/timeSeriesDataCell.xls"); 
  output.print(cells.modelStateTableHeader());
  output.flush();  // Writes the remaining data to the file
  output.close();
}

void saveCellData()
{
  if (runCtrl.timeStepCounter % runCtrl.num_frames_per_timeseries_save == 0 || runCtrl.additionalSaveTimes.contains(runCtrl.timeStepCounter) ){
    println("saving cell level data at time step " + runCtrl.timeStepCounter + "...");
    File f = new File(dataPath("timeSeriesDataCell.xls"));
    try {
      PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(f, true)));
      out.print(cells.modelStateTable());
      out.close();
    }catch (IOException e){
        e.printStackTrace();
    }
    println("done");
  }
}

void saveCellDataOneOff(String filename)
{
  println("saving cell level data at current time step " + runCtrl.timeStepCounter + " to " + filename + "...");
  PrintWriter output = createWriter(filename); 
  output.print(cells.modelStateTableHeader());
  output.print(cells.modelStateTable());
  output.flush();  // Writes the remaining data to the file
  output.close();
  println("done");
}

void upDateFrameRateTiming()
{
  long currentTime = System.currentTimeMillis();
  if (runCtrl.timeStepCounter == 0)
  {
    runCtrl.timeAtLastCheck = currentTime;
    return;
  }
  runCtrl.frame_rate_achieved_previous = runCtrl.frame_rate_achieved; // allows check on variability or rate of change  
  runCtrl.frame_rate_achieved = runCtrl.num_frames_for_rate_calc * 1000.0 / (currentTime - runCtrl.timeAtLastCheck);
  runCtrl.timeAtLastCheck = currentTime;
}

void countCellsWith012neighbours()
{
  int[] cnts012 = {0,0,0};
  for (Cell c : cells.cells)
  {
    if (c.joinedCells.size() < 3){
      cnts012[c.joinedCells.size()] +=1;
    }
  }
  println(cnts012[0] + ", " + cnts012[1] + ", " + cnts012[2] + " cells with (0, 1, 2) neighbours respectively");
}

