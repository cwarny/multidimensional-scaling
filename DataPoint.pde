class DataPoint {
  
  PVector pos;
  float[] data;
  String label;
  
  DataPoint(int itemCount) {
    pos = new PVector(random(width), random(height));
    data = new float[itemCount];
  }
  
  void update(PVector gradient, float rate) {
//    pos.sub(PVector.mult(gradient, rate));
    pos.x -= rate * gradient.x;
    pos.y -= rate * gradient.y;
  }
  
  void render() {
    pushMatrix();
      translate(pos.x, pos.y);
      ellipse(0,0,5,5);
      text(label, 0, 0);
    popMatrix();
  }
  
}
