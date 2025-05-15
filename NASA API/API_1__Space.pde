JSONObject json;
PImage apodImage;
String title = "";
String explanation = "";

void setup() {
  size(800, 600);
  fetchAPOD();
}

void draw() {
  background(0);

  if (apodImage != null) {
    image(apodImage, 0, 0, width, height);
    fill(255, 200);
    rect(0, height - 100, width, 100);
    fill(0);
    textSize(16);
    textAlign(LEFT, TOP);
    text(title, 10, height - 95, width - 20, 40);
    textSize(12);
    text(explanation, 10, height - 55, width - 20, 45);
  } else {
    fill(255);
    text("Loading NASA APOD...", 20, 20);
  }
}

void fetchAPOD() {
  String apiKey = "7ypeyaRSr7HyFrAfNhZ5KN3p5KIaG6rLgfknYQOF";
  String url = "https://api.nasa.gov/planetary/apod?api_key=" + apiKey;

  json = loadJSONObject(url);

  if (json != null) {
    title = json.getString("title");
    explanation = json.getString("explanation");
    
    String mediaType = json.getString("media_type");
    if (mediaType.equals("image")) {
      String imageUrl = json.getString("url");
      apodImage = loadImage(imageUrl);
    } else {
      title += " [Not an image]";
      explanation = "Today's APOD is a video. Visit: " + json.getString("url");
    }
  }
}
