import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits import mplot3d
from matplotlib.animation import FuncAnimation

fig = plt.figure(figsize = (7.2, 7.2))
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
th_0 = np.pi*np.random.rand()
ph_0 = 2*np.pi*np.random.rand()

x_0 = np.sin(th_0)*np.cos(ph_0)
y_0 = np.sin(th_0)*np.sin(ph_0)
z_0 = np.cos(th_0)

# Finishing point
th_f = np.pi*np.random.rand()
ph_f = 2*np.pi*np.random.rand()

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
    S = np.array([[n[0]**2, n[0]*n[1], n[0]*n[2]], [n[1]*n[0], n[1]**2, n[1]*n[2]], 
        [n[2]*n[0], n[2]*n[1], n[2]**2]])
    A = np.array([[0, -n[2], n[1]], [n[2], 0, -n[0]], [-n[1], n[0], 0]]) 

    return np.cos(a)*I + (1 - np.cos(a))*S + np.sin(a)*A

# The vector n is orthogonal to both r_0 and r_f
# Hence r_0 becomes r_f when it is rotated around n by the angle a

r_0 = np.array([x_0, y_0, z_0])
r_f = np.array([x_f, y_f, z_f])
n = np.cross(r_0, r_f)
a = angle(r_0, r_f)

# We divide the rotation into N equal pieces, calculate the position vector after each
# small rotation, and collect the vectors in the matrix X. Finally we plot the points,
# which represent the exact geodesic from r_0 to r_f.

N = 100
da = a/N
R = rot(da, n)

X = np.zeros((N+1, 3))
r = r_0

for i in range(N+1):
    r = R @ r
    X[i] = r
    x, y, z = r
    ax.scatter([x], [y], [z], color = 'r', s = 3)

# This extracts the spehrical angles of the vector r
def find_angles(r):
    x, y, z = r
    theta = np.arccos(z/np.linalg.norm(r))
    phi = np.arctan2(y, x)
    return theta, phi

# Rotation matrix around the z-axis
def Rz(a):
    return np.array([[np.cos(a), -np.sin(a), 0], [np.sin(a), np.cos(a), 0], [0, 0, 1]])

# Rotation matrix around the '2-axis', i.e. the rotated y-axis after R_z has been applied
def R2(a, b):
    R = np.array([[np.cos(b), 0, np.sin(b)], [0, 1, 0], [-np.sin(b), 0, np.cos(b)]])
    return Rz(a) @ R @ Rz(-a)

# We again start with the vector r_0, but at each step we now apply a sequence of two small
# rotations around the axes that the robot's arm can rotate around. The rotation is given by
# R_2(a, db)*R_z(da), where da, db are the change in alpha, beta when going from the i-th
# to the i+1-th iteration of the exact position vector. The result is stored in the matrix Y
# and plotted as animated curve, which shows how the robot's arm will supposedly move.

Y = np.zeros((N+1, 3))
r = r_0

for i in range(N):
    r_1 = X[i]
    r_2 = X[i+1]
    b_1, a_1 = find_angles(r_1)
    b_2, a_2 = find_angles(r_2)
    db = b_2 - b_1
    da = a_2 - a_1
    R = R2(a_1, db) @ Rz(da)
    r = R @ r
    Y[i] = r

# FuncAnimation is mysterious 

data = [np.zeros((3, N))]

for i in range(N):
    data[0][:, i] = Y[i]

def update(n, data, draw):
    for draw, data in zip(draw, data):
        draw.set_data(data[0:2, :n])
        draw.set_3d_properties(data[2, :n])
    return draw

draw = [ax.plot(data[0][0, 0:1], data[0][1, 0:1], data[0][2, 0:1], linewidth = 5)[0]]

ani = FuncAnimation(fig, update, N, fargs = (data, draw), interval = 33.33, repeat_delay = 1000) 

# ani.save('anim.mp4')

plt.show()
