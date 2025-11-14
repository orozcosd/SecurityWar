//Bullet.pde
class Bullet {
  float x, y;
  float vx, vy;
  boolean fromPlayer = true;
  boolean alive = true;

  Bullet(float x, float y, float vx, float vy) {
    this.x = x;
    this.y = y;
    this.vx = vx;
    this.vy = vy;
    // si vy negativo => bala del jugador (sube)
    this.fromPlayer = (vy < 0);
  }

  void update() {
    x += vx;
    y += vy;
  }

  void display() {
    fill(255, 255, 0);
    noStroke();
    ellipse(x, y, 6, 12);
  }

  boolean isOffScreen() {
    return (y < -20 || y > height + 20);
  }
}
