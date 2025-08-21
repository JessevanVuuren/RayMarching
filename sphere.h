#ifndef SPHERE_H
#define SPHERE_H

class Sphere : public Shape
{
    public:
    double radius;

    Sphere(Vector3 position, Color color, double r) : Shape(position, color)
    {
        radius = r;
    }

     
    double sdf(Vector3 p) override
    {
        return (p - position).length() - radius;
    }
};

#endif