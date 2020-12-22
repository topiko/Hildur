'''
The robot can perform rotations only in multiples of some fixed step size delta.

To come up with a sequence of rotations which each have the rotation angle
delta, and which approximate the geodesic from r_0 to r_f in a half-reasonable
way, we do the following:

1. Start with the initial point r_0 and the exact geodesic from r_0 to r_f.

2. Find the four possible points that can be obtained from r_0 by applying a
single 'elementary' rotation (i.e. by delta or -delta around the two available
axes of rotation).

3. Calculate which of the four points is closest to the geodesic, and find the
point on the geodesic that corresponds to this minimum distance -- call this
point p_min.

4. Take the best of the four points as the new position vector, and update the
geodesic by erasing the part from r_0 to p_min. (This is to ensure that we keep
moving towards r_f and cannot start going back towards r_0.)

5. Repeat until the whole geodesic has been erased, or if every rotation moves
the position vector farther away from the target point. At step 2 exclude the
rotation that would go back to the previous position.

6. Finally check if there are still rotations that take the position vector
closer to the desired finishing point. If so, perform them until no such
rotations can be found.

'''

import numpy as np
from utils.geodesic import geodesic
from utils.functions import angles, vector, Rz, R2


def find_path(p_0, p_f, delta):

    '''
    Finds a path from p_o to p_f that is constructed from discrete rotations by
    the angle delta, while following the geodesic reasonably closely.
    '''

    # Distance between the point p and the curve described by the points in C
    def dist(p, C):
        d = np.inf
        i = -1
        for q in C:
            i = i+1
            d_q = np.linalg.norm(p - q)
            if d_q < d:
                d = d_q
                i_min = i

        # Return the distance and the index of the nearest point as an element of C
        return d, i_min

    # The rotation to be excluded in step k+1, if the one in step k was of type i
    def exclude(i):
        if i == 0:
            return 1
        if i == 1:
            return 0
        if i == 2:
            return 3
        if i == 3:
            return 2

    C = geodesic(p_0, p_f, 1000)    # The exact geodesic from p_0 to p_f
    pts = np.zeros((1000, 3))       # Matrix to store the points of the arm's path

    r_f = vector(p_f)
    r = vector(p_0)
    pts[0] = r
    k = 0
    i_best = 0  # Apparently this must have an initial value even if it isn't used

    while len(C) > 0:

        # Angles of the current position
        b, a = angles(r)

        r_p = np.zeros((4, 3))

        # The possible positions that can be reached by a single rotation from r
        r_p[0] = Rz(delta) @ r
        r_p[1] = Rz(-delta) @ r
        r_p[2] = R2(a, delta) @ r
        r_p[3] = R2(a, -delta) @ r

        # Exclude the rotation that would go back to the previous position
        # (Would be better if the excluded position vector is not even calculated.)
        if k > 0:
            i_excl = exclude(i_best)
            r_p[i_excl] = np.array([1000, 0, 0])

        # Now calculate which r_p is closest to the curve C
        d = np.zeros(4)
        ind = np.zeros(4)

        for i in range(4):
            d[i], ind[i] = dist(r_p[i], C)

        # Index of the best r_p
        i_best = int(np.argmin(d))

        # Distance from the old position to the target point
        d_old = np.linalg.norm(r - r_f)

        # Distance from the new position to the target point
        d_new = np.linalg.norm(r_p[i_best] - r_f)

        # Update the position vector and store it in pts, unless the new
        # position is worse than the old position, in which case stop.
        if d_new > d_old:
            break

        r = r_p[i_best]

        k = k+1
        pts[k] = r

        # Index of the point in C that is closest to the best r_p
        i_min = int(ind[i_best])

        # Cut off the points in C until the point of minimum distance, and one
        # more point. (One more so that at least one point is cut off in any case,
        # and progress eventually happens.)
        C = C[i_min+1:, :]

    # Now check if some rotations still take the position vector closer to the
    # target point
    while True:

        b, a = angles(r)                    # Angles of the current position
        dist_0 = np.linalg.norm(r - r_f)    # Distance to target point

        r_p[0] = Rz(delta) @ r
        r_p[1] = Rz(-delta) @ r
        r_p[2] = R2(a, delta) @ r
        r_p[3] = R2(a, -delta) @ r

        d = np.zeros(4)

        for i in range(4):
            d[i] = np.linalg.norm(r_p[i] - r_f)

        dist = min(d)   # Distance from the best r_p to the target point
        i_min = int(np.argmin(d))

        # If we got closer to the target point, update the position vector to the
        # best r_p and store it in pts
        if dist < dist_0:
            r = r_p[i_min]
            k = k+1
            pts[k] = r

        else:
            break

    pts = pts[:k+1, :]  # Remove the remaining zero rows from pts

    return pts, r


def sequence(rotations, p_0, delta):

    '''
    Gives the path arising from a specific sequence of rotations. The sequence
    is defined by giving a set of integers n_1, n_2, ..., n_N. This means n_1
    elementary rotations around the z-axis, followed by n_2 elementary
    rotations around the '2-axis', etc. Positive/negative values of n_i
    correspond to positive/negative rotation angles.
    '''

    N = np.sum(np.abs(rotations))   # Total number of elementary rotations
    pts = np.zeros((N+1, 3))        # Position after each rotation stored here
    r = vector(p_0)                 # Initial position
    pts[0] = r

    k = 0           # Counter for individual rotations
    axis_z = True   # Keeps track of the rotation axis.
                    # The first rotation is around the z-axis.

    for n in rotations:

        a, _ = angles(r)
        d = np.sign(n)*delta    # Rotation angle of a single rotation

        if axis_z == True:
            R = Rz(d)
            axis_z = False

        if axis_z == False:
            R = R2(a, d)
            axis_z = True

        for _ in range(abs(n)):
            k = k+1
            r = R @ r
            pts[k] = r

    return pts, r
