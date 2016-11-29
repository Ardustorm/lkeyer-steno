use <MCAD/shapes.scad>;

$fn = 100;


//print bed (sort of)
//color([.9,.6,.6])translate([-20,0,0])cube([120,130,.3],center=true);
hingeThickness = .35;


/////////// Print this \\\\\\\\\\\\

difference() {
   union() {
      keyBankWidth([3,-1,0,0,1,-3]);
      translate([-53.5,40,0]) rotate([0,0,0]) color([.8,.8,.8,.9]) keyBankWidth( [2,-2], single=true );
      // to keep ends from lifting
      translate([-34,62.75,0.1]) cube([10,.5,.2],center = true);
      translate([33,61.75,0.1]) cube([6,.5,.2],center = true);
   }
   translate([-34,20,0]) rotate([90,0,0]) cylinder(r= 2, h = 20,center = true);
}

//This module allows the construction of a board using an array to indicate which keys to add extra width to
module keyBankWidth(keys=[0,0,0,0,0,0], sideSpacing=20, frontSpacing=2, single=false) {
   frameThickness = 4;  //how tall the frame is
   frameWidth = 8;      //how wide the frame is in x and y
   hingeLength = 4;     //how long each hinge should be
   frameX1 = 25 + frontSpacing+hingeLength; //x value
   frameX = single ? frameX1 : frameX1 + 25 + hingeLength; //xval based on if two or 1 key
   frameY = sideSpacing*(len(keys) -.1);
   keyWidth = 15;
   keyLength = 25;


   
   difference() {
      union(){
					
	 //Key bank  -- Generate each key
	 translate([0,-(len(keys)-1)*sideSpacing/2  ,0])
	    for( i =[ 0 : len(keys)-1 ] ) {
	       //bottom set (+x)
	       xOffset = single ? -keyLength/2 : 0;
	       translate([xOffset,i*sideSpacing,0])
		  key(rounded=false,length=keyLength, keyWidth,rounding=2,thickness=3, hinge=hingeThickness,
		      extraWidth=keys[i]);
	       //top set (-x)
	       translate([-frontSpacing,i*sideSpacing,0]) rotate([0,0,180]) {
		  if( ! single ) {
		     key(rounded=false,length=keyLength, keyWidth,
			 rounding=2, thickness=3, hinge=hingeThickness, extraWidth=-keys[i]);
		  }
	       }

	    }

	 // frame
	 difference(){
	    //outside
	    translate([0,0,frameThickness/2]) roundedBox(frameX+2*frameWidth,frameY+2*frameWidth/2,frameThickness,5);
	    //inside
	    roundedBox(frameX,frameY,frameThickness+10,3);
		
	 }
      }

      // wire channel
      //Bottom channel
      translate([frameX/2 + frameWidth/2,frameWidth/2,0])
	 rotate([90,0,0]) cylinder(r=2,h=frameY+frameWidth,center=true);
      //Topchannel
      translate([-(frameX/2 + frameWidth/2),frameWidth/2,0])
	 rotate([90,0,0]) {
	 if( ! single ) {
	    cylinder(r=2,h=frameY+frameWidth,center=true);
	 }
      }
   
   }
}


module halfBoard(){
   union(){
      keyFrame();
      translate([46.2,-31.,0]) rotate([0,0,90])keyFrame(numOfKeys=1);
      translate([35,-63.5,1.5]) cube([25,5,3],center=true);
   }
}


module keyFrame(numOfKeys = 6, sideSpacing = 20, frontSpacing = 2, single=false){
   frameThickness = 4;  //how tall the frame is
   frameWidth = 8;      //how wide the frame is in x and y
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
   lengthOfHinge = 5.1;
   wireAttachment = 2; // how wire is attached to end of key 1:wrap, 2:hole&glue
   depthOfHole = 3; // how deep the hole is when wireAttachment=2
   difference() {
      //'base' part of the key
      union() {
	 translate([length/2,extraWidth/2,thickness/2])roundedBox(length,keyWidth+abs(extraWidth),thickness,rounding);
	 //Hinge
	 if(hinge > 0) {
	    translate([(length+5)/2+lengthOfHinge,0,hinge/2])cube([length-5,keyWidth,hinge],center=true);
          
	 }
      }


     
      //dishing
      translate([-1,0,dishRadius+depthOfDish])rotate([0,90,0])cylinder(r = dishRadius, h = length + 5,$fn=400);


      if(wireAttachment == 1) { //hole and wraping around end
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
      else if( wireAttachment == 2 ) {
	 union() {
	    //center hole
	    translate([-.001,0,radiusOfWire+hingeThickness])rotate([0,90,0])cylinder(r=radiusOfWire,h=thickness+2);
	    //front groove
	    //translate([-.5,0,0])rotate([0,10,0])cylinder(r=radiusOfWire,h=radiusOfWire+hingeThickness);
	    //Bottom groove
	    //translate([length*.2,0,-radiusOfWire/2])r otate([0,90,0]) cylinder(r=radiusOfWire,h=length+lengthOfHinge/2);
	 }

      }



   }
}

