#ifndef SHAPE_H
#define SHAPE_H

class Shape {
public:
  Vector3 position;
  Color color;

  Shape(Vector3 p, Color c) {
    position = p;
    color = c;
  }

  virtual double sdf(Vector3 p) = 0;
};

#endif