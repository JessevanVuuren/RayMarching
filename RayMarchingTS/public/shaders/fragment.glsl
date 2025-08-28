uniform float uTime;
uniform vec2 uResolution;

uniform vec3 uPosition;
uniform mat4 uMatrixC;

//https://www.shadertoy.com/view/MtlfRs

#define PI 3.1415926538

#define MAX_STEPS 100
#define MAX_DIST 50.0
#define EPSILON 0.0001

float sdf_box(vec3 point, vec3 position, vec3 size) {
  vec3 q = abs(point - position) - size;
  return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float sdf_sphere(vec3 point, vec3 pos, float radius) {
  return length(point - pos) - radius;
}

float sdf_plane(vec3 p, vec3 n, float h) {
  // n must be normalized
  return dot(p, n) + h;
}

float sdf_rounded_cylinder(vec3 p, float ra, float rb, float h) {
  vec2 d = vec2(length(p.xz) - 2.0 * ra + rb, abs(p.y) - h);
  return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - rb;
}

vec4 min_dist(vec4 a, vec4 b) {
  return (a.w < b.w) ? a : b;
}

float circular_min(float a, float b, float k) {
  k *= 1.0 / (1.0 - sqrt(0.5));
  float h = max(k - abs(a - b), 0.0) / k;
  return min(a, b) - k * 0.5 * (1.0 + h - sqrt(1.0 - h * (h - 2.0)));
}

vec4 smooth_dist(vec4 a, vec4 b) {
  float w = circular_min(a.w, b.w, 0.4);

  return vec4(min_dist(a, b).xyz, w);
}

float range(float rng, float low, float high, float seed) {
  float offs = fract(seed);
  return (sin(rng * seed + offs) + 1.) * .5 * (high - low) + low;
}

vec4 tree(vec3 trunk, vec3 p, float n) {

  vec4 dist = vec4(vec3(0), MAX_DIST);

  vec3 trunk_color_1 = vec3(0.96, 0.69, 0.0);
  vec3 trunk_color_2 = vec3(0.549, 0.392, 0);

  vec3 leave_color_1 = vec3(0.06, 0.89, 0.0);
  vec3 leave_color_2 = vec3(0.07, 0.4, 0.01);

  vec3 trunk_color = mix(trunk_color_1, trunk_color_2, range(n, 0., 1., 234.34));
  vec3 leave_color = mix(leave_color_1, leave_color_2, range(n, 0., 1., 234.234));

  dist = min_dist(dist, vec4(trunk_color, sdf_rounded_cylinder(trunk, .5, 1., 1.)));

  if(n > range(n, -1., 1., 234.34)) {

    for(int i = 0; i < 4; i++) {
      for(int j = 0; j <= i; j++) {
        for(int k = 0; k <= i; k++) {
          float x = float(k - i / 2) * 1.6;
          float z = float(j - i / 2) * 1.6;
          float y = float(-i + 6) * 1.;

          vec3 pos = vec3(x, y, z);

          dist = smooth_dist(dist, vec4(leave_color, sdf_sphere(p, pos, 1.)));

        }
      }
    }
  } else {
    dist = smooth_dist(dist, vec4(leave_color, sdf_box(p, vec3(0, 3, 0), vec3(4, 1, 4))));
    dist = smooth_dist(dist, vec4(leave_color, sdf_box(p, vec3(0, 5, 0), vec3(3, 1, 3))));
    dist = smooth_dist(dist, vec4(leave_color, sdf_box(p, vec3(0, 7, 0), vec3(2, 1, 2))));
    dist = smooth_dist(dist, vec4(leave_color, sdf_box(p, vec3(0, 9, 0), vec3(1, 1, 1))));
  }

  return dist;
}

vec4 world(vec3 point) {
  vec4 dist = vec4(vec3(0), MAX_DIST);

  float x = mod(point.x, 10.) - 5.;
  float z = mod(point.z, 10.) - 5.;

  vec3 domain_point = vec3(x, point.y, z);

  float n = sin(dot(floor(point.xz / 10.), vec2(121, 12)) * 23424.234);
  vec3 rnd = fract(vec3(232, 23, 233) * n) * 2.;

  vec3 trunk = domain_point;
  trunk.x -= rnd.x;
  trunk.z -= rnd.z;

  dist = min_dist(dist, tree(trunk, domain_point, n));
  dist = smooth_dist(dist, vec4(vec3(0, 1, 0), sdf_plane(point, vec3(0, 1, 0), 2.)));

  return dist;
}

vec3 normals(vec3 p) {
  const vec2 k = vec2(1, -1);
  return normalize(k.xyy * world(p + k.xyy * EPSILON).w +
    k.yyx * world(p + k.yyx * EPSILON).w +
    k.yxy * world(p + k.yxy * EPSILON).w +
    k.xxx * world(p + k.xxx * EPSILON).w);
}

vec4 ray_march(vec3 origin, vec3 direction) {

  vec4 distance = vec4(0);

  for(int i = 0; i < MAX_STEPS; i++) {
    vec3 point = origin + direction * distance.w;
    vec4 step = world(point);
    distance.xyz = step.xyz;

    if(abs(step.w) < EPSILON || distance.w > MAX_DIST)
      break;

    distance.w += step.w;

  }

  return distance;
}

float get_directional(vec3 light, vec3 norm) {
  float d = dot(light, norm);
  return max(d, 0.0) * .5 + .5;
}

vec3 get_light(vec3 origin, vec3 light_dir, vec3 norm) {

  float light_length = max(length(light_dir), 0.001);
  float attenuate = 1. / (1. + light_length * .2 + light_length * light_length * .1);
  light_dir /= light_length;

  float diff = max(dot(norm, light_dir), 0.0);

  float spec = pow(max(dot(reflect(-light_dir, norm), -origin), 0.), 8.);

  return ((diff + .15) + vec3(.8, .7, .1) * spec * 5.0) * attenuate;
}

vec3 render(vec3 origin, vec3 direction) {
  vec3 sun = normalize(vec3(1, 1, 0));
  vec3 light_source = vec3(0.1, 0.4, 0.2);
  light_source += origin;

  vec3 color = vec3(0);
  // first pass
  vec4 dist = ray_march(origin, direction);
  vec3 point = origin + direction * dist.w;

  if(dist.w < MAX_DIST) {
    vec3 norm = normals(point);

    vec3 light_dir = light_source - point;
    vec3 light = get_light(direction, light_dir, norm);
    float direct = get_directional(sun, norm);
    float fog = smoothstep(0.8, 0., dist.w / MAX_DIST);

    vec3 reflect = reflect(direction, norm);
    vec4 dist2 = ray_march(point + norm * 0.005, reflect);

    color = dist.xyz * light;
    color += dist2.xyz * .3;
    color *= fog;
  }

  return color;
}

void main() {
  vec2 uv = gl_FragCoord.xy / uResolution.xy;
  uv -= 0.5;
  uv.xy *= 2.0;
  uv.x *= uResolution.x / uResolution.y;

  vec3 pos = uPosition;

  pos.z -= uTime * 0.05;

  vec3 cameraLeft = vec3(uMatrixC[0][0], uMatrixC[1][0], uMatrixC[2][0]);
  vec3 cameraUp = vec3(uMatrixC[0][1], uMatrixC[1][1], uMatrixC[2][1]);
  vec3 cameraForward = vec3(-uMatrixC[0][2], -uMatrixC[1][2], -uMatrixC[2][2]);

  vec3 direction = uv.x * cameraLeft + uv.y * cameraUp + cameraForward;
  vec3 color = render(pos, normalize(direction));

  // gl_FragColor = vec4(pow(color, vec3(0.4545)), 1.0);
  gl_FragColor = vec4(color, 1.0);
}
