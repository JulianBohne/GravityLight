
boolean pmousePressed = false;

// Roation speed of the camera ig
final float degreesPerWidth = 180.0;

RayMarcher marcher;

void setup(){
  size(800, 600, P2D);
  surface.setResizable(true);
  marcher = new RayMarcher();
}

void draw(){
  if(mousePressed && pmousePressed) {
    marcher.yaw -= radians((pmouseX-mouseX)*degreesPerWidth/width);
    marcher.pitch -= radians((pmouseY-mouseY)*degreesPerWidth/width);
    marcher.pitch = constrain(marcher.pitch, -HALF_PI, HALF_PI);
  }
  
  marcher.viewPos.set(0, 0, -2);
  rotateX(marcher.viewPos, marcher.pitch);
  rotateY(marcher.viewPos, marcher.yaw);
  marcher.viewPos.y = max(marcher.viewPos.y, -1);
  
  marcher.render();
  
  // Just a amall fix for touch screens
  pmousePressed = mousePressed;
}

int numShaderReloaded = 0;
void keyPressed() {
  if (key == 'r') {
    println("Reloading renderer... (" + (++numShaderReloaded) + ")");
    marcher.reloadRenderer();
  }
}
