//Player.pde
class Player {
  float x, y;
  float baseSpeed = 5;
  float speed;
  PImage sprite;
  int lives = 3;

  // Control de disparo (cooldown)
  int lastShotFrame = 0;
  int shootCooldownFrames = 10; // frames entre disparos

  Player(float startX, float startY) {
    x = startX;
    y = startY;
    speed = baseSpeed;
    sprite = null;
  }

  void update() {
    // Movimiento horizontal simple
    if (keyPressed && (keyCode == LEFT || key == 'a' || key == 'A')) {
      x -= speed;
    } else if (keyPressed && (keyCode == RIGHT || key == 'd' || key == 'D')) {
      x += speed;
    }

    x = constrain(x, 20, width - 20);
  }

  void display() {
    if (sprite != null) image(sprite, x - 24, y - 24, 48, 48);
    else {
      fill(50, 100, 200);
      rect(x - 20, y - 12, 40, 24);
    }
  }

void shoot() {
  if (frameCount - lastShotFrame >= shootCooldownFrames) {
    lastShotFrame = frameCount;
    if (gameInstance != null) {
      gameInstance.addPlayerBullet(x, y - 18, 0, -8);
      if (shootSound != null) {
        shootSound.play();
      }
    }
  }
}


  void keyPressed() {
    if (key == ' ' || key == 'x' || key == 'X') {
      shoot();
    }
  }

  void keyReleased() {
    // no-op por ahora
  }

  void knockback() {
    x = width / 2;
  }

  void resetSpeed() {
    speed = baseSpeed;
  }
}
