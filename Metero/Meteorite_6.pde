Table table;
ArrayList<Meteorite> meteorites = new ArrayList<Meteorite>();
int minYear = 1860;
int maxYear = 2024;
PFont font;

void setup() {
  size(1000, 1000, P2D);
  background(0);
  font = createFont("Arial", 14);
  textFont(font);
  noStroke();
  table = loadTable("Meteorite_Landings_20250404.csv", "header");

  for (TableRow row : table.rows()) {
    if (!row.getString("fall").equalsIgnoreCase("Fell")) continue;

    int year = parseYear(row.getString("year"));
    Float mass = row.getFloat("mass (g)");

    if (year == -1 || mass == null) continue;

    meteorites.add(new Meteorite(year, mass));
  }

  println("Loaded meteorites: " + meteorites.size());
}

void draw() {
  background(0, 40); // fade for trail effect

  // Draw year labels on the side
  fill(255);
  for (int y = 100; y <= height - 100; y += 100) {
    int yearLabel = (int) map(y, 100, height - 100, maxYear, minYear);
    text(yearLabel, 20, y);
  }

  for (Meteorite m : meteorites) {
    m.update();
    m.display();
  }
}

int parseYear(String yearString) {
  if (yearString == null) return -1;
  try {
    return int(yearString.substring(0, 4));
  } catch (Exception e) {
    return -1;
  }
}

class Meteorite {
  float x, y;
  float mass;
  float radius;
  float fallSpeed;
  int year;
  color c;

  Meteorite(int year, float mass) {
    this.year = year;
    this.mass = constrain(mass, 0, 100000);
    this.radius = map(this.mass, 0, 100000, 2, 12);
    this.radius = constrain(radius, 2, 12);
    this.x = random(50, width - 50);
    this.y = map(year, minYear, maxYear, 100, height - 100) + random(-10, 10);
    this.fallSpeed = random(0.3, 1.2);

    c = color(random(50, 255), random(50, 255), random(150, 255)); // cool glowing color
  }

  void update() {
    y += fallSpeed;
    if (y > height) {
      y = map(year, minYear, maxYear, 100, height - 100);
    }
  }

  void display() {
    fill(c, 180);
    ellipse(x, y, radius, radius);

    // Glow trail
    for (int i = 1; i <= 6; i++) {
      float trailY = y - i * 4;
      float alpha = map(i, 1, 6, 100, 0);
      fill(c, alpha);
      ellipse(x, trailY, radius * 0.7, radius * 0.7);
    }
  }
}
