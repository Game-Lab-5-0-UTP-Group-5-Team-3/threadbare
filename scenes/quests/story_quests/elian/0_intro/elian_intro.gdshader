shader_type canvas_item;
render_mode blend_mix, unshaded;

uniform vec4 frame_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float frame_thickness = 0.06;
uniform float base_extra = 0.04;
uniform float curvature = 0.15;
uniform float brightness = 1.0;
uniform float scanline_strength = 0.08;
uniform float flicker_strength = 0.02;
uniform float flicker_speed = 120.0;

uniform sampler2D chars;     // textura de caracteres
uniform sampler2D noise_tex; // textura de ruido
uniform float char_scale = 32.0;

void fragment() {
    vec2 uv = SCREEN_UV;

    // --- Curvatura tipo CRT ---
    uv = uv * 2.0 - 1.0;
    uv.x *= 1.0 + curvature * pow(abs(uv.y), 2.0);
    uv.y *= 1.0 + curvature * pow(abs(uv.x), 2.0);
    uv = uv * 0.5 + 0.5;

    // --- Marco con base ---
    float bottom_extra = base_extra;
    float left   = step(frame_thickness, uv.x);
    float right  = step(frame_thickness, 1.0 - uv.x);
    float top    = step(frame_thickness, uv.y);
    float bottom = step(frame_thickness + bottom_extra, 1.0 - uv.y);
    float mask = left * right * top * bottom;

    // --- Lluvia digital estilo Matrix ---
    vec2 uv_chars = fract(uv * char_scale);
    float n = texture(noise_tex, uv).g;
    float scroll = fract(uv.y + TIME * 2.0 + n);
    vec2 char_uv = (uv_chars + vec2(n, scroll)) / char_scale;
    vec3 char_color = texture(chars, char_uv).rgb;
    float drop = step(0.98, fract(scroll * 10.0));
    vec3 rain_color = char_color * drop * vec3(0.0, 1.0, 0.0);

    // --- Efectos CRT ---
    float scanline = sin(uv.y * 800.0) * scanline_strength;
    float flicker = sin(TIME * flicker_speed) * flicker_strength;
    float light = brightness + flicker - scanline;
    vec3 screen_col = rain_color * light;

    // --- Combinamos marco + pantalla ---
    vec3 frame_col = frame_color.rgb;
    vec3 final_col = mix(frame_col, screen_col, mask);

    COLOR = vec4(final_col, 1.0);
}

