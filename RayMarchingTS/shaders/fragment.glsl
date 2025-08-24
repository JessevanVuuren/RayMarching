uniform float uTime;
uniform vec2 uResolution;
uniform vec3 uLightPos;
uniform vec3 uSunDirection;

uniform vec3 uPosition;
uniform vec3 uCamera_fwd;
uniform vec3 uCamera_up;
uniform vec3 uCamera_right;

uniform mat4 uMatrixC;

#define MAX_STEPS 200
#define MAX_DIST 100.0
#define EPSILON 0.000001

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

  dist = min_dist(dist, box_dist(Box(vec3(4.0,2.0,0.0), vec3(1.0), vec3(1.0, 0.0, 0.0)), p));
  dist = min_dist(dist, box_dist(Box(vec3(-4.0,2.0,0.0), vec3(1.0), vec3(0.0,0.0,1.0)), p));
  dist = min_dist(dist, box_dist(Box(vec3(0.0,-1.5,2.0), vec3(0.5), vec3(1.0,1.0,1.0)), p));
  dist = min_dist(dist, sphere_dist(Sphere(vec3(2.0,0.0,0.0), 1.5, vec3(0.0,1.0,0.0)), p));
  dist = min_dist(dist, sphere_dist(Sphere(vec3(-3.0,-1.0,0.0), 1.0, vec3(1.0,0.0,1.0)), p));
  dist = min_dist(dist, plane_dist(Plane(vec3(-3.0,-1.0,0.0), vec3(0,1,0), 1.0, vec3(0.4,0.4,0.4)), p));

  return dist;
}

vec3 normals(vec3 p)
{
    const float h = 0.000001;
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
    for( int i=0; i<200 && t<maxt; i++ )
    {
        float h = world(ro + rd*t).w;
        if( h<0.001 )
            return 0.0;
        res = min( res, k*h/t );
        t += h;
    }
    return res;
}


vec3 ray_march(vec3 origin, vec3 direction) {
  vec3 color = vec3(0.0);
  float step = 0.0;

  for(int i = 0; i < MAX_STEPS; i++) {
    vec3 point = origin + direction * step;
    vec4 dist = world(point);
    
    step += dist.w;

    if(dist.w < EPSILON) {
      vec3 norm = normals(point);

      vec3 light_direction = normalize(uLightPos - point);
      float diff = dot(norm, light_direction);
      diff = clamp(diff, 0.0, 1.0);

      float shadow = soft_shadow(point, normalize(uLightPos), 0.02, 3.0, 5.0);

      return dist.xyz * (diff + 0.2) * max(0.5, shadow);
      
    }
  }
  return vec3(0.1,0.1,0.1);
}

// [ 1, 0, 0, 0,
//   0, 1, 0, 0,
//   0, 0, 1, 0,
//   0, 0, 5, 1
// ]

// mat4 aMat4 = mat4(1.0, 0.0, 0.0, 0.0,  // 1. column
//                   0.0, 1.0, 0.0, 0.0,  // 2. column
//                   0.0, 0.0, 1.0, 0.0,  // 3. column
//                   0.0, 0.0, 0.0, 1.0); // 4. column
// mat4 bMat4 = mat4(1.0);

// mat4 cMat4 = mat4(aVec4, bVec4, cVec4, dVec4);
// mat4 dMat4 = mat4(aVec4, aVec3, bVec4, cVec4, aFloat);

void main() {
  vec2 uv = gl_FragCoord.xy/uResolution.xy;
  uv -= 0.5;
  uv.xy *= 2.0;
  uv.x *= uResolution.x / uResolution.y;

  // vec3 direction_camera = normalize(vec3(uv.x, uv.y, -1.0))
  // vec3 direction = uv.x * uCamera_right + uv.y * uCamera_up + (-1.0) * uCamera_fwd;

// const camera_fwd = new THREE.Vector3(0.0, 0.0, 1.0)
// const camera_up = new THREE.Vector3(0.0, 1.0, 0.0)
// const camera_right = new THREE.Vector3(-1.0, 0.0, 0.0)

  // vec3 cameraLeft = vec3(1, 0, 0);
  // vec3 cameraUp = vec3(0, 1, 0);
  // vec3 cameraForward = vec3(0, 0, 1);

  vec3 cameraLeft = vec3(uMatrixC[0][0], uMatrixC[1][0], uMatrixC[2][0]);
  vec3 cameraUp = vec3(uMatrixC[0][1], uMatrixC[1][1], uMatrixC[2][1]);
  vec3 cameraForward = vec3(-uMatrixC[0][2], -uMatrixC[1][2], -uMatrixC[2][2]);

  vec3 direction = uv.x * cameraLeft + uv.y * cameraUp + cameraForward;

  vec3 color = ray_march(uPosition, normalize(direction));
  
  gl_FragColor = vec4(color,1.0);
}
