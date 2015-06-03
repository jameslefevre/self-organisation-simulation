// this contains 3 redundent implementations of near-cell detection and interaction (repulsion and adhesion)
// the simple pairwise version is for checking octree methods
// use nearCellInteractionOctreeNodePair()

// method used once we have identified a nearby pair

void nearPairInteration(Cell c1, Cell c2, float d){
  if (d < m.createAdhesionDist && c1.type == 2 && c2.type == 2 && m.adhesionFormationProbability > random(1) ){
    if (!c1.joinedCells.contains(c2)){
      c1.joinedCells.add(c2);
      c2.joinedCells.add(c1);
     }
   }
   if (d <= m.cellSpacingForceDist){
      PVector force = PVector.sub(c1.position,c2.position);
      force.setMag(m.cellSpacingForceStrength * (m.cellSpacingForceDist - d));
      c1.netForce.add(force);
      c2.netForce.sub(force);
    }
}


int nearCellInteractionOctreeNodePair(Octree ot1, Octree ot2) // returns number of cell pairs in contact
{
  if (ot1 == ot2){
    if (ot1._leaf){
      return 0;
    }
    int pairs = 0; 
    for (int i = 0 ; i <8 ; ++i){
      for (int j = i ; j <8 ; ++j){
        if (ot1._children[i] != null & ot1._children[j] != null){
          pairs += nearCellInteractionOctreeNodePair(ot1._children[i], ot1._children[j]);
        }
      }
    }
    return pairs;
  }
  float d = PVector.dist(ot1._leaf ? ot1._cell.position : ot1._centre, ot2._leaf ? ot2._cell.position : ot2._centre) 
  -1.7321 * ( (ot1._leaf ? 0 : ot1._radius) + (ot2._leaf ? 0 : ot2._radius) ); // 1.7321 gives upper bound on sqrt(3)
  
  if (d > m.nearCellInteractionDist()){
    return 0;
  }
  if (ot1._leaf && ot2._leaf){
    nearPairInteration(ot1._cell,ot2._cell,d);
    return 1;
  }
  
  Octree treeToSplit = ot1._leaf || (!ot2._leaf && ot2._radius > ot1._radius) ? ot2 : ot1;
  Octree treeToKeep = ot1._leaf || (!ot2._leaf && ot2._radius > ot1._radius) ? ot1 : ot2;
  int pairs = 0; 
  for (int i = 0 ; i <8 ; ++i){
    if (treeToSplit._children[i] != null){
      pairs += nearCellInteractionOctreeNodePair(treeToSplit._children[i], treeToKeep);
    }
  }
  return pairs;
}

