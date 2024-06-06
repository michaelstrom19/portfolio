//
// Ray
//

struct ray
{
    vec3 origin;    // this is the origin of the ray
    vec3 direction; // this is the direction the ray is pointing in
};

//////////////////////////////////////////////////////////////////
//                      TASK 2                                  //
bool hit_sphere(vec3 center, float radius, const ray r) {
    vec3 oc = r.origin - center;
    float a = dot(r.direction, r.direction);
    float b = 2.0 * dot(oc, r.direction);
    float c = dot(oc, oc) - radius*radius;
    float discriminant = b*b - 4.0*a*c;
    return (discriminant >= 0.0);
}

vec3 ray_color(const ray r) {
    if (hit_sphere(vec3(0,0,-1), 0.5, r))
    return vec3(1, 0, 0);
//                                                              //
//////////////////////////////////////////////////////////////////

    vec3 unit_direction = normalize(r.direction);
    float a = 0.5 * (unit_direction.y + 1.0);
    return (1.0 - a) * vec3(1.0, 1.0, 1.0) + a * vec3(0.5, 0.7, 1.0);
}

void main()
{
    // Image
    float aspect_ratio = iResolution.x / iResolution.y;
    float image_width = iResolution.x;
    float image_height = iResolution.y;

    // Camera
    float focal_length = 1.0;
    float viewport_height = 2.0;
    float viewport_width = viewport_height * aspect_ratio;
    vec3 camera_center = vec3(0.0, 0.0, 0.0);

    // Calculate the vectors across the horizontal and up the vertical viewport edges.
    vec3 viewport_u = vec3(viewport_width, 0.0, 0.0);

    //made this positive because gl_fragcoord starts at bottom left so later on declaring y is easier
    vec3 viewport_v = vec3(0.0, viewport_height, 0.0); 

    // Calculate the horizontal and vertical delta vectors from pixel to pixel.
    vec3 pixel_delta_u = viewport_u / image_width;
    vec3 pixel_delta_v = viewport_v / image_height;

    // Calculate the location of the lower left pixel.
    vec3 viewport_lower_left = camera_center - vec3(0.0, 0.0, focal_length) - viewport_u / 2.0 - viewport_v / 2.0;
    vec3 pixel00_loc = viewport_lower_left + 0.5 * (pixel_delta_u + pixel_delta_v);

    // Render

    //replace i and j with respective fragcoord
    float x = gl_FragCoord.x;
    float y = gl_FragCoord.y;
    vec3 pixel_center = pixel00_loc + (x * pixel_delta_u) + (y * pixel_delta_v);
    vec3 ray_direction = pixel_center - camera_center;

    ray r;
    r.origin = camera_center;
    r.direction = ray_direction;

    //make color
    vec3 color = ray_color(r);
    gl_FragColor = vec4(color, 1.0);
}