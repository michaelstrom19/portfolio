
//all of this is either what I wrote or taken from my assignment 6
#define MANGASHADING 0
#define TOONSHADING 1
#define COMIC 0

//integer 0-5 0 for default
#define TOONCOLOR 1

#define OUTLINE 0



// manga shading https://bnpr.gitbook.io/bnpr/shaders/manga-shader-collection
#iChannel0 "file://manga.png"


vec3 sphereColor = vec3(0.2, 0.3, 0.8); 
int bands = 3; 

struct Ray {
    vec3 origin;
    vec3 direction;
};


vec3 cameraPos = vec3(0.0, 0.0, 10.0);

vec3 sphereCenter = vec3(0.0, 0.0, 0.0); 
float sphereRadius = .2; 

Ray getRay(vec2 uv) {
    vec3 dir = normalize(vec3(uv, -1.0) - cameraPos);
    return Ray(cameraPos, dir);
}

//check if a ray hits a sphere
bool hitSphere(vec3 center, float radius, Ray ray, out float hitDistance) {
    vec3 oc = ray.origin - center;
    float a = dot(ray.direction, ray.direction);
    float b = 2.0 * dot(oc, ray.direction);
    float c = dot(oc, oc) - radius * radius;
    float discriminant = b * b - 4.0 * a * c;

    if (discriminant > 0.0) {
        float temp = (-b - sqrt(discriminant)) / (2.0 * a);
        if (temp > 0.0) {
            hitDistance = temp;
            return true;
        }
    }
    return false;
}

vec3 toonShading(vec3 normal, vec3 toLightDir, vec3 objectColor, int shadeType) {
    float intensity = max(dot(normal, toLightDir), 0.0);
    float step = 1.0 / 3.0; 

    //in other implementation files I include luminance 
    //to keep material properties/colors
    intensity = floor(intensity / step) * step;

    vec3 shadowColor, midColor, highlightColor;

        //fr differen color palletes :)
    switch(shadeType) {
        case 1: //black and white
            shadowColor = vec3(0.0, 0.0, 0.0);
            midColor = vec3(0.1, 0.1, 0.1);
            highlightColor = vec3(0.9, 0.9, 0.9);
            break;
        case 2: //comic color
            shadowColor = vec3(0.027, 0.400, 0.471);
            midColor = vec3(0.882, 0.369, 0.412);
            highlightColor = vec3 (0.969, 0.843, 0.514);
            break;
        case 3: // green and bleu
            shadowColor = vec3( 0.07059, 0.31765, 0.45882);
            midColor = vec3(0.40784,  0.74902,  0.65882);
            highlightColor = vec3(0.78039,  0.96471,  0.52157);
            break;
        case 4: //0ther comic
            shadowColor = vec3(0.00392,  0.20000,  0.30588);
            midColor = vec3(0.86667,  0.09412, 0.09804);
            highlightColor = vec3(1.00000, 0.89804,  0.66667);
            break;
        case 5: //shark? idk what to name it
            shadowColor = vec3(0.0, 0.1216, 0.2471);
            midColor = vec3(0.4294, 0.5078, 0.6216);
            highlightColor = vec3(1.0, 0.7745, 0.4294);
            break;
        default:
            return intensity * objectColor;
    }

    //apply colors
    if (intensity < 1.0 / 3.0) {
        return shadowColor;
    } else if (intensity < 2.0 / 3.0) {
        return midColor;
    } else {
        return highlightColor;
    }
}   

vec3 getNormalForSphere(vec3 hitPoint, vec3 sphereCenter) {
    return normalize(hitPoint - sphereCenter);
}

//https://www.martinpalko.com/triplanar-mapping/
vec3 triplanarMap(vec3 normal, vec3 position, sampler2D inputTexture) {
    vec3 blending = abs(normal);
    float minVal = 0.00001; 
    blending = max(blending, vec3(minVal)); 
    blending /= dot(blending, vec3(1.0));

    //scale in each dimension
    vec2 uvX = position.yz*3.0;
    vec2 uvY = position.xz*3.0;
    vec2 uvZ = position.xy*3.0;

    //sample once for each plane
    vec3 texX = texture(inputTexture, uvX).rgb;
    vec3 texY = texture(inputTexture, uvY).rgb;
    vec3 texZ = texture(inputTexture, uvZ).rgb;

    return texX * blending.x + texY * blending.y + texZ * blending.z;
}
vec4 mangaShading(vec3 normal, vec3 lightPos, vec3 hitPoint, sampler2D mangaTexture, vec3 basecol) {
    float lightIntensity = max(dot(normal, normalize(lightPos - hitPoint)), 0.0);
    float hatchingIntensity = .5 - lightIntensity;
    
    //use triplanar mapping
    vec3 mangaColor = triplanarMap(normal, hitPoint, mangaTexture);
    
    //hatching amount for a smooth transition between light and dark
    float hatchingAmount = smoothstep(0.2, 0.9, 1.0 - lightIntensity); 

    //https://en.wikipedia.org/wiki/Relative_luminance
    vec3 luminanceWeighting = vec3(0.2126, 0.7152, 0.0722);
    //calculate gray scale luminance
    float luminance = dot(basecol, luminanceWeighting);

    vec3 color = mix(vec3(luminance)*mangaColor.rgb, vec3(luminance)-mangaColor.rgb-hatchingIntensity+0.3, hatchingAmount);
    if (luminance > 0.25) {
        return vec4(mix(color, vec3(1.0), lightIntensity),1.0);
    }
    else if (luminance > 0.15){
        return vec4(mangaColor.rgb-hatchingIntensity-0.45,1.0);
    }
    return vec4(color, 1.0);
}

float pointPattern(vec2 pointCoord, float size) {

    //size down
    float pointSize = 0.8 * size;
    vec2 gridPosition = fract(pointCoord);
    float distanceToCenter = length(gridPosition - vec2(0.45));

    //if we are in point
    return step(distanceToCenter, pointSize);
}

vec3 comicShading(vec3 color, vec3 normal, vec3 lightPos, vec3 position, vec2 uv) {
    float lightIntensity = max(dot(normal, normalize(lightPos - position)), 0.0);

    //larger points for brighter spots
    float size = smoothstep(0.0, 1.0, lightIntensity);

    //adds a couple light points to the dark sections
    // size = mix(0.1, 1.0, size); 
    if (size > 0.75) size = 1.0;
    if (size < 0.2) size += 0.1;
    float pattern = pointPattern(uv * 51.0, size);

    //we want the shadows to be dark but not black
    vec3 shadowColor = mix(vec3(0.0), color, 0.08);
    //use dot pattern to add to base color
    vec3 dotColor = mix(shadowColor, color, pattern); 

    return dotColor;
}

vec3 adjustNormalForOutline(vec3 normal, vec3 viewDirection, float outlineThickness) {
    float facing = dot(normal, -viewDirection);
    return mix(normal, -viewDirection, smoothstep(0.0, 1.0, facing) * outlineThickness);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec3 outlineColor = vec3(0.0, 0.0, 0.0);



    vec2 uv = (fragCoord.xy - 0.5 * iResolution.xy) / iResolution.y;
    Ray ray = getRay(uv);
    float hitDistance;

    float lightRadius = 5.0; 
    vec3 lightPos = vec3(lightRadius * cos(iTime), 4.0, lightRadius * sin(iTime));

    if (hitSphere(sphereCenter, sphereRadius, ray, hitDistance)) {
        vec3 hitPoint = ray.origin + hitDistance * ray.direction;

        float depth = length(hitPoint - cameraPos);

        vec3 normal = getNormalForSphere(hitPoint, sphereCenter);
        vec3 viewDirection = normalize(ray.origin - hitPoint);
        normal = adjustNormalForOutline(normal, viewDirection, 0.005);
        vec3 toLightDir = normalize(lightPos - hitPoint);

        float normalEdgeWidth = 25.0 * fwidth(dot(normal, vec3(0.0, 0.0, 1.0)));
        bool isEdgeNormal = normalEdgeWidth > 1.0;

        
        if (isEdgeNormal && bool(OUTLINE)) {
        fragColor = vec4(mix(outlineColor,sphereColor,0.1),1.0);
        }  else {
        vec3 baseColor = sphereColor;
        if (bool(TOONSHADING)) {
            baseColor = toonShading(normal, toLightDir, sphereColor, TOONCOLOR);
        }
        if (bool(MANGASHADING)) {
            baseColor = mangaShading(normal, lightPos, hitPoint, iChannel0, sphereColor).rgb;
        }
        if (bool(COMIC)) {
            baseColor = comicShading(baseColor, normal, lightPos, hitPoint,uv);
        }
        baseColor = pow(baseColor,vec3(0.735));
            fragColor = vec4(baseColor, 1.0);
        }

        
    } else {
        fragColor = vec4(0.1, 0.1, 0.1, 1.0);
    }
}
