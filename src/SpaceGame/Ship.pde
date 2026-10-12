class Ship {
  int x, y;
  PImage s1;

  Ship(int x, int y) {
    this.x = x;
    this.y = y;
    
    try {
      s1 = loadImage("Ship.png");
    } catch (Exception e) {
      println("Ship image missing.");
    }
  }

  void display() {
    imageMode(CENTER);
    if (s1 != null) {
      image(s1, x, y);
    } else {
      fill(0, 200, 255);
      triangle(x, y - 20, x - 15, y + 15, x + 15, y + 15);
    }
  }

  void move(int tempX, int tempY) {
    x = tempX;
    y = tempY;
  }
}
