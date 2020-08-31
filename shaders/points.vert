#version 330

#extension GL_ARB_explicit_uniform_location: enable

layout(location = 0) uniform mat4 PVM;

layout(location = 0) in vec3 point;

void main()
{
	gl_Position = PVM * vec4(point.x, point.y, 0.0, 1.0);
	gl_PointSize = point.z;
}
