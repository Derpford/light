// voronoi functions pulled from:
// https://github.com/MaxBittker/glsl-voronoi-noise/blob/master/2d.glsl
// https://github.com/MaxBittker/glsl-voronoi-noise/blob/master/3d.glsl
const mat2 myt = mat2(.12121212, .13131313, -.13131313, .12121212);
const vec2 mys = vec2(1e4, 1e6);

uniform sampler2D tex;

vec2 rhash(vec2 uv) {
  uv *= myt;
  uv *= mys;
  return fract(fract(uv / mys) * uv) ;
}

vec3 v2dhash(vec3 p) {
  return fract(sin(vec3(dot(p, vec3(1.0, 57.0, 113.0)),
                        dot(p, vec3(57.0, 113.0, 1.0)),
                        dot(p, vec3(113.0, 1.0, 57.0)))) *
               43758.5453);
}

float voronoi2d(const in vec2 point) {
  vec2 p = floor(point);
  vec2 f = fract(point);
  float res = 0.0;
  for (int j = -1; j <= 1; j++) {
    for (int i = -1; i <= 1; i++) {
      vec2 b = vec2(i, j);
      vec2 r = vec2(b) - f + rhash(p + b);
      res += 1. / pow(dot(r, r), 8.);
    }
  }
  return pow(1. / res, (0.0625 * fract(timer)));
}

vec3 v3dhash(vec3 p) {
  return fract(
      sin(vec3(dot(p, vec3(1.0, 57.0, 113.0)), dot(p, vec3(57.0, 113.0, 1.0)),
               dot(p, vec3(113.0, 1.0, 57.0)))) *
      43758.5453);
}

vec3 voronoi3d(const in vec3 x) {
  vec3 p = floor(x);
  vec3 f = fract(x);

  float id = 0.0;
  vec2 res = vec2(100.0);
  for (int k = -1; k <= 1; k++) {
    for (int j = -1; j <= 1; j++) {
      for (int i = -1; i <= 1; i++) {
        vec3 b = vec3(float(i), float(j), float(k));
        vec3 r = vec3(b) - f + v3dhash(p + b);
        float d = dot(r, r);

        float cond = max(sign(res.x - d), 0.0);
        float nCond = 1.0 - cond;

        float cond2 = nCond * max(sign(res.y - d), 0.0);
        float nCond2 = 1.0 - cond2;

        id = (dot(p + b, vec3(1.0, 57.0, 113.0)) * cond) + (id * nCond);
        res = vec2(d, res.x) * cond + res * nCond;

        res.y = cond2 * d + nCond2 * res.y;
      }
    }
  }

  return vec3(sqrt(res), abs(id));
}

float getLum(vec4 cols)
{
	return ((cols.r*2)+(cols.g*3)+(cols.b))/6.;
}

void main() {
    vec4 cols = texture2D(tex, TexCoord);
    vec2 center = vec2(0.5,0.5);
    vec3 v = voronoi3d(vec3((TexCoord.x + cos(timer / 4.))*4, (TexCoord.y + sin(timer / 3.))*3, sin(timer) + sin(timer*2)));
    // How much original color is there?
    float orig = getLum(cols);
    // How close to the center are we?
    float d = distance(TexCoord,center);
    // How much of the voronoi is there?
    float vf = (getLum(vec4(normalize(v),1)) * (1 - orig)) * intensity * d;

    vec4 rainbow = abs(vec4(sin(timer), cos(timer), sin(timer * 3), 1));

    FragColor = max((cols) , (rainbow * vf));
}