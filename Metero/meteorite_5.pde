Table table;
ArrayList<Meteorite> meteorites = new ArrayList<Meteorite>();
PFont font;

void setup() {
  size(1000, 800);
  background(0);
  table = loadTable("Meteorite_Landings_20250404.csv", "header");
  font = createFont("Arial", 12);
  textFont(font);
  noStroke();
  smooth();

  for (TableRow row : table.rows()) {
    if (!row.getString("fall").equalsIgnoreCase("Fell")) continue;

    String name = row.getString("name");
    String recclass = row.getString("recclass");
    float mass = row.getFloat("mass (g)");
    int year = parseYear(row.getString("year"));
    Float reclong = row.getFloat("reclong");

    meteorites.add(new Meteorite(name, recclass, reclong, year, mass));
  }

  // Sort by year so earlier meteorites fall first
  meteorites.sort((a, b) -> Integer.compare(a.year, b.year));
}

void draw() {
  background(0, 20); // low alpha to make trails

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
  String name;
  String recclass;
  float x, y, speed;
  int year;
  float mass;
  color c;

  Meteorite(String name, String recclass, float reclong, int year, float mass) {
    this.name = name;
    this.recclass = recclass;
    this.mass = constrain(mass, 0, 100000);
    this.year = year;

    // Map reclong (-180 to 180) to screen width
    this.x = map(reclong, -180, 180, 50, width - 50);
    this.y = map(year, 860, 2024, 0, height); // oldest year to most recent

    this.speed = map(mass, 0, 100000, 0.3, 3); // heavier = faster fall
    this.speed = constrain(speed, 0.3, 3);

    // Color by class type
    this.c = getColorByRecclass(recclass);
  }

  void update() {
    y += speed;
    if (y > height + 20) y = -random(100); // loop around for fun
  }

  void display() {
    fill(c, 200);
    ellipse(x, y, map(mass, 0, 100000, 2, 16), map(mass, 0, 100000, 2, 16));
    drawTrail();
  }

  void drawTrail() {
    for (int i = 0; i < 5; i++) {
      float trailY = y - i * 6;
      float alpha = map(i, 0, 5, 100, 0);
      fill(c, alpha);
      ellipse(x, trailY, 4, 4);
    }
  }
}

color getColorByRecclass(String recclass) {
  int h = abs(recclass.hashCode());
  return color(h % 255, (h * 2) % 255, (h * 3) % 255);
}
