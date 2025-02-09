
public class RayMarcher {
  
  private int ppixelScalingFactor;
  int pixelScalingFactor = 5;
  
  private PGraphics canvas;
  private PImage bilinearFilterWorkaround;
  private PShader renderer;
  private PShader errorShader;
  
  private int pwidth, pheight;

  float fov = radians(90);
  float pitch = 0;
  float yaw = 0;
  PVector viewPos = new PVector(0, 0, -2);
  PVector gravity = new PVector(0, -0.05, 0);

  RayMarcher() {
    errorShader = loadShader("Error.glsl");
    reloadRenderer();
    initializeGraphics();
    
    ppixelScalingFactor = pixelScalingFactor;
    
    // Detecting window resize
    pwidth = width;
    pheight = height;
    registerMethod("pre", this);
  }
  
  void setPixelScalingFactor(int factor) {
    pixelScalingFactor = factor;
    initializeGraphics();
  }
  
  void initializeGraphics() {
    canvas = createGraphics(width/pixelScalingFactor, height/pixelScalingFactor, P2D);
    bilinearFilterWorkaround = createImage(canvas.width, canvas.height, ARGB);
  }
  
  void pre() {
    if (pwidth != width || pheight != height || ppixelScalingFactor != pixelScalingFactor) {
      pwidth = width;
      pheight = height;
      ppixelScalingFactor = pixelScalingFactor;
      initializeGraphics();
    }
  }

  void reloadRenderer() {
    renderer = loadShader("RayMarcher.glsl");
  }

  void render() {
    canvas.beginDraw();
    try {
      canvas.shader(renderer);
    } catch(RuntimeException e){
      println(e.toString());
      canvas.shader(errorShader);
      renderer = errorShader;
    }
    if(renderer != errorShader){
      
      renderer.set("resolution", (float)canvas.width, (float)canvas.height);
      renderer.set("fov", fov);
      renderer.set("pitch", pitch);
      renderer.set("yaw", yaw);
      renderer.set("viewPos", viewPos);
      renderer.set("gravity", gravity);
      
    }
    
    canvas.rect(0, 0, canvas.width, canvas.height);
    canvas.endDraw();
    // Yuck
    bilinearFilterWorkaround.copy(canvas, 0, 0, canvas.width, canvas.height, 0, 0, bilinearFilterWorkaround.width, bilinearFilterWorkaround.height);
    image(bilinearFilterWorkaround, 0, 0, width, height);
  }
}
