uniform float uTime;
uniform vec2 uResolution;

uniform vec3 uPosition;
uniform vec3 uCamera_fwd;
uniform vec3 uCamera_up;
uniform vec3 uCamera_right;

uniform mat4 uMatrixC;

#define MAX_STEPS 200
#define MAX_DIST 100.0
#define EPSILON 0.0001

struct Sphere {
	vec3 position;
	float radius;
	vec3 color;
};

struct Box {
	vec3 position;
	vec3 size;
	vec3 color;
};

struct Plane {
	vec3 position;
	vec3 norm;
  float height;
	vec3 color;
};

float sdf_plane( vec3 point, vec3 position, vec3 norm, float height ) {
  return dot(point - position,norm) + height;
}

float sdf_sphere(vec3 point, vec3 position, float radius) {
    return length(point - position) - radius;
}

float sdf_box( vec3 point, vec3 position, vec3 size ) {
  vec3 q = abs(point - position) - size;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

vec4 sphere_dist(Sphere s, vec3 point) {
  float d = sdf_sphere(point, s.position, s.radius);
  return vec4(s.color, d);
}

vec4 box_dist(Box b, vec3 point) {
  float d = sdf_box(point, b.position, b.size);
  return vec4(b.color, d);
}

vec4 plane_dist(Plane p, vec3 point) {
  float d = sdf_plane(point, p.position, p.norm, p.height);
  return vec4(p.color, d);
}

vec4 min_dist(vec4 a, vec4 b) {
  return (a.w < b.w) ? a : b;
}

vec4 world(vec3 p) {

  vec4 dist = vec4(MAX_DIST);

  dist = min_dist(dist, box_dist(Box(vec3(4.0,2.0,0.0), vec3(1), vec3(1.0,0.0,0.0)), p));
  dist = min_dist(dist, box_dist(Box(vec3(-4.0,2.0,0.0), vec3(1.0), vec3(0.0,0.0,1.0)), p));
  dist = min_dist(dist, box_dist(Box(vec3(0.0,-1.5,2.0), vec3(0.5), vec3(1.0,1.0,1.0)), p));
  dist = min_dist(dist, sphere_dist(Sphere(vec3(2.0,0.0,0.0), 1.5, vec3(0.0,1.0,0.0)), p));
  dist = min_dist(dist, sphere_dist(Sphere(vec3(-3.0,-1.0,0.0), 1.0, vec3(1.0,0.0,1.0)), p));
  dist = min_dist(dist, plane_dist(Plane(vec3(-3.0,-1.0,0.0), vec3(0,1,0), 1.0, vec3(0.4,0.4,0.4)), p));

  return dist;
}

vec3 normals(vec3 p)
{
    const float h = 0.0001;
    const vec2 k = vec2(1,-1);
    return normalize( k.xyy*world( p + k.xyy*h ).w + 
                      k.yyx*world( p + k.yyx*h ).w + 
                      k.yxy*world( p + k.yxy*h ).w + 
                      k.xxx*world( p + k.xxx*h ).w );
}

float soft_shadow( in vec3 ro, in vec3 rd, float mint, float maxt, float k )
{
    float res = 1.0;
    float t = mint;
    for( int i=0; i<24 && t<maxt; i++ )
    {
        float h = world(ro + rd*t).w;
        if( h<0.001 )
            return 0.0;
        res = min( res, k*h/t );
        t += h;
    }
    return res;
}

vec3 point_light = vec3(12,4,6);


vec3 ray_march(vec3 origin, vec3 direction) {
  vec3 color = vec3(0.0);
  float step = 0.0;

  for(int i = 0; i < MAX_STEPS; i++) {
    vec3 point = origin + direction * step;
    vec4 dist = world(point);

    step += dist.w;

    if(dist.w < EPSILON) {
      vec3 norm = normals(point);

      vec3 light_dir = normalize(point_light - point);
      float n_dot_l = dot(light_dir, norm);

      float shadow = soft_shadow(point, normalize(point_light),0.01, 2.5, 5.0);
      vec3 color = dist.xyz * 0.1 + dist.xyz * clamp(n_dot_l, 0.0, 1.0) * shadow;

      vec3 eye_dir = normalize(origin - point);
      vec3 half_h = normalize(eye_dir + light_dir);
      float n_dot_h = clamp(dot(half_h, norm),0.0,1.0);

      color += dist.xyz * pow(n_dot_h, 50.0) * 0.4;

      return color;

    }
  }
  return vec3(0.1,0.1,0.1);
}

void main() {
  vec2 uv = gl_FragCoord.xy/uResolution.xy;
  uv -= 0.5;
  uv.xy *= 2.0;
  uv.x *= uResolution.x / uResolution.y;

  vec3 cameraLeft = vec3(uMatrixC[0][0], uMatrixC[1][0], uMatrixC[2][0]);
  vec3 cameraUp = vec3(uMatrixC[0][1], uMatrixC[1][1], uMatrixC[2][1]);
  vec3 cameraForward = vec3(-uMatrixC[0][2], -uMatrixC[1][2], -uMatrixC[2][2]);

  vec3 direction = uv.x * cameraLeft + uv.y * cameraUp + cameraForward;

  vec3 color = ray_march(uPosition, normalize(direction));
  
  gl_FragColor = vec4(pow( color, vec3(0.4545) ),1.0);
}
