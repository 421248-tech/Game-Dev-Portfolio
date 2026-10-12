class PowerUp {
  int x, y, w, h, speed;
  PImage p1;

  PowerUp(int x, int y) {
    this.x = x;
    this.y = y;
    w = 40;
    h = 40;
    speed = int(random(2, 5));
    
    p1 = loadImage("powerup.png");
    
    if (p1 != null) {
      p1.format = ARGB;
      p1.loadPixels();
      for (int i = 0; i < p1.pixels.length; i++) {
        float r = red(p1.pixels[i]);
        float g = green(p1.pixels[i]);
        float b = blue(p1.pixels[i]);
        if (r > 200 && g > 200 && b > 200) {
          p1.pixels[i] = color(0, 0);
        }
      }
      p1.updatePixels();
    }
  }

  void display() {
    if (p1 != null) {
      imageMode(CENTER);
      image(p1, x, y, w, h);
    } else {
      fill(255, 215, 0);
      ellipse(x, y, w, h);
    }
  }

  void move() {
    y = y + speed;
  }

  boolean isOffScreen() {
    return y > height + h / 2;
  }

  boolean intersect(Ship s) {
    float d = dist(s.x, s.y, x, y);
    return d < 30 + (w / 2);
  }
}
