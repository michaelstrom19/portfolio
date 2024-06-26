//https://www.shadertoy.com/view/ldVXRW
#define MANGASHADING 1
#define TOONSHADING 0
#define COMIC 0

//integer 0-5 0 for default
//for spongebob, I noticed that cell shading 
// doesnt look as good because of the more complex geometry
#define TOONCOLOR 1

#define OUTLINE 1

// manga shading https://bnpr.gitbook.io/bnpr/shaders/manga-shader-collection
#iChannel0 "file://manga.png"

float hash(float n) {
    return fract(sin(n)*4358.5453);
}

float noise(vec3 x) {
    vec3 p = floor(x);
    vec3 f = fract(x);
    
    f = f*f*(3.0 - 2.0*f);
    float n = p.x + p.y*57.0 + p.z*113.0;
    
    return mix(
        mix(
            mix(hash(n + 000.0), hash(n + 001.0), f.x),
            mix(hash(n + 057.0), hash(n + 058.0), f.x),
            f.y),
        mix(
            mix(hash(n + 113.0), hash(n + 114.0), f.x),
            mix(hash(n + 170.0), hash(n + 171.0), f.x),
            f.y),
        f.z);
}

void rotate(inout vec2 p, float a) {
    float c = cos(a);
    float s = sin(a);
    
    p = mat2(c, s, -s, c)*p;
}

float len(vec3 p, float l) {
    p = pow(abs(p), vec3(l));
    return pow(p.x + p.y + p.z, 1.0/l);
}

float smin(float a, float b, float k) {
    float res = exp(-k*a) + exp(-k*b);
    return -log(res)/k;
}

float dBox(vec3 p, vec3 b) {
    vec3 d = abs(p) - b;
    return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
}

vec2 dSegment(vec3 p, vec3 a, vec3 b) {
    vec3 pa = p - a;
    vec3 ba = b - a;
    
    float h = clamp(dot(pa, ba)/dot(ba, ba), 0.0, 1.0);
    
    return vec2(length(pa - ba*h), h);
}

vec2 dSegment15(vec3 p, vec3 a, vec3 b) {
    vec3 pa = p - a;
    vec3 ba = b - a;
    
    float h = clamp(dot(pa, ba)/dot(ba, ba), 0.0, 1.0);
    
    return vec2(len(pa - ba*h, 15.0), h);
}

vec2 dSpongeBob(vec3 p) {
    float res = 0.0;
    // body
    float b = dBox(p - vec3(0, 0.5, 0), vec3(1.0, 1.5, .5)/2.0) - 0.02;
    b += 0.02*smoothstep(0.4, 1.0, noise(10.0*p))*smoothstep(0.1, 0.11, p.y);
    b -= 0.75*smoothstep(0.2, 1.0, p.y)*smoothstep(-0.13, -0.12, -p.y);
    
    // belt
    vec3 q = p;
    q.y *= 18.0;
    q.z *= 1.9;
    float e = len(q + vec3(0, 2.3, 0), 15.0) - 0.54;
    b = min(b, e);
    
    // tie
    q = p;
    q.x *= 0.4;
    vec2 s = dSegment15(q + vec3(0, -0.09, -0.28), vec3(0, -0.23, 0), vec3(0));
    float r = 0.04 - 0.02*smoothstep(0.5, 0.8, s.y) - 0.04*(1.0 - s.y);
    if(s.x - r < b) res = 1.0;
    b = min(b, s.x - r);
    
    // collar
    p.x = -abs(p.x);
    q = p;
    s = dSegment15(q + vec3(0, -0.09, -0.25), vec3(0), vec3(-0.15, 0, 0));
    r = 0.01 + 0.045*s.y*smoothstep(-0.2, -0.0, -q.y);
    if(s.x - r < b) res = 0.0;
    b = smin(b, s.x - r, 70.0);
    
    // arms
    q = p;
    rotate(q.xy, 0.4*q.y);
    s = dSegment(q + vec3(0.63, -0.3, 0.0), vec3(0., -0.5, 0), vec3(0.05, 0, 0));
    r = 0.034 + 0.05*smoothstep(0.85, 0.88, s.y) + 0.015*smoothstep(-0.1, 0.0, -s.y);
    if(s.x - r < b) res = 0.0;
    b = min(b, s.x - r);
    
    // hands
    q = p;
    q.z *= 1.9;
    q += vec3(0.61, 0.26, 0.0);
    q.x *= 2.7;
    e = length(q) - 0.08;
    if(e < b) res = 0.0;
    b = smin(b, e, 100.0);
    
    // fingers
    q = p;
    q += vec3(0.61, 0.26, 0.0);
    q = q.zyx;
    float f = 100.0;
    s = dSegment(q, vec3(0, -0.01, 0.04), vec3(0, -0.08, 0.07));
    r = 0.01;
    rotate(q.xy, 0.3*smoothstep(0.12, 0.17, -q.y));
    f = min(f, s.x - r);
    s = dSegment(q, vec3(0, -0.07, -0.02), vec3(0, -0.16, -0.04));
    f = min(f, s.x - r);
    s = dSegment(q, vec3(0, -0.07, -0.0), vec3(0, -0.16, -0.0));
    f = min(f, s.x - r);
    s = dSegment(q, vec3(0, -0.07, 0.02), vec3(0, -0.16, 0.04));
    f = min(f, s.x - r);
    
    b = smin(f, b, 60.0);
    
    // legs
    s = dSegment(p + vec3(0.25, 0.3, 0.0), vec3(0), vec3(0, -0.65, 0));
    r = 0.05;
    r -= 0.02*smoothstep(0.2, 0.21, s.y);
    r += 0.015*smoothstep(0.7, 0.715, s.y);
    if(s.x - r < b) res = 0.0;
    b = min(b, (s.x) - r); 
    
    // shoes
    q = p;
    q.y *= 1.0 + 0.05*smoothstep(0.05, 0.2, p.z);
    q.z *= 0.6;
    e = length(q + vec3(0.25, 0.98, -0.05)) - 0.08;
    if(s.x - r < b) res = 0.0;
    b = smin(b, e, 60.0);
    
    // nose
    q = p;
    rotate(q.zy, -0.25*p.z*p.z);
    s = dSegment(q + vec3(0.0, -0.6, 0.0), vec3(0), vec3(0.0, 0.0, .6));
    b = min(b, s.x - 0.035);
    
    // eyes
    q = p;
    q.y *= 0.75;
    q.z *= 1.5;
    q += vec3(0.15, -0.6, -0.3);
    e = length(q) - 0.2 - 0.02*smoothstep(0.56, 0.58, p.y - 0.39);
    if(e < b) res = 2.0;
    b = min(b, e);
    e = length(q + vec3(0, 0, -0.14)) - 0.07;
    if(e < b) res = 3.0;
    b = min(b, e);
    
    // mouth
    q = p;
    rotate(q.xy, 0.45*q.z);
    s = dSegment(q + vec3(0, -0.4, -0.27), vec3(-0.25, 0.0, 0.0), vec3(0.2, 0.0, 0.0));
    r =  0.03 - 0.02*smoothstep(0.0, 0.1, s.y);
    if(s.x - r < b) res = 1.0;
    b = min(b, s.x - r);
    
    // teeth
    e = dBox(p + vec3(0.042, -0.36, -0.27), vec3(0.03, 0.05, 0.01));
    if(e < b) res = 2.0;
    b = min(b, e);
    
    return vec2(b, res); 
}

vec2 map(vec3 p) {
    vec2 g = vec2(p.y + 1.0, -2.0);
    vec2 sb = dSpongeBob(p);
        return sb;
}

vec2 march(vec3 ro, vec3 rd) {
    float t = 0.0;
    float m = -4.0;
    
    for(int i = 0; i < 150; i++) {
        vec2 h = map(ro + rd*t);
        if(abs(h.x) < 0.0001 || t >= 10.0) break;
        t += h.x*0.5;
        m = h.y;
    }
    
    return vec2(t, m);
}

vec3 normal(vec3 p) {
    vec2 h = vec2(0.001, 0.0);
    vec3 n = vec3(
        map(p + h.xyy).x - map(p - h.xyy).x,
        map(p + h.yxy).x - map(p - h.yxy).x,
        map(p + h.yyx).x - map(p - h.yyx).x
    );
    return normalize(n);
}

float shadow(vec3 p, vec3 l) {
    float res = 1.0;
    float t = 0.002;
    
    for(int i = 0; i < 200; i++) {
        float h = map(p + l*t).x;
        if(abs(h) < 0.00 || t >= 6.0) break;
        t += h;
        res = min(res, 16.0*h/t);
    }
    
    return clamp(res, 0.0, 1.0);
}

float ao(vec3 p, vec3 n) {
    float s = 0.004;
    float t = s;
    
    float o = 0.0;
    float w = 1.0;
    
    for(int i = 0; i < 10; i++) {
        float h = map(p + n*t).x;
        
        o += (t - h)*w;
        w *= 0.95;
        
        t += s;
    }
    
    return 1.0 - clamp(o, 0.0, 1.0);
}

mat3 camera(vec3 eye, vec3 lat) {
    vec3 ww = normalize(lat - eye);
    vec3 vv = normalize(cross(vec3(0, 1, 0), ww));
    vec3 uu = normalize(cross(ww, vv));
    
    return mat3(vv, uu, ww);
}

vec3 material(vec3 p, float m) {
    vec3 mat = vec3(2.000,1.938,0.129);
    
    if(p.y < -0.86) {
        mat = vec3(0.2);
    } else if(p.y < -0.75) {
        mat = mix(vec3(2.0, 0.0, 0.0), vec3(2.0), 1.0 - smoothstep(-0.79, -0.78, p.y));
    } else if(p.y >= -0.45 && p.y < -0.15 && abs(p.x) < 0.55) {
        mat = vec3(1.0, 0.2, 0.0);
    } else if(p.y >= -0.17 && p.y < -0.095 && abs(p.x) < 0.55) {
        mat = vec3(0.1);
        float a = atan(p.z, p.x);
        a = mod(a, 0.4);
        mat = mix(mat, vec3(1.0, 0.2, 0.0), smoothstep(0.1, 0.101, a));
    } else if(p.y >= -0.095 && p.y < 0.12 && abs(p.x) < 0.55) {
        mat = vec3(2.0);
        if(m == 1.0) mat = vec3(2.0, 0.0, 0.0);
    } else if(p.y > 0.3 && p.y < 0.48 && abs(p.x) > 0.5 && abs(p.z) < 0.08) {
        mat = vec3(2.0);
    } else if(m == 2.0 && p.y < 0.96) {
        mat = vec3(2.0);
    } else if(m == 3.0) {
        p.x = -abs(p.x) + 0.15;
        p.y -=  0.8;
        mat = mix(vec3(0.3, 0.5, 1.0), vec3(0.2), 1.0 - smoothstep(0.0, 0.001, length(p.xy) - 0.02));
    }
    
    return mat;
}

////////////////////////////////////////////////////////////////////////////////////
vec3 toonShading(vec3 normal, vec3 toLightDir, vec3 objectColor, int shadeType) {
    float intensity = max(dot(normal, toLightDir), 0.0);
    float step = 1.0 / 3.0; 
    vec3 luminanceWeighting = vec3(0.2126, 0.7152, 0.0722);
    //calculate gray scale luminance
    float luminance = dot(objectColor, luminanceWeighting);
    intensity = floor(intensity*luminance / step) * step;

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
        case 5: //iceberg
            shadowColor = vec3(0.16471,  0.25098,  0.34510);
            midColor = vec3(0.27843,  0.45098,  0.54510);
            highlightColor = vec3(1.0, 1.0, 1.0);
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

//https://www.martinpalko.com/triplanar-mapping/
vec3 triplanarMap(vec3 normal, vec3 position, sampler2D inputTexture) {
    vec3 blending = abs(normal);
    float minVal = 0.00001; 
    blending = max(blending, vec3(minVal)); 
    blending /= dot(blending, vec3(1.0));

    //scale in each dimension
    vec2 uvX = position.yz*1.1;
    vec2 uvY = position.xz*1.1;
    vec2 uvZ = position.xy*1.1;

    //sample once for each plane
    vec3 texX = texture(inputTexture, uvX).rgb;
    vec3 texY = texture(inputTexture, uvY).rgb;
    vec3 texZ = texture(inputTexture, uvZ).rgb;

    return texX * blending.x + texY * blending.y + texZ * blending.z;
}
vec4 mangaShading(vec3 normal, vec3 lightDir, vec3 hitPoint, sampler2D mangaTexture, vec3 basecol) {
    float lightIntensity = max(dot(normal, lightDir), 0.0);
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
        return vec4(mangaColor.rgb-hatchingIntensity-0.25,1.0);
    }
    return vec4(color, 1.0);
}

float pointPattern(vec2 pointCoord, float size) {

    //size down
    float pointSize = 1.8 * size;
    vec2 gridPosition = fract(pointCoord);
    float distanceToCenter = length(gridPosition - vec2(0.45));

    //if we are in point
    return step(distanceToCenter, pointSize);
}

vec3 comicShading(vec3 color, vec3 normal, vec3 lightDir, vec2 uv) {
    // Calculate light intensity
    float lightIntensity = max(dot(normal, lightDir), 0.0);

    //larger points for brighter spots
    float size = smoothstep(0.0, 1.0, lightIntensity+0.09);

    if (size > 0.75) size = 1.0;
    if (size < 0.45) size = 0.08;

    float pattern = pointPattern(uv * 400.0, size);

    //we want the shadows to be dark but not black
    vec3 shadowColor = mix(vec3(0.0), color, 0.5);
    //use dot pattern to add to base color
    vec3 dotColor = mix(shadowColor, color, pattern); 

    return dotColor;
}



///////////////////////////////////////////////////////////////

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = -1.0 + 2.0*(fragCoord/iResolution.xy);
    uv.x *= iResolution.x/iResolution.y;
    
    vec3 col = vec3(0.1, 0.1, 0.1);    

    float an = iTime*0.5;
    
    vec3 ro = 2.5*vec3(cos(an), .9/3.0, -sin(-1.0));
    vec3 rd = camera(ro, vec3(0))*normalize(vec3(uv, 1.97));
    
    vec2 i = march(ro, rd);
    
    if(i.x < 10.0) {
        vec3 pos = ro + rd*i.x;
        vec3 nor = normal(pos);
        vec3 ref = reflect(rd, nor);

        vec3 sli = normalize(vec3(0.8, 0.7, 0.6));
        vec3 gli = normalize(vec3(0.0, -0.7, 0.0));
        vec3 bli = vec3(-sli.x, sli.y, -sli.z);

        float amb = clamp(0.5 + 0.5*nor.y, 0.0, 1.0);
        float gif = clamp(dot(gli, nor), 0.0, 1.0);
        float sif = clamp(dot(sli, nor), 0.0, 1.0);
        float bac = clamp(0.3 + 0.7*dot(bli, nor), 0.0, 1.0);
        float spe = pow(clamp(dot(sli, ref), 0.0, 1.0), 8.0);
        float fre = pow(clamp(1.0 + dot(rd, nor), 0.0, 1.0), 2.0);

        float sha = shadow(pos, sli);
        float occ = ao(pos, nor);

        col  = 0.2*amb*vec3(0.20, 0.34, 0.70);
        col += 0.3*gif*vec3(1.00, 1.00, 1.00)*sha;
        col += 0.7*sif*vec3(1.00, 0.97, 0.85)*sha;
        col += 0.1*bac*vec3(1.00, 0.97, 0.85);

        if(pos.y > -0.99) {
            col *= material(pos, i.y);
        } else {
            col *= vec3(0.1, 0.8, 0.5);
        }
      float normalEdgeWidth = 25.0 * fwidth(dot(nor, vec3(0.0, 0.0, 1.0)));
        bool isEdgeNormal = normalEdgeWidth > 7.0;
        // col += 0.4*spe*vec3(1.00, 0.97, 0.85)*sif*sha;
        // col += 0.2*fre*vec3(1.00, 1.00, 1.00);
        col *= vec3(occ);


/////////////////////////////////////////////////////////
         if (bool(TOONSHADING)) {
            col = toonShading(nor, sli, col, TOONCOLOR);
        }
        if (bool(MANGASHADING)) {
            col = mangaShading(nor, sli, pos, iChannel0, col).rgb;
        }
        if (bool(COMIC)) {
            col = comicShading(col, nor, sli,uv);
        }
        if (isEdgeNormal && bool(OUTLINE)) {
        col = mix(vec3(0.0),col,0.5);
        } 
    }
    /////////////////////////////////////////////////
    
        col = pow(col,vec3(0.735));
    
    fragColor = vec4(col, 1);
}