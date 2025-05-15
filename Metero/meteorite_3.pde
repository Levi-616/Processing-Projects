Table table;
float globeRadius = 200;
ArrayList<Meteorite> meteorites = new ArrayList<Meteorite>();
ArrayList<Meteorite> activeMeteorites = new ArrayList<Meteorite>();
int batchSize = 3;
int currentIndex = 0;
int frameDelay = 60; // Delay between new batches
int timer = 0;
color sphereColor = color(50, 50, 50); // Constant sphere color

void setup() {
  size(800, 800, P3D);
  table = loadTable("Meteorite_Landings_20250404.csv", "header");
  noStroke();

  // Load valid meteorites (ignoring "Found")
  for (TableRow row : table.rows()) {
    String fall = row.getString("fall");
    if (!fall.equalsIgnoreCase("Fell")) continue; // Skip if not "Fell"

    Float lat = row.getFloat("reclat");
    Float lon = row.getFloat("reclong");
    Float mass = row.getFloat("mass (g)");

    if (lat == null || lon == null || mass == null) continue;

    meteorites.add(new Meteorite(lat, lon, mass));
  }

  // Start with the first 3 meteorites
  launchNextBatch();
}

void draw() {
  background(0);
  lights();
  ambientLight(60, 60, 60);
  directionalLight(255, 255, 255, 0, 0, -1); // White light to enhance colors

  translate(width / 2, height / 2);
  rotateY(millis() * 0.0002);
  rotateX(PI / 8);

  drawSphere();

  // Launch new batch every frameDelay
  if (timer % frameDelay == 0 && currentIndex < meteorites.size()) {
    launchNextBatch();
  }
  timer++;

  // Update and draw active meteorites
  for (Meteorite m : activeMeteorites) {
    m.update();
    m.display();
  }
}

void launchNextBatch() {
  for (int i = 0; i < batchSize; i++) {
    if (currentIndex < meteorites.size()) {
      Meteorite m = meteorites.get(currentIndex);
      m.launch();
      activeMeteorites.add(m);
      currentIndex++;
    }
  }
}

void drawSphere() {
  fill(sphereColor);
  stroke(80);
  sphereDetail(40);
  sphere(globeRadius);
}

class Meteorite {
  float lat, lon, mass;
  float x, y, z;
  float startX, startY, startZ;
  float targetX, targetY, targetZ;
  float progress = 0;
  color meteoriteColor;

  Meteorite(float lat, float lon, float mass) {
    this.lat = radians(lat);
    this.lon = radians(lon);
    this.mass = constrain(mass, 0, 100000);

    // Convert to sphere position (correct landing)
    targetX = globeRadius * cos(this.lat) * cos(this.lon);
    targetY = globeRadius * sin(this.lat);
    targetZ = globeRadius * cos(this.lat) * sin(this.lon);

    // Start far away
    float angle = random(TWO_PI);
    float distance = random(600, 800);
    startX = distance * cos(angle);
    startY = random(-500, 500);
    startZ = distance * sin(angle);

    x = startX;
    y = startY;
    z = startZ;

    // Generate a random color that isn't red
    meteoriteColor = getRandomColor();
  }

  void launch() {
    progress = 0;
  }

  void update() {
    if (progress < 1) {
      progress += 0.02; // Speed of travel
      float ease = pow(progress, 3); // Smooth easing
      x = lerp(startX, targetX, ease);
      y = lerp(startY, targetY, ease);
      z = lerp(startZ, targetZ, ease);
    }
  }

  void display() {
    pushMatrix();
    translate(x, -y, z);
    float pointSize = map(mass, 0, 100000, 2, 20);
    pointSize = constrain(pointSize, 2, 20);
    noStroke();
    emissive(meteoriteColor);
    fill(meteoriteColor);
    sphere(pointSize);
    popMatrix();
  }
}

// Function to generate a random color avoiding pure red
color getRandomColor() {
  float r, g, b;
  do {
    r = random(255);
    g = random(255);
    b = random(255);
  } while (r > g * 1.5 && r > b * 1.5); // Avoid too much red
  return color(r, g, b);
}
