//https://www.shadertoy.com/view/Xl3Szj

#define MANGASHADING 0
#define TOONSHADING 1
#define COMIC 1

//integer 0-5 0 for default
#define TOONCOLOR 3
#define OUTLINE 1

// manga shading https://bnpr.gitbook.io/bnpr/shaders/manga-shader-collection
#iChannel0 "file://manga.png"


#define FAR 11.

#define shadows
#define God_Rays
#define normal_mapping
#define Sky 0

#define Volsteps 10. //quality of the godrays 10 is low but ok with the dithering

float rand(vec2 co){
    return fract(sin(dot(co,vec2(12.9898,78.233)))*43758.5453)-.5;}
float noise(vec2 uv)
{
    vec2 u = floor(uv);
    vec2 v =fract(uv);
    return mix(
        mix(
            rand(u),
            rand(u+vec2(1,0)),
            smoothstep(0.,1.,v.x))
        ,mix(rand(u+vec2(0,1)),
          rand(u+1.),smoothstep(0.,1.,v.x)),
                    smoothstep(0.,1.,v.y));
}

float fbm(vec2 uv)
{
    float n =1.;
    float r =1.;
    for (int i =0;i<8;i++)
    {
        uv*=1.9;
        uv+=100.;
        n=mix(n,noise(uv),r);
        r*=.25;
    }
    return n;
}

vec3 sol(vec2 uv)
{
    vec3 col = vec3(1.);
    vec2 p= vec2(length(uv),atan(uv.x,uv.y)+.2);
    col=mix(col,vec3(1,.4,.1),smoothstep(.005,-.005,p.x-.2*pow(.51+.51*cos(8.*p.y+fbm(vec2(10.*p.x,p.y))),5.-.5)-.15));
    col=mix(col,vec3(.5,.15,.15),smoothstep(.005,-.005,abs(p.x-.2*pow(.51+.51*cos(8.*p.y+fbm(vec2(10.*p.x,p.y))),5.-.5)-.15)-.01));    
    col=mix(col,vec3(1,1,.25),smoothstep(.005,-.005,p.x-.13));
    col=mix(col,vec3(.5,.15,.15),smoothstep(.005,-.005,2.*abs(p.x-.13)-.005));
	return col;
}


float rand(vec3 co){
    return fract(sin(dot(co,vec3(12.9898,78.233,45.4159)))*43758.5453)-.5;}
float noise(vec3 uv)
{
    vec3 u = floor(uv);
    vec3 v =fract(uv);
    return mix(
        mix(
        mix(
            rand(u),
            rand(u+vec3(1,0,0)),
            smoothstep(0.,1.,v.x))
        ,mix(rand(u+vec3(0,1,0)),
          rand(u+vec3(1,1,0)),smoothstep(0.,1.,v.x)),
                    smoothstep(0.,1.,v.y)),
            mix(
        mix(
            rand(u+vec3(0,0,1)),
            rand(u+vec3(1,0,1)),
            smoothstep(0.,1.,v.x))
        ,mix(rand(u+vec3(0,1,1)),
          rand(u+1.),smoothstep(0.,1.,v.x)),
                    smoothstep(0.,1.,v.y))
        ,smoothstep(0.,1.,v.z));
}
float fbm(vec3 uv)
{
    float n =1.;
    float r =1.;
    for (int i =0;i<8;i++)
    {
        uv*=2.;
        uv+=100.;
        n=mix(n,noise(uv),r);
        r*=.25;
    }
    return n;
}



float sdCappedCylinder( vec3 p, vec2 h )
{
  vec2 d = abs(vec2(length(p.xz),p.y)) - h;
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}
float sdBox( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}
float sdTorus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}
float udRoundBox( vec3 p, vec3 b, float r )
{
  return length(max(abs(p)-b,0.0))-r;
}
float sdTorus82( vec3 p, vec2 t )
{
  vec2 q = abs(vec2(length(p.xz)-t.x,p.y));
  return max(q.x,q.y)-t.y;
}

float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}
float udTriangle( vec3 p, vec3 a, vec3 b, vec3 c )
{
    vec3 ba = b - a; vec3 pa = p - a;
    vec3 cb = c - b; vec3 pb = p - b;
    vec3 ac = a - c; vec3 pc = p - c;
    vec3 nor = cross( ba, ac );
	#define dot2(n) dot(n,n)
    return sqrt(
    (sign(dot(cross(ba,nor),pa)) +
     sign(dot(cross(cb,nor),pb)) +
     sign(dot(cross(ac,nor),pc))<2.0)
     ?
     min( min(
     dot2(ba*clamp(dot(ba,pa)/dot2(ba),0.0,1.0)-pa),
     dot2(cb*clamp(dot(cb,pb)/dot2(cb),0.0,1.0)-pb) ),
     dot2(ac*clamp(dot(ac,pc)/dot2(ac),0.0,1.0)-pc) )
     :
     dot(nor,pa)*dot(nor,pa)/dot2(nor) );
}

float feather(vec3 p)
{
    p.x+=.02*cos(20.*p.y+smoothstep(.0,.03,p.y)*iTime);
    return udTriangle(p,vec3(0,0,0),vec3(0,0,.05),vec3(0,.2,.08));
}

float helmet(vec3 p)
{
    float d = sdCappedCylinder(p,vec2(.1,.11))-.03;
    d=min(d,sdCappedCylinder(p+vec3(0,-.03,0),vec2(.101,.02))-.03);
    d=min(d,sdBox(p+vec3(.13,.03,0),vec3(.005,.08,.02)));
    d=max(d,-sdCappedCylinder(p+vec3(.25,-.03,0),vec2(.2,.005)));
    d=min(d,length(p+vec3(.128,0,0))-.01);
    d=min(d,length(p+vec3(.128,.04,0))-.01);
    d=min(d,length(p+vec3(.128,.08,0))-.01);
    d=min(d,length(p+vec3(.128,-.041,0))-.01);
    d=smin(d,sdTorus(p+vec3(0,.15,0),vec2(.12+.002*sin(20.*atan(p.x,p.z)),.05)),.03);
    return d;
}

vec2 smun(vec2 a,vec2 b,float r)
{
	return vec2(smin(a.x,b.x,r),b.x<a.x?b.y:a.y);
}

vec2 chest(vec3 p)
{
    p.y+=.15;
    vec2 d = vec2(udRoundBox(p,vec3(.05+.1*sin(p.y),.18,.12+.01*sin(15.*p.y)),.1),2);
    d.x=smin(d.x,udTriangle(p,vec3(-.1,-.2,.17),vec3(-.2,-.5,.2),vec3(-.12,-.2,-.1)),.05);
    d.x=smin(d.x,udTriangle(p,vec3(-.1,-.2,-.17),vec3(-.15,-.5,-.2),vec3(-.12,-.2,.1)),.03);
    d.x=smin(d.x,udTriangle(p,vec3(.1,-.2,.17),vec3(.11,-.5,.2),vec3(.12,-.2,-.1)),.05);
    d.x=smin(d.x,udTriangle(p,vec3(.1,-.2,-.17),vec3(.1,-.5,-.2),vec3(.12,-.2,.1)),.03);
    p.z=-abs(p.z);
   	p+=vec3(0,-.18,.18);
    p.yz*=mat2(cos(.5),-sin(.5),sin(.5),cos(.5));
    float m= sdCappedCylinder(p,vec2(.1,.08))-.02;
    d=smun(d,vec2(m,4),.05);
    return d;
}

float arms(vec3 p)
{
        p.z=-abs(p.z);

    p.yz*=mat2(cos(.6),-sin(.6),sin(.6),cos(.6));
 float d =sdCappedCylinder(p-vec3(0,.2,-.16),vec2(.075,.2));  
    p.yz*=mat2(cos(.2),sin(.2),-sin(.2),cos(.2));
    d=smin( d,sdCappedCylinder(p-vec3(0,.48,-.23),vec2(.06,.15)),.01);
        p.yz*=mat2(cos(.2),sin(.2),-sin(.2),cos(.2));
    d=smin(d,udRoundBox(p-vec3(0,.62,-.35),vec3(.04,.08,.01+sin(240.*p.x)*.003*smoothstep(.61,.63,p.y)),.01),.02);
    return d;
}

vec2 un(vec2 a,vec2 b)
{
    return b.x<a.x?b:a;
}

vec2 legs(vec3 p)
{
     p.z=-abs(p.z);

    p.yz*=mat2(cos(.3),sin(.3),-sin(.3),cos(.3));
 vec2 d =vec2(sdCappedCylinder(p-vec3(0,-.55,.05),vec2(.075,.2)),5.);
    p.yz*=mat2(cos(.3),-sin(.3),sin(.3),cos(.3));
    d.x=smin(d.x,sdCappedCylinder(p-vec3(0,-.85,-.17),vec2(.065,.12)),.05);
    d=un(d,vec2(smin(
        sdCappedCylinder(p-vec3(0,-1.05,-.17),vec2(.07,.12)),
        udRoundBox(p-vec3(-.08,-1.2,-.17),vec3(.15,.02,.05),.02),.1)
        ,1.));
    return d;
}
float tower(vec3 p)
{
    float d = sdCappedCylinder(p-vec3(0,-10.,0),vec2(2.5,8.8));
    d=min(d,sdTorus82(p-vec3(0,-1.,0),vec2(2.5,.3)));
    p.xz=vec2(length(p.xz),atan(p.x,p.z));
    p.z=mod(p.z+.315,.63)-.315;
    p.xz=p.x*vec2(cos(p.z),sin(p.z));
    d=min(d,udRoundBox(p-vec3(2.6,-.6,0),vec3(.2,.4,.4),.01));
    return d;
    }

vec2 map(vec3 p)
{
    vec2 m = vec2(helmet(p+vec3(0,-.25,0)),1);
    m=un(m,chest(p));
    m=un(m,vec2(feather(p-vec3(0,.35,.05)),3));
    m=un(m,vec2(arms(p),5));
    m=smun(m,legs(p),.1);
    m=un(m,vec2(tower(p),6.));
    return m;
}


vec3 normal(vec3 p)
{
    vec2 e = vec2(.0001,0);
    vec3 n=  vec3 (map(p+e.xyy).x-map(p-e.xyy).x,map(p+e.yxy).x-map(p-e.yxy).x,map(p+e.yyx).x-map(p-e.yyx).x);
    return normalize(n);
}


vec2 intersect(vec3 ro, vec3 rd)
{
    float f=0.;
    for(int i = 0; i <500; i++)
    {
        vec2 h = map(ro+f*rd);
            if(h.x<.002)
                return vec2(f,h.y);
           if(f > FAR)
           		break;
            f+=.9*h.x;
    }
    return vec2(FAR,0);
}

float shad(vec3 rd,vec3 ro)
{
    float t=0.01;
    for(int i=0;i<100;i++)
    {
        vec3 pos = ro+t*rd;
        vec2 h= map(pos);
        if(h.x<.005)
                return 0.;
        t+=.8*h.x;
        if(t>FAR)
        break;
        }

    return 1.;
}
#ifdef God_Rays
float scat(vec3 p, vec3 rd, vec3 ld, float d)
{
    float Step= d/Volsteps;
    float scat=0.;
    p-=Step*rd*rand(sin(rd.xy/rd.z+iTime)*100.);
    for(float i =0.;i<Volsteps;i++)
    {
        p+=Step*rd;
        scat+=shad(ld,p);
    }
    return scat/Volsteps;
}
#endif

float ao(vec3 p, vec3 n)
{
    const float ao_it =4.;
    float d=0.;
    float sm =0.;
    for(float i=1.;i<ao_it;i++)
    {
        d+=.3;
        float h = map(p+d*n).x;
        sm+=(d-h)/pow(2.8,i);
    }
    return max(0.,1.-sm*4.);

}

vec3 gettex(vec3 p , float i)
{
    if(i==1.)
    	return .4+.2*texture(iChannel0,vec2(p.y+p.x,atan(p.x,p.z))).rgb;
    if(i==2.)
        return abs(p.y+.3)<.01?vec3(.32,.08,.08):(p.x<0.?sol(2.2*p.yz+vec2(.2,0)):vec3(1));
    if(i==3.)
        return vec3(.8,.1,.1);
     if(i==4.)
        return vec3(.1,.4,.1);
     if(i==5.)
    	return .2+.2*texture(iChannel0,vec2(p.y+p.x,atan(p.x,p.z))).rgb;
      if(i==6.)
    	return .4+.2*texture(iChannel2,p.xz).rgb;
    return vec3(1);
}
#ifdef normal_mapping
vec3 normap(vec3 nor,vec3 pos,float i)
{
    if(i==1.)
        return normalize(nor+.1*vec3(fbm(40.*pos),fbm(40.*pos+10.),fbm(40.*pos+20.)));
    if(i==2.)
        return  normalize(nor+.15*texture(iChannel1,vec2(pos.y+pos.x,atan(pos.x,pos.z))).rgb);
    if(i==3.)
        return normalize(nor+.25*texture(iChannel1,vec2(pos.y+pos.x,atan(pos.x,pos.z))).rgb);
    if(i==4.)
        return normalize(nor+.2*vec3(fbm(20.*pos),fbm(20.*pos+10.),fbm(20.*pos+20.)));
    if(i==5.)
        return normalize(nor+.3*cos(200.*pos)*cos(200.*pos)); 
    return nor;
}
#endif
float getspec(float i)
{
    if(i==1.)
        return 2.;
    if(i==2.)
        return .3;
    if(i==4.)
        return .15;
    if(i==5.)
        return 1.;
    return 0.;
}

vec4 gamma(vec4 x, float p)
{
    return vec4(pow(x.x,p),pow(x.y,p),pow(x.z,p),pow(x.w,p));
}
#ifdef Sky
vec3 SkyBg (vec3 rd)
{
  const vec3 sbCol1 = vec3 (0.05, 0.05, 0.15), sbCol2 = vec3 (0.2, 0.25, 0.5);
  vec3 col = vec3(0.1);
  return col;
}
vec3 SkyCol (vec3 ro, vec3 rd,vec3 sunDir)  //adapted from "train ride" by dr2
{
  const vec3 sCol1 = vec3 (0.06, 0.04, 0.02), sCol2 = vec3 (0.03, 0.03, 0.06),
     mBrite = vec3 (-0.5, -0.4, 0.77);
  const float skyHt = 150.;
  vec3 col;
  float cloudFac;
  if (rd.y > 0.) {
    ro.x += 0.5 ;
    vec2 p = 0.02 * (rd.xz * (skyHt - ro.y) / rd.y + ro.xz);
    float w = 0.8;
    float f = 0.;
    for (int j = 0; j < 4; j ++) {
      f += w * fbm (.8+p*.5)*2.+.1;
      w *= 0.5;
      p *= 2.;
    }
    cloudFac = clamp (5. * (f - 0.4) * rd.y - 0.1, 0., 1.);
  } else cloudFac = 0.;

    float s = max (dot (rd, sunDir), 0.);
    col = SkyBg (rd) + vec3(1,.9,.5) * (0.35 * pow (s, 6.) +
       0.65 * min (pow (s, 256.), 0.3));
    col = vec3(0.2);
  
  return col;
}
#endif

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
//https://www.martinpalko.com/triplanar-mapping/
vec3 triplanarMap(vec3 normal, vec3 position, sampler2D inputTexture) {
    vec3 blending = abs(normal);
    float minVal = 0.00001; 
    blending = max(blending, vec3(minVal)); 
    blending /= dot(blending, vec3(1.0));

    //scale in each dimension
    vec2 uvX = position.yz*1.9;
    vec2 uvY = position.xz*1.0;
    vec2 uvZ = position.xy*1.9;

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

vec3 comicShading(vec3 color, vec3 normal, vec3 lightDir, vec2 uv) {
    // Calculate light intensity
    float lightIntensity = max(dot(normal, lightDir), 0.0);

    //larger points for brighter spots
    float size = smoothstep(0.0, 1.0, lightIntensity);

    if (size > 0.75) size = 1.0;
    if (size < 0.2) size += 0.1;

    //adds a couple light points to the dark sections that arent zero
    // size = mix(0.1, 1.0, size); 
    float pattern = pointPattern(uv * 71.0, size);

    //we want the shadows to be dark but not black
    vec3 shadowColor = mix(vec3(0.0), color, 0.08);
    //use dot pattern to add to base color
    vec3 dotColor = mix(shadowColor, color, pattern); 

    return dotColor;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (2.*fragCoord.xy -iResolution.xy)/iResolution.y;
    vec2 mse =iMouse.xy/iResolution.x-vec2(.5,.5+(iResolution.y-iResolution.x)/(2.*iResolution.x));
    mse*=8.*vec2(-1,1)/*part of the fix*/;
    if(iMouse.xy==vec2(0))
        mse=vec2(-2.5,.3);
    mat3 rdroty = mat3(1,0,0,0,cos(mse.y),sin(mse.y),0,-sin(mse.y),cos(mse.y));
    mat3 rdrotx = mat3(cos(mse.x),0,sin(mse.x),0,1,0,-sin(mse.x),0,cos(mse.x));

    vec3 ro = vec3(0,0,-2.)*rdroty*rdrotx;
    vec3 rd = normalize(vec3(uv*vec2(-1,1)/*part of the fix*/,2.))*rdroty*rdrotx;
    rd=rd.zyx; //i fucked up with the distance fuction so this is just a fix
    ro=ro.zyx;
    float m =0.;
    vec2 i = intersect(ro,rd);
    
    vec3 ld = normalize(vec3(-1.,.5,-.5));
    
    m+=.1/distance(rd,ld);
    vec3 col = vec3(0.1);
    if(i.y>0.)
    {
    vec3 pos = ro+i.x*rd;
    vec3 nor = normal(pos);
    float amb =ao(pos,nor)*.5;
        #ifdef normal_mapping
    nor=normap(nor,pos,i.y);
	#endif
        m=amb;
        float sh =1.;
        #ifdef shadows
       sh=shad(ld,pos+.01*nor);
        #endif
        m+=max(0.,dot(nor,ld))*sh;
       m+=min(1.,pow(.1/distance(reflect(rd,nor),ld),2.))*getspec(i.y)*sh;
        col= gettex(pos,i.y);
             col *= (m);

        float normalEdgeWidth = 25.0 * fwidth(dot(nor, vec3(0.0, 0.0, 1.0)));
        bool isEdgeNormal = normalEdgeWidth > 7.0;


        if (bool(TOONSHADING)) {
            col = toonShading(nor, ld, col, TOONCOLOR);
            fragColor = gamma(vec4(col,1.0),.8);
        }
        if (bool(MANGASHADING)) {
            col = mangaShading(nor, ld, pos, iChannel0, col).rgb;
        }            fragColor = gamma(vec4(col,1.0),.8);

        if (bool(COMIC)) {
            col = comicShading(col, nor, ld,uv);
            fragColor = gamma(vec4(col,1.0),.8);

        }
        if (isEdgeNormal && bool(OUTLINE)) {
        col = mix(vec3(0.0),col,0.5);
        } 
        

        
    }
//     #ifdef God_Rays
//    col = mix(col, vec3(1,.9,.6),scat(ro,rd,ld,i.x)/4.);
//     #endif
    fragColor = vec4(col,1.0);
	// fragColor = gamma(vec4(col,1.0),.8);
}