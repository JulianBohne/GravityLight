
class RayMarcher {
  private PShader renderer;
  private PShader errorShader;

  float fov = radians(90);
  float pitch = 0;
  float yaw = 0;
  PVector viewPos = new PVector(0, 0, -2);

  RayMarcher() {
    reloadRenderer();
    errorShader = loadShader("Error.glsl");
  }

  void reloadRenderer() {
    renderer = loadShader("RayMarcher.glsl");
  }

  void render() {
    renderer.set("resolution", (float)width, (float)height);
    renderer.set("fov", fov);
    renderer.set("pitch", pitch);
    renderer.set("yaw", yaw);
    renderer.set("viewPos", viewPos);
    
    try {
      shader(renderer);
    } catch(RuntimeException e){
      println(e.toString());
      shader(errorShader);
    }
    rect(0, 0, width, height);
    resetShader();
  }
}
