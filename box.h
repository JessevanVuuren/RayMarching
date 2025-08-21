#ifndef BOX_H
#define BOX_H

class Box : public Shape {
  public:
    Vector3 size;

    Box(Vector3 position, Color color, Vector3 s) : Shape(position, color) {
        size = s;
    }

    double sdf(Vector3 p) override {
        Vector3 q = (p - position) .abs() - size;
        return q.max(0.0).length() + std::min(std::max(q.x(), std::max(q.y(), q.z())), 0.0);
    }
};

#endif