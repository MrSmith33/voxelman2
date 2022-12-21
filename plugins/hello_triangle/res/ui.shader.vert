#version 450

layout(row_major) layout(set = 0, binding = 0) uniform UniformBufferObject {
	vec2 screenSize;
} ubo;

layout(location = 0) in vec2 inPosition;
layout(location = 1) in vec2 inTexCoord;
layout(location = 2) in vec3 inColor;

layout(location = 0) out vec3 fragColor;
layout(location = 1) out vec2 fragTexCoord;

void main() {
	// gl_Position = vec4(inPosition, 0.0, 1.0);
	gl_Position = vec4((inPosition / ubo.screenSize) * 2 - 1, 0.0, 1.0);
	fragColor = inColor;
	fragTexCoord = inTexCoord;
}