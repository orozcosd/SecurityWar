//Boss.pde
class Boss {
  float x, y;
  float displayW = 140;
  float displayH = 140;
  float speedX = 0.9; // velocidad lateral base
  int health = 200;
  boolean isAlive = true;
  PImage boss;


  // Disparo
  float shootTimer = 0;
  float shootInterval = 1.0; // seconds

  Boss(float startX, float startY) {
    x = startX;
    y = startY;
    // Cargar sprite del boss 
    try {
      boss = loadImage("ske_boss.png"); 
    } catch (Exception e) {
      boss = null;
    }
  }

  void update() {
    if (!isAlive) return;

    // Movimiento lateral
    x += speedX;
    if (x < 20) {
      x = 20;
      speedX = abs(speedX);
    } else if (x + displayW > width - 20) {
      x = width - 20 - displayW;
      speedX = -abs(speedX);
    }

    // Actualizar timer
    float dt = 1.0 / max(1, int(frameRate));
    shootTimer += dt;
    if (health < 100) {
      shootInterval = max(0.45, 1.0 - (100 - health) * 0.005);
    }
  }

  void display() {
    if (!isAlive) return;
    if (boss != null) image(boss, x, y, displayW, displayH);
    else {
      fill(100, 0, 0);
      rect(x, y, displayW, displayH);
    }

    // Barra de vida encima
    float pct = constrain((float)health / 200.0, 0, 1);
    fill(60);
    rect(x, y - 12, displayW, 8);
    fill(0, 200, 0);
    rect(x, y - 12, displayW * pct, 8);
  }

  // Ahora devuelve una lista de balas (central + sides si corresponde)
  ArrayList<Bullet> tryShoot() {
    if (!isAlive) return null;
    if (shootTimer >= shootInterval) {
      shootTimer = 0;
      ArrayList<Bullet> out = new ArrayList<Bullet>();
      // central
      Bullet center = new Bullet(x + displayW/2, y + displayH - 6, 0, 7.5);
      out.add(center);
      // si está más débil, añade balas laterales
      if (health < 100) {
        Bullet left = new Bullet(x + displayW/2 - 28, y + displayH - 6, -1.2, 6.8);
        Bullet right = new Bullet(x + displayW/2 + 28, y + displayH - 6, 1.2, 6.8);
        out.add(left);
        out.add(right);
      }
      return out;
    }
    return null;
  }

  void takeDamage(int d) {
    health -= d;
    if (health <= 0) {
      isAlive = false;
    }
  }
}
