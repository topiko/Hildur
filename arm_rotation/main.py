import numpy as np
from utils.functions import angles
from utils.path import find_path, sequence
from utils.plot import animation

# Step size of rotations
delta = 360/64*np.pi/180

# Starting point
p_0 = np.pi/180*np.array(input().split(), dtype='float')

while True:

    command = input()

    # Quit
    if command == 'q':
        break

    # Go to a given position
    elif command == 'g':

        p_f = np.pi/180*np.array(input().split(), dtype='float')

        path, r = find_path(p_0, p_f, delta)
        p = angles(r)

        print('Current position:', np.round(180/np.pi*p, 2))

        animation(p_0, p_f, path)

        p_0 = p

    # Perform a given sequence of rotations
    elif command == 's':

        rotations = np.array(input().split(), dtype='int')

        path, r = sequence(rotations, p_0, delta)
        p = angles(r)

        print('Current position:', np.round(180/np.pi*p, 2))

        animation(p_0, p, path)

        p_0 = p

    else:
        print('Invalid command.')
