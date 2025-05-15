JSONObject json;
PImage apodImage;
String title = "";
String explanation = "";
boolean loading = true;

void setup() {
  size(800, 600);
  fetchRandomAPOD();
}

void draw() {
  background(0);

  if (loading) {
    fill(255);
    textSize(20);
    textAlign(CENTER, CENTER);
    text("Loading...", width / 2, height / 2);
    return;
  }

  if (apodImage != null) {
    image(apodImage, 0, 0, width, height);
    fill(0, 180);
    rect(0, height - 120, width, 120);
    fill(255);
    textAlign(LEFT, TOP);
    textSize(18);
    text(title, 10, height - 110, width - 20, 40);
    textSize(12);
    text(explanation, 10, height - 70, width - 20, 60);
  } else {
    fill(255);
    text("Failed to load image or today's content is a video.", 20, 20);
  }
}

void mousePressed() {
  fetchRandomAPOD(); // Load new image on click
}

void fetchRandomAPOD() {
  loading = true;
  apodImage = null;
  title = "";
  explanation = "";

  String apiKey = "7ypeyaRSr7HyFrAfNhZ5KN3p5KIaG6rLgfknYQOF";
  String url = "https://api.nasa.gov/planetary/apod?api_key=" + apiKey + "&count=1";

  JSONArray arr = loadJSONArray(url);

  if (arr != null && arr.size() > 0) {
    json = arr.getJSONObject(0);
    title = json.getString("title");
    explanation = json.getString("explanation");
    
    if (json.getString("media_type").equals("image")) {
      String imageUrl = json.getString("url");
      apodImage = loadImage(imageUrl);
    } else {
      title += " [Not an image]";
      explanation = "This random APOD is a video. Visit: " + json.getString("url");
    }
  }
  loading = false;
}
