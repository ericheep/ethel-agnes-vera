class Node { 
  float xPos, yPos;  
  float gain;
  
  Node () {  
    xPos = 0;
    yPos = 0;
    gain = 0;
  } 
  
  void setGain(float g) {
     gain = g;
  }
  
  void setCoordinate(float x, float y) {
     xPos = x;
     yPos = y;
  }
  
  void update(float scalar) { 
    ellipse(xPos, yPos, gain * scalar + 3.0, gain * scalar + 3.0); 
  } 
} 