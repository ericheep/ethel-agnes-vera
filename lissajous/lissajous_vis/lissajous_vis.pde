// lissajous_vis.pde

void setup() {
  size(500, 500);
  ellipseMode(CENTER);
}

void draw() {
  float x = 0.5;
  float y = 0.5;
  background(0);
  fill(255, 255, 255);
  ellipse(width/x, height/y, 30, 30); 
  fill(255, 255, 255);

}