import processing.video.*;

Capture cam;

boolean countdownStarted = false;
boolean videoPlaying = false;

String selectedPlanet = "";
int videoDelayMillis;
int countdownStartMillis;
int frameRateCapture = 30;

ArrayList<PImage> frameBuffer = new ArrayList<PImage>();
int delayFrames = 0;

// Starfield setup
int numStars = 800;
Star[] stars;

void setup() {
  size(640, 480);
  frameRate(frameRateCapture);

  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("No cameras found!");
    exit();
  } else {
    cam = new Capture(this, cameras[0]);
    cam.start();
  }

  textAlign(CENTER, CENTER);
  textSize(24);

  // Initialize stars for light-speed effect
  stars = new Star[numStars];
  for (int i = 0; i < numStars; i++) {
    stars[i] = new Star();
  }

  println("Press a key to select a destination:\n" +
         "'S' = Sun (8m20s)\n'M' = Mercury (3.2m)\n'V' = Venus (6m)\n" +
         "'L' = Moon (1.3s)\n'R' = Mars (12.5m)\n'J' = Jupiter (42m)\n" +
         "'A' = Saturn (1.418h)\n'U' = Uranus (2h 50m 40.8243s)\n" +
         "'N' = Neptune (4h 14m 29.0608s)\n'P' = Pluto (5.5h)");
}

void draw() {
  background(0);

  if (cam.available()) {
    cam.read();
  }

  if (!countdownStarted) {
    image(cam, 0, 0, width, height);
    fill(255);
    text("Select destination:\n" +
         "'S' = Sun (8m20s)\n'M' = Mercury (3.2m)\n'V' = Venus (6m)\n" +
         "'L' = Moon (1.3s)\n'R' = Mars (12.5m)\n'J' = Jupiter (42m)\n" +
         "'A' = Saturn (1.418h)\n'U' = Uranus (2h 50m 40.8243s)\n" +
         "'N' = Neptune (4h 14m 29.0608s)\n'P' = Pluto (5.5h)",
         width / 2, height / 2);
    return;
  }

  // Store live frame in buffer
  frameBuffer.add(cam.get());

  // Keep buffer from growing forever (optional)
  if (frameBuffer.size() > delayFrames + 300) {
    frameBuffer.remove(0);
  }

  // If enough frames buffered, show live feed
  if (frameBuffer.size() >= delayFrames) {
    int delayedIndex = frameBuffer.size() - delayFrames;
    PImage delayedFrame = frameBuffer.get(delayedIndex);
    image(delayedFrame, 0, 0, width, height);
    fill(0, 255, 0);
    text("LIVE from " + selectedPlanet + " (" + formatTime(videoDelayMillis / 1000) + " ago)", width / 2, height - 30);
  } else {
    // Starfield effect during buffering
    pushMatrix();
    translate(width / 2, height / 2);
    for (int i = 0; i < stars.length; i++) {
      stars[i].update();
      stars[i].show();
    }
    popMatrix();

    // Buffering message
    float percent = frameBuffer.size() * 100.0 / delayFrames;
    fill(255);
    text("Buffering... " + nf(percent, 0, 1) + "%", width / 2, height / 2);
  }
}

void keyPressed() {
  if (!countdownStarted) {
    if (key == 's' || key == 'S') {
      selectedPlanet = "Sun";
      videoDelayMillis = (8 * 60 + 20) * 1000;
    } else if (key == 'm' || key == 'M') {
      selectedPlanet = "Mercury";
      videoDelayMillis = int(3.2 * 60 * 1000);
    } else if (key == 'v' || key == 'V') {
      selectedPlanet = "Venus";
      videoDelayMillis = 6 * 60 * 1000;
    } else if (key == 'l' || key == 'L') {
      selectedPlanet = "The Moon";
      videoDelayMillis = int(1.3 * 1000);
    } else if (key == 'r' || key == 'R') {
      selectedPlanet = "Mars";
      videoDelayMillis = int(12.5 * 60 * 1000);
    } else if (key == 'j' || key == 'J') {
      selectedPlanet = "Jupiter";
      videoDelayMillis = 42 * 60 * 1000;
    } else if (key == 'a' || key == 'A') {
      selectedPlanet = "Saturn";
      videoDelayMillis = int(1.418 * 60 * 60 * 1000);
    } else if (key == 'u' || key == 'U') {
      selectedPlanet = "Uranus";
      videoDelayMillis = int((2 * 3600 + 50 * 60 + 40.8243) * 1000);
    } else if (key == 'n' || key == 'N') {
      selectedPlanet = "Neptune";
      videoDelayMillis = int((4 * 3600 + 14 * 60 + 29.0608) * 1000);
    } else if (key == 'p' || key == 'P') {
      selectedPlanet = "Pluto";
      videoDelayMillis = int(5.5 * 3600 * 1000);
    } else {
      return;
    }

    delayFrames = int(videoDelayMillis / 1000.0 * frameRateCapture);
    countdownStarted = true;
    println("Buffering for delay: " + selectedPlanet + " (" + delayFrames + " frames)");
  }

  if (key == 'e' || key == 'E') {
    println("Live stream ended.");
    countdownStarted = false;
    frameBuffer.clear();
  }
}

String formatTime(int seconds) {
  int h = seconds / 3600;
  int m = (seconds % 3600) / 60;
  int s = seconds % 60;
  return nf(h, 2) + ":" + nf(m, 2) + ":" + nf(s, 2);
}

// Star class for light-speed animation
class Star {
  float x, y, z;
  float pz;
  float speed = 40;

  Star() {
    reset();
  }

  void reset() {
    x = random(-width, width);
    y = random(-height, height);
    z = random(width);
    pz = z;
  }

  void update() {
    z -= speed;
    if (z < 1) {
      reset();
    }
  }

  void show() {
    float sx = map(x / z, 0, 1, 0, width);
    float sy = map(y / z, 0, 1, 0, height);

    float px = map(x / pz, 0, 1, 0, width);
    float py = map(y / pz, 0, 1, 0, height);

    pz = z;

    stroke(255);
    strokeWeight(2);
    line(px, py, sx, sy);
  }
}
