ArrayList<Bar> bars = new ArrayList<Bar>();
int maxBars = 10;
boolean loading = false;

void setup() {
  size(1000, 600);
  colorMode(HSB, 360, 100, 100);
  textAlign(CENTER, CENTER);
  loadNewImages();
}

void draw() {
  background(240, 10, 10); // dark space

  // Draw title
  fill(0, 0, 100);
  textSize(32);
  text("NASA Cosmic Brightness Chart", width / 2, 40);

  // Draw bars
  for (int i = 0; i < bars.size(); i++) {
    bars.get(i).update(i, bars.size());
    bars.get(i).display();
  }

  // Loading text
  if (loading) {
    fill(0, 0, 100);
    textSize(20);
    text("Fetching from the stars...", width / 2, height - 30);
  }
}

// Load a few images and compute their average brightness
void loadNewImages() {
  loading = true;
  new Thread(new Runnable() {
    public void run() {
      String apiKey = "7ypeyaRSr7HyFrAfNhZ5KN3p5KIaG6rLgfknYQOF";
      String url = "https://api.nasa.gov/planetary/apod?api_key=" + apiKey + "&count=3";
      JSONArray arr = loadJSONArray(url);

      if (arr != null) {
        for (int i = 0; i < arr.size(); i++) {
          JSONObject json = arr.getJSONObject(i);
          if (json.getString("media_type").equals("image")) {
            String imgUrl = json.getString("url");
            PImage img = loadImage(imgUrl);
            while (img.width == 0) {
              delay(100);
            }
            img.resize(100, 100);
            float totalBrightness = 0;
            colorMode(RGB);
            for (int x = 0; x < img.width; x++) {
              for (int y = 0; y < img.height; y++) {
                color c = img.get(x, y);
                totalBrightness += brightness(c);
              }
            }
            float avgBrightness = totalBrightness / (img.width * img.height);
            colorMode(HSB, 360, 100, 100);
            bars.add(new Bar(avgBrightness, img));
            if (bars.size() > maxBars) {
              bars.remove(0); // keep the most recent bars
            }
          }
        }
      }
      loading = false;
    }
  }).start();
}

// Press any key to simulate a "new entry"
void keyPressed() {
  if (!loading) {
    loadNewImages();
  }
}

class Bar {
  float targetHeight;
  float currentHeight;
  float brightnessValue;
  PImage thumbnail;
  color col;

  Bar(float brightnessValue, PImage img) {
    this.brightnessValue = brightnessValue;
    this.thumbnail = img;
    this.targetHeight = map(brightnessValue, 0, 255, 0, height - 150);
    this.currentHeight = 0;

    float avgHue = getAverageHue(img);
    col = color(avgHue, 80, 100);
  }

  void update(int index, int total) {
    // Smooth animation
    currentHeight = lerp(currentHeight, targetHeight, 0.05);
  }

  void display() {
    float barWidth = width / (maxBars + 1);
    float x = barWidth * (bars.indexOf(this) + 1);
    float y = height - 100 - currentHeight;

    fill(col);
    noStroke();
    rect(x - barWidth / 3, y, barWidth / 1.5, currentHeight);

    // Draw brightness value
    fill(0, 0, 100);
    textSize(14);
    text(nf(brightnessValue, 0, 1), x, y - 10);

    // Draw thumbnail
    image(thumbnail, x - 25, height - 90, 50, 50);
  }

  float getAverageHue(PImage img) {
    float totalHue = 0;
    int count = 0;
    for (int x = 0; x < img.width; x += 5) {
      for (int y = 0; y < img.height; y += 5) {
        color c = img.get(x, y);
        totalHue += hue(c);
        count++;
      }
    }
    return totalHue / count;
  }
}
