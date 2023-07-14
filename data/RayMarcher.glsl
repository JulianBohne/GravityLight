#ifdef GL_ES
precision mediump float;
#endif

#define PROCESSING_COLOR_SHADER

const int maxSteps = 1000;
const float eps = 0.0001; // a small epsilon to determine a hit and other nudges

uniform vec2 resolution; // resolution of the canvas
uniform float fov; // field of view
uniform float viewDistance = 50.; // The maximum range of a ray

uniform float pitch = 0.;
uniform float yaw = 0.;

uniform vec3 viewPos = vec3(0., 0., -2.);

uniform vec3 skyColor = vec3(0.5, 0.7, 1);

uniform float floorHeight = -1.5;

vec3 screenPosToDirection(vec2 pos) {
    float dist = 1./tan(fov/2);
    return normalize(vec3(pos.x, pos.y, dist));
}

float easeOutCubic(float x) {
    return 1. - pow(1. - x, 3);
}

// https://www.shadertoy.com/view/Ml3Gz8
float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5*(a-b)/k, 0.0, 1.0);
    return mix(a, b, h) - k*h*(1.0-h);
}

vec3 rotateY(vec3 v, float angle) {
    return vec3(
         cos(angle) * v.x + sin(angle) * v.z,
                                         v.y,
        -sin(angle) * v.x + cos(angle) * v.z
    );
}

vec3 rotateX(vec3 v, float angle) {
    return vec3(
                                        v.x,
        cos(angle) * v.y - sin(angle) * v.z,
        sin(angle) * v.y + cos(angle) * v.z
    );
}

float or(float a, float b) {
    return min(a, b);
}

float and(float a, float b) {
    return max(a, b);
}

float sub(float a, float b) {
    return -smin(-a, b, 0.10);
}

// pos is the ray poisition
// center is the sphere position
float sphere(vec3 pos, vec3 center, float radius) {
    return length(pos - center) - radius;
}

float floorDist(vec3 pos) {
    return pos.y - floorHeight;
}

float dist(vec3 pos) {
    return or(
        floorDist(pos),
        sub(
            sphere(pos, vec3(0.), 0.5), 
            sphere(pos, vec3(0., 0., -.5), 0.5)
        )
    );
}

// https://iquilezles.org/articles/normalsSDF/
vec3 calcNormal(vec3 pos) {
    const vec2 h = vec2(eps, 0);
    return normalize(vec3(
        dist(pos + h.xyy) - dist(pos - h.xyy),
        dist(pos + h.yxy) - dist(pos - h.yxy),
        dist(pos + h.yyx) - dist(pos - h.yyx)
    ));
}

vec3 getColor(vec3 pos) {
    float closestDist = floorDist(pos);
    vec3 color = mod(floor(pos.x) + floor(pos.z), 2) * vec3(1.);
    float currentDist = sub(
        sphere(pos, vec3(0.), 0.5), 
        sphere(pos, vec3(0., 0., -.5), 0.5)
    );
    bool isCloser = currentDist < closestDist;
    color = mix(color, vec3(0.9, 0., 0.), float(isCloser));
    closestDist = mix(closestDist, currentDist, float(isCloser));
    return color;
}

vec3 trace(vec3 pos, vec3 dir) {
    bool skyCond = false; // did we reach the sky yet?
    int i = 0; // iteration count
    float stepDist = dist(pos);
    float totalDist = 0.;

    vec3 tint = vec3(1.);

    while(!skyCond && stepDist >= eps) {
        pos += dir * stepDist;
        
        totalDist += stepDist;
        stepDist = dist(pos);
        i ++;

        skyCond = (i >= maxSteps || totalDist >= viewDistance);

        if (stepDist < eps && pos.y > -1.) {
            dir = reflect(dir, calcNormal(pos));
            tint *= getColor(pos);
            stepDist = eps;
        }
    }

    return tint * (mix(getColor(pos), skyColor, easeOutCubic(totalDist/viewDistance)) * float(!skyCond) + skyColor * float(skyCond));
}

void main(void) {
    vec2 coord = (gl_FragCoord.xy - resolution/2) / resolution.x*2;
    vec3 dir = rotateY(rotateX(screenPosToDirection(coord), pitch), yaw);
    gl_FragColor = vec4(trace(viewPos, dir), 1.);
}