import processing.video.*;
Capture cam;

boolean[][] visited;

void setup() {
  size(640, 480);
  String[] cameras = Capture.list();

  if (cameras.length == 0) {
    println("No camera found.");
    exit();
  } else {
    cam = new Capture(this, cameras[0]);
    cam.start();
  }

  textSize(28);
  textAlign(CENTER, CENTER);
}

void draw() {
  if (cam.available()) {
    cam.read();
    image(cam, 0, 0);
    cam.loadPixels();

    visited = new boolean[width][height];

    boolean redCluster = false;
    boolean greenCluster = false;
    boolean blueCluster = false;
    boolean yellowCluster = false;
    boolean orangeCluster = false;
    boolean purpleCluster = false;
    boolean pinkCluster = false;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (!visited[x][y]) {
          String colorType = getColorType(x, y);
          if (!colorType.equals("NONE")) {
            ArrayList<int[]> cluster = new ArrayList<int[]>();
            floodFill(x, y, cluster, colorType);

            if (cluster.size() >= 10) {
              switch (colorType) {
                case "RED": redCluster = true; break;
                case "GREEN": greenCluster = true; break;
                case "BLUE": blueCluster = true; break;
                case "YELLOW": yellowCluster = true; break;
                case "ORANGE": orangeCluster = true; break;
                case "PURPLE": purpleCluster = true; break;
                case "PINK": pinkCluster = true; break;
              }
            }
          }
        }
      }
    }

    int yOffset = 40;
    if (redCluster)    { fill(255, 0, 0);     text("RED",     width / 2, yOffset); yOffset += 40; }
    if (greenCluster)  { fill(0, 255, 0);     text("GREEN",   width / 2, yOffset); yOffset += 40; }
    if (blueCluster)   { fill(0, 0, 255);     text("BLUE",    width / 2, yOffset); yOffset += 40; }
    if (yellowCluster) { fill(255, 255, 0);   text("YELLOW",  width / 2, yOffset); yOffset += 40; }
    if (orangeCluster) { fill(255, 165, 0);   text("ORANGE",  width / 2, yOffset); yOffset += 40; }
    if (purpleCluster) { fill(128, 0, 128);   text("PURPLE",  width / 2, yOffset); yOffset += 40; }
    if (pinkCluster)   { fill(255, 105, 180); text("PINK",    width / 2, yOffset); yOffset += 40; }
  }
}

String getColorType(int x, int y) {
  int index = y * width + x;
  if (index < 0 || index >= cam.pixels.length) return "NONE";

  color c = cam.pixels[index];
  float r = red(c);
  float g = green(c);
  float b = blue(c);

  // Tweak the thresholds to match your lighting conditions
  if (r > 150 && g < 100 && b < 100) return "RED";
  if (g > 150 && r < 100 && b < 100) return "GREEN";
  if (b > 150 && r < 100 && g < 100) return "BLUE";
  if (r > 200 && g > 200 && b < 100) return "YELLOW";
  if (r > 200 && g > 100 && g < 170 && b < 100) return "ORANGE";
  if (r > 100 && b > 100 && g < 80) return "PURPLE";
  if (r > 200 && g < 150 && b > 180) return "PINK";

  return "NONE";
}

void floodFill(int startX, int startY, ArrayList<int[]> cluster, String targetColor) {
  ArrayList<int[]> stack = new ArrayList<int[]>();
  stack.add(new int[]{startX, startY});

  while (!stack.isEmpty()) {
    int[] current = stack.remove(stack.size() - 1);
    int x = current[0];
    int y = current[1];

    if (x < 0 || x >= width || y < 0 || y >= height || visited[x][y]) continue;
    if (!getColorType(x, y).equals(targetColor)) continue;

    visited[x][y] = true;
    cluster.add(new int[]{x, y});

    stack.add(new int[]{x + 1, y});
    stack.add(new int[]{x - 1, y});
    stack.add(new int[]{x, y + 1});
    stack.add(new int[]{x, y - 1});
  }
}
