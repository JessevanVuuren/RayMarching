#ifndef PLANE_H
#define PLANE_H

class Plane : public Shape {
  public:
    Vector3 normalized;
    double height;

    Plane(Vector3 position, Color color, Vector3 n, double h) : Shape(position, color) {
        normalized = n;
        height = h;
    }

    double sdf(Vector3 p) override {
        return dot((p - position), normalized) + height;
    }
};

#endif