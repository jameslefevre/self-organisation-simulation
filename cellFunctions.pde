CellColl randomCellPositions(int[][] limits,  int[] cellNumByType)
{
  CellColl coll = new CellColl();
  int next_id = 0;
  for (int t = 0 ; t< cellNumByType.length ; ++t){
    //for (int t = cellNumByType.length-1 ; t>=0  ; --t){
    
    for (int i = 0; i < cellNumByType[t] ; ++i){
      Cell c = new Cell(t);
      coll.cells.add(c);
      c.id = next_id;
      next_id += 1;
      c.position = new PVector(random(limits[0][0],limits[0][1]), random(limits[1][0],limits[1][1]), random(limits[2][0],limits[2][1]));
    }
  }
  return coll;
}


// get all cells connected to seed cell by path of joined cells (so includes seed and directly joined cells, cells joined to those etc)
ArrayList<Cell> getConnectedCells(Cell c)
{
  ArrayList<Cell> cl = new ArrayList<Cell>(); // all cells found
  ArrayList<Cell> clLatest = new ArrayList<Cell>(); // subset of cells with neighbours to be checked on current iteration
  ArrayList<Cell> clNext = new ArrayList<Cell>(); // subset of cells found in this iteration, to be checked next iteration
  cl.add(c); 
  clLatest.add(c);
  while (true){
    for (Cell cell : clLatest){
      for (Cell joinedCell : cell.joinedCells){
        if (!cl.contains(joinedCell)){
          cl.add(joinedCell);
          clNext.add(joinedCell);
        }
      }
    }
    if (clNext.size() == 0){
      break;
    }
    clLatest = clNext;
    clNext = new ArrayList<Cell>();
  } 
  return(cl);
}







