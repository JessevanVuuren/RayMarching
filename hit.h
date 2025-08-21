#ifndef HIT_H
#define HIT_H

class Hit {
  public:
    Color color;
    double distance;

    Hit(Color c, double d) {
        color = c;
        distance = d;
    }
};
#endif