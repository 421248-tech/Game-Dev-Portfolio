// Connor DeWeerd | Sept 16 2026 | SpaceGame
import processing.sound.*;

// Audio files
SoundFile bgMusic;
SoundFile laser01;
SoundFile hitSound;
SoundFile powerupSound;
SoundFile gameOverSound;

// Entity lists
ArrayList<Rock> rocks = new ArrayList<Rock>();
ArrayList<PowerUp> powUps = new ArrayList<PowerUp>();
ArrayList<Laser> lasers = new ArrayList<Laser>();
Ship ship01;
Timer rDist;
Timer pDist;

// Asset variables
PImage bg;

// State constants
final int START = 0;
final int PLAYING = 1;
final int GAME_OVER = 2;
int gameState = START;

// Trackers
int rockCount = 0;   
int rocksPassed = 0; 
int health = 100;    
int score = 0;       

void setup() {
  size(800, 1000);
  
  // Safely attempt to load background image
  try {
    bg = loadImage("background.png");
  } catch (Exception e) {
    println("Background image file 'background.png' missing or invalid.");
  }
  
  // Instantiate ship
  ship01 = new Ship(width/2, height/2);
  
  // Timers for spawning entities
  rDist = new Timer(1500);
  rDist.start();
  
  pDist = new Timer(4000);
  pDist.start();
  
  // Safely load all sound effects
  try {
    laser01 = new SoundFile(this, "l1.mp3");
  } catch (Exception e) {
    println("Laser sound file 'l1.mp3' missing or invalid.");
    laser01 = null;
  }

  try {
    hitSound = new SoundFile(this, "hit.wav");
  } catch (Exception e) {
    println("Hit sound file 'hit.wav' missing or invalid.");
    hitSound = null;
  }

  try {
    powerupSound = new SoundFile(this, "powerup.wav");
  } catch (Exception e) {
    println("Powerup sound file 'powerup.wav' missing or invalid.");
    powerupSound = null;
  }

  try {
    gameOverSound = new SoundFile(this, "gameover.wav");
  } catch (Exception e) {
    println("Game Over sound file 'gameover.wav' missing or invalid.");
    gameOverSound = null;
  }

  // Safely load background music and start loop
  try {
    bgMusic = new SoundFile(this, "background.mp3");
    if (bgMusic != null) {
      bgMusic.loop();
    }
  } catch (Exception e) {
    println("Background music file 'background.mp3' missing or invalid.");
    bgMusic = null;
  }
}

void draw() {
  // Render background or fallback color
  if (bg != null) {
    imageMode(CORNER);
    image(bg, 0, 0, width, height);
  } else {
    background(20);
  }

  // ---------------- STATE 0: START SCREEN ----------------
  if (gameState == START) {
    fill(255);
    textSize(40);
    textAlign(CENTER, CENTER);
    text("SPACE GAME", width / 2, height / 2 - 100);

    rectMode(CENTER);
    fill(50, 150, 255);
    rect(width / 2, height / 2, 200, 60, 10);

    fill(255);
    textSize(24);
    text("START", width / 2, height / 2);

  // ---------------- STATE 1: PLAYING ----------------
  } else if (gameState == PLAYING) {
    
    // Check Game Over conditions
    if (rocksPassed >= 10 || health <= 0) {
      gameState = GAME_OVER;
      
      if (bgMusic != null) {
        bgMusic.stop();
      }
      if (gameOverSound != null) {
        gameOverSound.play();
      }
      return;
    }

    // Spawn rocks on timer
    if (rDist.isFinished()) {
      rocks.add(new Rock(int(random(width)), -60));
      rockCount++;
      rDist.start();
    }

    // Spawn powerups on timer
    if (pDist.isFinished()) {
      powUps.add(new PowerUp(int(random(width)), -60));
      pDist.start();
    }

    // Move and display player ship
    ship01.move(mouseX, mouseY);
    ship01.display();

    // Update lasers
    for (int i = lasers.size() - 1; i >= 0; i--) {
      Laser l = lasers.get(i);
      l.move();
      l.display();
      if (l.isOffScreen()) {
        lasers.remove(i);
      }
    }

    // Update rocks and handle collisions
    for (int i = rocks.size() - 1; i >= 0; i--) {
      Rock r = rocks.get(i);
      r.move();
      r.display();

      // Check Laser vs Rock Collision
      for (int j = lasers.size() - 1; j >= 0; j--) {
        Laser l = lasers.get(j);
        float laserToRockDist = dist(l.x, l.y, r.x, r.y);
        
        if (laserToRockDist < (r.w / 2) + 5) {
          if (hitSound != null) {
            hitSound.play();
          }
          score += 10;
          lasers.remove(j);
          rocks.remove(i);
          break;
        }
      }

      // Skip remaining checks if rock was destroyed by laser
      if (i >= rocks.size()) {
        continue;
      }

      // Check Ship vs Rock Collision
      float d = dist(ship01.x, ship01.y, r.x, r.y);
      if (d < 30 + (r.w / 2)) {
        health -= 20;
        if (hitSound != null) {
          hitSound.play();
        }
        rocks.remove(i);
        continue;
      }

      // Check if rock went off screen
      if (r.isOffScreen()) {
        rocksPassed++;
        rocks.remove(i);
      }
    }

    // Update powerups and handle player pickup safely
    for (int i = powUps.size() - 1; i >= 0; i--) {
      PowerUp p = powUps.get(i);
      p.move();
      p.display();

      if (p.intersect(ship01)) {
        if (powerupSound != null) {
          try {
            powerupSound.play();
          } catch (Exception e) {
            println("Error playing powerup sound: " + e.getMessage());
          }
        }
        health = min(100, health + 20);
        powUps.remove(i);
        continue;
      }

      if (p.isOffScreen()) {
        powUps.remove(i);
      }
    }

    // Display Heads-Up Display (HUD)
    fill(255);
    textSize(20);
    textAlign(LEFT, TOP);
    text("Health: " + health, 20, 20);
    text("Rocks Passed: " + rocksPassed + " / 10", 20, 50);
    text("Score: " + score, 20, 80);

  // ---------------- STATE 2: GAME OVER ----------------
  } else if (gameState == GAME_OVER) {
    fill(255, 50, 50);
    textSize(50);
    textAlign(CENTER, CENTER);
    text("GAME OVER", width / 2, height / 2 - 20);

    fill(255);
    textSize(20);
    text("Final Score: " + score + " | Rocks Passed: " + rocksPassed, width / 2, height / 2 + 30);
  }
}

void mousePressed() {
  if (gameState == START) {
    if (mouseX >= width/2 - 100 && mouseX <= width/2 + 100 &&
        mouseY >= height/2 - 30 && mouseY <= height/2 + 30) {
      gameState = PLAYING;
    }
  } else if (gameState == PLAYING && mouseButton == LEFT) {
    lasers.add(new Laser(ship01.x, ship01.y - 20));
    if (laser01 != null) {
      laser01.play();
    }
  }
}
