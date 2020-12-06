import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation

fig = plt.figure(figsize = (10.8, 10.8))
ax = fig.add_subplot(111, projection='3d')

ax.xaxis.set_major_formatter(plt.NullFormatter())
ax.yaxis.set_major_formatter(plt.NullFormatter())
ax.zaxis.set_major_formatter(plt.NullFormatter())

# Draw a sphere
u, v = np.mgrid[0:2*np.pi:200j, 0:np.pi:100j]
x = np.cos(u)*np.sin(v)
y = np.sin(u)*np.sin(v)
z = np.cos(v)
ax.plot_surface(x, y, z, color = 'r', alpha = 0.33)

# Starting point (defined by random spherical angles)
th_0 = 0.136168 # np.pi*np.random.rand()
ph_0 = 1.134330 # 2*np.pi*np.random.rand()

x_0 = np.sin(th_0)*np.cos(ph_0)
y_0 = np.sin(th_0)*np.sin(ph_0)
z_0 = np.cos(th_0)

# Finishing point
th_f = 1.024921 # np.pi*np.random.rand()
ph_f = 1.781721 # 2*np.pi*np.random.rand()

x_f = np.sin(th_f)*np.cos(ph_f)
y_f = np.sin(th_f)*np.sin(ph_f)
z_f = np.cos(th_f)

ax.scatter([x_0], [y_0], [z_0], color = 'r', s = 25)
ax.scatter([x_f], [y_f], [z_f], color = 'g', s = 25)

# Angle between two vectors
def angle(u, v):
    return np.arccos(np.dot(u, v)/np.linalg.norm(u)/np.linalg.norm(v))

# Rotation matrix for a rotation by the angle a around the axis n
def rot(a, n):
    n = n/np.linalg.norm(n)
    I = np.array([[1, 0, 0], [0, 1, 0], [0, 0, 1]])
    S = np.array([[n[0]**2, n[0]*n[1], n[0]*n[2]],
                  [n[1]*n[0], n[1]**2, n[1]*n[2]],
                  [n[2]*n[0], n[2]*n[1], n[2]**2]])
    A = np.array([[0, -n[2], n[1]], [n[2], 0, -n[0]], [-n[1], n[0], 0]])

    return np.cos(a)*I + (1 - np.cos(a))*S + np.sin(a)*A

# The vector n is orthogonal to both r_0 and r_f
# Hence r_0 becomes r_f when it is rotated around n by the angle a

r_0 = np.array([x_0, y_0, z_0])
r_f = np.array([x_f, y_f, z_f])
n = np.cross(r_0, r_f)
a = angle(r_0, r_f)

# We divide the rotation into N equal pieces, calculate the position vector
# after each small rotation, and collect the vectors in the matrix X. Finally
# we plot the points, which represent the exact geodesic from r_0 to r_f.

N = 1000
da = a/N
R = rot(da, n)

X = np.zeros((N+1, 3))
r = r_0
X[0] = r_0

for i in range(N):
    r = R @ r
    X[i+1] = r
    x, y, z = r
    if np.mod(i, 10) == 0:
        ax.scatter([x], [y], [z], color = 'r', s = 5)

# This extracts the spehrical angles of the vector r
def find_angles(r):
    x, y, z = r
    theta = np.arccos(z/np.linalg.norm(r))
    phi = np.arctan2(y, x)
    if phi < 0:
        phi = phi + 2*np.pi

    return theta, phi

# Rotation matrix around the z-axis
def Rz(a):
    return np.array([[np.cos(a), -np.sin(a), 0],
                     [np.sin(a), np.cos(a), 0],
                     [0, 0, 1]])

# Rotation matrix around the '2-axis', i.e. the rotated y-axis after R_z has
# been applied
def R2(a, b):
    R = np.array([[np.cos(b), 0, np.sin(b)],
                  [0, 1, 0],
                  [-np.sin(b), 0, np.cos(b)]])
    return Rz(a) @ R @ Rz(-a)

'''
Here is the previous calculation, which now is not used.

# We again start with the vector r_0, but at each step we now apply a sequence
# of two small rotations around the axes that the robot's arm can rotate
# around. The rotation is given by R_2(a, db)*R_z(da), where da, db are the
# change in alpha, beta when going from the i-th to the i+1-th iteration of the
# exact position vector. The result is stored in the matrix Y and plotted as an
# animated curve, which shows how the robot's arm will supposedly move.

Y = np.zeros((N+1, 3))
r = r_0
Y[0] = r_0

for i in range(N):
    r_1 = X[i]
    r_2 = X[i+1]
    b_1, a_1 = find_angles(r_1)
    b_2, a_2 = find_angles(r_2)
    db = b_2 - b_1
    da = a_2 - a_1
    R = R2(a_1, db) @ Rz(da)
    r = R @ r
    Y[i+1] = r

'''

'''
In the above calculation the angle of rotation could have any value, while in
reality the robot can perform rotations only in multiples of some fixed step
size delta.

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

5. Repeat until the whole geodesic has been erased. At step 2 exclude the
rotation that would go back to the previous position.

6. Finally check if there are still rotations that take the position vector
closer to the desired finishing point. If so, perform them until no such
rotations can be found.

'''

delta = 360/64*np.pi/180    # Step size of rotations

# Distance between the point p and the curve described by the points in C
def dist(p, C):
    d = 100
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

r = r_0
C = X                   # The exact geodesic from r_0 to r_f
Z = np.zeros((1000, 3)) # Matrix to store the points of the arm's path
Z[0] = r_0

k = 0

while len(C) > 0:

    # Angles of the current position
    b, a = find_angles(r)

    r_p = np.zeros((4, 3))

    # The possible positions that can be reached by a single rotation from r
    r_p[0] = Rz(delta) @ r
    r_p[1] = Rz(-delta) @ r
    r_p[2] = R2(a, delta) @ r
    r_p[3] = R2(a, -delta) @ r

    # Exclude the rotation that would go back to the previous position
    # (Would be better if the excluded position vector is not even calculated.)
    if k > 0:
        i_excl = exclude(i)
        r_p[i_excl] = np.array([0, 0, 0])

    # Now calculate which r_p is closest to the curve C
    d = np.zeros(4)
    ind = np.zeros(4)

    for i in range(4):
        d[i], ind[i] = dist(r_p[i], C)

    # Find the index of the point in C that is closest to the best r_p 
    i = int(np.argmin(d))
    i_min = int(ind[i])

    # Cut off the points in C until the point of minimum distance, and one
    # more point. (One more so that at least one point is cut off in any case,
    # and progress eventually happens.)
    C = C[i_min+1:, :]

    # Update the position vector to the one closest to C, and store it in Z.
    r = r_p[i]

    k = k+1
    Z[k] = r

# Now check if some rotations still take the position vector closer to the
# target point
while True:

    k = k+1

    b, a = find_angles(r)               # Angles of the current position
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
    # best r_p and store it in Z
    if dist < dist_0:
        r = r_p[i_min]
        Z[k] = r

    else:
        break

Z = Z[:k, :]    # Remove the remaining zero rows from Z

# Check if the final point was reached already in an earlier step.
# If it was, remove the unnecessary points from Z. 
for i in range(len(Z) - 1):
    if np.linalg.norm(Z[i] - Z[len(Z)-1]) < 1e-6:
        Z = Z[:i+1, :]
        break

ax.scatter([Z[:, 0]], [Z[:, 1]], [Z[:, 2]], color = 'b', s = 20)

# FuncAnimation is mysterious 

n_Z = len(Z)
data = [np.zeros((3, n_Z))]

for i in range(n_Z):
    data[0][:, i] = Z[i]

''' Data for the old calculation
# data = [np.zeros((3, N+1))]

# for i in range(N+1):
#     data[0][:, i] = Y[i]
'''

def update(n, data, draw):
    for draw, data in zip(draw, data):
        draw.set_data(data[0:2, :n])
        draw.set_3d_properties(data[2, :n])
    return draw

draw = [ax.plot(data[0][0, 0:0], data[0][1, 0:0], data[0][2, 0:0],
                linewidth = 3)[0]]

ani = FuncAnimation(fig, update, n_Z+1, fargs = (data, draw),
                    interval = 66.66, repeat_delay = 1000)

# ani.save('anim.mp4', fps = 10)

plt.show()
