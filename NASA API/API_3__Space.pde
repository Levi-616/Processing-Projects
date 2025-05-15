ArrayList<APODImage> images = new ArrayList<APODImage>();
int columns = 4;
int rows = 2;
int margin = 10;
int thumbW, thumbH;
boolean loading = true;
APODImage selected = null;

void setup() {
  size(1000, 600);
  thumbW = (width - (columns + 1) * margin) / columns;
  thumbH = (height - (rows + 1) * margin) / rows;
  fetchImages();
}

void draw() {
  background(20);

  if (loading) {
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(24);
    text("Loading Gallery...", width / 2, height / 2);
    return;
  }

  if (selected != null) {
    // Fullscreen view
    background(0);
    if (selected.img != null) {
      image(selected.img, 0, 0, width, height);
    }
    fill(0, 180);
    rect(0, height - 150, width, 150);
    fill(255);
    textAlign(LEFT, TOP);
    textSize(20);
    text(selected.title, 20, height - 140, width - 40, 40);
    textSize(14);
    text(selected.explanation, 20, height - 100, width - 40, 80);
    
    fill(255);
    textSize(16);
    textAlign(RIGHT, BOTTOM);
    text("Click to return to gallery", width - 20, height - 20);
    
  } else {
    // Gallery grid
    for (int i = 0; i < images.size(); i++) {
      APODImage img = images.get(i);
      int col = i % columns;
      int row = i / columns;
      int x = margin + col * (thumbW + margin);
      int y = margin + row * (thumbH + margin);

      if (img.img != null) {
        tint(255, img.alpha);
        image(img.img, x, y, thumbW, thumbH);
        img.fadeIn();
        noTint();
      }
    }
    
    // "Load More" button
    fill(50);
    rect(width/2 - 60, height - 40, 120, 30, 10);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(14);
    text("Load More", width/2, height - 25);
  }
}

void mousePressed() {
  if (selected != null) {
    selected = null; // Exit full-screen
    return;
  }

  // Check thumbnails
  for (int i = 0; i < images.size(); i++) {
    APODImage img = images.get(i);
    int col = i % columns;
    int row = i / columns;
    int x = margin + col * (thumbW + margin);
    int y = margin + row * (thumbH + margin);
    
    if (mouseX > x && mouseX < x + thumbW && mouseY > y && mouseY < y + thumbH) {
      selected = img;
      return;
    }
  }

  // Check "Load More" button
  if (mouseX > width/2 - 60 && mouseX < width/2 + 60 && mouseY > height - 40 && mouseY < height - 10) {
    fetchImages();
  }
}

void fetchImages() {
  loading = true;
  new Thread(new Runnable() {
    public void run() {
      String apiKey = "7ypeyaRSr7HyFrAfNhZ5KN3p5KIaG6rLgfknYQOF";
      String url = "https://api.nasa.gov/planetary/apod?api_key=" + apiKey + "&count=8";
      JSONArray jsonArr = loadJSONArray(url);
      if (jsonArr != null) {
        for (int i = 0; i < jsonArr.size(); i++) {
          JSONObject obj = jsonArr.getJSONObject(i);
          if (obj.getString("media_type").equals("image")) {
            String title = obj.getString("title");
            String explanation = obj.getString("explanation");
            String imgUrl = obj.getString("url");
            PImage img = loadImage(imgUrl);
            if (img != null) {
              images.add(new APODImage(title, explanation, img));
            }
          }
        }
      }
      loading = false;
    }
  }).start();
}

// Helper class
class APODImage {
  String title;
  String explanation;
  PImage img;
  int alpha = 0;

  APODImage(String t, String e, PImage i) {
    title = t;
    explanation = e;
    img = i;
  }

  void fadeIn() {
    if (alpha < 255) alpha += 8;
  }
}
