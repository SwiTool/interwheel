shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float strength = 0.01;
uniform float noise_scale = 3.0;
uniform float noise_speed = 0.7;
uniform vec4  rect_color : source_color = vec4(1.0);

// épaisseur en pixels écran voulue (indépendante de la taille du polygone)
uniform float foam_height_px = 10.0;
uniform float foam_feather_px = 2.0;

varying float v_y_local;   // y local (en “px” si scale=1, zoom=1)
varying float v_top_local; // y du sommet le plus haut (en local)

float hash(vec2 p){ p=fract(p*vec2(123.34,456.21)); p+=dot(p,p+45.32); return fract(p.x*p.y); }
float noise(vec2 p){
    vec2 i=floor(p), f=fract(p);
    vec2 u=f*f*(3.0-2.0*f);
    return mix(mix(hash(i+vec2(0,0)),hash(i+vec2(1,0)),u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),u.x),u.y);
}

void vertex() {
    // On capture la position locale du sommet courant
    v_y_local = VERTEX.y;
    // Astuce : on suppose que le haut du poly est au min des y locaux = 0
    // -> si ton polygone n’est pas ancré comme ça, décale tes points
    //    (ou remplace 0.0 par une constante/uniform que tu règles à la main)
    v_top_local = 0.0;
}

void fragment() {
    // Réfraction (screen-space)
    vec2 uvn = SCREEN_UV * noise_scale + vec2(TIME * noise_speed, 0.0);
    float n1 = noise(uvn);
    float n2 = noise(uvn + vec2(5.2,7.3));
    vec2 offset = (vec2(n1,n2)*2.0 - 1.0) * strength;
    vec4 refracted = texture(SCREEN_TEXTURE, SCREEN_UV + offset);

    // Distance (en "px") depuis le bord haut du polygone :
    // en 2D Godot, l’axe Y va vers le bas, donc “haut” = plus petit Y.
    float local_from_top = v_y_local - v_top_local; // 0 au bord haut

    float a = max(foam_height_px - foam_feather_px, 0.0);
    float b = foam_height_px;
    float foam_blend = 1.0 - smoothstep(a, b, local_from_top);

    vec3 final_rgb = mix(refracted.rgb * rect_color.rgb, vec3(1.0), foam_blend);
    COLOR = vec4(final_rgb, refracted.a * rect_color.a);
}