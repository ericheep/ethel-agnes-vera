class Triset { 
  float ax, ay, bx, by, cx, cy;
  float g1, g2, g3;
  
  Triset () {  
    ax = 0;
    ay = 0;
    bx = 0;
    by = 0;
    cx = 0;
    cy = 0;
    g1 = 0;
    g2 = 0;
    g3 = 0;
  } 
  
  void setActiveCoordinate(float idx, float x, float y, float g) {
    if (idx == 0) {
      ax = x;
      ay = y;
      g1 = g * 340 + 20;
    }
    if (idx == 1) {
      bx = x;
      by = y;
      g2 = g * 340 + 20;
    }
    if (idx == 2) {
      cx = x;
      cy = y;
      g3 = g * 340 + 20;
    }
  }
  
  void update(float posX, float posY) {
    stroke(330, 360, g1);
    line(ax, ay, posX, posY);
    stroke(330, 360, g2);
    line(bx, by, posX, posY);
    stroke(330, 360, g3);
    line(cx, cy, posX, posY);

    stroke(330, 360, max(g1, g2, g3) * 0.35);
    line(ax, ay, bx, by); 
    line(bx, by, cx, cy);
    line(cx, cy, ax, ay);
  } 
  
  float gain() {
     return max(g1, g2, g3); 
  }
} 