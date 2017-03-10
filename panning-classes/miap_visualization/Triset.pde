class Triset { 
  float ax, ay, bx, by, cx, cy;
  
  Triset () {  
    ax = 0;
    ay = 0;
    bx = 0;
    by = 0;
    cx = 0;
    cy = 0;
  } 
  
  void setActiveCoordinate(float idx, float x, float y) {
    if (idx == 0) {
      ax = x;
      ay = y;
    }
    if (idx == 1) {
      bx = x;
      by = y;
    }
    if (idx == 2) {
      cx = x;
      cy = y;
    }
  }
  
  void update(float posX, float posY) {
    line(ax, ay, posX, posY);
    line(bx, by, posX, posY);
    line(cx, cy, posX, posY);

    line(ax, ay, bx, by); 
    line(bx, by, cx, cy);
    line(cx, cy, ax, ay);
  } 
} 