shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, shadows_disabled, specular_disabled, vertex_lighting;

uniform bool affine_mapping = false;
uniform sampler2D albedo : source_color, filter_nearest;
uniform float alpha_scissor : hint_range(0, 1) = 0.5;
uniform ivec2 resolution = ivec2(320, 240);

vec4 snap_to_position(vec4 base_position)
{
	vec4 snapped_position = base_position;
	
	// Convert to normalized device coordinates
	snapped_position.xyz = base_position.xyz / base_position.w;
	
	// Snap to pixel grid without jitter
	snapped_position.xy = floor(snapped_position.xy * vec2(resolution) + 0.5) / vec2(resolution);
	
	// Convert back to clip space
	snapped_position.xyz *= base_position.w;
	return snapped_position;
}

void vertex()
{
	vec4 world_space = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	vec4 clip_space = PROJECTION_MATRIX * world_space;
	vec4 snapped_position = snap_to_position(clip_space);
	
	if (affine_mapping)
	{
		POSITION = snapped_position;
		POSITION /= abs(POSITION.w);
	}
	else
	{
		POSITION = snapped_position;
	}
}

void fragment()
{
	vec4 color_base = COLOR;
	vec4 texture_color = texture(albedo, UV);

	ALBEDO = (color_base * texture_color).rgb;
	ALPHA = texture_color.a * color_base.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor;
}