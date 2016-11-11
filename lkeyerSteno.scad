include <MCAD/shapes.scad>;

$fn = 100;



//translate([10,0,0])cube([100,120,.3],center=true);
hingeThickness = .45;

//actual part to print 
halfBoard();



union(){
     //key(rounded=true,length=25, keyWidth=15,rounding=2,thickness=3, hinge=.6, extraWidth=2);
     }


module halfBoard(){
     union(){
	  keyFrame();
	  translate([46.2,-31.,0]) rotate([0,0,90])keyFrame(numOfKeys=1);
	  translate([35,-63.5,1.5]) cube([25,5,3],center=true);
     }
}

module keyFrame(numOfKeys = 6, sideSpacing = 20, frontSpacing = 2){
     frameThickness = 3;  //how tall the frame is
     frameWidth = 5;      //how wide the frame is in x and y
     hingeLength = 4;     //how long each hinge should be
     frameX = 25*2+frontSpacing+hingeLength*2;
     frameY = sideSpacing*(numOfKeys+.1);
     union(){
	  difference(){
	       translate([0,0,frameThickness/2])roundedBox(frameX+2*frameWidth,frameY+2*frameWidth,frameThickness,5);
	       roundedBox(frameX,frameY,frameThickness+10,3);
	  }
	  //the two banks of keys, facing each other
	  translate([frontSpacing/2,0,0])keyBank(numOfKeys,sideSpacing);
	  translate([-frontSpacing/2,0,0])mirror([1,0,0])keyBank(numOfKeys,sideSpacing);
     }
}

module keyBank(number=6, spacing = 20){
     /*Generates a set of keys with specified spacing*/
     translate([0,-(number*spacing)/2 +spacing/2 ,0])
	  for(i= [0:spacing:(number-1)*spacing])
     {
	  translate([0,i,0]) key();
     }
}


module key(rounded=false,length=25, keyWidth=15,rounding=2,thickness=3, hinge=.4,extraWidth=0){
     /*generates a single key
        length is the vertical distance of the key
        keyWidth is the horizontal length of the key
        rounded true if key should be rounded
        rounding radius of curve
        thickness how thick the top part of the key should be
        hinge the thickness of the hinge, set to 0 to disable
        extraWidth makes keyWider negative numbers changes the side its on*/
     dishRadius = 35; //how big of a cylinder is used to create curve
     depthOfDish = 2.5; //how deep the resulting curve should be
     radiusOfWire = .7; //radius for the holes that have bare copper wire
     radiusOfInsulation = 1.2;//radius for the parts that have insulation still
     lengthOfHinge = 7;
     difference(){
	  //'base' part of the key
	  union(){
	       translate([length/2,extraWidth/2,thickness/2])roundedBox(length,keyWidth+abs(extraWidth),thickness,rounding);
	       //Hinge
	       if(hinge > 0){
		    translate([(length+5)/2+lengthOfHinge,0,hinge/2])cube([length-5,keyWidth,hinge],center=true);
		    
	       }
	  }


	  
	  //dishing
	  translate([-1,0,dishRadius+depthOfDish])rotate([0,90,0])cylinder(r = dishRadius, h = length + 5,$fn=400);

	  
	  //holes for the wire
	  union(){
	       //front groove
	       translate([-.5,0,-1])rotate([0,10,0])cylinder(r=radiusOfWire,h=thickness+2);
	       //Top groove
	             translate([0,0,thickness-radiusOfWire])rotate([0,90,0])cylinder(r=radiusOfWire,h=thickness+2);
	       //center hole
	       translate([length*.2,0,-1])rotate([0,0,0])cylinder(r=radiusOfWire,h=thickness+2);
	  }



     }
}

