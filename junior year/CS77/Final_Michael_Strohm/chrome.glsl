
//took inspiration from this site where they do guassian blur for bloom,
//instead I only blur the lightest values in the scene
//https://learnopengl.com/Advanced-Lighting/Bloom#:~:text=To%20implement%20Bloom%2C%20we%20render,the%20original%20HDR%20scene%20image.
//another similar blur implementation
//https://en.sfml-dev.org/forums/index.php?topic=25019.0
#define SAMPLE_RADIUS 10 //radius of glow sample
#define LIGHT_INTENSITY_THRESHOLD 0.8


//change this to change file
#iChannel0 "file://spongebob.glsl"

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;

    //pull from origional scene
    vec4 sceneColor = texture(iChannel0, uv);
    vec4 accumulatedGlow = vec4(0.0);
    vec2 offset = vec2(0.7 / iResolution.xy);


//sample all surounding pixels
    for (int i = -SAMPLE_RADIUS; i <= SAMPLE_RADIUS; ++i) {
        for (int j = -SAMPLE_RADIUS; j <= SAMPLE_RADIUS; ++j) {
            //grab color plus offset
            vec4 color = texture(iChannel0, uv + vec2(i, j) * offset);
            float luminosity = dot(color.rgb, vec3(0.2126, 0.7152, 0.0722)); // Calculate luminance

            //if its bright enough add the accumulated glow
            if (luminosity > LIGHT_INTENSITY_THRESHOLD) {
                accumulatedGlow += color* 1.0;
            }
        }
    }

    //normalize accumulated glow
    accumulatedGlow /= 4.0 * pow((float(SAMPLE_RADIUS)),2.0);

    sceneColor += accumulatedGlow;

    fragColor = sceneColor;
}
