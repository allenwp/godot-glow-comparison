shader_type spatial;
render_mode unshaded;

uniform float log2_min = -18.0;
uniform float log2_max = 5.0;
uniform bool clip_to_max = false;
uniform float max_value = 10;
uniform bool clip_in_bt2020 = true;
uniform bool srgb = false;

vec3 linear_to_srgb(vec3 color) {
	const vec3 a = vec3(0.055f);
	return mix((vec3(1.0f) + a) * pow(color.rgb, vec3(1.0f / 2.4f)) - a, 12.92f * color.rgb, lessThan(color.rgb, vec3(0.0031308f)));
}

void fragment() {
	vec3 color;
	float top_bar = 0.4;
	float log2_value = UV.x * (log2_max - log2_min) + log2_min;
	float scale = pow(2.0, log2_value);

	if (UV.y >= top_bar)
	{
		float padding = 0.005;
		float y = (UV.y - top_bar - padding) / (1.0 - top_bar - padding * 2.0);
		y = clamp(y, 0.0, 1.0);
		float segments = 1.0 / 6.0;
		vec3 col = vec3(0);
		if (y < segments)
		{
			col.r = 1.0;
			col.g = y / segments;
			col.b = 0.0;
		}
		else if (y < segments * 2.0)
		{
			col.r = (y - segments * 2.0) / -segments;
			col.g = 1.0;
			col.b = 0.0;
		}
		else if (y < segments * 3.0)
		{
			col.r = 0.0;
			col.g = 1.0;
			col.b = (y - segments * 2.0) / segments;
		}
		else if (y < segments * 4.0)
		{
			col.r = 0.0;
			col.g = (y - segments * 4.0) / -segments;
			col.b = 1.0;
		}
		else if (y < segments * 5.0)
		{
			col.r = (y - segments * 4.0) / segments;
			col.g = 0.0;
			col.b = 1.0;
		}
		else
		{
			col.r = 1.0;
			col.g = 0.0;
			col.b = (y - segments * 6.0) / -segments;
		}

		color = col * scale;

		if (clip_to_max) {
			// TODO: maybe also give an option for P3 primaries?
			const mat3 LINEAR_SRGB_TO_LINEAR_REC2020 = mat3(
					vec3(0.627403895934699, 0.069097289358232, 0.016391438875150),
					vec3(0.329283038377884, 0.919540395075458, 0.088013307877226),
					vec3(0.043313065687417, 0.011362315566309, 0.895595253247624));

			const mat3 LINEAR_REC2020_TO_LINEAR_SRGB = mat3(
					vec3(1.660491002108435, -0.124550474521591, -0.018150763354905),
					vec3(-0.587641138788550, 1.132899897125961, -0.100578898008007),
					vec3(-0.072849863319885, -0.008349422604369, 1.118729661362913));

			if (clip_in_bt2020) {
				color = LINEAR_SRGB_TO_LINEAR_REC2020 * color;
			}
			color = min(color, max_value);
			if (clip_in_bt2020) {
				color = LINEAR_REC2020_TO_LINEAR_SRGB * color;
			}
		}
	}
	else
	{
		color = vec3(1.0) * scale;

		if (UV.y < 0.01) {
			// Max  value mark:
			float max_log2 = log2(max_value);
			float scale_log2 = log2(scale);
			float mark_size = 0.03;
			if (scale_log2 > max_log2 - mark_size && scale_log2 < max_log2 + mark_size) {
				color = vec3(0);
			}
		} else if (UV.y > 0.03) {
			// Log scale marks:
			float tick_col = scale > 0.184 ? 0.0 : 1.0;
			while (scale >= 1.0) {
				scale /= 10.0;
			}
			while (scale < 0.1) {
				scale *= 10.0;
			}
			float tick_threshold = scale * 0.02;
			if ((scale > 1.0 - tick_threshold && scale < 1.0 + tick_threshold)
				|| (scale > 0.0 - tick_threshold && scale < 0.0 + tick_threshold)
				|| (scale > 0.1 - tick_threshold && scale < 0.1 + tick_threshold)) {
				color = vec3(tick_col);
			} else if (UV.y > 0.04
				&& ((scale > 0.9 - tick_threshold && scale < 0.9 + tick_threshold)
				|| (scale > 0.8 - tick_threshold && scale < 0.8 + tick_threshold)
				|| (scale > 0.7 - tick_threshold && scale < 0.7 + tick_threshold)
				|| (scale > 0.6 - tick_threshold && scale < 0.6 + tick_threshold)
				|| (scale > 0.5 - tick_threshold && scale < 0.5 + tick_threshold)
				|| (scale > 0.4 - tick_threshold && scale < 0.4 + tick_threshold)
				|| (scale > 0.3 - tick_threshold && scale < 0.3 + tick_threshold)
				|| (scale > 0.2 - tick_threshold && scale < 0.2 + tick_threshold))) {
				color = vec3(tick_col);
			}
		}

		if (clip_to_max) {
			color = min(color, max_value);
		}
	}

	if (srgb) {
		color.rgb = linear_to_srgb(color.rgb);
	}
	ALBEDO = color;
}
