Table table;
ArrayList<Meteorite> meteorites = new ArrayList<Meteorite>();
float centerX, centerY;

void setup() {
  size(1000, 1000, P2D);
  background(0);
  table = loadTable("Meteorite_Landings_20250404.csv", "header");
  centerX = width / 2;
  centerY = height / 2;
  smooth();
  noStroke();

  for (TableRow row : table.rows()) {
    if (!row.getString("fall").equalsIgnoreCase("Fell")) continue;

    Float mass = row.getFloat("mass (g)");
    int year = parseYear(row.getString("year"));
    String recclass = row.getString("recclass");

    if (year == -1 || mass == null) continue;

    meteorites.add(new Meteorite(mass, year, recclass));
  }

  println("Loaded meteorites: " + meteorites.size());
}

void draw() {
  background(0);
  translate(centerX, centerY);

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
  float angle;
  float radius;
  float mass;
  float x, y;
  float speed;
  color c;

  Meteorite(float mass, int year, String recclass) {
    this.mass = constrain(mass, 0, 100000);
    this.radius = map(year, 860, 2024, 20, 400) + random(-5, 5);
    this.angle = random(TWO_PI);
    this.speed = map(mass, 0, 100000, 0.0005, 0.003);
    this.speed = constrain(speed, 0.0005, 0.003);

    c = getColorByRecclass(recclass);
  }

  void update() {
    angle += speed;
    x = radius * cos(angle);
    y = radius * sin(angle);
  }

  void display() {
    float size = map(mass, 0, 100000, 2, 15);
    fill(c, 200);
    ellipse(x, y, size, size);
    // Glow ring
    noFill();
    stroke(c, 40);
    strokeWeight(2);
    ellipse(x, y, size + 10, size + 10);
    noStroke();
  }
}

color getColorByRecclass(String recclass) {
  int h = abs(recclass.hashCode());
  return color((h * 2) % 255, (h * 3) % 255, (h * 5) % 255);
}
