class Node { 
  float xPos, yPos;  
  float gain;
  boolean m_active;
  color nodeColor;
  
  Node () {  
    xPos = 0;
    yPos = 0;
    gain = 0;
    nodeColor = color(330, 360, 90);
  } 
  
  void setBrightness(float b) {
     float scaledBrightness = b * 270 + 90; 
     nodeColor = color(330, 360, scaledBrightness); 
  }
  
  void setGain(float g) {
     gain = g;
  }
  
  float getGain() {
     return gain; 
  }
  
  void setCoordinate(float x, float y) {
     xPos = x;
     yPos = y;
  }
  
  void active(boolean a) {
     a = m_active; 
  }
  
  void update(float multiplier) { 
    stroke(nodeColor);
    ellipse(xPos, yPos, gain * multiplier + 3.0, gain * multiplier + 3.0); 
  } 
} 