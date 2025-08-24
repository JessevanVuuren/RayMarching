#ifndef RAY_H
#define RAY_H

class Ray {
  public:
    Ray() {}

    Ray(const Vector3 origin, const Vector3 direction) : orig(origin), dir(direction) {}

    const Vector3 &origin() const { return orig; }
    const Vector3 &direction() const { return dir; }

    Vector3 at(double t) const {
        return orig + t * dir;
    }

  private:
    Vector3 orig;
    Vector3 dir;
};

#endif // RAY_H