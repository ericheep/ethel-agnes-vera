class Node { 
  float xPos, yPos;  
  float gain, brightness;
  float scaledBrightness;
  boolean m_active;
  
  Node () {  
    xPos = 0;
    yPos = 0;
    gain = 0;
  } 
  
  void setBrightness(float b) {
     brightness = b;
     scaledBrightness = b * 280 + 20; 
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
    stroke(330, 360, scaledBrightness + gain * 60);
    ellipse(xPos, yPos, gain * multiplier + 2.0, gain * multiplier + 2.0); 
  } 
} 