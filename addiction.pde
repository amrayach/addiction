import com.hamoid.*;
VideoExport videoExport;

float movieFPS = 60;
float soundDuration = 32; // in seconds

ArrayList<Particle> particles;
int numParticles = 6000;
int numElements = 400; // Increased for more spread
int centerX, centerY;
float relapseAngle = 0;
ArrayList<PVector> targetPositions;
float lerpAmount = 0.009;
boolean isTransitioning = false;
float[] rotationAngles; // Separate rotation angle for each line
float[] lengths; // Initial lengths of each line

void setup() {
  //size(1080, 1920);
  fullScreen();
  videoExport = new VideoExport(this);
  videoExport.setFrameRate(movieFPS);
  videoExport.setAudioFileName("mix.wav");
  videoExport.startMovie();  
  
  centerX = width / 2;
  centerY = height / 2;
  particles = new ArrayList<Particle>();
  targetPositions = new ArrayList<PVector>();
  rotationAngles = new float[numElements];
  lengths = new float[numElements];

  for (int i = 0; i < numParticles; i++) {
    particles.add(new Particle(random(width), random(height)));
  }

  for (int i = 0; i < numElements; i++) {
    float angle = TWO_PI / numElements * i;
    float radius = random(100, 200); // Random initial lengths
    float x = centerX + cos(angle) * radius;
    float y = centerY + sin(angle) * radius;
    targetPositions.add(new PVector(x, y));
    rotationAngles[i] = angle;
    lengths[i] = radius;
  }
}

void draw() {
  background(0);

  if (frameCount == 350) {
    isTransitioning = true;
  }

  for (Particle p : particles) {
    if (isTransitioning) {
      p.approachTarget(targetPositions.get(particles.indexOf(p) % targetPositions.size()));
    } else {
      p.update();
    }
    p.display();
  }

  if (isTransitioning) {
    drawRotatingNeuralConnections();
    drawRelapseCycle(centerX, centerY, 200 + sin(relapseAngle) * 10);
    relapseAngle += 0.02;
  }
  videoExport.saveFrame();
  
  // End when we have exported enough frames 
  // to match the sound duration.
  if(frameCount > round(movieFPS * soundDuration)) {
    videoExport.endMovie();
    exit();
  } 
}

void drawRotatingNeuralConnections() {
  stroke(255);
  for (int i = 0; i < numElements; i++) {
    float dynamicRadius = lengths[i] + sin(rotationAngles[i] + frameCount * 0.01) * 50;
    float x = centerX + cos(rotationAngles[i]) * dynamicRadius;
    float y = centerY + sin(rotationAngles[i]) * dynamicRadius;
    line(centerX, centerY, x, y);
    rotationAngles[i] += 0.005; // Independent rotation speed
  }
}

void drawRelapseCycle(int x, int y, float radius) {
  noFill();
  stroke(random(255), random(255), random(255));
  ellipse(x, y, radius * 2 + random(-20, 20), radius * 2 + random(-20, 20));
}

class Particle {
  PVector position;
  PVector velocity;
  float noiseScale = 0.02;
  boolean isFixed = false;

  Particle(float x, float y) {
    position = new PVector(x, y);
    velocity = new PVector(0, 0);
  }

  void update() {
    if (!isFixed) {
      float angle = noise(position.x * noiseScale, position.y * noiseScale) * TWO_PI * 4;
      velocity.x = cos(angle);
      velocity.y = sin(angle);
      position.add(velocity);
    }

    // Wrap around edges
    if (position.x < 0) position.x = width;
    if (position.x > width) position.x = 0;
    if (position.y < 0) position.y = height;
    if (position.y > height) position.y = 0;
  }

  void approachTarget(PVector target) {
    if (!isFixed) {
      position.lerp(target, lerpAmount);
      if (PVector.dist(position, target) < 1) {
        isFixed = true;
      }
    }
  }
  void display() {
    if (isFixed) {
      // Randomize color when the particle is fixed
      fill(random(255), random(255), random(255), 100);
    } else {
      // Default color when not fixed
      fill(255, 100);
    }
    noStroke();
    ellipse(position.x, position.y, 4, 4);
}

//  void display() {
//    fill(255, 100);
//    noStroke();
//    ellipse(position.x, position.y, 4, 4);
//  }
}