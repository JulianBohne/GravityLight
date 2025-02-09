
boolean pmousePressed = false;

// Roation speed of the camera ig
final float degreesPerWidth = 180.0;
final int fovChangeSensitivity = 10; // Changes by how much the fov changes when zooming with the scroll wheel

RayMarcher marcher;

void setup(){
  size(800, 600, P2D);
  ((PGraphicsOpenGL)g).textureSampling(2);
  surface.setResizable(true);
  marcher = new RayMarcher();
}

void draw(){
  
  float step = 0.001;
  if (keyPressed) {
    if (key == '1') marcher.gravity.x -= step;
    else if (key == '4') marcher.gravity.x = 0;
    else if (key == '7') marcher.gravity.x += step;
    else if (key == '2') marcher.gravity.y -= step;
    else if (key == '5') marcher.gravity.y = 0;
    else if (key == '8') marcher.gravity.y += step;
    else if (key == '3') marcher.gravity.z -= step;
    else if (key == '6') marcher.gravity.z = 0;
    else if (key == '9') marcher.gravity.z += step;
    println(marcher.gravity);
  }
  
  
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
  
  fill(0, 255, 0);
  textSize(50);
  textAlign(LEFT, TOP);
  text((int)frameRate, 20, 10);
  
  // Just a amall fix for touch screens
  pmousePressed = mousePressed;
}

int numShaderReloaded = 0;
void keyPressed() {
  if (key == 'r') {
    println("Reloading renderer... (" + (++numShaderReloaded) + ")");
    marcher.reloadRenderer();
  } else if (key == '+') {
    marcher.pixelScalingFactor += 1;
    println("Pixel scale is now: " + marcher.pixelScalingFactor);
  } else if (key == '-') {
    marcher.pixelScalingFactor -= 1;
    if (marcher.pixelScalingFactor < 1) marcher.pixelScalingFactor = 1;
    println("Pixel scale is now: " + marcher.pixelScalingFactor);
  }
}

void mouseWheel(MouseEvent e) {
  marcher.fov += radians(fovChangeSensitivity) * e.getCount();
  marcher.fov = radians(round(degrees(marcher.fov) / fovChangeSensitivity) * fovChangeSensitivity); // Snap fov to the nearest n degrees
  marcher.fov = constrain(marcher.fov, radians(1), radians(179));
  println("Current FOV: " + round(degrees(marcher.fov)));
}
