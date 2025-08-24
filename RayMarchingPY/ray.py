from vector import Vector3

class Ray:
    def __init__(self, origin, direction):
        self.origin:Vector3 = origin
        self.direction:Vector3 = direction

    def at(self, t):
        return self.origin + self.direction * t