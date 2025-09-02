/*----------------------------------------------------------------------------*/
/*                                                                            */
/*    Module:       main.cpp                                                  */
/*    Author:       C:\Users\Aadit                                            */
/*    Created:      Sun Jan 28 2024                                           */
/*    Description:  V5 project                                                */
/*                                                                            */
/*----------------------------------------------------------------------------*/

// ---- START VEXCODE CONFIGURED DEVICES ----
// ---- END VEXCODE CONFIGURED DEVICES ----
#include "vex.h"
#include "main.h"
#include  "robot-config.h"
#include <cmath>

using namespace vex;

competition Competition;

int autonomousSelection = -1;

typedef struct _button {
    int    xpos;
    int    ypos;
    int    width;
    int    height;
    bool   state;
    vex::color offColor;
    vex::color onColor;
    const char *label;
} button;

button buttons[] = {
    {   25,  30, 70, 70,  false, 0x404040, 0x40826d , "5 Ball"},
    {  145,  30, 70, 70,  false, 0x404040, 0x40826d ,"AWP" },
    {  265,  30, 70, 70,  false, 0x404040, 0xE00000, "BallCornerLeft" },
    {  385,  30, 70, 70,  false, 0x404040, 0xE34234, "Skills" },
    {   25, 140, 70, 70,  false, 0x404040, 0x0000E0, "Blue 1" },
    {  145, 140, 70, 70,  false, 0x404040, 0x0000E0, "Blue 2" },
    {  265, 140, 70, 70,  false, 0x404040, 0x0000E0, "Blue 3" },
    {  385, 140, 70, 70,  false, 0x404040, 0XDC9E43 , "Simple" }
};

void displayButtonControls( int index, bool pressed );

int findButton(  int16_t xpos, int16_t ypos ) {
    int nButtons = sizeof(buttons) / sizeof(button);

    for( int index=0;index < nButtons;index++) {
      button *pButton = &buttons[ index ];
      if( xpos < pButton->xpos || xpos > (pButton->xpos + pButton->width) )
        continue;

      if( ypos < pButton->ypos || ypos > (pButton->ypos + pButton->height) )
        continue;

      return(index);
    }
    return (-1);
}

/*-----------------------------------------------------------------------------*/
/** @brief      Init button states                                             */
/*-----------------------------------------------------------------------------*/
void initButtons() {
    int nButtons = sizeof(buttons) / sizeof(button);

    for( int index=0;index < nButtons;index++) {
      buttons[index].state = false;
    }
}

/*-----------------------------------------------------------------------------*/
/** @brief      Screen has been touched                                        */
/*-----------------------------------------------------------------------------*/
void userTouchCallbackPressed() {
    int index;
    int xpos = Brain.Screen.xPosition();
    int ypos = Brain.Screen.yPosition();

    if( (index = findButton( xpos, ypos )) >= 0 ) {
      displayButtonControls( index, true );
    }

}

/*-----------------------------------------------------------------------------*/
/** @brief      Screen has been (un)touched                                    */
/*-----------------------------------------------------------------------------*/
void userTouchCallbackReleased() {
    int index;
    int xpos = Brain.Screen.xPosition();
    int ypos = Brain.Screen.yPosition();

    if( (index = findButton( xpos, ypos )) >= 0 ) {
      // clear all buttons to false, ie. unselected
      //      initButtons(); 

      // now set this one as true
      if( buttons[index].state == true) {
      buttons[index].state = false; }
      else    {
      buttons[index].state = true;}

      // save as auton selection
      autonomousSelection = index;

      displayButtonControls( index, false );
    }
}

/*-----------------------------------------------------------------------------*/
/** @brief      Draw all buttons                                               */
/*-----------------------------------------------------------------------------*/
void displayButtonControls( int index, bool pressed ) {
    vex::color c;
    Brain.Screen.setPenColor( vex::color(0xe0e0e0) );

    for(int i=0;i<sizeof(buttons)/sizeof(button);i++) {

      if( buttons[i].state )
        c = buttons[i].onColor;
      else
        c = buttons[i].offColor;

      Brain.Screen.setFillColor( c );

      // button fill
      if( i == index && pressed == true ) {
        Brain.Screen.drawRectangle( buttons[i].xpos, buttons[i].ypos, buttons[i].width, buttons[i].height, c );
      }
      else
        Brain.Screen.drawRectangle( buttons[i].xpos, buttons[i].ypos, buttons[i].width, buttons[i].height );

      // outline
      Brain.Screen.drawRectangle( buttons[i].xpos, buttons[i].ypos, buttons[i].width, buttons[i].height, vex::color::transparent );

// draw label  
      if(  buttons[i].label != NULL )
        Brain.Screen.printAt( buttons[i].xpos + 8, buttons[i].ypos + buttons[i].height - 8, buttons[i].label );
    }
}

double speedCap = 1; 
double speedCapTurn = 1;

double kP = 0.15; //.13
double kI = 0.0; //integral control causes the robot to jitter
double kD = 2.3; //0.5
double turnkP = 0.55;//0.14
double turnkI = 0.0; //integral control causes the robot to jitter
double turnkD = 0.21;//0.0015; 0.44
float dV = 0;
int dTV = 0;
 
int error; //sensor-desired value positional value
int prevError = 0; //error 20 milliseconds ago
int derivative;
int totalError = 0; //what in the world is this
 
int turnError; //sensor-desired value positional value
int turnPrevError = 0; //error 20 milliseconds ago
int turnDerivative;
int turnTotalError = 0; //what in the world is this
 
bool resetDriveSensors = false;
bool enablePID = false;
 

//odom Variables 

//noDeadwheel odom
double X = 0.0; //starting global Cord 
double Y = 0.0; //starting globalCord
double rightPos = 0.0;
double leftPos = 0.0;
double prevRightPos = 0.0;
double prevLeftPos = 0.0;
double deltaRightpos = 0;
double deltaLeftPos = 0;
double avgPos = 0.0;
double rHeading = iner.heading();
double wheelDist = 0.0;
const double PI = 3.141592653589793; 
const double wheelRadius = 3.25; //chasnge for your robot
const double circumfrence  = 2 * PI * wheelRadius;
 //two deadwheel odom
 double X1 = 0.0;
 double Y1 = 0.0;
 double parallelRadius = 8; // if wheel is mounted on left side make this value negative - due to turn physics
 double perpenducularRadius = 7; // if wheel is mounted on the back make this negative  - due to the way algorithm is structured
 double deltaH = 0;
 double deltaParallelPos = 0;
 double deltaPerpendicularPos = 0;
 double heading1 = iner.rotation();
 double currParallelPos = parallelDeadWheel.position(degrees);
 double currPerpendicularPos = perpendicularDeadWheel.position(degrees);
 double deltaX = 0.0;
 double deltaY = 0.0;
 double prevheading = 0;
 double PrevParallellPos = 0.0;
 double PrevPerpPos = 0.0;
 
  
 





int drivePID()
{
 
 while(enablePID)
 {
 
   if(resetDriveSensors)
   { 
     frontL.setPosition(0,degrees);
     frontR.setPosition(0,degrees);
  
     iner.setRotation(0,degrees);
     resetDriveSensors = false; //this is a bool, once the sensors have been reset, it will return as "true"
   }
  
   int inertialPosition = iner.rotation(degrees);

   int averagePosition = (frontL.position(degrees) + frontR.position(degrees)) / 2;

   error = averagePosition - ((360 * dV) * 1.05); 
 
   derivative = error - prevError; 

   totalError += error;  
 
   double lateralMotorPower = ((error * kP + derivative * kD + totalError * kI) / 12 );
  
   int turnDifference = inertialPosition; 
   
   turnError = turnDifference - dTV;
 
   turnDerivative = turnError - turnPrevError; 
 
   turnTotalError += turnError; 
 
   double turnMotorPower = (turnError * turnkP + turnDerivative * turnkD + turnTotalError * turnkI) / 3 ;
 
   frontL.spin(reverse , (lateralMotorPower * speedCap) + (turnMotorPower * speedCapTurn) , voltageUnits::volt);
   middleL.spin(reverse , (lateralMotorPower * speedCap) + (turnMotorPower * speedCapTurn) , voltageUnits::volt);
   backL.spin(reverse , (lateralMotorPower * speedCap) + (turnMotorPower * speedCapTurn) , voltageUnits::volt);   
   frontR.spin(reverse , (lateralMotorPower * speedCap) - (turnMotorPower * speedCapTurn) , voltageUnits::volt);
   middleR.spin(reverse , (lateralMotorPower * speedCap) - (turnMotorPower * speedCapTurn) , voltageUnits::volt);
   backR.spin(reverse , (lateralMotorPower * speedCap) - (turnMotorPower * speedCapTurn) , voltageUnits::volt);

   prevError = error;
   turnPrevError = turnError;
 
   vex::task::sleep(25);
 }
 return 1; 
}

int  noDeadWheelTankOdom(void){
  // use wheel rotation equations.
  
   rightPos = (frontR.position(degrees) + middleR.position(degrees) + backR.position(degrees))/3 ;
leftPos = (frontL.position(degrees) + middleL.position(degrees) + backL.position(degrees))/3 ;
deltaRightpos = rightPos - prevRightPos;
deltaLeftPos = leftPos - prevLeftPos;
   avgPos = (deltaRightpos + deltaLeftPos )/2;
  wheelDist = circumfrence * (avgPos/360);
 // convert imu angle to radians as c++ trig functions use radians 
   rHeading *= (PI/180);
   // break wheel distance vector into x and y components and add them to respective coordinates
    X += wheelDist *std::cos(rHeading);
    Y += wheelDist * std::sin(rHeading);
   //reset values for next cycle 
   prevRightPos = rightPos;
   prevLeftPos = leftPos;
    frontL.setPosition(0,degrees);
     frontR.setPosition(0,degrees);
     middleL.setPosition(0,degrees);
     middleR.setPosition(0,degrees);
      backL.setPosition(0,degrees);
     backR.setPosition(0,degrees);
      return 1;
}
int twoDeadWheelOdom(void){
   // deltax + parallelRadius/2 * deltaTheta = wheel distance travel equation 
 // deltaX = -parallellRadius/2  * deltaTheta + wheel distance travel equation 
 heading1 *= (PI/180);
  deltaH = heading1 - prevheading;
  deltaParallelPos = currParallelPos - PrevParallellPos;
  double temp = parallelRadius/2 *-1;
  deltaX = circumfrence * deltaParallelPos + temp; 
  // deltay = -perpendicularRadius/2  * deltaTheta + wheel distance travel equation 
  deltaPerpendicularPos = currPerpendicularPos - PrevPerpPos;
  double temp2 = perpenducularRadius/2 * -1;
  deltaY = circumfrence * deltaPerpendicularPos + temp;
  // apply rotation matrix equation 
  X1 = X1 + deltaX *std::cos(heading1) - deltaY * std::sin(heading1);
  Y1 = Y1 +deltaX * std::sin(heading1) + deltaY *std::cos(heading1);
  prevheading = heading1;
  PrevParallellPos = currParallelPos;
  PrevPerpPos = currPerpendicularPos;


  return 1;
}






void pre_auton(void) {
  calib();
  vexcodeInit();

 
}


void autonomous(void) {
  vex::task bill(drivePID);
  enablePID = true; 
  resetDriveSensors = true; 

  int Red1   = buttons[0].state; //auton selector 
  int Red2   = buttons[1].state;
  int Red3   = buttons[2].state;
  int Skills = buttons[3].state;
  int Blue1  = buttons[4].state;
  int Blue2  = buttons[5].state;
  int Simple = buttons[7].state;
  int Blue3  = buttons[6].state;

  if(Red1){
    dV = 10;
    dTV = 0;
    task::sleep(700);
    resetDriveSensors = true;
    //utilizing heading control, avoid using "resetDriveSensors"
    /*
    kP = 0.124;
    //while going forward open the wings to release preload, additionally intake is spinning
    spinUp(true);
    wings.open();
    wingsR.open();
    task::sleep(400);
    dV = 5.2;
    dTV = -48;
    wings.close();
    wingsR.close(); 
    task::sleep(1600);
    spinUp(false);

    kP = 0.118;
    //turn right to align with goal, swipe to avoid touching middle pipe 
    dV = 5.0; 
    dTV = 90; 
    task::sleep(800);

    //reverse the intakes while pushing both balls into the goal 
    spinUpReverse(true);
    wings.open();
    wingsR.open();
    dV = 7.5;
    dTV = 90;
    task::sleep(1000);
    spinUpReverse(false);
    wings.close();
    wingsR.close();
    
    //reverse a bit
    kP = 0.124;
    dV = 5;
    dTV = 90;
    task::sleep(700);

    //turn right to get the 2nd ball 
    kP = 0.119;
    dV = 5;
    dTV = 225;
    task::sleep(800);

    //intakes the 2nd ball 
    spinUp(true);
    dV = 6.8; 
    dTV = 225; 
    task::sleep(1100);

    //back out get ready for alignment for match load bar to push ball out w/Wings
    //the robot should be perpindicular to the middle pipe 
    dV = 3.7;
    dTV = 225;
    task::sleep(1300);
    spinUp(false);
    resetDriveSensors = true;

    
    
    dV = 1; //this is the problem child 
    dTV = -135;
    task::sleep(700);

    spinUpReverse(true);
    dV = 3;
    dTV = -135;
    task::sleep(700);

    dV = 1;
    dTV = -135;
    task::sleep(700);

    dV = 1;
    dTV = -235;
    task::sleep(900);
    resetDriveSensors = true;

    dV = -5.3; //hit the wall for alignment 
    dTV = 0;
    task::sleep(1500);
    resetDriveSensors = true;


    //speedCapTurn = 0.8;
    dV = 0; 
    dTV = 77;
    task::sleep(800);

    speedCap = 1;
    wings.open();
    wingsR.open();
    dV = 2.8;
    dTV = 77;
    task::sleep(700);

    speedCap = 1;
    dV = 4.55;
    dTV = 0;
    task::sleep(800);

    
    wings.close();
    wingsR.close();
    kP = 0.8;
    dV = 4.1;
    dTV = 0;
    task::sleep(300);
    
    dV = 6.5;
    dTV = 20;
    task::sleep(1000);
    //LOL 
    

//   dV = 2;
    dTV = -135;
    task::sleep(1000);


    dV = 3.3;
    dTV = 90;
    task::sleep(1500);
    
   
    
    //hit the wall 
    dV = -1;
    dTV = 90;
    task::sleep(700);
    resetDriveSensors = true;

    wings.open();
    spinUpReverse(true);
    dV = 6; 
    dTV = 30;
    task::sleep(2000);
    
    dV = 8;
    dTV = 90;
    task::sleep(2000);
    wings.close();
    resetDriveSensors = true;

    spinUpReverse(false);

    dV = 2;
    dTV = 0;
    task::sleep(1000);

*/
   
     
    cata.spin(forward, 12, voltageUnits::volt);
      intake.spin(forward, 12, voltageUnits::volt);
      


  }
  if(Red2)
  {
    //AWP 
    spinUp(true);
    wings.open();
    wingsR.open();
    speedCap = 0.2;
    speedCapTurn = 0.5;
    dV = 1.5;
    dTV = 30;
    task::sleep(3000);
  }

  if(Red3){
    
  }

  if(Blue1){
    speedCap = 0.5;
    speedCapTurn = 0.5;
    
    //Move robot to matchloading position
    dV = 5.3;
    dTV = 0;
    task:: sleep(700);
    dV = 0;
    dTV = 133;
    task::sleep(700);
    resetDriveSensors = true;;
    //drop vertical wing down to touch matchload bar and fire cata
    wingsV.open();
    spinUpReverse(true);
    //Adds heading to counteract vibrations rotating the bot
    dTV = 5;
    dV = 0;
    //Controls amount of time it shoots for
    wait(60, sec);
    /*
    dTV = 5;
    dV = 0;
    resetDriveSensors = true;;
    dTV = 5;
    dV = 0;
    resetDriveSensors = true;;
    spinUp(false);
    wingsV.close();
    
    //First Turn
    dV = 0;
    dTV = 63;
    task::sleep(700);
    dTV = 63;
    dV = 0;
    resetDriveSensors = true;
    dV = 3;
    dTV = 0;
    task::sleep(1200);
    dV = 3;
    //dTV = 0;
    //second turn
    dTV = -45;
    task::sleep(300);
    dTV = -45;
    
    resetDriveSensors = true;
    dV = 7;
    dTV = -1;
    task::sleep(2400);
    dV = 7;
    dTV = -1;
    resetDriveSensors = true;
    dV = 0;
    dTV = -50;
    task::sleep(500);
    dV = 0;
    dTV = -50;
    resetDriveSensors = true;
    wings.open();
    dTV = 0;
    dV = 6.66;
    task::sleep(620);
    dTV = 0;
    dV = 6.66;
    resetDriveSensors = true;
    dV = 0;
    dTV = -40;
    task::sleep(400);
    dTV = -40;
    dV = 0;
    speedCap= 1;
     spinUpReverse(true);
    resetDriveSensors= true;
    dV = 2.5;
    dTV = 0;
    task::sleep(250);
    dTV = 0;
    dV = 2.5;
    resetDriveSensors = true;
    dTV = 0;
    dV = -2.5;
    task::sleep(250);
    dTV = 0;
    dV = -2.5;
    resetDriveSensors = true;
    dTV = 0;
    dV = 2.5;
    task::sleep(250);
    dTV = 0;
    dV = 2.5;
    








   
   
    
    resetDriveSensors = true;
   
    dV = 5.66;
    dTV = 0;
    task::sleep(250);
    dV = 5.66;
    dTV = 0;
  
   
    //dV = 3;
   // dTV = 0;
    //task::sleep(1000);
    //dV = 3;
    //dTV = 0;
    */
    
   
  }
  if(Blue2){
    //wings and drive forward
    wings.open();
    task :: sleep(200);
    spinUpReverse(true);
    wait(200, msec);    
    wings.close();
    spinUpReverse(false);
    //first rush
    spinUp(true);
    dV = 4.8;
    dTV = 0;
    task ::sleep(1600);
    resetDriveSensors = true;
    //first drive back
    dV = -3;
    dTV = 0;
    //turn off intake
    spinUp(false);
    task :: sleep(1200);
    //first turn
    resetDriveSensors = true;
    // dV = 0;
    // dTV = +70;
    // spinUpReverse(true);
    // task :: sleep(2000);
    // resetDriveSensors = true;
    // //dTV = 0;
    // //dV = 6;
  }
  if(Blue3){}

  if(Skills)
  {
    // conversion factors;
    
    /* DV = inches/6
      for time (inches * 10)/12;
      */
    /*
    spinUp(true);
    task::sleep(50);
    spinUp(false);


    spinUpReverse(true);
    kP = 0.9;
    dV = 2;
    dTV = 0;
    task::sleep(900);

    kP = 0.118;
    dV = -0.1;
    dTV = 0;
    task::sleep(1000);

    dV = -2;
    dTV = 85;
    task::sleep(1000);

    dV = -2.08;
    dTV = 85;
    task::sleep(400);
    */
    dV = - 6.83;
    dTV = 0;
    task::sleep(34);
    dV = -6.83;
    dTV = 0;

    



    /*int stupidSkills = 0;
    do
    {
      cata.spin(forward, 100, percent);
    
    if(ballDetector.value(analogUnits::mV) <= 2700)
    {
      cata.spin(forward,100,percent);
      //stupidSkills++;

    }
    else if (cataLimit.pressing())
    {
      task::sleep(40);
      cata.stop(brakeType::brake);
      
    }
    
    }
    while(stupidSkills < 10000);

    cata.stop(brakeType::brake);*/
    /*
    task::sleep(1000);

    cata.spin(forward, 70, percent);
    task::sleep(55000);
    cata.stop(brakeType::coast);

    dV = 6;
    dTV = 110;
    task::sleep(2000);
    
    dV = 12;
    dTV = 90;
    task::sleep(3000);

    wings.open();
    wingsR.open();
    dV = 15;
    dTV = 20;
    task::sleep(2000);

    wings.close();
    wingsR.close();
    dV = 13;
    dTV = -20;
    task::sleep(2000);

    wings.open();
    wingsR.open();
    dV = 14;
    dTV = 75;
    task::sleep(2000);

    dV = 11;
    dTV = 30;
    task::sleep(2000);

    dV = 17;
    dTV = 60;
    task::sleep(2000);
    */


    /*

    do

    cata.spin(forward, 100, percent);
    if(cataLimit.pressing())
    {
      //task::sleep(40);
      cata.stop(brakeType::brake);
    }
    if(ballDetector.value(analogUnits::mV) <= 2700)
    {
      cata.spin(forward,100,percent);

    }
    */
    
    
    
  }
  if(Simple)
  {
    speedCap = 0.6;
    //(true);
    dV = 4;
    dTV = 0;
    task::sleep(3000);

    speedCap = 1;
    dV = 3;
    dTV = 0;
    task::sleep(2000);
     

    dV = 4.1;
    dTV = 0;
    task::sleep(3000);
  }

}


void usercontrol(void) {
  enablePID = false;
  while (1) {
    joystickCont();
    intakeCont();
    cataCont();
    autoCata();
  
    wingsCont();
    //assistUp();
    //autoLift();
    
    wait(10, msec);
  }
}

//
// Main will set up the competition functions and callbacks.
//
int main() {
  Brain.Screen.pressed(userTouchCallbackPressed);
  Brain.Screen.released(userTouchCallbackReleased);
  displayButtonControls(0, false);
  // Set up callbacks for autonomous and driver control periods.
  Competition.autonomous(autonomous);
  Competition.drivercontrol(usercontrol);

  // Run the pre-autonomous function.
  pre_auton();
  Brain.Screen.setFont(mono20);
  Brain.Screen.setCursor(2,14);
  Brain.Screen.print("Base Temperature(C):");
  Brain.Screen.setCursor(2,37);

  // Prevent main from exiting with an infinite loop.
  while (true) {
  
    
    //Brain.Screen.print(motorStats());

    wait(100, msec);
  }
}