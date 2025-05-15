import processing.video.*;
import java.util.HashSet;

Capture cam;
boolean[][] visited;
ArrayList<Bot> bots = new ArrayList<Bot>();
HashSet<String> activeColors = new HashSet<String>();  // currently visible
HashMap<String, Boolean> colorPresence = new HashMap<String, Boolean>(); // Track color visibility
HashMap<String, Bot> colorBots = new HashMap<String, Bot>();  // Keep track of existing bots for each color

// To store the position of the centroid for each color
HashMap<String, float[]> colorCentroids = new HashMap<String, float[]>();

void setup() {
  size(1280, 480);  // Left: camera, Right: canvas
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
  background(0);  // Set the background to black by default

  if (cam.available()) {
    cam.read();
    cam.loadPixels();
    image(cam, 0, 0); // Draw camera on the left

    activeColors.clear();
    visited = new boolean[cam.width][cam.height];
    colorCentroids.clear();  // Reset centroids at the start of each frame
    HashSet<String> detectedInFrame = new HashSet<String>();  // Temporarily track detected colors

    for (int y = 0; y < cam.height; y++) {
      for (int x = 0; x < cam.width; x++) {
        if (!visited[x][y]) {
          String colorType = getColorType(x, y);
          if (!colorType.equals("NONE")) {
            ArrayList<int[]> cluster = new ArrayList<int[]>();
            floodFill(x, y, cluster, colorType);

            if (cluster.size() >= 15) {  // Only detect clusters with 15+ pixels
              activeColors.add(colorType);
              // Update color presence to true when it is detected
              colorPresence.put(colorType, true);

              // Calculate centroid of the detected color
              float[] centroid = calculateCentroid(cluster);
              colorCentroids.put(colorType, centroid);

              // Add a new bot (dot) at a random position for the detected color, but don't clear it on detection
              if (!colorBots.containsKey(colorType)) {
                colorBots.put(colorType, new Bot(random(640, width), random(height), getColorFromType(colorType)));
              }

              detectedInFrame.add(colorType);  // Add to the temporary list of detected colors
            }
          }
        }
      }
    }

    // Update color visibility based on the current frame's detections
    for (String color1 : colorPresence.keySet()) {
      if (!detectedInFrame.contains(color1)) {
        colorPresence.put(color1, false);  // Mark as not detected if it's not in the current frame
      }
    }

    // If no colors are detected, clear the canvas (reset the dots)
    if (detectedInFrame.isEmpty()) {
      fill(0);  // Set the fill color to black for the reset effect
      rect(640, 0, 640, 480);  // Clear the right side canvas
    }
  }

  // Draw canvas side (right side) if colors are detected
  fill(30);
  rect(640, 0, 640, 480);

  // Draw and update bots (balls) on the canvas
  for (String colorType : colorBots.keySet()) {
    if (colorPresence.get(colorType)) {
      colorBots.get(colorType).update();  // Update bot position
      colorBots.get(colorType).display();  // Display the bot for detected colors
    }
  }

  // Draw label for detected colors (only those detected in the current frame)
  fill(255);
  String displayedText = "";
  boolean isColorDetected = false;

  for (String colorType : activeColors) {
    if (colorPresence.get(colorType)) {
      if (isColorDetected) {
        displayedText += ", ";  // Add a separator between colors
      }
      displayedText += colorType;  // Add color name to the display text
      isColorDetected = true;
    }
  }

  // If no colors are detected, set the text to empty
  if (isColorDetected) {
    text(displayedText, width / 2, 10);  // Display detected colors at the top
  } else {
    text("", width / 2, 10);  // Clear the text if no colors are detected
  }

  // Draw the centroid dots for each detected color
  for (String colorType : activeColors) {
    if (colorPresence.get(colorType)) {  // Only draw centroids for detected colors
      float[] centroid = colorCentroids.get(colorType);
      if (centroid != null) {
        float x = map(centroid[0], 0, cam.width, 640, width);  // Translate to the canvas side
        float y = map(centroid[1], 0, cam.height, 0, height);
        fill(getColorFromType(colorType));
        noStroke();
        ellipse(x, y, 20, 20);  // Draw a dot on the canvas
      }
    }
  }
}

// ======= Bot Class =======
class Bot {
  float x, y;
  float vx, vy;  // Velocity components
  color botColor;  // Changed from 'color' to 'botColor' to avoid conflict with the color type

  // Constructor to set a random position and velocity
  Bot(float x, float y, color botColor) {
    this.x = x;
    this.y = y;
    this.botColor = botColor;
    this.vx = 0;
    this.vy = 0;
  }

  // Update the bot's position and apply gravitational pull
  void update() {
    // Gravitational pull and orbiting behavior
    for (Bot other : bots) {
      if (other != this) {
        float dx = other.x - this.x;
        float dy = other.y - this.y;
        float dist = dist(this.x, this.y, other.x, other.y);

        // If they're close enough, apply a gravitational pull (orbital force)
        if (dist > 0 && dist < 200) {  // 200 is the distance threshold for pulling
          float force = 1000 / (dist * dist);  // Inverse square law, stronger pull closer
          float angle = atan2(dy, dx);

          // Apply the force as velocity change
          vx += cos(angle) * force;
          vy += sin(angle) * force;
        }
      }
    }

    // Update position based on velocity
    x += vx;
    y += vy;

    // Keep the bots within bounds (optional)
    x = constrain(x, 640, width);
    y = constrain(y, 0, height);
  }

  // Display the bot at its fixed position
  void display() {
    fill(botColor);
    noStroke();
    ellipse(x, y, 20, 20);  // Draw the bot at its fixed position
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
    case "RED":
      return color(255, 0, 0);
    case "GREEN":
      return color(0, 255, 0);
    case "BLUE":
      return color(0, 0, 255);
    case "YELLOW":
      return color(255, 255, 0);
    case "ORANGE":
      return color(255, 165, 0);
    case "PURPLE":
      return color(128, 0, 128);
    case "PINK":
      return color(255, 105, 180);
    default:
      return color(255);  // Default to white
  }
}

// ======= Centroid Calculation =======
float[] calculateCentroid(ArrayList<int[]> cluster) {
  float sumX = 0;
  float sumY = 0;
  for (int[] point : cluster) {
    sumX += point[0];
    sumY += point[1];
  }
  return new float[]{sumX / cluster.size(), sumY / cluster.size()};  // Return centroid (average position)
}

// ======= Flood Fill =======
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
