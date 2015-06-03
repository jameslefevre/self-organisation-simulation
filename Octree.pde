///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Octree class
// this provides an alternate (recursive) view of the Cell objects in the CellColl provided to constructor (i.e. "cells"),
// with different set of methods (mostly for constructor)
// algorithm using Octree is in nearCellInteraction/nearCellInteractionOctreeNodePair
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class Octree{
  float _radius;
  PVector _centre;
  
  boolean _leaf;
  Cell _cell; // iff leaf
  Octree[] _children; // iff !leaf
  
  Octree(PVector centre, float radius, Cell cell)
  {
    _radius = radius;
    _centre = centre;
    _leaf = true;
    _cell = cell;
  }
  
  Octree(CellColl coll)
  {
    if (coll.cells.size() == 0)
    {
      return;
    }
    
    PVector p = coll.cells.get(0).position;
    float[] bounds = new float[]{p.x,p.x,p.y,p.y,p.z,p.z};
    for (Cell c : coll.cells)
    {
      p = c.position;

      bounds[0] = min(bounds[0], p.x);
      bounds[1] = max(bounds[1], p.x);
      bounds[2] = min(bounds[2], p.y);
      bounds[3] = max(bounds[3], p.y);
      bounds[4] = min(bounds[4], p.z);
      bounds[5] = max(bounds[5], p.z);
    }
    _centre = new PVector( (bounds[0] + bounds[1])/2, (bounds[2] + bounds[3])/2, (bounds[4] + bounds[5])/2 );
    _radius = max(bounds[1] - bounds[0], bounds[3] - bounds[2], bounds[5] - bounds[4])/2;
    _leaf = true;
    boolean first = true;
    for (Cell c : coll.cells)
    {
      // println("  adding a cell to tree");
      if (first)
      {
        _cell = c;
        first = false;
        continue;
      }
      insert(c);
    }
  }
  
  void addToAChild(Cell c)
  {
    int index = (c.position.x < _centre.x ? 1 : 0) + (c.position.y < _centre.y ? 2 : 0) + (c.position.z < _centre.z ? 4 : 0);
    // println(index);
    if (_children[index] == null)
    {
      //println("add new child node");
      float newR = _radius/2;
      PVector newCentre = new PVector(c.position.x < _centre.x ? -newR : newR, c.position.y < _centre.y ? -newR : newR, c.position.z < _centre.z ? -newR : newR);
      newCentre.add(_centre);
      _children[index] = new Octree(newCentre, newR, c);
      //println("added new child node");
    }
    else
    {
      //println("add to existing child node");
      _children[index].insert(c);
    }
  }
  
  void insert(Cell c)
  {
    // println("inserting cell");
    if (_leaf)
    {
      //println("splitting leaf");
      _children = new Octree[8];
      //println("t1");
      addToAChild(_cell);
      //println("t2");
      _cell = null;
      //println("leaf split");
      _leaf = false;
    }
    addToAChild(c);
  }
 
  
//  display of octree for checking work
  

  void drawLeaves(boolean solid)
  {
    if (_leaf){
      if (solid){
        drawCubeSolid(_centre,_radius);
      }
      else {
        drawCubeOutline(_centre,_radius);
      }
    }
    else {
      for (int i = 0; i<8 ; ++i){
        if (_children[i] != null){
          _children[i].drawLeaves(solid);
        }
      }
    }
  }
  
  void drawCubeOutline(PVector centre, float r)
{
  beginShape( LINES );
  stroke(color(0,255,0));
  for (int a = -1; a < 3 ; a+=2){
    for (int b = -1; b < 3 ; b+=2){
      vertex( centre.x + a*r, centre.y + b*r, centre.z - r);
      vertex( centre.x + a*r, centre.y + b*r, centre.z + r);
      vertex( centre.x + a*r, centre.y - r, centre.z + b*r);
      vertex( centre.x + a*r, centre.y + r, centre.z + b*r);
      vertex( centre.x - r, centre.y + a*r, centre.z + b*r);
      vertex( centre.x + r, centre.y + a*r, centre.z + b*r);
    }
  }
  endShape();
}


void drawCubeSolid(PVector centre, float r)
{
  
  fill(204, 102, 50);
  
  for (int dim = 0; dim < 3 ; ++dim){
    pushMatrix();
    translate(centre.x, centre.y, centre.z);
    if (dim == 1) { rotateX(PI/2); }
    if (dim == 2) { rotateY(PI/2); }
    translate(0, 0, -r);
    rect(-r,-r,2*r,2*r);
    translate(0, 0, 2*r);
    rect(-r,-r,2*r,2*r);
    popMatrix();
  }
}
}
