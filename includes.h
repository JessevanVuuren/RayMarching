#ifndef INCLUDES_H
#define INCLUDES_H


#include <cmath>
#include <cstdlib>
#include <iostream>
#include <limits>
#include <memory>

// C++ Std Usings

using std::make_shared;
using std::shared_ptr;
using std::sqrt;


const double pi = 3.1415926535897932385;

// Utility functions

inline double degrees_to_radians(double degrees) {
    return degrees * pi / 180.0;
}

inline double random_double() {
    return rand() / (RAND_MAX + 1.0);
}

inline double random_double(double min, double max) {
    return min + (max-min) * random_double();
}

// Common headers

#include "vector.h"
#include "color.h"
#include "ray.h"
#include "hit.h"

#include "shape.h"
#include "sphere.h"
#include "box.h"

#endif // INCLUDES_H