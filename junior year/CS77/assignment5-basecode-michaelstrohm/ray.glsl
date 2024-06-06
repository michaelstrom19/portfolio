#include "sdf.glsl"

////////////////////////////////////////////////////
// TASK 2 - Write up your ray generation code here:
////////////////////////////////////////////////////
//
// Ray
//
struct ray
{
    vec3 origin;    // This is the origin of the ray
    vec3 direction; // This is the direction the ray is pointing in
};
float map(vec3 p, settings setts)
{
    return world_sdf(p, iTime, setts);
}

// TASK 2.1
void compute_camera_frame(vec3 dir, vec3 up, out vec3 u, out vec3 v, out vec3 w)
{

    w = normalize(-dir);
    u = normalize(cross(up, w));
    v = cross(w, u);
}

// TASK 2.2
ray generate_ray_orthographic(vec2 uv, vec3 e, vec3 u, vec3 v, vec3 w)
{

//from book chapter 4.3
    vec3 origin = e + uv.x * u - uv.y * v;

//face camera
    vec3 direction = -w;

    return ray(origin,direction);
}

// TASK 2.3
ray generate_ray_perspective(vec2 uv, vec3 eye, vec3 u, vec3 v, vec3 w, float focal_length)
{

// ################ Edit your code below ################
//from book chapter 4.3
    vec3 origin = eye;

//face camera
    vec3 direction = normalize(-w * focal_length + uv.x * u + uv.y * v);

    return ray(origin,direction);
}

////////////////////////////////////////////////////
// TASK 3 - Write up your code here:
////////////////////////////////////////////////////

// TASK 3.1
bool ray_march(ray r, float step_size, int max_iter, settings setts, out vec3 hit_loc, out int iters)
{

// ################ Edit your code below ################

    float distanceTravelled = 0.0;

    //while (hit has not occured && iteration < max_iters)
    for (iters = 0; iters < max_iter; iters++) {
        vec3 pos = r.origin + r.direction * distanceTravelled;
        //evaluate the sdf
        float sdf = map(pos, setts); 
        //if a collision occurs (SDF < EPSILON)
        if (sdf < 1e-4) { 
            //return hit location and iteration count
            hit_loc = pos;
            return true;
        }
    //march a distance of step_size forwards
        distanceTravelled += step_size;
    }

    //no hit detected
    return false;

}

// TASK 3.2
bool sphere_tracing(ray r, int max_iter, settings setts, out vec3 hit_loc, out int iters)
{

// ################ Edit your code below ################
    float distanceTravelled = 0.0;
    
    //while (hit has not occured && iteration < max_iters)
    for (iters = 0; iters < max_iter; iters++) {
        vec3 pos = r.origin + r.direction * distanceTravelled;
        //evaluate the sdf
        float sdf = map(pos, setts); 
        //make step size sdf
        float step_size = sdf;
        //if a collision occurs (SDF < EPSILON)
        if (sdf < 1e-4) { 
            //return hit location and iteration count
            hit_loc = pos;
            return true;
        }
        //march a distance of step_size forwards
        distanceTravelled += step_size;
    }

    //no hit detected
    return false;
}

////////////////////////////////////////////////////
// TASK 4 - Write up your code here:
////////////////////////////////////////////////////


// TASK 4.1
vec3 computeNormal(vec3 p, settings setts)
{

// ################ Edit your code below ################
    const float ep = 0.0001;
    const vec3 ep_x = vec3(ep, 0.0, 0.0);
    const vec3 ep_y = vec3(0.0, ep, 0.0);
    const vec3 ep_z = vec3(0.0, 0.0, ep);

    //compute tiny difference in direction
    float dx = map(p + ep_x,setts) - map(p - ep_x,setts);
    float dy = map(p + ep_y,setts) - map(p - ep_y,setts);
    float dz = map(p + ep_z,setts) - map(p - ep_z,setts);

    //normalize
    vec3 normal = normalize(vec3(dx, dy, dz));
    return normal;
}