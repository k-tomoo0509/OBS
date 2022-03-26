import processing.net.*;
//server
final int n = 5;

class Player {
  private int id, lv, shotLv, HPLv, GageLv;
  private float cx, cy, angle, step, cBx, cBy, cBt;
  private boolean [] shots = new boolean[n];
  private float [] sx = new float[n];
  private float [] sy = new float[n];
  private float [] sAngle = new float[n];
  private boolean heal;
  private boolean cB;
  private int hp, GageTime, cBtime;
  final int size = 20;

  Player(int id) {
    this.id = id;
    this.lv = 1;
    this.cx = random(width);
    this.cy = random(height);
    this.angle = random(TWO_PI);
    this.hp = 5;
    this.shotLv = 1;
    this.HPLv = 1;
    this.GageLv = 1;
    for (int i = 0; i<n; i++) {
      this.shots[i] = false;
    }
    this.heal = false;
    this.cB = false;
    this.step = 1.0;
    this.GageTime = 0;
    this.cBt = 0;
  }

  void forward() {
    float x = step * cos(this.angle) + this.cx;
    float y = step * sin(this.angle) + this.cy;
    this.cx = x;
    if (this.cx > width) {
      this.cx -= width;
    }
    if (this.cx < 0) {
      this.cx += width;
    }
    this.cy = y;
    if (this.cy > height) {
      this.cy -= height;
    }
    if (this.cy < 0) {
      this.cy += height;
    }
  }
  void shot(int i) {
    this.shots[i] = true;
    sx[i] = 20*cos(this.angle)+this.cx;
    sy[i] = 20*sin(this.angle)+this.cy;
    sAngle[i] = this.angle;
  }
  void sStepAndHit(float sStep) {
    for (int i = 0; i<n; i++) {
      if (this.shots[i]) {
        float x = sStep * cos(sAngle[i]);
        float y = sStep * sin(sAngle[i]);
        sx[i] += x;
        sy[i] += y;
        if (sx[i] > width || sx[i] < 0) {
          this.shots[i] = false;
        }
        if (sy[i] > height || sy[i] < 0) {
          this.shots[i] = false;
        }
        for (Player player : players.values()) {
          if (player.id != this.id) {

            if (Hitjudge(player.cx, player.cy, player.angle, sx[i], sy[i])) {
              this.shots[i] = false;
              player.hp -= 1;
              if (player.hp < 1 && this.lv < 5) {
                this.lv += 1;
                levelUp();
              }
            }
          }
        }
      }
    }
  }
  void Heal() {
    if (this.heal) {
      if ((this.hp < 5 && this.HPLv == 1) || (this.hp < 10 && this.HPLv == 2)) {
        this.hp = this.hp+1;
        this.heal = false;
        this.GageTime = 0;
      } 
    }
  }
  void circleBalls() {
    this.cB = true;
    this.cBtime = this.GageTime;
  }
  void cBHit() {
    if (this.cB) {
      final float x1 = size * cos(this.angle) + this.cx;
      final float y1 = size * sin(this.angle) + this.cy;
      final float x2 = size * cos(this.angle + radians(150)) + this.cx;
      final float y2 = size * sin(this.angle + radians(150)) + this.cy;
      final float x3 = size * cos(this.angle - radians(150)) + this.cx;
      final float y3 = size * sin(this.angle - radians(150)) + this.cy;
      this.cBx = (x1+x2+x3)/3+60*cos(this.cBt);
      this.cBy = (y1+y2+y3)/3+60*sin(this.cBt);
      for (Player player : players.values()) {
        if (Hitjudge(player.cx, player.cy, player.angle, this.cBx, this.cBy)) {
          player.hp -= 1;
          if (player.hp < 1 && this.lv < 5) {
            this.lv += 1;
            levelUp();
          }
        }
      }
      if (GageLv == 1) {
        if (this.GageTime/60-this.cBtime/60 > 10) {
          this.cB = false;
          this.GageTime = 0;
        }
      } else if (GageLv == 2) {
        if ((this.GageTime/60-this.cBtime/60)/2 > 10) {
          this.cB = false;
          this.GageTime = 0;
        }
      }
    }
  }
  void levelUp() {
    int x = int(random(1, 4));
    while (x != 0) {
      if (this.shotLv < 3 && x == 1) {
        this.shotLv += 1;
        x = 0;
      } else if (this.HPLv < 2 && x == 2) {
        this.hp += 5;
        this.HPLv += 1;
        x = 0;
      } else if (this.GageLv < 2 && x == 3) {
        this.GageLv += 1;
        x = 0;
      }
    }
  }
  void addTime() {
    if (GageLv == 1) {
      this.GageTime += 1;
    } else if (GageLv == 2) {
      this.GageTime += 2;
    }
  }
  private boolean Hitjudge(float cx, float cy, float angle, float sBx, float sBy) {

    final float x1 = size * cos(angle) + cx;
    final float y1 = size * sin(angle) + cy;
    final float x2 = size * cos(angle + radians(150)) + cx;
    final float y2 = size * sin(angle + radians(150)) + cy;
    final float x3 = size * cos(angle - radians(150)) + cx;
    final float y3 = size * sin(angle - radians(150)) + cy;

    if ((judge(x1, y1, x2, y2, sBx, sBy, 15) && min(x1, x2) < sBx && max(x1, x2) > sBx && min(y1, y2) < sBy && max(y1, y2) > sBy)
      || (judge(x2, y2, x3, y3, sBx, sBy, 15)&& min(x3, x2) < sBx && max(x3, x2) > sBx && min(y3, y2) < sBy && max(y3, y2) > sBy)
      || (judge(x1, y1, x3, y3, sBx, sBy, 15)&& min(x1, x3) < sBx && max(x1, x3) > sBx && min(y1, y3) < sBy && max(y1, y3) > sBy)) {
      return true;
    } else {
      return false;
    }
  }
  private boolean judge(float ax, float ay, float bx, float by, float mx, float my, float r) {
    final float a = (by-ay);
    final float b = (ax-bx);
    final float c = -a*ax-b*ay;
    final float d = abs((a*mx+b*my+c)/mag(a, b));
    if (d <= r/2) {
      return true;
    }
    return false;
  }
  boolean stopConnect() {
    if (this.hp < 1) {
      return true;
    }
    return false;
  }
}



Server server;
int idOffset = 0;
HashMap<Client, Player> players = new HashMap();

void setup() {
  size(800, 800);
  server = new Server(this, 5204);
}

void draw() {
  final float sStep = 1;
  for (Player player : players.values()) {
    player.forward();
    player.sStepAndHit(sStep*2.0);
    player.Heal();
    player.cBHit();
    player.addTime();
    player.cBt += 0.1;
  }
  for (Client client : players.keySet()) {
    if (players.get(client).stopConnect()) {
      //client.clear();
      players.remove(client);
      server.disconnect(client);
      break;
    }
  }
  JSONObject message = playerInfo();
  server.write(message.toString());
  server.write('\0');
}

void clientEvent(Client client) {
  int dAngle = 20;
  String payload = client.readStringUntil('\0');
  if (payload != null) {
    JSONObject message = parseJSONObject(payload.substring(0, payload.length() - 1));
    String direction = message.getString("direction");
    String action = message.getString("action");
    if (direction != null) {
      if (direction.equals("left")) {
        players.get(client).angle += radians(-dAngle);
      } else if (direction.equals("right")) {
        players.get(client).angle += radians(dAngle);
      }
    } else if (action != null) {
      for (int i = 0; i<n; i++) {
        if (action.equals("shot"+i) && !players.get(client).shots[i]) {
          players.get(client).shot(i);
        }
      }
      if (action.equals("speed-up")) {
        players.get(client).step = 2.5;
      } else if (action.equals("speed-reset")) {
        players.get(client).step = 1.0;
      } else if (action.equals("heal")) {
        players.get(client).heal = true;
      } else if (action.equals("cB")) {
        players.get(client).circleBalls();
      }
    }
  }
}




void serverEvent(Server server, Client client) {
  Player player = new Player(idOffset++);
  players.put(client, player);
}

void disconnectEvent(Client client) {
  players.remove(client);
}

JSONObject playerInfo() {
  JSONArray playerArray = new JSONArray();
  for (Player player : players.values()) {
    JSONObject item = new JSONObject();
    item.setInt("id", player.id);
    item.setInt("level", player.lv);
    item.setInt("shotLv", player.shotLv);
    item.setInt("HPLv", player.HPLv);
    item.setInt("GageLv", player.GageLv);
    item.setFloat("x", player.cx);
    item.setFloat("y", player.cy);
    item.setFloat("angle", player.angle);
    item.setFloat("cBt", player.cBt);
    item.setInt("hp", player.hp);
    item.setInt("sn", n);
    item.setBoolean("cB", player.cB);
    item.setInt("GageTime", player.GageTime/60);
    for (int i = 0; i<n; i++) {
      item.setBoolean("shot"+i, player.shots[i]);
      item.setFloat("sx"+i, player.sx[i]);
      item.setFloat("sy"+i, player.sy[i]);
    }
    playerArray.append(item);
  }
  JSONObject message = new JSONObject();
  message.setJSONArray("players", playerArray);
  return message;
}
