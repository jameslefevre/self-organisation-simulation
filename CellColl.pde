///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CellColl class
//  data is a bunch of Cell objects
//  methods contain much of the modelling work, as well as main drawing method
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class CellColl{
  ArrayList<Cell> cells; 
  
  CellColl()
  {
    cells = new ArrayList<Cell>();
  }
  
  ArrayList<Cell> cellsOfType(int type)
  {
    ArrayList<Cell> cs = new ArrayList<Cell>();
    for (Cell c : cells){
      if (c.type == type){
        cs.add(c);
      }
    }
    return cs;
  }
  
  void brownianMotion()
  {
    for (Cell c : cells){
      float bm_mag = m.brownianMotionPerTimestepStdev[c.type];
      c.netForce.x += randomGaussian()*bm_mag;
      c.netForce.y += randomGaussian()*bm_mag;
      c.netForce.z += randomGaussian()*bm_mag;
    }
  }
  
  
  
  ///////////////////////////////////////// type 2 cells (disag UE) ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  
  void calculateClusterIds(){
    for (Cell c:cells){
      c.clusterId = null;
    }
    for (Cell c:cells){
      if (c.clusterId == null){
        ArrayList<Cell> connectedCells = getConnectedCells(c);
        int minId = c.id;
        for (Cell cell:connectedCells){
          minId = min(minId,cell.id);
        }
        for (Cell cell:connectedCells){
          cell.clusterId = minId;
        }
      }
    }
    
  }
  

  void addAdhesionImpulses()
  {
    //println("");
    ArrayList<Cell[]> brokenAdhesions = new ArrayList<Cell[]>();
    float brokenAdhesionLengthMin = 100000; // these three numbers for debugging/monitoring
    float brokenAdhesionLengthMax = 0;
    float brokenAdhesionLengthSum = 0;
    for (Cell cell : cells)
    {
      if (cell.type != 2) continue;
      for (Cell c2 : cell.joinedCells)
      {
        
        if (cell.id <= c2.id) continue;
        //println("adh "+ cell.id + " " + c2.id);
        PVector disp = PVector.sub(c2.position,cell.position);
        float d =  disp.mag() - m.adhesionSpringLength;
        // println(d);
        if (d < 0) continue;
        if (d > m.breakAdhesionDist - m.adhesionSpringLength)
        {
          brokenAdhesions.add(new Cell[]{cell,c2});
          brokenAdhesionLengthSum += d;
          brokenAdhesionLengthMin = brokenAdhesionLengthMin > d ? d : brokenAdhesionLengthMin;
          brokenAdhesionLengthMax = brokenAdhesionLengthMax < d ? d : brokenAdhesionLengthMax;
          continue;
        }
        disp.setMag(d*m.adhesionSpringForce);
        cell.netForce.add(disp);
        c2.netForce.sub(disp);
      }
    }
    if (brokenAdhesions.size() > 0 & displayCtrl.noteBrokenAdhesions) {
      println(brokenAdhesions.size() + " broken adhesions ["+ 
      (brokenAdhesionLengthMin+m.adhesionSpringLength) + "," + 
      (m.adhesionSpringLength + brokenAdhesionLengthSum/brokenAdhesions.size()) + "," + 
      (brokenAdhesionLengthMax+m.adhesionSpringLength)+"]");
    }
    for (Cell[] cellPair : brokenAdhesions){
      cellPair[0].joinedCells.remove(cellPair[1]);
      cellPair[1].joinedCells.remove(cellPair[0]);
    }
  }




///////////////////////////////////////// INFORMATION / TEST METHODS ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  
  
  // see global method "updatetimeseriesDataCellLevel" for use of following to record cell data
  
  String modelStateTableHeader()
  {
    return "time.steps\tid\ttype\tcluster.id\tx\ty\tz\tjoined.cells";
    //return "";
  }
  String modelStateTable()
  {
    String s = "";
    for (Cell c : cells)
    {
      s += "\n";
      s += runCtrl.timeStepCounter + "\t" + c.id + "\t" + c.type + "\t" + c.clusterId + "\t" + c.position.x + "\t" + c.position.y+ "\t" + c.position.z + "\t";
      boolean fst = true;
      for (Cell jc : c.joinedCells){
        if (!fst) {
          s+=",";
        }
        fst = false;
        s+=jc.id;
      }
    }
    return s;
  }
  
  
  
  void printSummary()
  {
    println("");

    float[] cp = cam.getPosition();
    float[] cr = cam.getRotations();
    println("camera position: " + cp[0] + " " + cp[1] + " " + cp[2] + "; " + cr[0] + " " + cr[1] + " " + cr[2]);
    println("Summary of current situation");
    println("  Elapsed time: " + (System.currentTimeMillis()-runCtrl.start_time) + " milliseconds");
    println("  Number of time steps: " + runCtrl.timeStepCounter);
    println("  Number of cells: " + cells.size() + " (" + cellsOfType(1).size() + " type 1, " +  cellsOfType(2).size() + " type 2)");
    println(" Number of pairwise touching cell repulsion interactions in last step: " + runCtrl.repulsionPairCount);
    println("  Frame rate: " + String.format("%.2f", runCtrl.frame_rate_achieved)  + " (previous: " + String.format("%.2f", runCtrl.frame_rate_achieved_previous) + "; target: " + runCtrl.targetFrameRate + ")");
  }


  void checkType2ClusterConsistency(String codeLocation, boolean pauseModel)
  {
    // first check joins all symmetric (and count type 2 cells)
    int type2Count = 0;
    for (Cell c1 : cells)
    {
      if (c1.type != 2) continue;
      type2Count++;
      int n = c1.joinedCells.size();
      for (int i = 0; i < n ; ++i)
      {
        Cell c2 = c1.joinedCells.get(i);
        Cell c3 = c1.joinedCells.get((i+1)%n);
        if (!c2.joinedCells.contains(c1)){
          println(codeLocation);
          println("!!! " + c2.id + " neighbour of " + c1.id + " but not vice-versa");
          if (pauseModel) {runCtrl.paused = true;}
          continue;
        }
      }
    }
  }
  
///////////////////////////////////////// DRAW ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  void drawCells()
  {
    //for (Cell cell : cells) // following is a hack to get alpha on type 1 cells working
    int n = cells.size();
    for (int cellNum = n-1; cellNum >= 0 ; --cellNum)
    {
      Cell cell = cells.get(cellNum);
      PVector pos = cell.position.get();
      
      if (displayCtrl.showCells && displayCtrl.showCellType[cell.type])
      {
        pushMatrix();
        translate(pos.x, pos.y, pos.z);
        fill(cell.cellColour());
        sphere(displayCtrl.cellRadiusForDrawing); 
        popMatrix();
      }
      beginShape( LINES );
      stroke(0);
      
      int id = cell.id;
      for (Cell c2 : cell.joinedCells){
        if (c2.id > id ){ // && c2.tipActivation >= cellDisplayThreshold
          PVector pos2 = c2.position.get();
          vertex( pos.x, pos.y, pos.z );
          vertex( pos2.x, pos2.y, pos2.z );
        }
      }
      endShape();
    }    
  }
}






