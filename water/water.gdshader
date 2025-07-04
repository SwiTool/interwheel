shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float strength    = 0.01;
uniform float noise_scale = 3.0;
uniform float noise_speed = 0.7;
uniform vec4  rect_color : source_color = vec4(1.0,1.0,1.0,1.0);

// une fonction de hash rapide
float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

// interpolation smoothstep
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(
        mix(hash(i + vec2(0.,0.)), hash(i + vec2(1.,0.)), u.x),
        mix(hash(i + vec2(0.,1.)), hash(i + vec2(1.,1.)), u.x),
        u.y
    );
}

void fragment() {
    // calcule un offset de bruit
    vec2 uvn = SCREEN_UV * noise_scale + vec2(TIME * noise_speed);
    float n1 = noise(uvn);
    float n2 = noise(uvn + vec2(5.2,7.3));
    vec2 offset = (vec2(n1,n2)*2.0 - 1.0) * strength;

    // prélève l’arrière-plan
    vec4 refracted = texture(SCREEN_TEXTURE, SCREEN_UV + offset);
    // applique ta couleur de rect (teinte + alpha)
    COLOR = vec4(refracted.rgb * rect_color.rgb,
                 refracted.a   * rect_color.a);
}