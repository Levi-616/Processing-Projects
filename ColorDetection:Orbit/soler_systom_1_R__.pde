class Orbiter {
  float angle;
  float speed;
  float a, b;
  float offset;
  float size;
  color col;

  Orbiter(float a, float b, float speed, float size, color col) {
    this.angle = 0;
    this.offset = random(TWO_PI);
    this.speed = speed;
    this.a = a;
    this.b = b;
    this.size = size;
    this.col = col;
  }

  void updateAndDisplay(float cx, float cy) {
    float x = cx + a * cos(angle + offset);
    float y = cy + b * sin(angle + offset);

    fill(col);
    noStroke();
    ellipse(x, y, size, size);

    angle += speed;
  }
}

ArrayList<Orbiter> orbiters;
float centerX, centerY;

void setup() {
  size(800, 800);
  smooth();

  centerX = width / 2;
  centerY = height / 2;

  orbiters = new ArrayList<Orbiter>();
  int num = int(random(2, 7)); // 2 to 6 orbiters

  float minRadius = 100;

  for (int i = 0; i < num; i++) {
    float baseRadius = minRadius + i * 60;
    
    float a = baseRadius + random(-5, 5);
    float b = baseRadius + random(-5, 5);

    // Increased speed multiplier from 0.05 to 0.15
    float speed = 0.15 / sqrt(baseRadius);  
    float size = random(10, 20);
    color col = color(random(255), random(255), random(255));
    
    orbiters.add(new Orbiter(a, b, speed, size, col));
  }
}

void draw() {
  background(0);

  // Draw central sun
  fill(255, 204, 0);
  noStroke();
  ellipse(centerX, centerY, 30, 30);

  for (Orbiter o : orbiters) {
    o.updateAndDisplay(centerX, centerY);
  }
}
