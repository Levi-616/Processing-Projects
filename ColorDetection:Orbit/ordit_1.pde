ArrayList<Planet> planets;
float G = 0.1;  // Gravitational constant
float sunMass = 10000;  // Mass of the Sun

void setup() {
  size(800, 800);
  planets = new ArrayList<Planet>();
  
  // Sun at center
  PVector sunPos = new PVector(width / 2, height / 2);
  
  // Create random planets
  for (int i = 0; i < 10; i++) {
    // Randomize the distance from the Sun
    float randomDistance = random(100, 300);  // Distance between 100 and 300 pixels
    float randomVelocity = random(2, 5);  // Randomize orbital velocity
    float randomMass = random(10, 100);   // Randomize the mass
    color randomColor = color(random(255), random(255), random(255));  // Random color
    
    addPlanet(randomDistance, randomVelocity, randomMass, randomColor);
  }
}

void addPlanet(float d, float v, float m, color c) {
  // Place planet randomly within a range of distance
  float angle = random(TWO_PI);
  PVector pos = new PVector(width / 2 + cos(angle) * d, height / 2 + sin(angle) * d);
  
  // Orbital velocity using random velocity
  PVector vel = new PVector(0, v);  // Initial velocity perpendicular to radius
  
  planets.add(new Planet(pos, vel, m, c, 10, false));
}

void draw() {
  background(0);
  
  // Draw the Sun
  fill(255, 204, 0); // Sun color
  noStroke();
  ellipse(width / 2, height / 2, 50, 50);  // Draw Sun at center
  
  // Update and draw all planets
  for (Planet p : planets) {
    p.update(planets);
    p.display();
  }
}

class Planet {
  PVector pos, vel, acc;
  float mass;
  color col;
  float radius;
  boolean fixed;

  Planet(PVector p, PVector v, float m, color c, float r, boolean f) {
    pos = p.copy();
    vel = v.copy();
    mass = m;
    col = c;
    radius = r;
    fixed = f;
    acc = new PVector();
  }

  void update(ArrayList<Planet> others) {
    if (fixed) return;  // Don't move the Sun (fixed)
    
    acc.set(0, 0);  // Reset acceleration at each update
    
    // Gravitational attraction towards the center (Sun)
    PVector center = new PVector(width / 2, height / 2);  // The Sun at the center
    PVector force = PVector.sub(center, pos);
    float distSq = constrain(force.magSq(), 25, 10000);  // Avoid extremely small distances
    float strength = G * (mass * sunMass) / distSq;  // Gravitational force equation
    force.setMag(strength / mass);  // Apply force per unit mass
    acc.add(force);
    
    // Update velocity and position based on acceleration
    vel.add(acc);
    pos.add(vel);
  }

  void display() {
    fill(col);
    noStroke();
    ellipse(pos.x, pos.y, radius, radius);  // Draw the planet
  }
}
