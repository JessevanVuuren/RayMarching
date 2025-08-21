#include <iostream>
#include <time.h>

#include "includes.h"

Sphere sphere1 = Sphere(Vector3{5, 0, 0}, Color(1, 0, 0), 4);
Sphere sphere2 = Sphere(Vector3{-7, 0, 0}, Color(0, 1, 0), 2);
Box box = Box(Vector3{-5, 5, 0}, Color(0, 0, 1), Vector3(2, 2, 2));
Shape *world[] = {&sphere1, &sphere2, &box};

int world_size = sizeof(world) / sizeof(*world);

Hit world_sdf(Vector3 p) {
    double min = world[0]->sdf(p);
    int index_of = 0;

    for (int i = 1; i < world_size; i++) {
        double d = world[i]->sdf(p);
        if (d < min) {
            min = d;
            index_of = i;
        }
    }

    return Hit(world[index_of]->color, min);
}

Vector3 normals(Vector3 p) {
    double e = 1e-3;

    Vector3 finite_distance = Vector3(
        world_sdf(p + Vector3(e, 0, 0)).distance - world_sdf(p - Vector3(e, 0, 0)).distance,
        world_sdf(p + Vector3(0, e, 0)).distance - world_sdf(p - Vector3(0, e, 0)).distance,
        world_sdf(p + Vector3(0, 0, e)).distance - world_sdf(p - Vector3(0, 0, e)).distance);

    return finite_distance.normalized();
}

Color ray_color(const ray &r) {
    double t = 1;
    while (t < 70) {
        Point3 point = r.at(t);
        Hit hit = world_sdf(point);

        if (hit.distance < 1e-3) {
            Vector3 norm = normals(point);

            return norm;
        }

        t += hit.distance;
    }

    Vector3 unit_direction = r.direction().normalized();
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
    auto focal_length = 1.0;
    auto viewport_height = 2.0;
    auto viewport_width = viewport_height * (double(image_width) / image_height);
    auto camera_center = Point3(0, 0, 10);

    // Calculate the vectors across the horizontal and down the vertical viewport edges.
    auto viewport_u = Vector3(viewport_width, 0, 0);
    auto viewport_v = Vector3(0, -viewport_height, 0);

    // Calculate the horizontal and vertical delta vectors from pixel to pixel.
    auto pixel_delta_u = viewport_u / image_width;
    auto pixel_delta_v = viewport_v / image_height;

    // Calculate the location of the upper left pixel.
    auto viewport_upper_left = camera_center - Vector3(0, 0, focal_length) - viewport_u / 2 - viewport_v / 2;
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
            auto ray_direction = pixel_center - camera_center;
            ray r(camera_center, ray_direction);

            Color pixel_color = ray_color(r);
            write_color(std::cout, pixel_color);
        }
    }

    std::clog << "\rDone.                 \n";

    clock_t end = clock();
    double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
    printf("%g\n", time_spent);
    std::clog << time_spent << std::endl;
}