#ifdef GL_ES
precision mediump float;
#endif

#define PROCESSING_COLOR_SHADER

void main(void) {
    gl_FragColor = vec4(1., .2, .2, 1.);
}