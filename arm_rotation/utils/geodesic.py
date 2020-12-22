import numpy as np
from utils.functions import vector, rot

# Gives N equally spaced points on the geodesic from p_0 to p_f
def geodesic(p_0, p_f, N):

    # Angle between two vectors
    def angle(u, v):
        return np.arccos(np.dot(u, v)/np.linalg.norm(u)/np.linalg.norm(v))

    r_0 = vector(p_0)
    r_f = vector(p_f)

    # The vector n = r_0 x r_f is orthogonal to both r_0 and r_f. Hence r_0
    # becomes r_f when it is rotated around n by the angle a = angle(r_0, r_f).
    # We divide the rotation into N equal pieces and calculate the position vector
    # after each small rotation.

    n = np.cross(r_0, r_f)
    a = angle(r_0, r_f)
    da = a/N
    R = rot(da, n)

    points = np.zeros((N+1, 3))
    r = r_0
    points[0] = r_0

    for i in range(N):
        r = R @ r
        points[i+1] = r

    return points
