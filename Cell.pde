
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Cell class
// couple of methods, but mostly used as data struct by CellColl class
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class Cell{
  int id;
  int type; // 1 = CM, 2 = disaggregated UE
  PVector position;
  ArrayList<Cell> joinedCells;
  PVector netForce;
  Integer clusterId=0; // implemented for type 2 for now, replacing complex cluster stuff; equal to smallest cell id in group defined by joinedCells

  
  Cell(int cellType){
    type = cellType;
    joinedCells = new ArrayList<Cell>();
    netForce = new PVector(0,0,0);
  }
  
  int cellColour()
  {
    if (type == 1){
      return(displayCtrl.c1col);
    }
    if (type == 2){
      if (!displayCtrl.colourByCluster) {
        return(displayCtrl.c2col);
      }
      int k = clusterId;
      return(color(255*(k%4)/3,255*(floor(k/4)%4)/3,255*(floor(k/16)%4)/3));
    }
    return(0);
  }
  
  
  void updatePosition()
  {
    position.add(netForce);
    if (m.limit != null){
      if (position.x < m.limit[0][0]) { position.x = m.limit[0][0]; } 
      if (position.y < m.limit[1][0]) { position.y = m.limit[1][0]; } 
      if (position.z < m.limit[2][0]) { position.z = m.limit[2][0]; } 
      if (position.x > m.limit[0][1]) { position.x = m.limit[0][1]; } 
      if (position.y > m.limit[1][1]) { position.y = m.limit[1][1]; } 
      if (position.z > m.limit[2][1]) { position.z = m.limit[2][1]; } 
    }
    netForce.set(0,0,0);
  }
}
  
  
  


