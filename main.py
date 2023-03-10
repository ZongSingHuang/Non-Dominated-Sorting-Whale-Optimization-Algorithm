import matplotlib.pyplot as plt
import numpy as np

import benchmark
import NSWOA

optimizer = NSWOA.NSWOA(
    size_dim=30,
    size_obj=2,
    size_iter=100,
    size_pop=100,
    lb=0,
    ub=1,
    benchmark=benchmark.ztd3,
)

optimizer.opt()
aaa = np.array([k for k in optimizer.best_front])
plt.scatter(aaa[:, 0], aaa[:, 1])
plt.show()
