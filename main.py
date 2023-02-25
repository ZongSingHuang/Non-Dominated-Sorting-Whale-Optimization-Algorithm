import benchmark
import NSWOA
import numpy as np
import matplotlib.pyplot as plt

optimizer = NSWOA.NSWOA(
    size_dim=2,
    size_obj=2,
    size_iter=100,
    size_pop=5,
    lb=0,
    ub=1,
    benchmark=benchmark.ztd1,
)

optimizer.opt()
print(777)
aaa = np.array([k["F"] for k in optimizer.best_front])
plt.scatter(aaa[:, 0], aaa[:, 1])
plt.show()
