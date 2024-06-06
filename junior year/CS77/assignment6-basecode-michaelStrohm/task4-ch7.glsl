#include "common.glsl"

struct ray
{
    vec3 origin;    // this is the origin of the ray
    vec3 direction; // this is the direction the ray is pointing in
};

struct hit_record {
    float t;
    vec3 p;
    vec3 normal;
    bool front_face;
};
struct sphere {
    vec3 center;
    float radius;
};


/////////////////////////////
struct camera {
    vec3 center;
    vec3 viewport_lower_left;
    vec3 viewport_u;
    vec3 viewport_v;
    vec3 pixel_delta_u;
    vec3 pixel_delta_v;
};
//moved these functions to camera
camera get_camera() {
    // Image
    float aspect_ratio = iResolution.x / iResolution.y;
    float image_width = iResolution.x;
    float image_height = iResolution.y;

    // Camera
    float focal_length = 1.0;
    float viewport_height = 2.0;
    float viewport_width = viewport_height * aspect_ratio;
    vec3 center = vec3(0.0, 0.0, 0.0);

    // Calculate the vectors across the horizontal and up the vertical viewport edges.
    vec3 viewport_u = vec3(viewport_width, 0.0, 0.0);

    //made this positive because gl_fragcoord starts at bottom left so later on declaring y is easier
    vec3 viewport_v = vec3(0.0, viewport_height, 0.0);

    // Calculate the horizontal and vertical delta vectors from pixel to pixel.
    vec3 pixel_delta_u = viewport_u / iResolution.x;
    vec3 pixel_delta_v = viewport_v / iResolution.y;

    // Calculate the location of the lower left pixel.
    vec3 viewport_lower_left = center - vec3(0.0, 0.0, focal_length) - viewport_u / 2.0 - viewport_v / 2.0;

    return camera(center, viewport_lower_left, viewport_u, viewport_v,pixel_delta_u,pixel_delta_v);
}

ray get_ray(const camera cam, float u, float v) {
    return ray(cam.center, cam.viewport_lower_left + u * cam.viewport_u + v * cam.viewport_v - cam.center);
}
////////////////////////////


//set face normal as a function outside of struct
void set_face_normal(inout hit_record rec, const ray r, const vec3 outward_normal) {
    rec.front_face = dot(r.direction, outward_normal) < 0.0;
    rec.normal = rec.front_face ? outward_normal : -outward_normal;
}



//made hit_sphere use sphere struct and hit record
bool hit_sphere(const sphere s, const ray r, float ray_tmin, float ray_tmax, out hit_record rec) {
    vec3 oc = r.origin - s.center;
    //length squared replaced with dot
    float a = dot(r.direction,r.direction);
    float half_b = dot(oc, r.direction);
    float c = dot(oc,oc) - s.radius*s.radius;
    float discriminant = half_b*half_b - a*c;

    if (discriminant < 0.0) return false;
    float sqrt_discriminant = sqrt(discriminant);

    //find the nearest root in range
    float root = (-half_b - sqrt_discriminant) / a;
    if (root < ray_tmin || root > ray_tmax) {
        root = (-half_b + sqrt_discriminant) / a;
        //checks both intersection points and if both ar enegative sphere is not visible
        if (root < ray_tmin || root > ray_tmax) return false;
    }

    //uses hit record her einstead of just returning
    rec.t = root;
    rec.p = r.origin + root * r.direction;
    vec3 outward_normal = (rec.p - s.center) / s.radius;
    set_face_normal(rec, r, outward_normal);

    return true;

}

vec3 ray_color(const ray r) {
    //updated spheres ot array
    sphere spheres[2];
    spheres[0] = sphere(vec3(0, 0, -1), 0.5);
    spheres[1] = sphere(vec3(0, -100.5, -1), 100.0); 

    //added temp rec for multiple spheres
    hit_record temp_rec;
    hit_record rec;
    bool hit_anything = false;
    //essentially infinity
    float closest_so_far = MAX_FLOAT; 


    for (int i = 0; i < 2; i++) {
        if (hit_sphere(spheres[i], r, 0.0, closest_so_far, temp_rec)) {
            //if we hit anything make sure it is closest and assign rec
            hit_anything = true;
            closest_so_far = temp_rec.t;
            rec = temp_rec;
        }
    }

    if (hit_anything) {
        return 0.5 * (rec.normal + vec3(1.0, 1.0, 1.0));
    }
    vec3 unit_direction = normalize(r.direction);
    float a = 0.5 * (unit_direction.y + 1.0);
    return (1.0 - a) * vec3(1.0, 1.0, 1.0) + a * vec3(0.5, 0.7, 1.0);
}

//////////////////////////////////////////
void main()
{
    init_rand(gl_FragCoord.xy, iTime);
    camera cam = get_camera();
    vec3 color = vec3(0.0, 0.0, 0.0);
    int samples_per_pixel = 100;
    float x = gl_FragCoord.x;
    float y = gl_FragCoord.y;

     for (int s = 0; s < samples_per_pixel; s++) {
        //adding random seed to x and y
        float u = (x + rand1(g_seed));
        float v = (y + rand1(g_seed));

        //regular code as normal but need to average after
        vec3 pixel_center = cam.viewport_lower_left + u * cam.pixel_delta_u + v * cam.pixel_delta_v;
        vec3 ray_direction = pixel_center - cam.center;
        ray r;
        r.origin = cam.center;
        r.direction = ray_direction;
        color += ray_color(r);
    }

    //averaging here
    color /= float(samples_per_pixel);
    gl_FragColor = vec4(color, 1.0);


}