import numpy as np
from utils.path import find_path
from utils.plot import animation

# Starting point and target point
p_0 = np.pi*np.array([np.random.rand(), 2*np.random.rand()])
p_f = np.pi*np.array([np.random.rand(), 2*np.random.rand()])

# Step size of rotations
delta = 360/64*np.pi/180

path = find_path(p_0, p_f, delta)

animation(p_0, p_f, path)
