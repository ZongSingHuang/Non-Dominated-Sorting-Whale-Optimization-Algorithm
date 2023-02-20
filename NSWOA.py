import functools
import itertools
from operator import attrgetter, itemgetter

import numpy as np


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
        population = [self.initial_chromosome() for _ in range(self.size_pop)]

        # 計算適應值
        population = self.calc_benchmark(population=population)

        # 非支配快速排序
        population = self.fast_nondominated_sort(population=population)

        # 擁擠度
        population = self.crowding_distance(population=population)

    # 初始化染色體
    def initial_chromosome(self) -> dict:
        chromosome = {
            "X": np.random.uniform(low=self.lb, high=self.ub, size=[self.size_dim]),
            "F": np.zeros(self.size_obj),
            "輸給幾組": 0,
            "贏了誰": [],
        }
        return chromosome

    # 快速非支配排序
    def fast_nondominated_sort(self, population) -> list:
        FRONTs = [[]]
        for master_idx, master in enumerate(population):
            master["擁擠度"] = 0
            master["輸給幾組"] = 0
            master["贏了誰"] = []
            for slave_idx, slave in enumerate(population):
                if self.dominates(master, slave):
                    master["贏了誰"].append(slave_idx)
                elif self.dominates(slave, master):
                    master["輸給幾組"] += 1
                else:
                    pass

            if master["輸給幾組"] == 0:
                master["推薦等級"] = 0
                FRONTs[0].append(master_idx)

        i = 0
        while len(FRONTs[i]):
            FRONT = []
            for master_idx in FRONTs[i]:
                master = population[master_idx]
                for slave_idx in master["贏了誰"]:
                    slave = population[slave_idx]
                    slave["輸給幾組"] -= 1
                    if slave["輸給幾組"] == 0:
                        slave["推薦等級"] = i + 1
                        FRONT.append(slave_idx)
            i += 1
            FRONTs.append(FRONT)

        population.sort(key=itemgetter("推薦等級"))
        return population

    # 支配判定
    def dominates(self, p1: dict, p2: dict) -> bool:
        and_condition = True
        or_condition = False

        # 望小
        for i in range(self.size_obj):
            and_condition = and_condition and p1["F"][i] <= p2["F"][i]
            or_condition = or_condition or p1["F"][i] < p2["F"][i]
        return and_condition and or_condition

    # 擁擠度
    def crowding_distance(self, population: list) -> list:
        # 分群
        FRONTs = itertools.groupby(population, key=itemgetter("推薦等級"))

        # by 推薦等級
        for i, FRONT in FRONTs:
            FRONT = list(FRONT)
            FRONT_len = len(FRONT)
            # by 目標式個數
            for j in range(self.size_obj):
                FRONT.sort(key=lambda chromosome: chromosome["F"][j])
                FRONT[0]["擁擠度"] = np.inf
                FRONT[-1]["擁擠度"] = np.inf
                F_all = [t["F"][j] for t in FRONT]
                scale = max(F_all) - min(F_all)
                if scale == 0:
                    scale = 1
                for k in range(1, FRONT_len - 1):
                    FRONT[k]["擁擠度"] += (
                        FRONT[k + 1]["F"][j] - FRONT[k - 1]["F"][j]
                    ) / scale
        return population
