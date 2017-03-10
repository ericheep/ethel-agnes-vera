// miap-visualization.pde
// Eric Heep

import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress myRemoteLocation;

float posX;
float posY;
boolean trisetActive = false;

Node[] nodes;
Triset triset;

void setup() {
  background(0);
  frameRate(60);
  //fullScreen();
  size(800, 800);
  
  nodes = new Node[35];
  for (int i = 0; i < nodes.length; i++) {
     nodes[i] = new Node(); 
  }
  
  triset = new Triset();
  
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);
  colorMode(HSB, 360); 
  noCursor();
}

void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/pos") == true) {
    posX = msg.get(0).floatValue();
    posY = msg.get(1).floatValue();
  }
  if (msg.checkAddrPattern("/coord") == true) {
    int idx = msg.get(0).intValue();
    float xPos = msg.get(1).floatValue() * width;
    float yPos = msg.get(2).floatValue() * height;
    nodes[idx].setCoordinate(xPos, yPos);
  }
  if (msg.checkAddrPattern("/gain") == true) {
    int idx = msg.get(0).intValue();
    float gain = msg.get(1).floatValue();
    nodes[idx].setGain(gain);
  }
  if (msg.checkAddrPattern("/activeCoord") == true) {
    int idx = msg.get(0).intValue();
    float x = msg.get(1).floatValue() * width;
    float y = msg.get(2).floatValue() * height;
    triset.setActiveCoordinate(idx, x, y);
  }
  if (msg.checkAddrPattern("/active") == true) {
    if (msg.get(0).intValue() == 1) {
      trisetActive = true;
    } else {
      trisetActive = false;
    }
  }
}


void draw() {
  noStroke();
  strokeWeight(3);
  fill(0, 0, 0, 55);
  rect(0, 0, width, height);
  stroke(330, 360, 360);
  ellipse(posX * width, posY * height, 10, 10);
  for (int i = 0; i < nodes.length; i++) {
     nodes[i].update(120); 
  }
  if (trisetActive) {
    triset.update(posX * width, posY * height);
  }
}