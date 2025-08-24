import math


class Vector3:
    def __init__(self, x=0, y=0, z=0):
        self.x = x
        self.y = y
        self.z = z

    def __add__(self, other):
        if isinstance(other, Vector3):
            return Vector3(self.x + other.x, self.y + other.y, self.z + other.z)
        if isinstance(other, (int, float)):
            return Vector3(self.x + other, self.y + other, self.z + other)
        return NotImplemented

    def __sub__(self, other):
        if isinstance(other, Vector3):
            return Vector3(self.x - other.x, self.y - other.y, self.z - other.z)
        if isinstance(other, (int, float)):
            return Vector3(self.x - other, self.y - other, self.z - other)
        return NotImplemented

    def __radd__(self, other):
        return self.__add__(other)

    def __rsub__(self, other):
        if isinstance(other, (int, float)):
            return Vector3(other - self.x, other - self.y, other - self.z)

    def __repr__(self):
        return f"Vector3({self.x}, {self.y}, {self.z})"

    def __mul__(self, other):
        if isinstance(other, Vector3):
            return Vector3(self.x * other.x, self.y * other.y, self.z * other.z)
        if isinstance(other, (int, float)):
            return Vector3(self.x * other, self.y * other, self.z * other)
        return NotImplemented

    def __rmul__(self, other):
        if isinstance(other, (int, float)):
            return Vector3(other * self.x, other * self.y, other * self.z)
        return NotImplemented

    def __truediv__(self, other):
        if other == 0:
            raise ZeroDivisionError("Division by zero in Vector3")
        if isinstance(other, Vector3):
            return Vector3(self.x / other.x, self.y / other.y, self.z / other.z)
        if isinstance(other, (int, float)):
            return Vector3(self.x / other, self.y / other, self.z / other)
        return NotImplemented

    def __rtruediv__(self, other):
        if isinstance(other, (int, float)):
            return Vector3(other / self.x, other / self.y, other / self.z)
        return NotImplemented

    def length_sqr(self):
        return self.x * self.x + self.y * self.y + self.z * self.z

    def length(self):
        return math.sqrt(self.length_sqr())

    def dot(self, other):
        return self.x * other.x + self.y * other.y + self.z * other.z

    def cross(self, other):
        return Vector3(
            self.y * other.z - self.z * other.y,
            self.z * other.x - self.x * other.z,
            self.x * other.y - self.y * other.x,
        )

    def normalized(self):
        l = self.length()
        if l == 0:
            return Vector3(0, 0, 0)
        return self / l

    def __abs__(self):
        return Vector3(abs(self.x), abs(self.y), abs(self.z))

    def __eq__(self, other):
        return (
            isinstance(other, Vector3)
            and self.x == other.x
            and self.y == other.y
            and self.z == other.z
        )

    def max(self, other):
        if isinstance(other, Vector3):
            return Vector3(max(self.x, self.x), max(self.y, self.y), max(self.zx, self.z))   
        if isinstance(other, (int, float)):
            return Vector3(max(self.x, other), max(self.y, other), max(self.z, other))
    
    def min(self, other):
        if isinstance(other, Vector3):
            return Vector3(min(self.x, self.x), min(self.y, self.y), min(self.z, self.z))   
        if isinstance(other, (int, float)):
            return Vector3(min(self.x, other), min(self.y, other), min(self.z, other))
    
    def __pow__(self, other):
        if isinstance(other, Vector3):
            return Vector3(pow(self.x, self.x), pow(self.y, self.y), pow(self.z, self.z))   
        if isinstance(other, (int, float)):
            return Vector3(pow(self.x, other), pow(self.y, other), pow(self.z, other))
