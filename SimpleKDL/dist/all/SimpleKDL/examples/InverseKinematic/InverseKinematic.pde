/* --------------------------------------------------------------------------
 * SimpleKDL Inverse Kinematic Example
 * --------------------------------------------------------------------------
 * Processing Wrapper for the Orocos KDL library
 * http://code.google.com/p/simple-kdl
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / Zhdk / http://iad.zhdk.ch/
 * date:  08/26/2012 (m/d/y)
 * ----------------------------------------------------------------------------
 * This example is based on: http://eris.liralab.it/wiki/KDL-simple
 * ----------------------------------------------------------------------------
 */
 
import peasy.*;
import SimpleKDL.*;

PeasyCam cam;

SimpleKDL.Chain                        chain;
SimpleKDL.JntArray                     jointAngles;
SimpleKDL.ChainFkSolverPos_recursive   fk;
SimpleKDL.Frame                        finalFrame;
SimpleKDL.ChainIkSolverVel_pinv        vik;
SimpleKDL.ChainIkSolverPos_NR          ik;
SimpleKDL.Frame                        desiredFrame;
PMatrix3D                              finalMat;

SimpleKDL.JntArray q_init;
SimpleKDL.JntArray q_out;

PVector planeP1;
PVector planeP2;
PVector planeP3;

void setup() 
{
  size(800,600,P3D);
  
  // setup cam
  cam = new peasy.PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2000);

  SimpleKDLContext.init(this);
  SimpleKDL.KinematicSolver.setScale(0.001f);
  
  ///////////////////////////////////////////////////////////
  // start with the chain
  chain   = new SimpleKDL.Chain();
 
  SimpleKDL.Joint    joint;
  SimpleKDL.Frame    frame;
  SimpleKDL.Segment  segment;

  // set 1. segment of the chain
  joint  = new SimpleKDL.Joint(Joint.JointType.RotZ); 
  frame  = new SimpleKDL.Frame(new SimpleKDL.Vector(0.2, 0.3, 0.0));
  segment = new SimpleKDL.Segment(joint,frame);
  chain.addSegment(segment);
  
  // set 2. segment of the chain
  joint  = new SimpleKDL.Joint(Joint.JointType.RotZ); 
  frame  = new SimpleKDL.Frame(new SimpleKDL.Vector(0.4, 0.0, 0.0));
  segment = new SimpleKDL.Segment(joint,frame);
  chain.addSegment(segment);
  
  // set 3. segment of the chain
  joint  = new SimpleKDL.Joint(Joint.JointType.RotZ); 
  frame  = new SimpleKDL.Frame(new SimpleKDL.Vector(0.1, 0.1, 0.0));
  segment = new SimpleKDL.Segment(joint,frame);
  chain.addSegment(segment);
   
  jointAngles = new SimpleKDL.JntArray(3);
  jointAngles.set(0,radians(30));
  jointAngles.set(1,radians(30));
  jointAngles.set(2,radians(-90));
  
  ///////////////////////////////////////////////////////////
  // inverse kinematic
  println("------------------------------");
  println("Inverse Kinematics");
  
  fk = new SimpleKDL.ChainFkSolverPos_recursive(chain);
  finalFrame = new SimpleKDL.Frame();
  fk.JntToCart(jointAngles,finalFrame);

  q_init = new SimpleKDL.JntArray(jointAngles);
  vik = new SimpleKDL.ChainIkSolverVel_pinv(chain);
  ik = new SimpleKDL.ChainIkSolverPos_NR(chain,fk,vik);
  
  desiredFrame = new SimpleKDL.Frame(new SimpleKDL.Vector(0.4,0.4,0));
  finalMat = SimpleKDL.KinematicSolver.getMatrix(desiredFrame);
  
  println("Desired Position: " + desiredFrame.getP());
  
  q_out = new SimpleKDL.JntArray(3);
  ik.CartToJnt(q_init,desiredFrame,q_out);
  print("Output angles in rads:\n" + q_out);
 
  // grid
  planeP1 = new PVector(0,0,0);
  planeP2 = new PVector(1,0,0);
  planeP3 = new PVector(0,1,0);
}


void draw() 
{
  // set the lights
  ambientLight(100, 100,100);
  directionalLight(200, 172, 235,
                   1, -1, 0);
  background(0);
  
  scale(100,100,100);
  rotateX(radians(180));
  SimpleKDL.KinematicSolver.drawChain(g,chain,q_out);
  
  stroke(100);
  Utils.drawPlane(g,planeP1,planeP2,planeP3,
                  2,20);
  
  applyMatrix(finalMat);
  Utils.drawCoordSys(g,.1);                  
}


