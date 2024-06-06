#define SPHERE 0
#define BOX 1
#define CYLINDER 3
#define CONE 5
#define NONE 4

////////////////////////////////////////////////////
// TASK 1 - Write up your SDF code here:
////////////////////////////////////////////////////

// returns the signed distance to a sphere from position p
float sdSphere(vec3 p, float r)
{
    return length(p) - r;
}

//
// Task 1.1
//
// Returns the signed distance to a line segment.
//
// p is the position you are evaluating the distance to.
// a and b are the end points of your line.
//
float sdLine(in vec2 p, in vec2 a, in vec2 b)
{
// ################ Edit your code below ################
    //make vectors
    vec2 ab = b - a;
    vec2 ap = p - a;
    //project ap onto ab and normalize
    float t = dot(ap, ab) / dot(ab, ab);
    //clamp projection to line
    t = clamp(t, 0.0, 1.0);

    vec2 closestPoint = a + t * ab;
    //p to the closest point line
    return length(p - closestPoint);
}

//
// Task 1.2
//
// Returns the signed distance from position p to an axis-aligned box centered at the origin with half-length,
// half-height, and half-width specified by half_bounds
//
float sdBox(vec3 p, vec3 half_bounds)

{
    // ################ Edit your code below ################
  //distance from p to the edge of box
    vec3 d = abs(p) - half_bounds;
    
    //for outside points gives distance, for inside 0
    float outsideDistance = length(max(d, vec3(0.0)));
    
    //for inside points gives shortest distance to the outside, for outside 0
    float insideDistance = min(max(d.x, max(d.y, d.z)), 0.0);
    
    //it doesnt matter if it is inside or outsude because the distance will now work for both
    return outsideDistance + insideDistance; 

}

//
// Task 1.3
//
// Returns the signed distance from position p to a cylinder or radius r with an axis connecting the two points a and b.
//
float sdCylinder(vec3 p, vec3 a, vec3 b, float r)
{
// ################ Edit your code below ################
     vec3 ba = b - a;
    vec3 pa = p - a;
    float baM = dot(ba, ba);
    float pab = dot(pa, ba);
    
    float radialDist = length(pa * baM - ba * pab) / baM - r;
    float axialDist = abs(pab - baM * 0.5) / baM - 0.5;

    float dist;
    //is point in cylinder
    bool isInside = max(radialDist, axialDist) < 0.0;

    if (isInside) {
        //use closest to zero squared distance if inside
        dist = -min(radialDist * radialDist, axialDist * axialDist * baM);
    } else {
        //outside
        //takes the square axial and radialdistances if they are positive
        dist = max(radialDist,0.0)*max(radialDist,0.0) + max(axialDist,0.0)* max(axialDist,0.0);
    }

    //normalize and signed distance
    
    float signedDist = sign(dist) * sqrt(abs(dist)) / sqrt(baM);
    return signedDist;
}

//
// Task 1.4
//
// Returns the signed distance from position p to a cone with axis connecting points a and b and (ra, rb) being the
// radii at a and b respectively.
//
float sdCone(vec3 p, vec3 a, vec3 b, float ra, float rb)
{
//for this one most calculations were same as cylinder besides radialDist
// ################ Edit your code below ################
//from cylinder
 vec3 ba = b - a;
vec3 pa = p - a;
float baM = dot(ba, ba); 
float pab = dot(pa, ba); 

//position along line
float linePos = pab / baM; 

//radius at specific point
float rc = mix(ra, rb, linePos); 

float slope = (rb - ra) / sqrt(baM);
//computes vector from point to closest point on cone
//takes into account corrected slope
float radialDist = length(pa * baM - ba * pab) / baM - rc * sqrt(1.0 + slope * slope);

//same as cylinder
float axialDist = abs(pab - baM * 0.5) / baM - 0.5;
float dist;
bool isInside = max(radialDist, axialDist) < 0.0;
if (isInside) {
    dist = -min(radialDist * radialDist, axialDist * axialDist * baM);
} else {
    dist = max(radialDist, 0.0) * max(radialDist, 0.0) + max(axialDist, 0.0) * max(axialDist, 0.0);
}

float signedDist = sign(dist) * sqrt(abs(dist)) / sqrt(baM);
return signedDist;



}

// Task 1.5
float opSmoothUnion(float d1, float d2, float k)
{

// ################ Edit your code below ################
    float h = max(k - abs(d1 - d2), 0.0);
    return min(d1, d2) - (h * h) / (4.0 * k);
}

// Task 1.6
float opSmoothSubtraction(float d1, float d2, float k)
{

// ################ Edit your code below ################

    float h = max(k - abs(-d1 - d2), 0.0);

    return max(-d1, d2) + (h * h) / (4.0 * k);
}

// Task 1.7
float opSmoothIntersection(float d1, float d2, float k)
{

// ################ Edit your code below ################
    float h = max(k - abs(d1 - d2), 0.0);
    return max(d1, d2) + (h * h) / (4.0 * k);
}

// Task 1.8
float opRound(float d, float iso)
{

// ################ Edit your code below ################

    return d - iso;
}

////////////////////////////////////////////////////
// FOR TASK 3 & 4
////////////////////////////////////////////////////

#define TASK3 3
#define TASK4 4
#define TASK5 5


//
// Render Settings
//
struct settings
{
    int sdf_func;      // Which primitive is being visualized (e.g. SPHERE, BOX, etc.)
    int shade_mode;    // How the primiive is being visualized (GRID or COST)
    int marching_type; // Should we use RAY_MARCHING or SPHERE_TRACING?
    int task_world;    // Which task is being rendered (TASK3 or TASK4)?
    float anim_speed;  // Specifies the animation speed
};

// returns the signed distance to an infinite plane with a specific y value
float sdPlane(vec3 p, float z)
{
    return p.y - z;
}

float world_sdf(vec3 p, float time, settings setts)
{
    if (setts.task_world == TASK3)
    {
        if ((setts.sdf_func == SPHERE) || (setts.sdf_func == NONE))
        {
            return min(sdSphere(p - vec3(0.f, 0.25 * cos(setts.anim_speed * time), 0.f), 0.4f), sdPlane(p, 0.f));
        }
        if (setts.sdf_func == BOX)
        {
            return min(sdBox(p - vec3(0.f, 0.25 * cos(setts.anim_speed * time), 0.f), vec3(0.4f)), sdPlane(p, 0.f));
        }
        if (setts.sdf_func == CYLINDER)
        {
            return min(sdCylinder(p - vec3(0.f, 0.25 * cos(setts.anim_speed * time), 0.f), vec3(0.0f, -0.4f, 0.f),
                                  vec3(0.f, 0.4f, 0.f), 0.2f),
                       sdPlane(p, 0.f));
        }
        if (setts.sdf_func == CONE)
        {
            return min(sdCone(p - vec3(0.f, 0.25 * cos(setts.anim_speed * time), 0.f), vec3(-0.4f, 0.0f, 0.f),
                              vec3(0.4f, 0.0f, 0.f), 0.1f, 0.6f),
                       sdPlane(p, 0.f));
        }
    }

    if (setts.task_world == TASK4)
    {
        float dist = 100000.0;

        dist = sdPlane(p.xyz, -0.3);
        dist = opSmoothUnion(dist, sdSphere(p - vec3(0.f, 0.25 * cos(setts.anim_speed * time), 0.f), 0.4f), 0.1);
        dist = opSmoothUnion(
            dist, sdSphere(p - vec3(sin(time), 0.25 * cos(setts.anim_speed * time * 2. + 0.2), cos(time)), 0.2f), 0.01);
        dist = opSmoothSubtraction(sdBox(p - vec3(0.f, 0.25, 0.f), 0.1 * vec3(2. + cos(time))), dist, 0.2);
        dist = opSmoothUnion(
            dist, sdSphere(p - vec3(sin(-time), 0.25 * cos(setts.anim_speed * time * 25. + 0.2), cos(-time)), 0.2f),
            0.1);

        return dist;
    }
        if (setts.task_world == TASK5)
    {

    //sdun
    vec3 sunPosition = vec3(0.0, 0.0, 0.0);
    float sunSize = 0.15;
    float dist = sdSphere(p - sunPosition, sunSize);

    //planet 1
    vec3 planet1Position = vec3(sin(setts.anim_speed * time*2.0) * 0.4 , 0.0, cos(setts.anim_speed * time*2.0) * 0.4);
    float planet1Size = 0.03;
    dist = opSmoothUnion(dist, sdSphere(p - planet1Position, planet1Size), 0.1);
   

    //planet2
    vec3 planet2Position = vec3(sin(-setts.anim_speed * time * 0.5) * 0.7, 0.0, cos(-setts.anim_speed * time * 0.5) * 0.7);
    float planet2Size = 0.06;
    dist = opSmoothUnion(dist, sdSphere(p - planet2Position, planet2Size), 0.1);

    //planet2 moon
    vec3 moonPosition = planet2Position + vec3(sin(setts.anim_speed * time * 5.0) * 0.2, 0.0, cos(setts.anim_speed * time * 5.0) * 0.15);
    float moonSize = 0.007;
    dist = opSmoothUnion(dist, sdSphere(p - moonPosition, moonSize), 0.05);


//planet3
    vec3 planet3Position = vec3(sin(setts.anim_speed * time * 0.7), 0.0, cos(setts.anim_speed * time * 0.7)*1.2);
    float planet3Size = 0.08;
    dist = opSmoothUnion(dist, sdSphere(p - planet3Position, planet3Size), 0.1);


    return dist;
    }

    return 1.f;
}
