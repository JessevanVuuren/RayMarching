#include <algorithm>
#include <iostream>
#include <time.h>

#include "includes.h"

Sphere sphere1 = Sphere(Vector3(5, 0, 0), Color(1, 0, 0), 4);
Sphere sphere2 = Sphere(Vector3(-13, 3, 0), Color(1, 1, 1), 2);
Box box0 = Box(Vector3(0, 0, 100), Color(0, 0, 1), Vector3(2, 2, 2));
Box box1 = Box(Vector3(-4, 4, 0), Color(0, 0, 1), Vector3(2, 2, 2));
Box box2 = Box(Vector3(-6, -4, 0), Color(1, 0, 0), Vector3(2.4, 2.4, 2.4));
Box box3 = Box(Vector3(5, 0, 0), Color(1, 0, 0), Vector3(2.4, 2.4, 2.4));
Box box4 = Box(Vector3(-13, 3, 0), Color(1, 0, 0), Vector3(2.4, 2.4, 2.4));
Plane plane = Plane(Vector3(0, -6.4, 0), Color(.4, .4, 1), Vector3(0, 1, 0), 1);

Shape *world[] = {&plane, &sphere1, &sphere2, &box1, &box2};
int world_size = sizeof(world) / sizeof(*world);

Hit world_sdf(Vector3 p) {
    double min = 70;
    int index = 0;

    for (int i = 0; i < world_size; i++) {


        double d = world[i]->sdf(p);
        if (d < min) {
            min = d;
            index = i;
        }
    }

    return Hit(world[index]->color, min);
}

Hit world_sdf2(Vector3 p, float dist) {
    double min = 70;
    int index = 0;

    for (int i = 0; i < world_size; i++) {
        double d = world[i]->sdf(p);
        if (d < min) {
            min = d;
            index = i;
        }
    }

    return Hit(world[index]->color, min);
}

Vector3 normals(Vector3 p) {
    double e = 1e-4;

    double df_dx = (world_sdf(p + Vector3(e, 0, 0)).distance - world_sdf(p - Vector3(e, 0, 0)).distance);
    double df_dy = (world_sdf(p + Vector3(0, e, 0)).distance - world_sdf(p - Vector3(0, e, 0)).distance);
    double df_dz = (world_sdf(p + Vector3(0, 0, e)).distance - world_sdf(p - Vector3(0, 0, e)).distance);

    return unit_vector(Vector3{df_dx, df_dy, df_dz});
}

Color ray_color(Ray r) {
    double t = 0;
    while (t < 70) {
        Vector3 point = r.at(t);
        Hit hit = world_sdf2(point, 70);

        if (hit.distance < 1e-4) {
            Vector3 norm = normals(point);

            Vector3 point_light = Vector3(10, 10, 10);

            Vector3 point_direct = (point_light - point).normalized();
            double diff = dot(norm, point_direct);
            diff = std::clamp(diff, 0.0, 1.0);

            return Vector3(diff, diff, diff);
        }

        t += hit.distance;
    }

    Vector3 unit_direction = unit_vector(r.direction());
    auto a = 0.5 * (unit_direction.y() + 1.0);
    return (1.0 - a) * Color(1.0, 1.0, 1.0) + a * Color(0.5, 0.7, 1.0);
}

int main() {

    std::clog << world_size << std::endl;

    // Image
    auto aspect_ratio = 16.0 / 9.0;
    int image_width = 480;

    // Calculate the image height, and ensure that it's at least 1.
    int image_height = int(image_width / aspect_ratio);
    image_height = (image_height < 1) ? 1 : image_height;

    // Camera
    auto focal_length = 1;
    auto viewport_height = 2.0;
    auto viewport_width = viewport_height * (double(image_width) / image_height);
    auto camera = Vector3(0, 0, 10);

    // Calculate the vectors across the horizontal and down the vertical viewport edges.
    auto viewport_u = Vector3(viewport_width, 0, 0);
    auto viewport_v = Vector3(0, -viewport_height, 0);

    // Calculate the horizontal and vertical delta vectors from pixel to pixel.
    auto pixel_delta_u = viewport_u / image_width;
    auto pixel_delta_v = viewport_v / image_height;

    // Calculate the location of the upper left pixel.
    auto viewport_upper_left = camera - Vector3(0, 0, focal_length) - viewport_u / 2 - viewport_v / 2;
    auto pixel00_loc = viewport_upper_left + 0.5 * (pixel_delta_u + pixel_delta_v);

    // Render
    std::cout << "P3" << std::endl;
    std::cout << image_width << " " << image_height << std::endl;
    std::cout << "255" << std::endl;

    clock_t begin = clock();

    for (int j = 0; j < image_height; j++) {
        std::clog << "\rScanlines remaining: " << (image_height - j) << ' ' << std::flush;
        for (int i = 0; i < image_width; i++) {
            auto pixel_center = pixel00_loc + (i * pixel_delta_u) + (j * pixel_delta_v);
            auto ray_direction = pixel_center - camera;
            Ray ray = Ray{camera, ray_direction.normalized()};

            Color pixel_color = ray_color(ray);
            write_color(std::cout, pixel_color);
        }
    }

    std::clog << "\rDone.                 \n";

    clock_t end = clock();
    double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
    printf("%g\n", time_spent);
    std::clog << time_spent << std::endl;
}