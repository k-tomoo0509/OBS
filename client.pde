import processing.net.*;
//client
int n;
int playId = 0;
int buf = 0;
int playIdcount = 0;
int shotCount = 0;
boolean gage = false;
color bg1 = color(30, 10, 75);
color bg2 = color(20, 140, 250);


class Player {
  private int id, lv, shotLv, HPLv, GageLv;
  private float cx, cy, angle, cBt;
  private boolean [] shots;
  private float [] sx;
  private float [] sy;
  private int hp;
  private boolean cB;
  private int GageTime;

  Player(int id, int lv, int shotLv, int HPLv, int GageLv, float cx, float cy, float angle, boolean [] shots, float [] sx, float [] sy,
    int hp, int sn, int time, boolean cB, float cBt) {
    this.id = id;
    this.lv = lv;
    this.shotLv = shotLv;
    this.HPLv = HPLv;
    this.GageLv = GageLv;
    this.cx = cx;
    this.cy = cy;
    this.angle = angle;
    this.shots = shots;
    this.sx = sx;
    this.sy = sy;
    this.hp = hp;
    this.cB = cB;
    this.GageTime = time;
    n = sn;
    this.cBt = cBt;
  }

  void draw() {
    int size = 20;
    noStroke();
    fill(140,70,40);
    final float x1 = size * cos(this.angle) + cx;
    final float y1 = size * sin(this.angle) + cy;
    final float x2 = size * cos(this.angle + radians(150)) + cx;
    final float y2 = size * sin(this.angle + radians(150)) + cy;
    final float x3 = size * cos(this.angle - radians(150)) + cx;
    final float y3 = size * sin(this.angle - radians(150)) + cy;
    triangle(x1, y1, x2, y2, x3, y3);
    text("HP:"+hp, max(x1, x2, x3), max(y1, y2, y3));
    text("Lv:"+lv, min(x1, x2, x3), min(y1, y2, y3));
    countId();
    judgeMyId();
    shotting();
    circleBall(x1, x2, x3, y1, y2, y3);
  }
  private void countId() {
    if (playIdcount == 0) {
      if (playId != buf) {
        playId = buf;
      }
      playIdcount++;
    }
  }
  private void judgeMyId() {
    if (this.id == playId) {
      fill(255);
      textSize(20);
      text("GAGE:", 50, 50);
      rect(51, 51, 102, 12);
      text("shotLv:"+shotLv, 20, 150);
      text("HPLv:"+HPLv, 20, 175);
      text("GageLv:"+GageLv, 20, 200);
      if (this.GageTime >= 20) {
        gage = true;
      } else {
        gage = false;
      }
      if (gage) {
        fill(255, 0, 0);
        rect(52, 52, 100, 10);
      } else {
        fill(0);
        rect(52, 52, 5*this.GageTime, 10);
      }
    }
  }
  private void shotting () {
    fill(0);
    for (int i = 0; i<shots.length; i++) {
      if (this.shots[i]) {
        ellipse(this.sx[i], this.sy[i], 15, 15);
      }
    }
  }
  private void circleBall(float x1, float x2, float x3, float y1, float y2, float y3) {
    if (this.cB) {
      final float zx = (x1+x2+x3)/3;
      final float zy = (y1+y2+y3)/3;
      if (shotLv >= 1) {
        ellipse(zx+60*cos(this.cBt), zy+60*sin(this.cBt), 15, 15);
        if (shotLv >= 2) {
          ellipse(zx-60*cos(this.cBt), zy-60*sin(this.cBt), 15, 15);
        }
      }
    }
  }
}

Client client;
ArrayList<Player> players = new ArrayList();

void setup() {
  size(800, 800);
  client = new Client(this, "127.0.0.1", 5204);
}

void draw() {
  background(255);
  for (float i = 0; i < height; i += 5) {
    color c = lerpColor(bg1, bg2, i/height);
    fill(c);
    rect(0, i, width, 5);
  }
  if (!client.active()) {
    textSize(100);
    text("GAMEOVER", width/5, height/2);
  } else {
    synchronized(players) {
      for (Player player : players) {
        if (buf < player.id ) {
          buf = player.id;
        }
      }
      for (Player player : players) {
        player.draw();
      }
    }
  }

  println("BUF:"+buf);
  println("PLAYID:"+playId);
}


void keyPressed() {
  if (key == CODED) {
    JSONObject message = null;
    if (keyCode == RIGHT) {
      message = new JSONObject();
      message.setString("direction", "right");
    } else if (keyCode == LEFT) {
      message = new JSONObject();
      message.setString("direction", "left");
    } else if (keyCode == CONTROL) {
      message = new JSONObject();
      message.setString("action", "shot"+shotCount);
      shotCount++;
      if (shotCount%n==0) {
        shotCount = 0;
      }
    } else if (keyCode == SHIFT) {
      message = new JSONObject();
      message.setString("action", "speed-up");
    }
    if (message != null) {
      client.write(message.toString());
      client.write('\0');
    }
  }
  if (gage) {
    JSONObject message = null;
    if (key == 'a') {
      message = new JSONObject();
      message.setString("action", "heal");
    } else if (key == 's') {
      message = new JSONObject();
      message.setString("action", "cB");
    }
    if (message != null) {
      client.write(message.toString());
      client.write('\0');
    }
  }
}

void keyReleased() {
  if (key == CODED) {
    JSONObject message = null;
    if (keyCode == SHIFT) {
      message = new JSONObject();
      message.setString("action", "speed-reset");
    }
    if (message != null) {
      client.write(message.toString());
      client.write('\0');
    }
  }
}

void clientEvent(Client client) {
  String payload = client.readStringUntil('\0');
  if (payload != null) {
    JSONObject message = parseJSONObject(payload.substring(0, payload.length() - 1));
    JSONArray playerArray = message.getJSONArray("players");
    synchronized(players) {
      players.clear();
      for (int i = 0; i < playerArray.size(); ++i) {
        JSONObject item = playerArray.getJSONObject(i);
        final int id = item.getInt("id");
        final int lv = item.getInt("level");
        final int shotLv = item.getInt("shotLv");
        final int HPLv = item.getInt("HPLv");
        final int GageLv = item.getInt("GageLv");
        final float x = item.getFloat("x");
        final float y = item.getFloat("y");
        final float angle = item.getFloat("angle");
        final float cBt = item.getFloat("cBt");
        final int hp = item.getInt("hp");
        final int sn = item.getInt("sn");
        final int playTime = item.getInt("GageTime");
        final boolean cB = item.getBoolean("cB");
        final boolean [] shots = new boolean[sn];
        final float [] sx = new float[sn];
        final float [] sy = new float[sn];
        for (int j = 0; j<sx.length; j++) {
          shots[j] = item.getBoolean("shot"+j);
          sx[j] = item.getFloat("sx"+j);
          sy[j] = item.getFloat("sy"+j);
        }

        Player player = new Player(id, lv, shotLv, HPLv, GageLv, x, y, angle, shots, sx, sy,
          hp, sn, playTime, cB, cBt);
        players.add(player);
      }
    }
  }
}
