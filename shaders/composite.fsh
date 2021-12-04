#version 150

#define DRAW_SHADOW_MAP gcolor // Configures which buffer to draw to the screen [gcolor shadowcolor0 shadowtex0 shadowtex1]

uniform float frameTimeCounter;
uniform sampler2D gcolor;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;

varying vec2 texcoord;

#define EXPOSURE 1.5 // [0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0]

#define BLOOM // Enable Bloom
#define BLOOM_INTENSITY 0.80 // Bloom Intensity [0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00]
#define BLOOM_THRESHOLD 0.40 // Bloom Threshold [0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00]
#define BLOOM_RADIUS 0.050 // Bloom Radius [0.000 0.025 0.050 0.075 0.100 0.125 0.150 0.175 0.200 0.225 0.250 0.275 0.300]
#define BLOOM_SAMPLES 16 // Bloom Samples [1 2 4 6 8 12 16 24 32]

#ifdef BLOOM
#include "./rng.glsl"

uniform int frameCounter;
uniform float viewWidth;
uniform float viewHeight;
#endif

void main()
{
	vec3 color = texture2D(DRAW_SHADOW_MAP, texcoord).rgb;

	#ifdef BLOOM
	INIT_RNG( frameCounter, vec2(viewWidth, viewHeight) );

	vec3 bloom = vec3(0.0);

	for(int i = 0; i < BLOOM_SAMPLES; i++)
	{
		bloom += texture2D( DRAW_SHADOW_MAP, nrand2(texcoord, BLOOM_RADIUS) ).rgb;
	}

	bloom /= float(BLOOM_SAMPLES);

	color = color + ( BLOOM_INTENSITY * max(bloom - BLOOM_THRESHOLD, 0.0) );
	#endif

	color = smoothstep( 0.0, 1.0, 1.0 - exp(-max(color, 0.0) * EXPOSURE) );

	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); // gcolor
}