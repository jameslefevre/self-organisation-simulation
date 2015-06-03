class ModelSpecification{
  int[][] limit = null; // optional 3x2 array restricting simulation volume, eg  new int[][]{ {-4000,4000}, {-4000,4000}, {-4000,4000}};
  
  // MODEL PARAMETERS //////////////////////////////////////////////////////////////////////
  
  // mechanical parameters for dissociated UT cell clustering
  // APPLIES TO CELL TYPE 2
  float createAdhesionDist; 
  float adhesionSpringLength;
  float adhesionSpringForce; // attractive only
  float breakAdhesionDist;
  float adhesionFormationProbability;
  
  // cell physical exlusion rule parameters 
  float cellSpacingForceDist;
  float cellSpacingForceStrength;
   
  float[] brownianMotionPerTimestepStdev; // can set different values for different cell types

  float nearCellInteractionDist(){
    return(max(cellSpacingForceDist,createAdhesionDist)); 
  }
}


// used this instead of just constructor or setting defaults above to make it easy to define alternative specifications
ModelSpecification cellAggregation3d(int xDim, int yDim, int zDim){
  
  ModelSpecification m = new ModelSpecification();
  m.limit = new int[][]{ {0,xDim}, {0,yDim}, {0,zDim}};
  cam.lookAt(xDim/2,yDim/2,zDim/2);
  
  m.brownianMotionPerTimestepStdev = new float[]{0,0.2,0.2};
  m.cellSpacingForceDist = 8 ; 
  m.cellSpacingForceStrength = 0.8; 
  
  m.createAdhesionDist = 10;
  m.adhesionSpringLength = 8; 
  m.adhesionSpringForce = 0.02; // 0.2 is unstable (fun)
  m.breakAdhesionDist = 12;
  m.adhesionFormationProbability = 0.005;

  return(m);
}

