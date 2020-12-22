import numpy as np


# Extract the spehrical angles of the vector r
def angles(r):
    x, y, z = r
    theta = np.arccos(z/np.linalg.norm(r))
    phi = np.arctan2(y, x)

    if phi < 0:     # We want phi in the interval [0, 2*pi]
        phi = phi + 2*np.pi

    return theta, phi


# Find the vector defined by given spherical angles
def vector(angles):
    theta, phi = angles

    return np.array([np.sin(theta)*np.cos(phi),
                     np.sin(theta)*np.sin(phi),
                     np.cos(theta)])


# Rotation matrix for a rotation by the angle a around the axis n
def rot(a, n):
    n = n/np.linalg.norm(n)
    I = np.array([[1, 0, 0], [0, 1, 0], [0, 0, 1]])
    S = np.array([[n[0]**2, n[0]*n[1], n[0]*n[2]],
                  [n[1]*n[0], n[1]**2, n[1]*n[2]],
                  [n[2]*n[0], n[2]*n[1], n[2]**2]])
    A = np.array([[0, -n[2], n[1]], [n[2], 0, -n[0]], [-n[1], n[0], 0]])

    return np.cos(a)*I + (1 - np.cos(a))*S + np.sin(a)*A


# Rotation matrix around the z-axis
def Rz(a):
    return np.array([[np.cos(a), -np.sin(a), 0],
                     [np.sin(a), np.cos(a), 0],
                     [0, 0, 1]])


# Rotation matrix around the '2-axis', i.e. the rotated y-axis after the
# rotation R_z(a) has been applied
def R2(a, b):
    R = np.array([[np.cos(b), 0, np.sin(b)],
                  [0, 1, 0],
                  [-np.sin(b), 0, np.cos(b)]])
    return Rz(a) @ R @ Rz(-a)
