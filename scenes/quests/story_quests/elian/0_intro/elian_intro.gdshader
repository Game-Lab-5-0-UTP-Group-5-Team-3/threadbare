shader_type canvas_item;
render_mode unshaded;

// === CONFIGURACIÓN GENERAL ===
uniform int columns = 4;                // número de pantallas horizontales
uniform int rows = 4;                   // número de pantallas verticales
uniform float border_thickness = 0.03;  // grosor del marco negro

// === COLORES ===
uniform vec3 screen_color = vec3(1.0);           // blanco puro
uniform vec3 border_color = vec3(0.0);           // negro puro
uniform vec3 line_color = vec3(0.0, 1.0, 0.0);   // verde Matrix

// === EFECTO MATRIX ===
uniform float fall_speed = 1.0;       // velocidad de caída
uniform float line_density = 40.0;    // densidad (más alto = más líneas)
uniform float line_spacing = 0.015;   // espacio entre líneas (más alto = más separación)
uniform float line_thickness = 0.02;  // grosor visible de las líneas
uniform float brightness = 1.5;       // brillo general de las líneas

// === FUNCIÓN DE RUIDO ===
float hash21(vec2 p) {
	p = fract(p * vec2(234.34, 543.45));
	p += dot(p, p + 23.34);
	return fract(p.x * p.y);
}

// === FUNCIÓN PRINCIPAL ===
void fragment() {
	vec2 uv = UV;

	// --- División de cuadrícula ---
	vec2 grid_uv = uv * vec2(float(columns), float(rows));
	vec2 cell = fract(grid_uv);
	vec2 id = floor(grid_uv);

	// --- Bordes entre pantallas ---
	float bx = step(border_thickness, cell.x) * step(cell.x, 1.0 - border_thickness);
	float by = step(border_thickness, cell.y) * step(cell.y, 1.0 - border_thickness);
	float inside = bx * by;

	// --- Fondo blanco + bordes negros ---
	vec3 col = mix(border_color, screen_color, inside);

	// --- Efecto Matrix (líneas cayendo) ---
	float seed = hash21(id);
	float time_offset = TIME * fall_speed + seed;

	// Multiplicamos densidad por el tamaño de la celda para escalar correctamente
	float x_pattern = fract(cell.x * line_density + seed);
	float y_scroll = fract(cell.y + time_offset);

	// Definir líneas verticales (más visible sobre blanco)
	float lines = smoothstep(0.5 - line_thickness, 0.5 + line_thickness, x_pattern);

	// Movimiento vertical (la "lluvia")
	float mask = smoothstep(0.0, 0.3, 1.0 - y_scroll);

	// Aplicamos espaciado configurable
	float spacing_mod = step(line_spacing, abs(fract(x_pattern / (line_spacing + 0.001)) - 0.5));

	// Color final de las líneas
	vec3 matrix_color = line_color * lines * mask * spacing_mod * brightness;

	// Combinamos sobre el fondo
	col = mix(col, matrix_color, inside);

	COLOR = vec4(col, 1.0);
}
