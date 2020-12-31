import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from utils.functions import vector
from utils.geodesic import geodesic

def animation(p_0, p_f, path):

    plt.clf()

    fig = plt.figure(1, figsize = (10, 10))
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

    x_0, y_0, z_0 = vector(p_0)
    ax.scatter([x_0], [y_0], [z_0], color = 'r', s = 50)

    x_f, y_f, z_f = vector(p_f)
    ax.scatter([x_f], [y_f], [z_f], color = 'g', s = 50)

    G = geodesic(p_0, p_f, 100)
    ax.plot(G[:, 0], G[:, 1], G[:, 2], 'r-')

    ax.scatter(path[:, 0], path[:, 1], path[:, 2], color = 'b', s = 20)

    # FuncAnimation is mysterious 

    ax.set_xlim(-1, 1)
    ax.set_ylim(-1, 1)
    ax.set_zlim(-1, 1)

    N = len(path)
    ln, = ax.plot([], [], linewidth = 3)

    def update(n):
        if n > N:
            ani.event_source.stop()
        ln.set_data(path[:n, 0], path[:n, 1])
        ln.set_3d_properties(path[:n, 2])

    ani = FuncAnimation(fig, update, frames = np.arange(N+2), interval = 50)

    plt.pause(10)
    plt.show(block = False)
