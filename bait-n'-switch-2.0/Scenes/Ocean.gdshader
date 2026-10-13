shader_type spatial;
render_mode unshaded; 

uniform float pixel_size : hint_range(1.0, 512.0, 1.0) = 128.0; 
uniform float texture_scale : hint_range(0.1, 100.0, 0.1) = 500.0; 
uniform vec4 water_color : source_color = vec4(0.1, 0.4, 0.8, 1.0);
uniform vec4 foam_color : source_color = vec4(0.8, 0.9, 1.0, 1.0);
uniform sampler2D wave_texture : filter_nearest, repeat_enable;
uniform float time_scale = 0.5;

void fragment() {
    // Tiling: Multiply UV by texture_scale BEFORE pixelating it
    vec2 scaled_uv = UV * texture_scale;
    
    // Quantize the scaled UV grid
    vec2 pixelated_uv = floor(scaled_uv * pixel_size) / pixel_size;
    
    // Animate - Arise thine creation
    vec2 animated_uv = pixelated_uv + TIME * 0.05 * time_scale;
    
    // Sample the wave noise
    float wave = texture(wave_texture, animated_uv).r;
    
    // Color banding / quantization step
    float steps = 4.0;
    wave = floor(wave * steps) / steps;
    
    vec4 final_color = mix(water_color, foam_color, wave);
    ALBEDO = final_color.rgb;
}