varying vec2 v_uv;
void main( void ) {
    float alpha = pow(v_uv.x, 1.5);
	gl_FragColor = vec4( 1.0, 1.0, 1.0, alpha);
}

