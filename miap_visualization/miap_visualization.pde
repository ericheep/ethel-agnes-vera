// miap-visualization.pde
// Eric Heep

import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress myRemoteLocation;

int voices = 3;
float posX[] = new float[3];
float posY[] = new float[3];
float offset = 0.0;

boolean[] trisetActive = new boolean[3];

Node[] nodes;
Triset[] triset;

void setup() {
  background(0);
  frameRate(60);
  fullScreen();
  colorMode(HSB, 360); 
  noCursor();
  offset = (width - height) * 0.5 - ((height/7.5) * 0.5);
  
  for (int i = 0; i < voices; i++) {
    trisetActive[i] = false;
    posX[i] = -2.0;
    posY[i] = -2.0;
  }

  nodes = new Node[49];
  for (int i = 0; i < nodes.length; i++) {
    nodes[i] = new Node();
  }

  triset = new Triset[3];
  for (int i = 0; i < 3; i++) {
    triset[i] = new Triset();
  }

  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);

}

void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/pos") == true) {
    int voice = msg.get(0).intValue();
    posX[voice] = msg.get(1).floatValue();
    posY[voice] = msg.get(2).floatValue();
  }
  if (msg.checkAddrPattern("/coord") == true) {
    int idx = msg.get(0).intValue();
    float xPos = msg.get(1).floatValue() * height + offset;
    float yPos = msg.get(2).floatValue() * height;
    nodes[idx].setCoordinate(xPos, yPos);
  }
  if (msg.checkAddrPattern("/gain") == true) {
    int idx = msg.get(0).intValue();
    float gain = msg.get(1).floatValue();
    nodes[idx].setGain(gain);
  }
  if (msg.checkAddrPattern("/activeCoord") == true) {
    int trisetID = msg.get(0).intValue();
    int nodeID = msg.get(1).intValue();
    int localNode = msg.get(2).intValue();
    float x = msg.get(3).floatValue() * height + offset;
    float y = msg.get(4).floatValue() * height;
    float g = nodes[nodeID].gain * nodes[nodeID].brightness;
    triset[trisetID].setActiveCoordinate(localNode, x, y, g);
  }
  if (msg.checkAddrPattern("/active") == true) {
    int voice = msg.get(0).intValue();
    if (msg.get(1).intValue() == 1) {
      trisetActive[voice] = true;
    } else {
      trisetActive[voice] = false;
    }
  }
  if (msg.checkAddrPattern("/nodeActive") == true) {
    int nodeID = msg.get(0).intValue();
    float value = msg.get(1).floatValue();
    nodes[nodeID].setBrightness(value);
  }
}

void draw() {
  noStroke();
  strokeWeight(2);
  fill(360, 360, 0, 180);
  rect(0, 0, width, height);

  translate(width/2.0, height/2.0);
  scale(1.5);
  translate(-width/2.0, -height/2.0);
  
  for (int i = 0; i < 3; i++) {
    if (trisetActive[i]) {
      triset[i].update(posX[i] * height + offset, posY[i] * height);
    }
  }
   
  for (int i = 0; i < nodes.length; i++) {
    nodes[i].update(90);
  }
   
  for (int i = 0; i < 3; i++) {
    stroke(330, 360, triset[i].gain());
    ellipse(posX[i] * height + offset, posY[i] * height, 2.5, 2.5);
  }
}