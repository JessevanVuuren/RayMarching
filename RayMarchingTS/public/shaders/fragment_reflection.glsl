uniform float uTime;
uniform vec2 uResolution;

//https://www.shadertoy.com/view/4dt3zn

uniform vec3 uPosition;
uniform mat4 uMatrixC;

#define PI 3.1415926538

#define MAX_STEPS 200
#define MAX_DIST 30.0
#define EPSILON 0.001

float sdf_box(vec3 point, vec3 position, vec3 size) {
  vec3 q = abs(point - position) - size;
  return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) + dot(point, point) * .5;
}

float world(vec3 p) {

  float n = sin(dot(floor(p), vec3(12, 11, 123)));
  vec3 rnd = fract(vec3(232, 23, 233) * n) * 0.2;

  p = fract(p + rnd) - .5;

  return sdf_box(p, vec3(0), vec3(.35));
}

vec3 normals(vec3 p) {
  const float h = 0.0001;
  const vec2 k = vec2(1, -1);
  return normalize(k.xyy * world(p + k.xyy * h) +
    k.yyx * world(p + k.yyx * h) +
    k.yxy * world(p + k.yxy * h) +
    k.xxx * world(p + k.xxx * h));
}

vec3 color_palette(float t) {

  vec3 a = vec3(0.5, 0.5, 0.5);
  vec3 b = vec3(0.5, 0.5, 0.5);
  vec3 c = vec3(1.0, 1.0, 1.0);
  vec3 d = vec3(0.00, 0.33, 0.67);

  return a + b * cos(2.0 * PI * (c * t + d));

}

vec3 get_color(vec3 p) {
  
  vec3 ip = floor(p);

  float rnd = fract(sin(dot(ip, vec3(27.17, 112.61, 57.53))) * 43758.5453);

  vec3 col = (fract(dot(ip, vec3(.5))) > .001) ? .5 + .45 * cos(mix(3., 4., rnd) + vec3(.9, .45, 1.5)) //vec3(.6, .3, 1.)
  : vec3(.7 + .3 * rnd);

  if(fract(rnd * 1183.5437 + .42) > .65)
    col = col.zyx;

  return col;
}

float ray_march2(vec3 origin, vec3 direction) {

  float distance = 0.0;

  for(int i = 0; i < MAX_STEPS; i++) {
    vec3 point = origin + direction * distance;
    float step = world(point);

    if(abs(step) < EPSILON || step > MAX_DIST)
      break;

    distance += step;
  }

  return distance;
}

vec3 get_light(vec3 origin, vec3 light_dir, vec3 norm) {

  float light_length = max(length(light_dir), 0.001);
  float attenuate = 1. / (1. + light_length * .2 + light_length * light_length * .1);
  light_dir /= light_length;

  float diff = max(dot(norm, light_dir), 0.0);

  float spec = pow(max(dot(reflect(-light_dir, norm), -origin), 0.), 8.);

  return ((diff + .15) + vec3(.8, .7, .1) * spec * 5.0) * attenuate;
}

float shadow(vec3 origin, vec3 direction, float k) {
  const int max_iter = 24;

  vec3 rd = direction - origin;

  float shade = 1.;
  float dist = .002;
  float end = max(length(rd), .001);
  float step_dist = end / float(max_iter);

  rd /= end;

  for(int i = 0; i < max_iter; i++) {
    float h = world(origin + dist * rd);
    shade = min(shade, smoothstep(0., 1., k * h / dist));

    dist += clamp(h, .02, .25);
    if(h < 0. || dist > end)
      break;

  }

  return min(max(shade, 0.) + .25, 1.);
}

vec3 render(vec3 origin, vec3 direction) {
  vec3 light_source = vec3(0.1, 0.4, 0.2);
  light_source += origin;

  // first pass
  float distance = ray_march2(origin, direction);

  vec3 point = origin + direction * distance;
  vec3 norm = normals(point);
  vec3 light_dir = light_source - point;

  vec3 light = get_light(direction, light_dir, norm);
  vec3 color = get_color(point);

  float shadow = shadow(origin + norm * 0.002, light_dir, 16.);

  // second pass with reflections
  vec3 r_direction = reflect(direction, norm);
  float r_distance = ray_march2(point + norm * 0.003, r_direction);
  point += r_direction * r_distance;

  norm = normals(point);
  vec3 r_light = get_light(r_direction, light_dir, norm);
  vec3 r_color = get_color(point);


  // last pass
  vec3 rr_direction = reflect(r_direction, norm);
  float rr_distance = ray_march2(point + norm * 0.003, rr_direction);
  point += rr_direction * rr_distance;

  norm = normals(point);
  vec3 rr_light = get_light(rr_direction, light_dir, norm);
  vec3 rr_color = get_color(point);


  // coloring
  float fog = 1.0 - (distance / MAX_DIST);
  
  vec3 final_color = color * light; //first pass
  final_color += r_color * r_light * .4; // second pass
  final_color += rr_color * rr_light * .1; // last pass

  final_color *= shadow * fog;
  return final_color;
  
}

void main() {
  vec2 uv = gl_FragCoord.xy / uResolution.xy;
  uv -= 0.5;
  uv.xy *= 2.0;
  uv.x *= uResolution.x / uResolution.y;

  vec3 cameraLeft = vec3(uMatrixC[0][0], uMatrixC[1][0], uMatrixC[2][0]);
  vec3 cameraUp = vec3(uMatrixC[0][1], uMatrixC[1][1], uMatrixC[2][1]);
  vec3 cameraForward = vec3(-uMatrixC[0][2], -uMatrixC[1][2], -uMatrixC[2][2]);

  vec3 position = uPosition;

  vec3 direction = uv.x * cameraLeft + uv.y * cameraUp + cameraForward;

  float a = sin(uTime * .004);
  float b = cos(uTime * .004);
  direction.zy = mat2(cos(b), -sin(b), sin(b), cos(b)) * direction.zy;
  direction.xz = mat2(cos(a), -sin(a), sin(a), cos(a)) * direction.xz;
  position.z += uTime * 0.01;
  

  vec3 color = render(position, normalize(direction));

  gl_FragColor = vec4(pow(color, vec3(0.4545)), 1.0);
}
