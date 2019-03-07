attribute vec4 a_pos;
attribute vec2 a_uv;

uniform mat4 u_mvp;

varying vec2 v_uv;

void main()
{
	gl_Position = u_mvp * a_pos;
	v_uv = a_uv;

}
