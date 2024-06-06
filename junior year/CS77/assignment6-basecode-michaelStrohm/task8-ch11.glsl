#include "common.glsl"
#define MATERIAL_LAMBERTIAN 0
#define MATERIAL_METAL 1
#define MATERIAL_DIELECTRIC 2

struct material {
    vec3 albedo;
    int type;
    float fuzz;
    float index_of_refraction;
};

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
    material mat;
};

struct sphere {
    vec3 center;
    float radius;
    material mat;
};

/////////////////////////////////////////////////////////////////////
struct camera {
    vec3 center;
    vec3 viewport_lower_left;
    vec3 viewport_u;
    vec3 viewport_v;
    vec3 pixel_delta_u;
    vec3 pixel_delta_v;
    vec3 u, v, w;
};
//moved these functions to camera, also added inputs to get_cam
camera get_camera(vec3 lookfrom, vec3 lookat, vec3 vup, float vfov) {

    ///it became easier to make a 
    //camera object and return that for readability

    //basically just implemented camera code from book, 
    //this one didnt take as much change as other tasks for glsl
    camera cam;
    float aspect_ratio = iResolution.x / iResolution.y;
    float theta = radians(vfov);
    float h = tan(theta / 2.0);
    float viewport_height = 2.0 * h;
    float viewport_width = aspect_ratio * viewport_height;

    cam.w = normalize(lookfrom - lookat); 
    cam.u = normalize(cross(vup, cam.w));
    cam.v = cross(cam.w, cam.u);

    cam.center = lookfrom;

    cam.viewport_lower_left = cam.center - viewport_width / 2.0 * cam.u - viewport_height / 2.0 * cam.v - cam.w;
    cam.viewport_u = viewport_width * cam.u;
    cam.viewport_v = viewport_height * cam.v;

    cam.pixel_delta_u = cam.viewport_u / iResolution.x; 
    cam.pixel_delta_v = cam.viewport_v / iResolution.y; 
    return cam;
}
///////////////////////////////////////////////////////////////
ray get_ray(const camera cam, float u, float v) {
    return ray(cam.center, cam.viewport_lower_left + u * cam.viewport_u + v * cam.viewport_v - cam.center);
}


//set face normal as a function outside of struct
void set_face_normal(inout hit_record rec, const ray r, const vec3 outward_normal) {
    rec.front_face = dot(r.direction, outward_normal) < 0.0;
    if (rec.front_face){
        rec.normal = outward_normal;
    }
    else {
        rec.normal = -outward_normal;
    }
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
    rec.mat = s.mat;
    vec3 outward_normal = (rec.p - s.center) / s.radius;
    rec.normal = outward_normal;

    set_face_normal(rec, r, outward_normal);

    return true;

}





// Schlick's approximation for reflectance.
float reflectance(float cosine, float ref_idx) {
    float r0 = (1.0 - ref_idx) / (1.0 + ref_idx);
    r0 = r0 * r0;
    return r0 + (1.0 - r0) * pow((1.0 - cosine), 5.0);
}

 bool material_scatter(const material mat, const ray r_in, const hit_record rec, out vec3 attenuation, out ray scattered) {
    if (mat.type == MATERIAL_LAMBERTIAN) {

        vec3 scatter_direction = rec.normal + random_in_unit_sphere(g_seed);
        scattered = ray(rec.p, normalize(scatter_direction));
        attenuation = mat.albedo;
        
        return true;
    } else if (mat.type == MATERIAL_METAL) {

        vec3 reflected = reflect(normalize(r_in.direction), rec.normal);
        scattered = ray(rec.p, reflected + mat.fuzz * random_in_unit_sphere(g_seed));
        attenuation = mat.albedo;

        return dot(scattered.direction, rec.normal) > 0.0;
    }
     else if (mat.type == MATERIAL_DIELECTRIC) {

        attenuation = vec3(1.0, 1.0, 1.0);
        float refraction_ratio = rec.front_face ? (1.0/mat.index_of_refraction) : mat.index_of_refraction;

        vec3 unit_direction = normalize(r_in.direction);
        float cos_theta = min(dot(-unit_direction, rec.normal), 1.0);
        float sin_theta = sqrt(1.0 - cos_theta*cos_theta);

        bool cannot_refract = refraction_ratio * sin_theta > 1.0;
        vec3 direction;

        if (cannot_refract || reflectance(cos_theta, refraction_ratio) > rand1(g_seed))
            direction = reflect(unit_direction, rec.normal);
        else
            direction = refract(unit_direction, rec.normal, refraction_ratio);

        scattered = ray(rec.p, direction);
        return true;
    }
    return false;
}


vec3 ray_color(const ray r, int depth) {
  
    material material_ground = material(vec3(0.8, 0.8, 0.0), MATERIAL_LAMBERTIAN, 0.0, 0.0); 
    material material_center = material(vec3(0.1, 0.2, 0.5), MATERIAL_LAMBERTIAN, 0.0, 0.0);
    material material_left   = material(vec3(0.0, 0.0, 0.0), MATERIAL_DIELECTRIC, 0.0, 1.5); 
    material material_right  = material(vec3(0.8, 0.6, 0.2), MATERIAL_METAL, 0.0, 0.0); 


    // Define spheres
    sphere spheres[5];
    spheres[0] = sphere(vec3( 0.0, -100.5, -1.0), 100.0, material_ground);
    spheres[1] = sphere(vec3( 0.0,    0.0, -1.0),   0.5, material_center);
    spheres[2] = sphere(vec3(-1.0,    0.0, -1.0),   0.5, material_left);
    spheres[3] = sphere(vec3(-1.0,    0.0, -1.0),   -0.4, material_left);
    spheres[4] = sphere(vec3( 1.0,    0.0, -1.0),   0.5, material_right);

    ray current_ray = r;
    vec3 accumulated_color = vec3(1.0);

    for (int i = 0; i < depth; i++) {

        //added temp rec for multiple spheres
        hit_record temp_rec;
        hit_record rec;
        bool hit_anything = false;
        //essentially infinity
        float closest_so_far = MAX_FLOAT;

        for (int j = 0; j < spheres.length(); j++) {
            if (hit_sphere(spheres[j], current_ray, 0.001, closest_so_far, temp_rec)) {
                //if we hit anything make sure it is closest and assign rec
                hit_anything = true;
                closest_so_far = temp_rec.t;
                rec = temp_rec;
                //make sure mat gets transferred
                rec.mat = spheres[j].mat;
            }
        }

        if (hit_anything) {
        ray scattered;
        vec3 attenuation;
        if (material_scatter(rec.mat, current_ray, rec, attenuation, scattered)) {
            accumulated_color *= attenuation;
            current_ray = scattered;
        }
        else{
            accumulated_color *= vec3(0.0, 0.0, 0.0);
            break;
        } 
        } else {
            vec3 unit_direction = normalize(current_ray.direction);
            float a = 0.5 * (unit_direction.y + 1.0);
            vec3 background = (1.0 - a) * vec3(1.0, 1.0, 1.0) + a * vec3(0.5, 0.7, 1.0);
            accumulated_color *= background;
            break;
        }
    }
    return accumulated_color;
}



void main()
    {
    init_rand(gl_FragCoord.xy, iTime);

    ////////////////////////////////////////////////////////
    // new camera stuff//
    vec3 lookfrom = vec3(-2, 2, 1);
    vec3 lookat = vec3(0, 0, -1);
    vec3 vup = vec3(0, 1, 0);
    float vfov = 20.0;

    camera cam = get_camera(lookfrom, lookat, vup, vfov);
    //////////////////////////////////////////////////////
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
        color += ray_color(r,MAX_RECURSION);
    }

    //averaging here
    color /= float(samples_per_pixel);
    gl_FragColor = vec4(pow(color, vec3(1.0 / 2.2)), 1.0);


}