// http://www.mimirgames.com/articles/programming/digits-of-pi-needed-for-floating-point-numbers/
const float pi         = 3.141592653589793;
const float inverse_pi = 0.318309886183790;

// ##### Random Number Generator #####

// Triple32 Hash: https://nullprogram.com/blog/2018/07/31/
uint triple32(uint x)
{
	x ^= x >> 17u;
	x *= 0xED5AD4BBu;
	x ^= x >> 11u;
	x *= 0xAC4C1B51u;
	x ^= x >> 15u;
	x *= 0x31848BABu;
	x ^= x >> 14u;
	return x;
}

// Random Number Generator Seed
uint ns;

void INIT_RNG(int frame_number, vec2 resolution)
{
	ns = uint(frame_number) * uint(resolution.x * resolution.y) + uint(gl_FragCoord.x + gl_FragCoord.y * resolution.x);
}

// Random Value Between 0.0 and 1.0
float rand()
{
	// Update RNG
	ns = triple32(ns);

	//
	return float(ns)/float(0xFFFFFFFFu);
}

// 2-Component Uniform Random Vector
vec2 rand2()
{
	vec2 vector;
	vector.x = rand();
	vector.y = rand();
	return vector;
}

// 3-Component Uniform Random Vector
vec3 rand3()
{
	vec3 vector;
	vector.x = rand();
	vector.y = rand();
	vector.y = rand();
	return vector;
}

// 4-Component Uniform Random Vector
vec4 rand4()
{
	vec4 vector;
	vector.x = rand();
	vector.y = rand();
	vector.z = rand();
	vector.w = rand();
	return vector;
}

// See michael0884's usage of PCG Random
// https://www.shadertoy.com/view/wltcRS
// https://www.shadertoy.com/view/WttyWX

vec2 nrand2(vec2 mean, float sigma)
{
	vec2 z = rand2();
	return mean+sigma*sqrt(-2.0*log(z.x   ))*vec2(cos(2.0*pi*z.y), sin(2.0*pi*z.y));
}

vec3 nrand3(vec3 mean, float sigma)
{
	vec4 z = rand4();
	return mean+sigma*sqrt(-2.0*log(z.xxy ))*vec3(cos(2.0*pi*z.z), sin(2.0*pi*z.z), cos(2.0*pi*z.w));
}

vec4 nrand4(vec4 mean, float sigma)
{
	vec4 z = rand4();
	return mean+sigma*sqrt(-2.0*log(z.xxyy))*vec4(cos(2.0*pi*z.z), sin(2.0*pi*z.z), cos(2.0*pi*z.w), sin(2.0*pi*z.w));
}

// Random Uniform Direction
vec2 udir2()
{
	float z = rand();
	float r = 2.0 * pi * z;
	float s = sin(r), c = cos(r);
	return vec2(s, c);
}

vec3 udir3()
{
	vec2 z = rand2();
	vec2 r = vec2(2.0*pi*z.x, acos(2.0*z.y-1.0));
	vec2 s = sin(r), c = cos(r);
	return vec3(c.x*s.y, s.x*s.y, c.y);
}

// Blackman-Harris Pixel Filter
vec2 pixel_filter(vec2 pixel_coord)
{
	// https://en.wikipedia.org/wiki/Window_function#Blackman–Harris_window
	// w[n] = a0-a1*cos(2*pi*n/N)+a2*cos(4*pi*n/N)-a3*cos(6*pi*n/N)
	// a0 = 0.35875; a1 = 0.48829; a2 = 0.14128; a3 = 0.01168
	float n = 0.5*rand()+0.5;
	float w = 0.35875-0.48829*cos(2.0*pi*n)+0.14128*cos(4.0*pi*n)-0.01168*cos(6.0*pi*n);
	return pixel_coord+(udir2()*2.0*w);
}