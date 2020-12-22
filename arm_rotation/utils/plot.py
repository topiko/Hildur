import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from utils.convert import vector
from utils.geodesic import geodesic

def animation(p_0, p_f, path):

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

    x_0, y_0, z_0 = vector(p_0)
    ax.scatter([x_0], [y_0], [z_0], color = 'r', s = 25)

    x_f, y_f, z_f = vector(p_f)
    ax.scatter([x_f], [y_f], [z_f], color = 'g', s = 25)

    G = geodesic(p_0, p_f, 100)
    ax.plot(G[:, 0], G[:, 1], G[:, 2], 'r-')

    ax.scatter([path[:, 0]], [path[:, 1]], [path[:, 2]], color = 'b', s = 20)

    # FuncAnimation is mysterious 

    N = len(path)
    data = [np.zeros((3, N))]

    for i in range(N):
        data[0][:, i] = path[i]

    def update(n, data, draw):
        for draw, data in zip(draw, data):
            draw.set_data(data[0:2, :n])
            draw.set_3d_properties(data[2, :n])
        return draw

    draw = [ax.plot(data[0][0, 0:0], data[0][1, 0:0], data[0][2, 0:0],
                    linewidth = 3)[0]]

    ani = FuncAnimation(fig, update, N+1, fargs = (data, draw),
                        interval = 66.66, repeat_delay = 1000)

    # ani.save('anim.mp4', fps = 10)

    plt.show()
