class Laser {
  int x, y, w, h, speed;

  Laser(int x, int y) {
    this.x = x;
    this.y = y;
    this.w = 4;
    this.h = 15;
    this.speed = 7;
  }

  void display() {
    fill(0, 255, 255);
    noStroke();
    rectMode(CENTER);
    rect(x, y, w, h);
  }

  void move() {
    y = y - speed;
  }

  boolean isOffScreen() {
    return y < -h;
  }
}
