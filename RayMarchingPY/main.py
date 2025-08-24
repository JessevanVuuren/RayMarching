from vector import Vector3
from color import Color
from ray import Ray
import time


# time: 9.078925609588623
HEIGHT = 1080
WIDTH = 1920

FOCAL_LENGTH = 1


def sdSphere(p: Vector3, s):
    return p.length() - s


def sdBox(p: Vector3, b: Vector3):
    q = abs(p) - b
    return q.max(0.0).length() + min(max(q.x, max(q.y, q.z)), 0.0)


def sdPlane(p, n, h):
    return p.dot(n) + h


def scene_SDF(p):
    sphere = sdSphere(p - Vector3(15, 2, 0), 3)
    box = sdBox(p - Vector3(0, 2, 0), Vector3(3, 3, 3))
    plane = sdPlane(p, Vector3(0, 1, 0), 1)
    return min(sphere, box, plane)


def normals(p) -> Vector3:
    e = 1e-4

    return Vector3(
        scene_SDF(p + Vector3(e, 0, 0)) - scene_SDF(p - Vector3(e, 0, 0)),
        scene_SDF(p + Vector3(0, e, 0)) - scene_SDF(p - Vector3(0, e, 0)),
        scene_SDF(p + Vector3(0, 0, e)) - scene_SDF(p - Vector3(0, 0, e)),
    ).normalized()


def ray_march(r: Ray):

    t_min = 1
    t_max = 20

    t = t_min
    for _ in range(70):
        ray_point = r.at(t)
        d = scene_SDF(ray_point)

        if d < 1e-4:
            norm = normals(ray_point)

            light_pos = Vector3(-10, 10, 10)
            l = (light_pos - ray_point).normalized()

            # shadow_origin = ray_point + norm * 1e-3

            # ray = Ray(shadow_origin, l)
            # tt = 0.1
            # for _ in range(70):
            #     ray_point = ray.at(tt)
            #     dd = scene_SDF(ray_point)
            #     if dd < 1e-4:
            #         return Vector3(0,0,0)

            #     if tt > t_max:
            #         break

            intensity = max(0, norm.dot(l))

            v = (camera - ray_point).normalized()
            r = (2 * norm.dot(l) * norm - l).normalized()
            spec = max(0, r.dot(v)) ** 4

            return Vector3(1, 0, 0) * intensity + Vector3(1, 1, 1) * spec

        t += d

        if t > t_max:
            break

    unit_direction = r.direction.normalized()
    a = 0.5 * (unit_direction.y + 1.0)
    return (1.0 - a) * Color(1.0, 1.0, 1.0) + a * Color(0.5, 0.7, 1.0)


def write_color(c):
    # Translate the [0,1] component values to the byte range [0,255].
    r_byte = 255.999 * c.x
    g_byte = 255.999 * c.y
    b_byte = 255.999 * c.z

    # Write out the pixel color components.
    return f"{r_byte} {g_byte} {b_byte}"


def write_to_file(name, data):
    with open(f"{name}.ppm", "w+") as f:
        f.write("P3\n")
        f.write(f"{WIDTH} {HEIGHT}\n")
        f.write("255\n")
        for color in data:
            f.write(color + "\n")


camera = Vector3(5, 0, 10)


viewport_height = 2.0
viewport_width = viewport_height * (WIDTH / HEIGHT)

viewport_u = Vector3(viewport_width, 0, 0)
viewport_v = Vector3(0, -viewport_height, 0)

pixel_delta_u = viewport_u / WIDTH
pixel_delta_v = viewport_v / HEIGHT

viewport_upper_left = camera - Vector3(0, 0, FOCAL_LENGTH) - viewport_u / 2 - viewport_v / 2
pixel00_loc = viewport_upper_left + 0.5 * (pixel_delta_u + pixel_delta_v)

img = []


start = time.time()
for j in range(HEIGHT):
    for i in range(WIDTH):
        pixel_center = pixel00_loc + (i * pixel_delta_u) + (j * pixel_delta_v)
        ray_direction = pixel_center - camera

        ray = Ray(camera, ray_direction)
        color = ray_march(ray)
        img.append(write_color(color))

print("time:", time.time() - start)

write_to_file("file", img)
