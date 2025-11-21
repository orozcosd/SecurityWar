// SecurityWar.pde
// Estados del juego:
// 0 = START_MENU, 1 = PLAYER_SELECT, 2 = PLAYING, 3 = GAME_OVER,
// 4 = SETTINGS, 5 = WIN, 6 = DIFICULTY_SELECT, 7 = PAUSE, 8 = HELP, 9 = RECORDS

import java.io.RandomAccessFile;
import java.io.File;
import java.io.IOException;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.ArrayList;
import processing.sound.*;

// Imágenes y recursos
PImage btnJugar, btnHelp, btnAjustes, btnSalir, btnMenu, btnHombre, btnMujer;
PImage btnMusicOn, btnMusicOff;
PImage btnRestar, btnDificil, btnFacil, btnMedia, btnVolver, btnRecords, btnSaveRecords;
PImage bg, bg1, bg2;
PImage heart, g_o, win, choosep, choosed;
PImage playerBoy, playerWoman;
PImage logo;
PImage txtpausa, txtajustes, txtayuda, keyAyuda, musica, txtrecords, txtpuntuacion;
PFont pixelFont;
PImage[] enemySpritesGlobal;

int gameState = 0;
int previousState = 0;

// Records
RecordsManager recordsManager;
boolean enteringName = false;
String newRecordName = "";
boolean showSavedMsg = false;
int savedMsgTimer = 0;

// Singleton-like Game instance
Game gameInstance = null;
Game getGame() {
  if (gameInstance == null) {
    gameInstance = new Game(enemySpritesGlobal, heart);
  }
  return gameInstance;
}

void resetGame() {
  gameInstance = new Game(enemySpritesGlobal, heart);
  enteringName = false;
  newRecordName = "";
  showSavedMsg = false;
  savedMsgTimer = 0;

  // Detener sonidos relacionados con pantallas finales y permitir que se reproduzcan otra vez
  if (gameovers != null) {
    try {
      gameovers.stop();
    }
    catch (Exception e) {
    }
  }
  if (wins != null) {
    try {
      wins.stop();
    }
    catch (Exception e) {
    }
  }
  winPlayed = false;
  gameoverPlayed = false;
}

void destroyGame() {
  gameInstance = null;
}

// Música y efectos
SoundFile music, shootSound, gameovers, wins;
boolean musicLoaded = false;
boolean musicOn = true;
boolean winPlayed = false;
boolean gameoverPlayed = false;

void setup() {
  size(800, 600);

  // Fuente pixel art
  pixelFont = createFont("PressStart2P.ttf", 32);
  textFont(pixelFont);
  noSmooth();

  // Inicializar manager de records
  recordsManager = new RecordsManager();
  recordsManager.initFiles();

  // Cargar imágenes
  btnJugar = loadImage("botton_jugar.png");
  btnHelp = loadImage("botton_Help.png");
  btnAjustes = loadImage("botton_ajustes.png");
  btnSalir = loadImage("botton_salir.png");
  btnMenu = loadImage("botton_menu.png");
  btnHombre = loadImage("botton_hombre.png");
  btnMujer = loadImage("botton_mujer.png");
  btnRestar = loadImage("botton_Restar.png");
  btnDificil = loadImage("botton_dificil.png");
  btnFacil = loadImage("botton_facil.png");
  btnMedia = loadImage("botton_media.png");
  btnVolver = loadImage("botton_volver.png");
  btnRecords = loadImage("botton_records.png");
  btnSaveRecords = loadImage("botton_saverecords.png");
  txtrecords = loadImage("txtrecords.png");
  btnMusicOn = loadImage("botton_musicon.png");
  btnMusicOff = loadImage("botton_musicoff.png");
  musica = loadImage("musica.png");
  heart = loadImage("heart.png");
  bg = loadImage("bg.jpg");
  bg1 = loadImage("bgsw1.png");
  bg2 = loadImage("bgsw2.png");
  heart = loadImage("heart.png");
  g_o = loadImage("Game_Over.png");
  win = loadImage("win.png");
  choosep = loadImage("choosep.png");
  choosed = loadImage("choosed.png");
  playerBoy = loadImage("player_boy.png");
  playerWoman = loadImage("player_women.png");
  logo = loadImage("logo.png");
  txtpausa = loadImage("txtpausa.png");
  txtajustes = loadImage("txtajustes.png");
  txtayuda = loadImage("txtayuda.png");
  keyAyuda = loadImage("keyAyuda.png");
  txtpuntuacion = loadImage("txtpuntuacion.png");
  
  enemySpritesGlobal = new PImage[] {
  loadImage("ske_green.png"),
  loadImage("ske_orange.png"),
  loadImage("ske_purple.png"),
  loadImage("ske_red.png"),
  loadImage("ske_blue.png"),
  loadImage("ske_white.png"),
  loadImage("ske_yellow.png")
};


  // Inicializar música
  try {
    music = new SoundFile(this, "music.mp3");
    musicLoaded = true;
    if (musicOn) {
      music.loop();
    }
  }
  catch (Exception e) {
    println("No se pudo cargar la música 'music.mp3' -> " + e);
    musicLoaded = false;
  }
  shootSound = new SoundFile(this, "shoot.mp3");
  gameovers = new SoundFile(this, "gameovers.mp3");
  wins = new SoundFile(this, "wins.mp3");

  // Crear instancia única al final de setup
  resetGame();
  gameInstance = getGame();
}

void draw() {
  background(0);

  switch (gameState) {
  case 0: // MENU PRINCIPAL
    image(bg, 0, 0, width, height);
    imageMode(CENTER);
    image(logo, width / 2, height / 2 - 160, 220, 220);
    imageMode(CORNER);
    image(btnJugar, width / 2 - 100, 300, 200, 60);
    image(btnAjustes, width / 2 - 100, 400, 200, 60);
    image(btnSalir, width / 2 - 100, 500, 200, 60);
    image(btnRecords, width / 2 + 240, 550, 150, 40);
    fill(#1b2e59);
    textAlign(CENTER);
    textFont(pixelFont);
    textSize(20);
    text("¡DEFIENDE EL SISTEMA!", width / 2, height / 2 - 30);
    break;

  case 1: // SELECCIÓN DE JUGADOR
    image(bg1, 0, 0, width, height);
    imageMode(CENTER);
    image(choosep, width / 2, height / 2 - 160, 200, 100);
    imageMode(CORNER);
    image(btnHombre, width / 2 - 250, 350, 200, 60);
    image(btnMujer, width / 2 + 50, 350, 200, 60);
    image(playerBoy, width / 2 - 180, 285, 60, 60);
    image(playerWoman, width / 2 + 120, 280, 60, 60);
    fill(255);
    textAlign(CENTER);
    textFont(pixelFont);
    textSize(16);
    text("¡Se parte de la policia antivirus!", width / 2, height / 2 - 80);
    break;

  case 2: // JUEGO
    if (gameInstance != null) {
      gameInstance.update();
      gameInstance.display();
    } else {
      gameInstance = getGame();
    }
    break;

  case 3: // GAME OVER
    image(bg1, 0, 0, width, height);
    imageMode(CENTER);
    image(g_o, width / 2, height / 2 - 160, 300, 200);
    imageMode(CORNER);
    image(btnRestar, width / 2 - 100, height / 2 + 10, 200, 60);
    image(btnMenu, width / 2 - 100, height / 2 + 90, 200, 60);
    if (!gameoverPlayed) {
      if (gameovers != null) gameovers.play();
      gameoverPlayed = true;
    }
    break;

  case 4: // AJUSTES
    image(bg1, 0, 0, width, height);
    imageMode(CENTER);
    image(txtajustes, width / 2, height / 2 - 160, 200, 100);
    imageMode(CORNER);
    image(btnMusicOn, width / 2 - 150, 300, 100, 100);
    image(btnMusicOff, width / 2 + 30, 300, 100, 100);
    image(musica, width / 2 - 100, 200, 200, 60);
    image(btnHelp, width / 2 - 100, 430, 200, 60);
    image(btnVolver, width / 2 - 100, 500, 200, 60);
    break;

  case 5: // GANASTE
    image(bg1, 0, 0, width, height);
    imageMode(CENTER);
    image(win, width / 2, height / 2 - 200, 250, 200);
    imageMode(CORNER);
    if (!winPlayed) {
      if (wins != null) wins.play();
      winPlayed = true;
    }

    image(txtpuntuacion, width / 2 - 200, height / 2 - 70, 100, 30);

    // Obtener datos del juego
    int baseScore = (gameInstance != null) ? gameInstance.getScore() : 0;
    int elapsed = (gameInstance != null) ? gameInstance.getElapsedSeconds() : 0;
    String diff = (gameInstance != null) ? gameInstance.getDifficulty() : "media";

    // Multiplicadores por dificultad
    MultipliersList diffList = new MultipliersList();
    diffList.add("facil", 1.1);
    diffList.add("media", 1.3);
    diffList.add("dificil", 1.6);

    // Multiplicadores por tiempo
    MultipliersList timeList = new MultipliersList();
    timeList.add("<=30", 1.5);
    timeList.add("<=60", 1.2);
    timeList.add("else", 1.0);

    float diffMult = diffList.applyForDifficulty(diff);
    float timeMult = timeList.applyForTime(elapsed);
    int finalPreviewScore = round(baseScore * diffMult * timeMult);

    fill(255);
    textAlign(LEFT, CENTER);
    textFont(pixelFont);
    textSize(28);
    text(finalPreviewScore, width / 2 - 80, height / 2 - 55);

    image(btnSaveRecords, width / 2 + 150, height / 2 - 70, 100, 30);
    image(btnRestar, width / 2 - 100, height / 2 + 10, 200, 60);
    image(btnMenu, width / 2 - 100, height / 2 + 90, 200, 60);

    if (enteringName) {
      fill(0, 180);
      rect(width / 2 - 160, height / 2 - 20, 320, 80);
      fill(255);
      textAlign(CENTER, CENTER);
      textFont(pixelFont);
      textSize(20);
      text("INGRESA NOMBRE (3 CAR.): " + newRecordName, width / 2, height / 2 + 10);
      textFont(pixelFont);
      textSize(12);
      text("Backspace: borrar | Enter: aceptar", width / 2, height / 2 + 40);
    }

    if (showSavedMsg) {
      fill(255);
      textAlign(CENTER);
      textFont(pixelFont);
      textSize(16);
      text("Puntuación guardada!", width / 2, height / 2 - 120);
      savedMsgTimer++;
      if (savedMsgTimer > 120) {
        showSavedMsg = false;
        savedMsgTimer = 0;
      }
    }
    break;

  case 6: // SELECCIÓN DE DIFICULTAD
    image(bg1, 0, 0, width, height);
    imageMode(CENTER);
    image(choosed, width / 2, height / 2 - 160, 200, 100);
    imageMode(CORNER);
    image(btnFacil, width / 2 - 100, 270, 200, 60);
    image(btnMedia, width / 2 - 100, 350, 200, 60);
    image(btnDificil, width / 2 - 100, 430, 200, 60);
    fill(255);
    textAlign(CENTER);
    textFont(pixelFont);
    textSize(16);
    text("¡Demuestra que tan fuerte eres!", width / 2, height / 2 +250);
    break;

  case 7: // PAUSA
    image(bg1, 0, 0, width, height);
    imageMode(CENTER);
    image(txtpausa, width / 2, height / 2 - 160, 200, 100);
    imageMode(CORNER);
    image(btnRestar, width / 2 - 100, 270, 200, 60);
    image(btnMenu, width / 2 - 100, 350, 200, 60);
    image(btnAjustes, width / 2 - 100, 430, 200, 60);
    image(btnVolver, width / 2 - 100, 520, 200, 60);
    break;

  case 8: // AYUDA
    image(bg1, 0, 0, width, height);
    imageMode(CENTER);
    image(txtayuda, width / 2, height / 2 - 200, 200, 100);
    image(keyAyuda, width / 2, height / 2 + 30, 500, 300);
    imageMode(CORNER);
    image(btnVolver, width / 2 - 100, 520, 200, 60);
    break;

  case 9: // RECORDS
    image(bg1, 0, 0, width, height);
    imageMode(CENTER);
    image(txtrecords, width / 2, height / 2 - 270, 150, 50);
    imageMode(CORNER);

    ArrayList<RecordEntry> top = recordsManager.getTop(10);
    textAlign(LEFT);
    textFont(pixelFont);
    textSize(18);
    int startY = 120;
    int gap = 32;
    for (int i = 0; i < top.size(); i++) {
      RecordEntry r = top.get(i);
      text((i + 1) + ".  " + r.name + "   " + r.score, width / 2 - 120, startY + i * gap);
    }

    image(btnVolver, width / 2 - 100, 500, 200, 60);
    break;
  }
}

void mousePressed() {
  // Menú principal
  if (gameState == 0) {
    if (overButton(width / 2 - 100, 300, 200, 60)) {
      gameState = 1;
      return;
    }
    if (overButton(width / 2 - 100, 400, 200, 60)) {
      previousState = gameState;
      gameState = 4;
      return;
    }
    if (overButton(width / 2 - 100, 500, 200, 60)) {
      exit();
      return;
    }
    if (overButton(width / 2 + 240, 550, 150, 40)) {
      gameState = 9;
      return;
    }
  }

  // Ajustes
  else if (gameState == 4) {
    if (overButton(width / 2 - 100, 430, 200, 60)) {
      gameState = 8;
      return;
    }
    if (overButton(width / 2 - 100, 500, 200, 60)) {
      gameState = previousState;
      return;
    }
    if (overButton(width / 2 - 150, 300, 100, 100)) {
      if (musicLoaded) {
        if (!music.isPlaying()) music.loop();
        musicOn = true;
      } else {
        println("Música no cargada; no se puede encender.");
      }
      return;
    }
    if (overButton(width / 2 + 30, 300, 100, 100)) {
      if (musicLoaded) {
        if (music.isPlaying()) music.stop();
        musicOn = false;
      } else {
        println("Música no cargada; no se puede apagar.");
      }
      return;
    }
  }

  // Selección de jugador
  else if (gameState == 1) {
    if (overButton(width / 2 - 250, 350, 200, 60)) {
      resetGame();
      gameInstance = getGame();
      gameInstance.setPlayerSprite(playerBoy);
      gameState = 6;
      return;
    }
    if (overButton(width / 2 + 50, 350, 200, 60)) {
      resetGame();
      gameInstance = getGame();
      gameInstance.setPlayerSprite(playerWoman);
      gameState = 6;
      return;
    }
  }

  // Selección de dificultad
  else if (gameState == 6) {
    if (gameInstance == null) gameInstance = getGame();
    if (overButton(width / 2 - 100, 270, 200, 60)) {
      gameInstance.setDifficulty("facil");
      gameState = 2;
      return;
    }
    if (overButton(width / 2 - 100, 350, 200, 60)) {
      gameInstance.setDifficulty("media");
      gameState = 2;
      return;
    }
    if (overButton(width / 2 - 100, 430, 200, 60)) {
      gameInstance.setDifficulty("dificil");
      gameState = 2;
      return;
    }
  }

  // Game over
  else if (gameState == 3) {
    if (overButton(width / 2 - 100, height / 2 + 10, 200, 60)) {
      resetGame();
      gameInstance = getGame();
      gameState = 1;
      return;
    }
    if (overButton(width / 2 - 100, height / 2 + 90, 200, 60)) {
      gameState = 0;
      return;
    }
  }

  // Ganaste
  else if (gameState == 5) {
    if (overButton(width / 2 + 150, height / 2 - 70, 100, 30)) {
      enteringName = true;
      newRecordName = "";
      return;
    }
    if (overButton(width / 2 - 100, height / 2 + 10, 200, 60)) {
      resetGame();
      gameInstance = getGame();
      gameState = 1;
      return;
    }
    if (overButton(width / 2 - 100, height / 2 + 90, 200, 60)) {
      gameState = 0;
      return;
    }
  }

  // Ayuda
  else if (gameState == 8) {
    if (overButton(width / 2 - 100, 520, 200, 60)) {
      gameState = 4;
      return;
    }
  }

  // Records
  else if (gameState == 9) {
    if (overButton(width / 2 - 100, 500, 200, 60)) {
      gameState = 0;
      return;
    }
  }

  // Pausa
  else if (gameState == 7) {
    if (overButton(width / 2 - 100, 270, 200, 60)) {
      resetGame();
      gameInstance = getGame();
      gameState = 1;
      return;
    }
    if (overButton(width / 2 - 100, 350, 200, 60)) {
      gameState = 0;
      destroyGame();
      return;
    }
    if (overButton(width / 2 - 100, 430, 200, 60)) {
      previousState = gameState;
      gameState = 4;
      return;
    }
    if (overButton(width / 2 - 100, 520, 200, 60)) {
      gameState = 2;
      return;
    }
  }
}

boolean overButton(int x, int y, int w, int h) {
  return mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;
}

void stop() {
  if (musicLoaded && music != null) music.stop();
  if (wins != null) wins.stop();
  if (gameovers != null) gameovers.stop();
  super.stop();
}

void keyPressed() {
  if ((key == 'p' || key == 'P')) {
    if (gameState == 2) {
      gameState = 7;
      return;
    } else if (gameState == 7) {
      gameState = 2;
      return;
    }
  }

  if (gameState == 2 && gameInstance != null && gameInstance.player != null) {
    gameInstance.player.keyPressed();
  }

  if (enteringName) {
    if (key == BACKSPACE || key == 8) {
      if (newRecordName.length() > 0) {
        newRecordName = newRecordName.substring(0, newRecordName.length() - 1);
      }
    } else if (key == ENTER || key == RETURN) {
      while (newRecordName.length() < 3) newRecordName += " ";

      int baseScore = (gameInstance != null) ? gameInstance.getScore() : 0;
      int elapsed = (gameInstance != null) ? gameInstance.getElapsedSeconds() : 0;
      String diff = (gameInstance != null) ? gameInstance.getDifficulty() : "media";

      MultipliersList diffList = new MultipliersList();
      diffList.add("facil", 1.1);
      diffList.add("media", 1.3);
      diffList.add("dificil", 1.6);

      MultipliersList timeList = new MultipliersList();
      timeList.add("<=30", 1.5);
      timeList.add("<=60", 1.2);
      timeList.add("else", 1.0);

      float diffMult = diffList.applyForDifficulty(diff);
      float timeMult = timeList.applyForTime(elapsed);
      int finalScore = round(baseScore * diffMult * timeMult);

      if (recordsManager != null) {
        recordsManager.saveRecord(newRecordName, finalScore);
        showSavedMsg = true;
        savedMsgTimer = 0;
      }
      enteringName = false;
      newRecordName = "";
    } else {
      char k = key;
      if (Character.isLetterOrDigit(k) && newRecordName.length() < 3) {
        newRecordName += Character.toUpperCase(k);
      }
    }
    return;
  }
}

void keyReleased() {
  if (gameState == 2 && gameInstance != null && gameInstance.player != null) {
    gameInstance.player.keyReleased();
  }
}

// RecordEntry simple container
class RecordEntry {
  String name;
  int score;
  RecordEntry(String name, int score) {
    this.name = name;
    this.score = score;
  }
}

// RecordsManager: archivo secuencial + índice
class RecordsManager {
  String recordsPath;
  String indexPath;
  int RECORD_NAME_BYTES = 3;

  RecordsManager() {
    recordsPath = sketchPath("records.dat");
    indexPath = sketchPath("index.dat");
  }

  void initFiles() {
    try {
      File rf = new File(recordsPath);
      if (!rf.exists()) rf.createNewFile();
      File idx = new File(indexPath);
      if (!idx.exists()) idx.createNewFile();
    }
    catch (IOException e) {
      println("Error initFiles: " + e);
    }
  }

  void saveRecord(String name, int score) {
    if (name == null) name = "NNN";
    name = name.toUpperCase();
    if (name.length() > RECORD_NAME_BYTES) name = name.substring(0, RECORD_NAME_BYTES);
    while (name.length() < RECORD_NAME_BYTES) name += " ";

    try {
      RandomAccessFile raf = new RandomAccessFile(recordsPath, "rw");
      long offset = raf.length();
      raf.seek(offset);
      byte[] nb = name.getBytes("ISO-8859-1");
      raf.write(nb);
      raf.writeInt(score);
      raf.close();

      RandomAccessFile idx = new RandomAccessFile(indexPath, "rw");
      idx.seek(idx.length());
      idx.writeInt(score);
      idx.writeLong(offset);
      idx.close();
    }
    catch (Exception e) {
      println("saveRecord error: " + e);
    }
  }

  ArrayList<RecordEntry> loadAllRecords() {
    ArrayList<RecordEntry> arr = new ArrayList<RecordEntry>();
    try {
      RandomAccessFile idx = new RandomAccessFile(indexPath, "r");
      RandomAccessFile raf = new RandomAccessFile(recordsPath, "r");
      while (idx.getFilePointer() < idx.length()) {
        int sc = idx.readInt();
        long off = idx.readLong();
        raf.seek(off);
        byte[] nb = new byte[RECORD_NAME_BYTES];
        raf.readFully(nb);
        String name = new String(nb, "ISO-8859-1").trim();
        int s2 = raf.readInt();
        arr.add(new RecordEntry(name, s2));
      }
      idx.close();
      raf.close();
    }
    catch (Exception e) {
      println("loadAllRecords error: " + e);
    }
    return arr;
  }

  ArrayList<RecordEntry> getTop(int n) {
    ArrayList<RecordEntry> all = loadAllRecords();
    Collections.sort(all, new Comparator<RecordEntry>() {
      public int compare(RecordEntry a, RecordEntry b) {
        return b.score - a.score;
      }
    }
    );
    ArrayList<RecordEntry> out = new ArrayList<RecordEntry>();
    for (int i = 0; i < all.size() && i < n; i++) out.add(all.get(i));
    return out;
  }
}

// Lista enlazada de multiplicadores (dificultad / tiempo)
class MultiplierNode {
  String key;
  float factor;
  MultiplierNode next;
  MultiplierNode(String key, float factor) {
    this.key = key;
    this.factor = factor;
    this.next = null;
  }
}

class MultipliersList {
  MultiplierNode head;
  MultipliersList() {
    head = null;
  }

  void add(String key, float factor) {
    MultiplierNode n = new MultiplierNode(key, factor);
    if (head == null) head = n;
    else {
      MultiplierNode cur = head;
      while (cur.next != null) cur = cur.next;
      cur.next = n;
    }
  }

  float applyForDifficulty(String difficulty) {
    float mult = 1.0;
    MultiplierNode cur = head;
    while (cur != null) {
      if (cur.key != null && cur.key.equalsIgnoreCase(difficulty)) {
        mult *= cur.factor;
        break;
      }
      cur = cur.next;
    }
    return mult;
  }

  float applyForTime(int elapsedSeconds) {
    float mult = 1.0;
    MultiplierNode cur = head;
    while (cur != null) {
      String k = cur.key;
      if (k != null) {
        if (k.startsWith("<=")) {
          int val = Integer.parseInt(k.substring(2));
          if (elapsedSeconds <= val) {
            mult *= cur.factor;
            break;
          }
        } else if (k.equals("else")) {
          mult *= cur.factor;
          break;
        }
      }
      cur = cur.next;
    }
    return mult;
  }
}
