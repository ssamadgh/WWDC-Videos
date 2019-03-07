#version 120

attribute vec4 a_pos;
attribute vec3 a_vel;
attribute vec2 a_uv; // angle, life

uniform mat4 u_mv;

varying vec3 v_params; // angle, scale, life
varying vec4 v_pos;
varying vec3 v_vel;

void main()
{
	gl_Position = u_mv * vec4(a_pos.xyz, 1.0);
    v_params = vec3(a_uv.x, a_pos.w, a_uv.y);
    v_vel = mat3(u_mv) * a_vel;
}
