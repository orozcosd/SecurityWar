// Game.pde

class Game {
  // --- Entidades y colecciones ---
  Player player;
  ArrayList<Enemy> enemies;
  ArrayList<Bullet> bullets;
  ArrayList<Bullet> enemyBullets;
  Boss boss;
  boolean bossSpawned = false;

  // --- Recursos gráficos ---
  PImage[] enemySprites;
  PImage heart;

  // --- Spawning / timing ---
  float spawnTimer = 0;
  float spawnInterval = 1.0;
  int maxEnemiesToSpawn = 12;
  int spawnedCount = 0;

  // --- Dificultad configurable ---
  float minEnemySpeed = 0.6;
  float maxEnemySpeed = 2.0;
  float enemyShootIntervalMin = 1.2;
  float enemyShootIntervalMax = 3.0;
  float bossSpeedMultiplier = 1.0;
  float bossShootInterval = 1.0;
  float bossShotAcceptance = 1.0;

  // --- Estado del juego ---
  int score = 0;
  int collisions = 0;
  int lives = 3;

  // Duración total de la partida (ms)
  int gameDurationMs = 100 * 1000;
  int timerStart = 0;

  // Para calcular delta-time entre updates
  int lastUpdateMs = 0;

  // Indica si la partida terminó en victoria
  boolean gameWon = false;

  // Dificultad actual
  String difficulty = "media";

  // Constructor
  Game() {
    loadResources();

    player = new Player(width / 2, height - 80);
    enemies = new ArrayList<Enemy>();
    bullets = new ArrayList<Bullet>();
    enemyBullets = new ArrayList<Bullet>();

    spawnTimer = 0;
    spawnInterval = 1.0;
    spawnedCount = 0;
    boss = null;
    bossSpawned = false;

    score = 0;
    collisions = 0;
    lives = 3;

    timerStart = millis();
    setDifficulty("media");
  }

  // Carga de imágenes
  void loadResources() {
    enemySprites = new PImage[] {
      loadImage("ske_green.png"),
      loadImage("ske_orange.png"),
      loadImage("ske_purple.png"),
      loadImage("ske_red.png"),
      loadImage("ske_blue.png"),
      loadImage("ske_white.png"),
      loadImage("ske_yellow.png")
    };
    heart = loadImage("heart.png");
  }

  // Ajustar parámetros según dificultad
  void setDifficulty(String difficulty) {
    if (difficulty == null) difficulty = "media";
    String d = difficulty.toLowerCase();
    this.difficulty = d;

    if (d.equals("facil") || d.equals("fácil")) {
      spawnInterval = 1.5;
      maxEnemiesToSpawn = 8;
      minEnemySpeed = 0.6;
      maxEnemySpeed = 1.2;
      enemyShootIntervalMin = 1.6;
      enemyShootIntervalMax = 3.2;
      bossSpeedMultiplier = 0.8;
      bossShootInterval = 1.2;
      bossShotAcceptance = 0.6;
    } else if (d.equals("media")) {
      spawnInterval = 1.0;
      maxEnemiesToSpawn = 12;
      minEnemySpeed = 1.0;
      maxEnemySpeed = 1.6;
      enemyShootIntervalMin = 1.2;
      enemyShootIntervalMax = 2.0;
      bossSpeedMultiplier = 1.0;
      bossShootInterval = 1.0;
      bossShotAcceptance = 0.8;
    } else if (d.equals("dificil")) {
      spawnInterval = 0.7;
      maxEnemiesToSpawn = 20;
      minEnemySpeed = 1.8;
      maxEnemySpeed = 2.0;
      enemyShootIntervalMin = 1.0;
      enemyShootIntervalMax = 1.6;
      bossSpeedMultiplier = 1.4;
      bossShootInterval = 0.75;
      bossShotAcceptance = 1.0;
    } else {
      setDifficulty("media");
    }
  }

  // Getters útiles
  int getScore() {
    return score;
  }

  int getElapsedSeconds() {
    return max(0, (millis() - timerStart) / 1000);
  }

  String getDifficulty() {
    return difficulty == null ? "media" : difficulty;
  }

  // Permite asignar sprite seleccionado del jugador desde SecurityWar
  void setPlayerSprite(PImage s) {
    if (player != null) player.sprite = s;
  }

  // Update principal del juego (llamado cada frame desde SecurityWar)
  void update() {
    int now = millis();
    lastUpdateMs = now;

    if (player != null) player.update();

    // Balas del jugador
    for (int i = bullets.size() - 1; i >= 0; i--) {
      Bullet b = bullets.get(i);
      b.update();
      if (b.isOffScreen()) {
        bullets.remove(i);
        continue;
      }

      boolean removed = false;
      // Colisiones con enemigos
      for (int j = enemies.size() - 1; j >= 0; j--) {
        Enemy e = enemies.get(j);
        if (dist(b.x, b.y, e.x, e.y) < 20) {
          enemies.remove(j);
          bullets.remove(i);
          score += 10;
          removed = true;
          break;
        }
      }
      if (removed) continue;

      // Colisión con boss
      if (boss != null && boss.isAlive) {
        float bx = boss.x + boss.displayW / 2;
        float by = boss.y + boss.displayH / 2;
        float r = max(boss.displayW, boss.displayH) / 2;
        if (dist(b.x, b.y, bx, by) < r) {
          bullets.remove(i);
          boss.takeDamage(10);
          if (!boss.isAlive) {
            gameWon = true;
            gameState = 5; // pantalla "GANASTE" (gameState es global del sketch)
            return;
          }
          continue;
        }
      }
    }

    // Enemigos
    for (int i = enemies.size() - 1; i >= 0; i--) {
      Enemy e = enemies.get(i);
      e.update();
      if (e.isOffScreen()) {
        enemies.remove(i);
        collisions++;
        lives--;
        if (lives <= 0) {
          gameWon = false;
          gameState = 3;
          return;
        }
      } else {
        if (random(1) < 0.0025) {
          Bullet shot = e.shoot();
          if (shot != null) enemyBullets.add(shot);
        }
      }
    }

    // Balas enemigas
    for (int i = enemyBullets.size() - 1; i >= 0; i--) {
      Bullet eb = enemyBullets.get(i);
      eb.update();
      if (eb.isOffScreen()) {
        enemyBullets.remove(i);
        continue;
      }
      if (player != null && dist(eb.x, eb.y, player.x, player.y) < 24) {
        enemyBullets.remove(i);
        collisions++;
        lives--;
        if (player != null) player.knockback();
        if (lives <= 0) {
          gameWon = false;
          gameState = 3;
          return;
        }
      }
    }

    // Spawnear enemigos
    float dt = 1.0 / max(1, int(frameRate));
    spawnTimer += dt;
    if (spawnTimer >= spawnInterval && spawnedCount < maxEnemiesToSpawn) {
      spawnTimer = 0;
      spawnOneEnemy();
    }

    // Spawn boss cuando corresponde
    if (enemies.isEmpty() && spawnedCount >= maxEnemiesToSpawn && !bossSpawned) {
      boss = new Boss(width / 2 - 65, 40);
      boss.speedX *= bossSpeedMultiplier;
      boss.shootInterval = bossShootInterval;
      bossSpawned = true;
    }

    // Lógica del boss
    if (boss != null && boss.isAlive) {
      boss.update();
      ArrayList<Bullet> bshots = boss.tryShoot();
      if (bshots != null) {
        for (Bullet bshot : bshots) {
          if (random(1) < bossShotAcceptance) {
            enemyBullets.add(bshot);
          }
        }
      }
    }
  }

  // Mostrar entidades
  void display() {
    if (player != null) player.display();
    for (Enemy e : enemies) e.display();
    for (Bullet b : bullets) b.display();
    for (Bullet eb : enemyBullets) eb.display();
    if (boss != null && boss.isAlive) boss.display();

    // UI: puntuación
    fill(255);
    textSize(18);
    textAlign(LEFT);
    text("Score: " + score, 16, 24);

    // Vidas
    int displayLives = lives;
    int heartX = width - 140;
    for (int i = 0; i < displayLives; i++) {
      if (heart != null) {
        image(heart, heartX + i * 36, 8, 32, 32);
      } else {
        fill(255, 0, 0);
        ellipse(heartX + i * 36 + 12, 24, 18, 18);
        fill(255);
      }
    }

    // Tiempo restante
    int timeLeftSec = max(0, (gameDurationMs - (millis() - timerStart)) / 1000);
    textAlign(CENTER);
    text("Time: " + timeLeftSec, width / 2, 24);
  }

  // Spawn de un enemigo
  void spawnOneEnemy() {
    float x = random(40, width - 40);
    float y = random(40, 140);
    float spd = random(minEnemySpeed, maxEnemySpeed);

    PImage sprite = null;
    if (enemySprites != null && enemySprites.length > 0) {
      int idx = int(random(enemySprites.length));
      sprite = enemySprites[idx];
    }

    enemies.add(new Enemy(x, y, spd, sprite));
    Enemy e = enemies.get(enemies.size() - 1);
    e.shootInterval = random(enemyShootIntervalMin, enemyShootIntervalMax);
    spawnedCount++;
  }

  // Añadir bala del jugador
  void addPlayerBullet(float x, float y, float vx, float vy) {
    bullets.add(new Bullet(x, y, vx, vy));
  }

  // Registrar que el jugador fue golpeado
  void playerHit() {
    collisions++;
    lives--;
    if (lives <= 0) {
      gameWon = false;
      gameState = 3;
    }
  }

  // Utilidades
  boolean safeLoadImage(String filename) {
    try {
      PImage t = loadImage(filename);
      return t != null;
    } catch (Exception e) {
      return false;
    }
  }

  boolean isGameWon() {
    return gameWon;
  }
}
