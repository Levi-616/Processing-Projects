import processing.video.*;

Capture cam;

boolean isRecording = false;
boolean recordingFinished = false;
boolean countdownStarted = false;
boolean videoPlaying = false;

int recordDuration = 5; // in seconds
int frameRateCapture = 30;
int totalFrames;
int currentFrame = 0;
int playbackFrame = 0;

String selectedPlanet = "";
int videoDelayMillis;
int countdownStartMillis;

ArrayList<PImage> recordedFrames = new ArrayList<PImage>();

// Starfield animation setup
int numStars = 800;
Star[] stars;

void setup() {
  size(640, 480);
  frameRate(frameRateCapture);
  totalFrames = recordDuration * frameRateCapture;

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

  // Initialize stars
  stars = new Star[numStars];
  for (int i = 0; i < numStars; i++) {
    stars[i] = new Star();
  }
}

void draw() {
  background(0);

  if (cam.available()) {
    cam.read();
  }

  if (!isRecording && !recordingFinished && !countdownStarted && !videoPlaying) {
    image(cam, 0, 0, width, height);
    fill(255);
    text("Press 'R' to record 5 seconds", width / 2, height - 30);
  }

  if (isRecording) {
    image(cam, 0, 0, width, height);
    recordedFrames.add(cam.get()); // Save current frame

    currentFrame++;
    fill(255, 0, 0);
    text("Recording... " + (totalFrames - currentFrame), width / 2, height - 30);

    if (currentFrame >= totalFrames) {
      stopRecording();
    }
  }

  if (recordingFinished && !countdownStarted) {
    background(0);
    fill(255);
    text("Select destination:\n" +
         "'S' = Sun (8m20s)\n'M' = Mercury (3.2m)\n'V' = Venus (6m)\n" +
         "'L' = Moon (1.3s)\n'R' = Mars (12.5m)\n'J' = Jupiter (42m)\n" +
         "'A' = Saturn (1.418h)\n'U' = Uranus (2h 50m 40.8243s)\n" +
         "'N' = Neptune (4h 14m 29.0608s)\n'P' = Pluto (5.5h)",
         width / 2, height / 2);
  }

  if (countdownStarted && !videoPlaying) {
    // Starfield background
    pushMatrix();
    translate(width/2, height/2);
    for (int i = 0; i < stars.length; i++) {
      stars[i].update();
      stars[i].show();
    }
    popMatrix();

    // Countdown logic
    int remaining = videoDelayMillis - (millis() - countdownStartMillis);
    if (remaining <= 0) {
      startVideoPlayback();
    } else {
      fill(255);
      textAlign(CENTER, CENTER);
      textSize(24);
      text("Signal from " + selectedPlanet + " arriving in:\n" + formatTime(remaining / 1000), width / 2, height / 2);
    }
  }

  if (videoPlaying) {
    if (playbackFrame < recordedFrames.size()) {
      image(recordedFrames.get(playbackFrame), 0, 0, width, height);
      playbackFrame++;
    } else {
      fill(255);
      text("Playback finished.", width / 2, height / 2);
    }
  }
}

void keyPressed() {
  if (key == 'r' || key == 'R') {
    startRecording();
  }

  if (recordingFinished && !countdownStarted) {
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
    startCountdown();
  }
}

void startRecording() {
  println("Started recording.");
  isRecording = true;
  currentFrame = 0;
  recordedFrames.clear();
}

void stopRecording() {
  println("Finished recording.");
  isRecording = false;
  recordingFinished = true;
}

void startCountdown() {
  countdownStarted = true;
  countdownStartMillis = millis();
  println("Countdown started for " + selectedPlanet);
}

void startVideoPlayback() {
  videoPlaying = true;
  playbackFrame = 0;
  println("Playback started.");
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
