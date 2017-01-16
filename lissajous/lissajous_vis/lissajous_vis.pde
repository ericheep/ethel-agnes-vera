// lissajous_vis.pde

float x = 0.5; 
float y = 0.5;

import oscP5.*;
import netP5.*;
OscP5 oscP5;

void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/l") == true) {
    x = msg.get(0).floatValue();
    y = msg.get(1).floatValue();
  }
}

void setup() {
  size(500, 500);
  ellipseMode(CENTER);
  frameRate(60);
  oscP5 = new OscP5(this, 12001);
}

void draw() {
  fill(0, 0, 0, 15);
  rect(0, 0, width, height);
  fill(30, 255, 175);
  ellipse(width * x, height * y, 4, 4); 
}