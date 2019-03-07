// source position in the geometry
attribute vec4 a_srcPos;
// destination position in the geometry
attribute vec4 a_dstPos;
// texture coordinates in the geometry
attribute vec2 a_texcoord;
// ModelView transform
uniform mat4 u_mv;
// Projection transform
uniform mat4 u_proj;
// Morph factor
uniform float factor;
// Time
uniform float time;

// varying are interpolated and given to the fragment shaders
varying vec2 v_uv; // sprite texture coordinates
varying float v_color; // sprite color

void main()
{
    // Billboard sprite scale
    float scale = 0.4;
    // Billboard sprite angular speed
    float angularSpeed = 5.0;
    
    // morph the position between the source position (a_vertices) and the
    // destination position (a_normals), based on the "factor" uniform,
    // then transform it in view space.
    vec4 vsPos = u_mv * mix(a_srcPos, a_dstPos, factor);

    // Billboard sprite expansion, based on the texCoord cardinal values
    vsPos.xy += vec2(a_texcoord.x * scale, a_texcoord.y * scale);

	// project the position in Ndc
    gl_Position = u_proj * vsPos;

    // rotate the UVs based on given time (and offset basedon source position in the geometry, to avoid aligning all the sprites).
    float angle = angularSpeed * time + (a_srcPos.x + a_srcPos.y);
    float sn = sin(angle);
    float cs = cos(angle);
    v_uv = vec2( a_texcoord.x * cs - a_texcoord.y * sn, a_texcoord.y * cs + a_texcoord.x * sn);
    
    // colorized the sprite based on the source position in the geometry.
    v_color = pow(1. - abs(a_srcPos.y) / 7., 1.5);

}
