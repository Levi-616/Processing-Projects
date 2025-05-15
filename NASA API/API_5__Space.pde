PImage img;
String title = "";
String explanation = "";
boolean loading = true;
Button button;

void setup() {
  size(1000, 700);
  surface.setTitle("NASA APOD Poster");
  textFont(createFont("Arial", 16));
  button = new Button("New Image", width / 2 - 75, height - 70, 150, 40);
  fetchRandomAPOD();
}

void draw() {
  background(20);
  
  if (loading) {
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(24);
    text("Reaching out to the cosmos...", width / 2, height / 2);
    return;
  }

  // Image
  if (img != null) {
    imageMode(CENTER);
    float imgW = min(width * 0.8, img.width);
    float imgH = imgW * img.height / img.width;
    image(img, width / 2, 180, imgW, imgH);
  }

  // Title
  textAlign(CENTER, TOP);
  fill(255);
  textSize(24);
  text(title, width / 2, 370);

  // Explanation
  textAlign(CENTER, TOP);
  textSize(16);
  fill(200);
  text(explanation, width / 2, 410, width * 0.8, 200);

  // Button
  button.display();
}

void mousePressed() {
  if (button.isHovered(mouseX, mouseY)) {
    fetchRandomAPOD();
  }
}

void fetchRandomAPOD() {
  loading = true;
  new Thread(new Runnable() {
    public void run() {
      String apiKey = "7ypeyaRSr7HyFrAfNhZ5KN3p5KIaG6rLgfknYQOF";
      String url = "https://api.nasa.gov/planetary/apod?api_key=" + apiKey + "&count=1";
      JSONArray arr = loadJSONArray(url);
      if (arr != null && arr.size() > 0) {
        JSONObject json = arr.getJSONObject(0);
        if (json.getString("media_type").equals("image")) {
          title = json.getString("title");
          explanation = json.getString("explanation");
          img = loadImage(json.getString("url"));
        } else {
          title = "Not an image.";
          explanation = "The NASA API returned a video or unsupported media.";
          img = null;
        }
      }
      loading = false;
    }
  }).start();
}

class Button {
  String label;
  float x, y, w, h;
  Button(String label, float x, float y, float w, float h) {
    this.label = label;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  void display() {
    if (isHovered(mouseX, mouseY)) {
      fill(255, 80, 100);
      stroke(255);
    } else {
      fill(50);
      stroke(150);
    }
    strokeWeight(2);
    rect(x, y, w, h, 10);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(16);
    text(label, x + w / 2, y + h / 2);
  }

  boolean isHovered(float mx, float my) {
    return mx >= x && mx <= x + w && my >= y && my <= y + h;
  }
}
