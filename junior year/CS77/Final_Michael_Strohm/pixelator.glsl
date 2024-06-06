
//change this to whatever file you want pixelated
#iChannel0 "file://trash.glsl"

//works really similarly to how you generate intensity for toon shaders, just taking away resolution
void mainImage(out vec4 fragColor, in vec2 fragCoord) 
{
    float pixelsize = 4.0;
    vec2 uv = 
        floor(fragCoord / pixelsize)
        * pixelsize                     
        / iResolution.xy;             
    
    fragColor = texture(iChannel0, uv);
}