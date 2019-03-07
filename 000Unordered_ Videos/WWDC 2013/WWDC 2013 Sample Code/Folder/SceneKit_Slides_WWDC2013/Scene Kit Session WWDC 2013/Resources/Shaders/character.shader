#pragma transparent;

uniform float FresnelPower = 1.0;
uniform float ghostFactor = 0.0;
uniform float myTransparency = 0.0;

float saturateF = max(max(_output.color.r, _output.color.g), _output.color.b);
float fresnelFactor = 0.9;
float fresnel = pow(1.0 - abs(dot(_surface.view, _surface.normal)), FresnelPower);
fresnel = (1.0 - fresnelFactor) + fresnelFactor * fresnel;

vec4 colorGhost;
colorGhost.rgb = _output.color.rgb * fresnel / saturateF;
colorGhost.rgba = _output.color.rgba * fresnel;

_output.color.rgba = mix(_output.color, colorGhost, vec4(ghostFactor));
