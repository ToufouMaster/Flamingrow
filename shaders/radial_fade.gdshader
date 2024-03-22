shader_type canvas_item;

uniform float time; // Update this each frame. Larger value = larger radius
uniform vec2 center; // The point towards which it will fade out, in pixels
uniform vec4 inColor;
uniform vec4 outColor;

void fragment() {
	// Distance between this pixel and the middle of the screen
    float dist = distance(VERTEX, center);

    if (dist < time) {
		COLOR = inColor;
	} else {
		COLOR = outColor;
	}
}