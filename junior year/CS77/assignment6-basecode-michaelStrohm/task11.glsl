#include "common.glsl"


#iChannel0 "file://task11.glsl"

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

struct camera {
    vec3 center;
    vec3 viewport_lower_left;
    vec3 viewport_u;
    vec3 viewport_v;
    vec3 pixel_delta_u;
    vec3 pixel_delta_v;
    vec3 u, v, w;
    vec3 defocus_disk_u;  // Defocus disk horizontal radius
    vec3 defocus_disk_v;  // Defocus disk vertical radius
    float lens_radius;
};
camera get_camera(vec3 lookfrom, vec3 lookat, vec3 vup, float vfov, float aperture, float focus_dist) {
    camera cam;

    float theta = radians(vfov);
    float h = tan(theta / 2.0);
    float viewport_height = 2.0 * h;
    float aspect_ratio = iResolution.x / iResolution.y;
    float viewport_width = aspect_ratio * viewport_height;

    cam.center = lookfrom;
    cam.w = normalize(lookfrom - lookat);
    cam.u = normalize(cross(vup, cam.w));
    cam.v = cross(cam.w, cam.u);

    cam.viewport_lower_left = cam.center - viewport_width / 2.0 * focus_dist * cam.u 
    - viewport_height / 2.0 * focus_dist * cam.v - focus_dist * cam.w;

    cam.viewport_u = viewport_width * focus_dist * cam.u;
    cam.viewport_v = viewport_height * focus_dist * cam.v;

    // Lens radius for defocus effect
    cam.lens_radius = aperture / 2.0;

    return cam;
}


vec3 defocus_disk_sample(camera cam) {
        //randomly returns a defocus point
        vec2 p = random_in_unit_disk(g_seed);
        return cam.center + (p.x * cam.defocus_disk_u) + (p.y * cam.defocus_disk_v);
}

vec3 pixel_sample_square(camera cam) {
        // Returns a random point in the square surrounding a pixel at the origin.
        float px = -0.5 + rand1(g_seed);
        float py = -0.5 + rand1(g_seed);
        return (px * cam.pixel_delta_u) + (py * cam.pixel_delta_v);
}

ray get_ray(const camera cam, float s, float t) {
    vec2 rdef = cam.lens_radius * random_in_unit_disk(g_seed);
    vec3 offset = cam.u * rdef.x + cam.v * rdef.y;

    vec3 ray_origin = cam.center + offset;
    vec3 target = cam.viewport_lower_left + s * cam.viewport_u + t * cam.viewport_v;
    vec3 ray_direction = target - ray_origin;

    return ray(ray_origin, normalize(ray_direction));
}


void set_face_normal(inout hit_record rec, const ray r, const vec3 outward_normal) {
    rec.front_face = dot(r.direction, outward_normal) < 0.0;
    if (rec.front_face){
        rec.normal = outward_normal;
    }
    else {
        rec.normal = -outward_normal;
    }
}



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
//////////////////////////////////////////////////////////////////////////////
//fixed seed
float SEED = 120.5; 
const int NUM_SPHERES = 65; //limit number of spheres so it can load lol
sphere random_spheres[NUM_SPHERES]; 

void create_random_scene() {
    material ground_material = material(vec3(0.5, 0.5, 0.5), MATERIAL_LAMBERTIAN, 0.0, 0.0);
    random_spheres[0] = sphere(vec3(0.0, -1000.0, 0.0), 1000.0, ground_material);
    int index = 1;
    //big spheres & ground  before random gen
    random_spheres[index++] = sphere(vec3(0, 1, 0), 1.0, material(vec3(1.0, 1.0, 1.0), MATERIAL_DIELECTRIC, 0.0, 1.5));
    random_spheres[index++] = sphere(vec3(-4, 1, 0), 1.0, material(vec3(0.4, 0.2, 0.1), MATERIAL_LAMBERTIAN, 0.0, 0.0));
    random_spheres[index++] = sphere(vec3(4, 1, 0), 1.0, material(vec3(0.7, 0.6, 0.5), MATERIAL_METAL, 0.0, 0.0));

    //pretty much same as book but i changed some of the random values on rand so it looked better
    for (int a = -1; a < 7; a++) {
        for (int b = -5; b < 5; b++) {
            float choose_mat = rand1(SEED);
            vec3 center = vec3(float(a) + rand1(SEED), 0.2, float(b) + rand1(SEED));

            if (length(center - vec3(4, 0.2, 0)) > 0.9) {
                if (choose_mat < 0.8) {
                    // diffuse
                    vec3 albedo = vec3(rand1(SEED), rand1(SEED), rand1(SEED)) * vec3(rand1(SEED), rand1(SEED), rand1(SEED));
                    random_spheres[index++] = sphere(center, 0.2, material(albedo, MATERIAL_LAMBERTIAN, 0.0, 0.0));
                } else if (choose_mat < 0.95) {
                    // metal
                    vec3 albedo = vec3(0.5 * (1.0 + rand1(SEED)), 0.5 * (1.0 + rand1(SEED)), 0.5 * (1.0 + rand1(SEED)));
                    float fuzz = 0.5 * rand1(SEED);
                    random_spheres[index++] = sphere(center, 0.2, material(albedo, MATERIAL_METAL, fuzz, 0.0));
                } else {
                    // glass
                    random_spheres[index++] = sphere(center, 0.2, material(vec3(1.0, 1.0, 1.0), MATERIAL_DIELECTRIC, 0.0, 1.5));
                }
            }
        }
    }
}

vec3 ray_color(const ray r, int depth) {
  
    sphere spheres[NUM_SPHERES]; 
    for (int i = 0; i < NUM_SPHERES; i++) {
        spheres[i] = random_spheres[i];
    }
///////////////////////////////////////////////////////
    ray current_ray = r;
    vec3 accumulated_color = vec3(1.0);

    for (int i = 0; i < depth; i++) {

        //added temp rec for multiple spheres
        hit_record temp_rec;
        hit_record rec;
        bool hit_anything = false;
        //essentially infinity
        float closest_so_far = MAX_FLOAT;

        for (int j = 0; j < NUM_SPHERES; j++) {
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



void mainImage( out vec4 fragColor, in vec2 fragCoord )
 {
    
    create_random_scene();
    
    init_rand(gl_FragCoord.xy, iTime);

    // Camera setup
    vec3 lookfrom = vec3(15, 2, 4);
    vec3 lookat = vec3(0, 0, 0);
    vec3 vup = vec3(0, 1, 0);
    float vfov = 20.0;
    float aperture = 0.2;
    //to focus on shiny sphere
    float focus_dist = length(lookfrom - vec3(4.0, 1.0, 0.0));
          
    camera cam = get_camera(lookfrom, lookat, vup, vfov, aperture, focus_dist);

    // Single sample per frame
    float u = (gl_FragCoord.x + rand1(g_seed)) / iResolution.x;
    float v = (gl_FragCoord.y + rand1(g_seed)) / iResolution.y;
    ray r = get_ray(cam, u, v);
    vec3 new_color = ray_color(r, MAX_RECURSION);

    //taking previous color from ichannel0
    vec3 prev_color = texture(iChannel0, fragCoord / iResolution.xy).rgb;
    //use weight to make the influence of new images get exponentially smaller
    float weight = 1.0 / float(iFrame + 1);

    //used mix for the colors 
    vec3 blendedColor = mix(prev_color, pow(new_color, vec3(1.0 / 2.2)), weight);

    fragColor = vec4(blendedColor, 1.0);
}
