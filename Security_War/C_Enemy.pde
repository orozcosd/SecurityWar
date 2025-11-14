//Enemy.pde
class Enemy {
  float x, y;
  float baseSpeed;
  float vx;            // movimiento horizontal suave 
  PImage sprite;
  boolean alive = true;

  // Disparo: cada enemigo tiene su propio cooldown aleatorio
  float shootTimer = 0;
  float shootInterval; // segundos entre disparos

  // Para oscilación
  float oscillationPhase;
  float oscillationAmp = 12;

  Enemy(float x, float y, float speed, PImage sprite) {
    this.x = x;
    this.y = y;
    this.baseSpeed = speed;
    this.vx = random(-0.6, 0.6);
    this.oscillationPhase = random(TWO_PI);
    this.sprite = sprite;
    this.shootInterval = random(1.2, 3.0);
    this.shootTimer = random(0, shootInterval);
  }

  // Constructor 
  Enemy(float x, float y, float speed, PImage[] sprites) {
    this.x = x;
    this.y = y;
    this.baseSpeed = speed;
    this.vx = random(-0.6, 0.6);
    this.oscillationPhase = random(TWO_PI);
    if (sprites != null && sprites.length > 0) {
      this.sprite = sprites[int(random(sprites.length))];
    } else {
      this.sprite = null;
    }
    this.shootInterval = random(1.2, 3.0);
    this.shootTimer = random(0, shootInterval);
  }

  void update() {
    if (!alive) return;
    // Movimiento vertical
    y += baseSpeed * 0.6;

    // Oscilación horizontal
    oscillationPhase += 0.03;
    x += sin(oscillationPhase) * 0.6 + vx * 0.3;

    // Mantener en márgenes horizontales
    x = constrain(x, 20, width - 20);

    // Actualizar timer
    float dt = 1.0 / max(1, int(frameRate));
    shootTimer += dt;
  }

  void display() {
    if (!alive) return;

    if (sprite != null) {
      image(sprite, x - 20, y - 20, 40, 40);
    } else {
      fill(200, 50, 50);
      rect(x - 18, y - 18, 36, 36);
    }
  }

  // Retorna bala si es momento
  Bullet shoot() {
    if (!alive) return null;

    if (shootTimer >= shootInterval) {
      shootTimer = 0;
      if (gameInstance != null && gameInstance.player != null) {
        float dx = gameInstance.player.x - x;
        float dy = gameInstance.player.y - y;
        float angle = atan2(dy, dx);

        float speed = 5.5;
        float vx = cos(angle) * 0.3;
        float vy = speed;

        return new Bullet(x, y + 18, vx, vy);
      } else {
        return new Bullet(x, y + 18, 0, 5);
      }
    }
    return null;
  }

  boolean isOffScreen() {
    return y > height + 20;
  }
}
