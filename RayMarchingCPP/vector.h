#ifndef VECTOR3_H
#define VECTOR3_H

class Vector3 {
  public:
    double e[3];

    Vector3() : e{0, 0, 0} {}
    Vector3(double e0, double e1, double e2) : e{e0, e1, e2} {}

    double x() const { return e[0]; };
    double y() const { return e[1]; };
    double z() const { return e[2]; };

    Vector3 operator-() const { return Vector3(-e[0], -e[1], -e[2]); }
    double operator[](int i) const { return e[i]; }
    double &operator[](int i) { return e[i]; }

    Vector3 &operator+=(const Vector3 &v) {
        e[0] += v[0];
        e[1] += v[1];
        e[2] += v[2];
        return *this;
    }

    Vector3 &operator*=(double t) {
        e[0] *= t;
        e[1] *= t;
        e[2] *= t;
        return *this;
    }

    Vector3 operator/=(double t) {
        return *this *= 1 / t;
    }

    double length() const { return sqrt(length_squared()); }
    double length_squared() const { return e[0] * e[0] + e[1] * e[1] + e[2] * e[2]; }

    static Vector3 random() {
        return Vector3(random_double(), random_double(), random_double());
    }

    static Vector3 random(double min, double max) {
        return Vector3(random_double(min, max), random_double(min, max), random_double(min, max));
    }

    Vector3 abs() const {
        return Vector3(std::abs(e[0]), std::abs(e[1]), std::abs(e[2]));
    }

    Vector3 max(double v) const {
        return Vector3(std::max(e[0], v), std::max(e[1], v), std::max(e[2], v));
    }

    Vector3 min(double v) const {
        return Vector3(std::min(e[0], v), std::min(e[1], v), std::min(e[2], v));
    }

    Vector3 normalized() const {
        double l = length();
        return Vector3(e[0] / l, e[1] / l, e[2] / l);
    }
};

inline std::ostream &operator<<(std::ostream &out, const Vector3 &v) {
    return out << v.e[0] << " " << v.e[1] << " " << v.e[2];
}

inline Vector3 operator+(const Vector3 &u, const Vector3 &v) {
    return Vector3(u.e[0] + v.e[0], u.e[1] + v.e[1], u.e[2] + v.e[2]);
}

inline Vector3 operator-(const Vector3 &u, const Vector3 &v) {
    return Vector3(u.e[0] - v.e[0], u.e[1] - v.e[1], u.e[2] - v.e[2]);
}

inline Vector3 operator-(const double u, const Vector3 &v) {
    return Vector3(u - v.e[0], u - v.e[1], u - v.e[2]);
}

inline Vector3 operator*(const Vector3 &u, const Vector3 &v) {
    return Vector3(u.e[0] * v.e[0], u.e[1] * v.e[1], u.e[2] * v.e[2]);
}

inline Vector3 operator*(double t, const Vector3 &v) {
    return Vector3(t * v.e[0], t * v.e[1], t * v.e[2]);
}

inline Vector3 operator*(const Vector3 &v, double t) {
    return t * v;
}

inline Vector3 operator/(const Vector3 &v, double t) {
    return (1 / t) * v;
}

inline double dot(const Vector3 &u, const Vector3 &v) {
    return u.e[0] * v.e[0] + u.e[1] * v.e[1] + u.e[2] * v.e[2];
}

inline Vector3 cross(const Vector3 &u, const Vector3 &v) {
    return Vector3(u.e[1] * v.e[2] - u.e[2] * v.e[1],
                   u.e[2] * v.e[0] - u.e[0] * v.e[2],
                   u.e[0] * v.e[1] - u.e[1] * v.e[0]);
}

inline Vector3 unit_vector(const Vector3 &v) {
    return v / v.length();
}

inline Vector3 random_in_unit_sphere() {
    while (true) {
        auto p = Vector3::random(-1, 1);
        if (p.length_squared() < 1) {
            return p;
        }
    }
}

inline Vector3 random_unit_vector() {
    return unit_vector(random_in_unit_sphere());
}

inline Vector3 random_on_hemisphere(const Vector3 &normal) {
    Vector3 on_unit_sphere = random_unit_vector();
    if (dot(on_unit_sphere, normal) > 0.0) {
        return on_unit_sphere;
    } else {
        return -on_unit_sphere;
    }
}

#endif // VECTOR3_H