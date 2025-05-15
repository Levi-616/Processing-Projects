import processing.video.*;
import java.util.HashSet;
import java.util.HashMap;

Capture cam;
boolean[][] visited;

HashMap<String, Bot> colorBots = new HashMap<String, Bot>();
HashMap<String, float[]> colorCentroids = new HashMap<String, float[]>();
HashMap<String, Boolean> colorPresence = new HashMap<String, Boolean>();

void setup() {
  size(1280, 480);
  String[] cameras = Capture.list();

  if (cameras.length == 0) {
    println("No camera found.");
    exit();
  } else {
    cam = new Capture(this, cameras[0]);
    cam.start();
  }

  textSize(32);
  textAlign(CENTER, TOP);
}

void draw() {
  background(0);

  if (cam.available()) {
    cam.read();
    cam.loadPixels();
    // Don't show the camera image
    colorCentroids.clear();
    visited = new boolean[cam.width][cam.height];
    HashSet<String> detectedInFrame = new HashSet<String>();

    for (int y = 0; y < cam.height; y++) {
      for (int x = 0; x < cam.width; x++) {
        if (!visited[x][y]) {
          String colorType = getColorType(x, y);
          if (!colorType.equals("NONE")) {
            ArrayList<int[]> cluster = new ArrayList<int[]>();
            floodFill(x, y, cluster, colorType);
            if (cluster.size() >= 15 && !colorCentroids.containsKey(colorType)) {
              float[] centroid = calculateCentroid(cluster);
              colorCentroids.put(colorType, centroid);
              detectedInFrame.add(colorType);

              if (!colorBots.containsKey(colorType)) {
                colorBots.put(colorType,
                  new Bot(random(width), random(height), getColorFromType(colorType))
                );
              }
              colorPresence.put(colorType, true);
            }
          }
        }
      }
    }

    for (String color1 : colorBots.keySet()) {
      if (!detectedInFrame.contains(color1)) {
        colorPresence.put(color1, false);
      }
    }
  }

  // Move and draw bots
  for (String colorType : colorBots.keySet()) {
    if (colorPresence.getOrDefault(colorType, false)) {
      Bot b = colorBots.get(colorType);
      float[] centroid = colorCentroids.get(colorType);

      // Map camera coordinates to full canvas width
      float x = map(centroid[0], 0, cam.width, 0, width);
      float y = map(centroid[1], 0, cam.height, 0, height);

      b.moveTo(x, y);
      b.update();
      b.display();
    }
  }

  // Draw active color label
  fill(255);
  String label = "";
  for (String color1 : colorCentroids.keySet()) {
    if (!label.isEmpty()) label += ", ";
    label += color1;
  }
  text(label, width/2, 10);

  // Draw centroid circles
  for (String color1 : colorCentroids.keySet()) {
    if (colorPresence.getOrDefault(color1, false)) {
      float[] c = colorCentroids.get(color1);
      float x = map(c[0], 0, cam.width, 0, width);
      float y = map(c[1], 0, cam.height, 0, height);
      fill(getColorFromType(color1));
      noStroke();
      ellipse(x, y, 20, 20);
    }
  }
}

// ======= Bot Class =======
class Bot {
  float x, y;
  float tx, ty;
  color botColor;

  Bot(float x, float y, color botColor) {
    this.x = x;
    this.y = y;
    this.tx = x;
    this.ty = y;
    this.botColor = botColor;
  }

  void moveTo(float newX, float newY) {
    tx = newX;
    ty = newY;
  }

  void update() {
    float ease = 0.1;
    x += (tx - x) * ease;
    y += (ty - y) * ease;
  }

  void display() {
    fill(botColor);
    noStroke();
    ellipse(x, y, 20, 20);
  }
}

// ======= Color Detection =======
String getColorType(int x, int y) {
  int index = y * cam.width + x;
  if (index < 0 || index >= cam.pixels.length) return "NONE";

  color c = cam.pixels[index];
  float r = red(c);
  float g = green(c);
  float b = blue(c);

  if (r > 150 && g < 100 && b < 100) return "RED";
  if (g > 150 && r < 100 && b < 100) return "GREEN";
  if (b > 150 && r < 100 && g < 100) return "BLUE";
  if (r > 200 && g > 200 && b < 100) return "YELLOW";
  if (r > 200 && g > 100 && g < 170 && b < 100) return "ORANGE";
  if (r > 100 && b > 100 && g < 80) return "PURPLE";
  if (r > 200 && g < 150 && b > 180) return "PINK";

  return "NONE";
}

color getColorFromType(String type) {
  switch (type) {
    case "RED": return color(255, 0, 0);
    case "GREEN": return color(0, 255, 0);
    case "BLUE": return color(0, 0, 255);
    case "YELLOW": return color(255, 255, 0);
    case "ORANGE": return color(255, 165, 0);
    case "PURPLE": return color(128, 0, 128);
    case "PINK": return color(255, 105, 180);
    default: return color(255);
  }
}

// ======= Flood Fill and Centroid =======
void floodFill(int startX, int startY, ArrayList<int[]> cluster, String targetColor) {
  ArrayList<int[]> stack = new ArrayList<int[]>();
  stack.add(new int[]{startX, startY});

  while (!stack.isEmpty()) {
    int[] current = stack.remove(stack.size() - 1);
    int x = current[0];
    int y = current[1];

    if (x < 0 || x >= cam.width || y < 0 || y >= cam.height || visited[x][y]) continue;
    if (!getColorType(x, y).equals(targetColor)) continue;

    visited[x][y] = true;
    cluster.add(new int[]{x, y});

    stack.add(new int[]{x + 1, y});
    stack.add(new int[]{x - 1, y});
    stack.add(new int[]{x, y + 1});
    stack.add(new int[]{x, y - 1});
  }
}

float[] calculateCentroid(ArrayList<int[]> cluster) {
  float sumX = 0;
  float sumY = 0;
  for (int[] point : cluster) {
    sumX += point[0];
    sumY += point[1];
  }
  return new float[]{sumX / cluster.size(), sumY / cluster.size()};
}
