#include "common.glsl"
#include "ray.glsl"

#iChannel0 "file://environment_maps/Uffizi_{}.jpg"
#iChannel0::Type "CubeMap"

// shade mode
#define GRID 0
#define COST 1
#define NORMAL 2
#define DIFFUSE_POINT 3
#define ENVIRONMENT_MAP 4
#define SUNLIGHT 5

// settings struct found on line 152 in sdf.glsl
// variable order = settings(sdf_func, shade_mode, marching_type, task_world, animation_speed)
settings render_settings = settings(NONE, ENVIRONMENT_MAP, NONE, TASK4, 0.35);

#define PROJECTION_ORTHOGRAPHIC 0
#define PROJECTION_PERSPECTIVE 1

int projection_func = PROJECTION_PERSPECTIVE;

int cost_norm = 200;

vec3 shade(ray r, int iters, settings setts)
{
    vec3 p = r.origin;
    vec3 d = r.direction;

    if (setts.shade_mode == GRID)
    {
        float res = 0.2;
        float one = abs(mod(p.x, res) - res / 2.0);
        float two = abs(mod(p.y, res) - res / 2.0);
        float three = abs(mod(p.z, res) - res / 2.0);
        float interp = min(one, min(two, three)) / res;

        return mix(vec3(0.2, 0.5, 1.0), vec3(0.1, 0.1, 0.1), smoothstep(0.0, 0.05, abs(interp)));
    }
    else if (setts.shade_mode == COST)
    {
        return vec3(float(iters) / float(cost_norm));
    }
    else if (setts.shade_mode == NORMAL)
    {

// ################ Edit your code below ################

        //// TASK 4.1

    //normalize
    vec3 normal = computeNormal(p,setts);

    //mix with white
    return mix(normal, vec3(1.0), 0.5);


    }
    else if (setts.shade_mode == DIFFUSE_POINT)
    {
        vec3 light_pos = vec3(0.0, 5.0, 0.0);
        vec3 light_intensity = vec3(5.0);
        vec3 surface_color = vec3(0.5);


// ################ Edit your code below ################

        //// TASK 4.2
    //normalize
    vec3 normal = computeNormal(p,setts);

    //this part is similar to our assignment 4
    vec3 light_dir = normalize(light_pos - p);
    float dist = length(light_pos - p);

    //lambert
    float lam = max(dot(normal, light_dir), 0.0);

    //light attenuation
    float attenuation = 1.0 / (dist * dist);

    vec3 diffuse = surface_color * light_intensity * lam * attenuation;

    return diffuse;
    }
    else if (setts.shade_mode == ENVIRONMENT_MAP)
    {

// ################ Edit your code below ################

      vec3 normal = computeNormal(p,setts);

    //reflect
    vec3 viewDir = normalize(-r.origin); //reversing for view
    vec3 reflectDir = reflect(viewDir, normal);

    //get from texture mao
    vec3 envColor = texture(iChannel0, reflectDir).rgb;

    return envColor;
    }
    else if (setts.shade_mode == SUNLIGHT) {

        vec3 col = vec3(0.0);
        vec3 sunPosition = vec3(0.0, 0.0, 0.0);
        vec3 lightDirection = normalize(sunPosition - p);

        float sunDistance = length(p - sunPosition) - 0.151; //sun radius plus a tiny amount
        if (sunDistance < 0.0) {
            //render the sun as light color
            return vec3(1, 0.85, 0.45);
        }
    
           vec3 normal = computeNormal(p,setts);

            float diff = max(dot(normal, lightDirection), 0.0);
            vec3 diffuseColor = vec3(1, 0.85, 0.45); // Warm sunlight color
            col = diff * diffuseColor;
        return col;
    }

    return vec3(0.0);
}

//////////////////////////////////////////////////////////////////////////////////
// we will be replacing all of the code below with our own method(s). All of    //
// the changes you make will be disgarded. But feel free to change the main     //
// method to help debug your code.                                              //
//////////////////////////////////////////////////////////////////////////////////

vec3 render(settings setts)
{
    vec2 p = (2.0 * gl_FragCoord.xy - iResolution.xy) / iResolution.y;

    if (p.y < -0.95)
    {
        float val = cos(iTime * setts.anim_speed);
        return shade_progress_bar(p, iResolution.xy, val);
    }

    float aspect = iResolution.x / iResolution.y;
    vec2 uv = gl_FragCoord.xy / iResolution.xy - 0.5;
    uv.x *= aspect;

    // Rotate the camera
    vec3 eye = vec3(-3.0 * cos(iTime * 0.2), 2.0 + 0.5 * sin(iTime * 0.1), -3.0 * sin(iTime * 0.2));
    vec3 dir = vec3(0.0, 0.0, 0.0) - eye;
    vec3 up = vec3(0, 1, 0);

    float focal_length = 2.;

    vec3 u, v, w;
    compute_camera_frame(dir, up, u, v, w);

    ray r;
    switch (projection_func)
    {
    case PROJECTION_ORTHOGRAPHIC:
        r = generate_ray_orthographic(uv, eye, u, v, w);
        break;

    case PROJECTION_PERSPECTIVE:
        r = generate_ray_perspective(uv, eye, u, v, w, focal_length);
        break;
    }

    int max_iter = 1000;

    vec3 col = vec3(0.0);

    vec3 hit_loc;
    int iters;
    bool hit;

    if (sphere_tracing(r, max_iter, setts, hit_loc, iters))
    {
        r.origin = hit_loc;
        col = shade(r, iters, setts);
    }

    return pow(col, vec3(1.0 / 2.2));
}

void main()
{
    gl_FragColor = vec4(render(render_settings), 1.0);
}