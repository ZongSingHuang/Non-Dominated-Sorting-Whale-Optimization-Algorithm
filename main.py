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
