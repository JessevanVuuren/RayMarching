#ifndef COLOR_H
#define COLOR_H

using Color = Vector3;

void write_color(std::ostream& out, const Color& pixel_color) {
    auto r = pixel_color.x();
    auto g = pixel_color.y();
    auto b = pixel_color.z();

    // Translate the [0,1] component values to the byte range [0,255].
    int r_byte = int(255.999 * r);
    int g_byte = int(255.999 * g);
    int b_byte = int(255.999 * b);

    // Write out the pixel color components.
    out << r_byte << ' ' << g_byte << ' ' << b_byte << '\n';
}

#endif // COLOR_H