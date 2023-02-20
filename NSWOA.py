import numpy as np
import functools


class NSWOA:
    def __init__(
        self,
        size_dim: int,
        size_obj: int,
        size_iter: int,
        size_pop: int,
        lb: float,
        ub: float,
        benchmark: functools.partial,
    ) -> None:
        self.size_dim = size_dim  # 解空間維度
        self.size_obj = size_obj  # 目標式個數
        self.size_iter = size_iter  # 最大迭代次數
        self.size_pop = size_pop  # 候選解個數
        self.lb = lb * np.ones(size_dim)  # 各維度下限
        self.ub = ub * np.ones(size_dim)  # 各維度上限
        self.calc_benchmark = benchmark  # 適應函數

    def opt(self):
        # 初始化候選解
        X = self.initial_population()

        # 計算適應值
        F = self.calc_benchmark(X)

        # 非支配快速排序

    def initial_population(self):
        X = np.random.uniform(
            low=self.lb, high=self.ub, size=[self.size_pop, self.size_dim]
        )
        return X
