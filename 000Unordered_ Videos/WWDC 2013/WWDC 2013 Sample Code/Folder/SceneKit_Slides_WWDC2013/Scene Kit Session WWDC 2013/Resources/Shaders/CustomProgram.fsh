// interpolated values, computed by the vertex shader
varying vec2 v_uv;
varying float v_color;

void main( void ) {
    const float sinPi4 = 0.7071;

    float feather = 0.3;

    // display a diamond shape
    float fade = pow(abs(v_uv.x) + abs(v_uv.y), feather);

    // rotate the texCoords 45 degrees to add a smaller
    // offseted diamond
    vec2 uv45 = vec2( v_uv.x * sinPi4 - v_uv.y * sinPi4,
                      v_uv.y * sinPi4 + v_uv.x * sinPi4);
    fade *= pow(abs(uv45.x) + abs(uv45.y), feather * 0.4);

    float col = v_color * max(1. - fade, 0.);
    // apply the final color in the fragment
	gl_FragColor = vec4(col, col, col, col);
}

