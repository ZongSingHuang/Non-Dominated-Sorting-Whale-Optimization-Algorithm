import functools
import itertools
from operator import itemgetter

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
        self.best_front = list()  # 第一前緣解

    def opt(self):
        # 初始化候選解
        population = [self.initial_chromosome() for _ in range(self.size_pop)]

        # 計算適應值
        population = self.calc_benchmark(population=population)

        # 快速非支配排序
        population = self.fast_nondominated_sort(population=population)

        # 擁擠度
        population = self.crowding_distance(population=population)

        # 開始迭代
        iteration = 0
        while iteration <= self.size_iter:
            # 訊息
            if (iteration + 1) % 10 == 0:
                print(f"iteration {iteration + 1}")

            # 初始化子代
            offspring = [
                self.initial_chromosome(is_zero=True) for _ in range(self.size_pop)
            ]

            # by size_pop
            for i in range(self.size_pop):
                # 從第一前緣解中隨機挑一條鯨魚 whale_best
                best_front = [k for k in population if k["推薦等級"] == 0]
                whale_best = np.random.choice(best_front)

                # ---------- 新鯨魚 1: MFO ----------
                # 新鯨魚 1 = 父代[i] + rand(D) × (whale_best - SF × 父代[i])
                SF = np.random.randint(1, 3)  # SF 不是 1 就是 2
                whale_new1 = population[i]["X"] + np.random.uniform(
                    size=self.size_dim
                ) * (whale_best["X"] - SF * population[i]["X"])

                # 邊界處理
                whale_new1 = np.clip(whale_new1, self.lb, self.ub)

                # 新鯨魚 1 轉 dict
                whale_new1 = {
                    "X": whale_new1,
                    "F": np.zeros(self.size_obj),
                    "輸給幾組": 0,
                    "贏了誰": [],
                    "推薦等級": None,
                }

                # 新鯨魚 1 的適應值
                whale_new1 = self.calc_benchmark(population=[whale_new1])[0]

                # 若新鯨魚 1 比父代[i]還要好
                if self.dominates(whale_new1, population[i]):
                    # 父代[i]放入子代[i]
                    offspring[i]["X"] = population[i]["X"].copy()
                    offspring[i]["F"] = population[i]["F"].copy()
                    # 新鯨魚 1 取代父代[i]
                    population[i]["X"] = whale_new1["X"].copy()
                    population[i]["F"] = whale_new1["F"].copy()
                # 否則
                else:
                    # 新鯨魚 1 放入子代[i]
                    offspring[i]["X"] = whale_new1["X"].copy()
                    offspring[i]["F"] = whale_new1["F"].copy()

                # 從父代隨機挑選一隻鯨魚 whale_rand，該鯨魚不可以是父代[i]
                j = int(np.floor(np.random.uniform() * self.size_pop))
                while i == j:
                    j = int(np.floor(np.random.uniform() * self.size_pop))
                whale_rand = population[j]

                # ---------- 新鯨魚 2: Seyedali Mirjalili 的 WOA ----------
                # 生成係數
                a = 2 - iteration * (2 / self.size_iter)
                a2 = -1 + iteration * (-1 / self.size_iter)
                r1 = np.random.uniform()
                r2 = np.random.uniform()
                A = 2 * a * r1 - a
                C = 2 * r2
                b = 1
                t = (a2 - 1) * np.random.uniform() + 1
                p = np.random.uniform()
                if p < 0.5:
                    whale_new2 = (
                        population[i]["X"]
                        + whale_best["X"]
                        - A * np.abs(C * whale_best["X"] - whale_rand["X"])
                    )
                else:
                    whale_new2 = (
                        population[i]["X"]
                        + np.abs(whale_best["X"] - whale_rand["X"])
                        * np.exp(b * t)
                        * np.cos(t * 2 * np.pi)
                        + whale_best["X"]
                    )

                # 邊界處理
                whale_new2 = np.clip(whale_new2, self.lb, self.ub)

                # 新鯨魚 2 轉 dict
                whale_new2 = {
                    "X": whale_new2,
                    "F": np.zeros(self.size_obj),
                    "輸給幾組": 0,
                    "贏了誰": [],
                    "推薦等級": None,
                }

                # 適應值
                whale_new2 = self.calc_benchmark(population=[whale_new2])[0]

                # 若新鯨魚 2 比父代[i]還要好
                if self.dominates(whale_new2, population[i]):
                    # 父代[i]放入子代[i]
                    offspring[i]["X"] = population[i]["X"].copy()
                    offspring[i]["F"] = population[i]["F"].copy()
                    # 新鯨魚 2 取代父代[i]
                    population[i]["X"] = whale_new2["X"].copy()
                    population[i]["F"] = whale_new2["F"].copy()
                # 否則
                else:
                    # 新鯨魚 2 放入子代[i]
                    offspring[i]["X"] = whale_new2["X"].copy()
                    offspring[i]["F"] = whale_new2["F"].copy()

                # ---------- 新鯨魚 3: 突變策略 ----------
                # 從父代隨機挑選一隻鯨魚 whale_rand，該鯨魚不可以是父代[i]
                j = int(np.floor(np.random.uniform() * self.size_pop))
                while i == j:
                    j = int(np.floor(np.random.uniform() * self.size_pop))
                whale_rand = population[j]

                # 令父代[i] 為 whale_new3
                whale_new3 = population[i]["X"].copy()
                # 生成一個由 1~D 組成的亂數數列 seed
                seed = np.random.permutation(self.size_dim)
                # seed 只取前 k 個
                k = int(np.ceil(np.random.uniform() * self.size_dim))
                pick = seed[:k]
                # 對 whale_new3 的特定維度進行突變
                whale_new3[pick] = np.random.uniform(
                    low=self.ub[pick], high=self.lb[pick]
                )

                # 新鯨魚 3 轉 dict
                whale_new3 = {
                    "X": whale_new3,
                    "F": np.zeros(self.size_obj),
                    "輸給幾組": 0,
                    "贏了誰": [],
                    "推薦等級": None,
                }

                # 適應值
                whale_new3 = self.calc_benchmark(population=[whale_new3])[0]

                # 若 whale_new3 比 whale_rand 還要好
                if self.dominates(whale_new3, whale_rand):
                    # whale_rand 放入子代[i]
                    offspring[j]["X"] = whale_rand["X"].copy()
                    offspring[j]["F"] = whale_rand["F"].copy()
                    # whale_new3 取代父代[i]
                    population[j]["X"] = whale_new3["X"].copy()
                    population[j]["F"] = whale_new3["F"].copy()
                else:
                    # whale_new3 放入子代[i]
                    offspring[j]["X"] = whale_new3["X"].copy()
                    offspring[j]["F"] = whale_new3["F"].copy()

            # 父代+子代
            family = population + offspring

            # 快速非支配排序
            family = self.fast_nondominated_sort(population=family)

            # 擁擠度
            family = self.crowding_distance(population=family)

            # 菁英策略
            population = self.elitist_strategy(population=family)
            self.best_front = [k["F"].copy() for k in population if k["推薦等級"] == 0]

            # 迭代 + 1
            iteration += 1

    # 初始化染色體
    def initial_chromosome(self, is_zero: bool = False) -> dict:
        if is_zero:
            chromosome = {
                "X": np.zeros(self.size_dim),
                "F": np.zeros(self.size_obj),
                "輸給幾組": 0,
                "贏了誰": [],
                "推薦等級": None,
            }
        else:
            chromosome = {
                "X": np.random.uniform(low=self.lb, high=self.ub, size=[self.size_dim]),
                "F": np.zeros(self.size_obj),
                "輸給幾組": 0,
                "贏了誰": [],
                "推薦等級": None,
            }
        return chromosome

    # 快速非支配排序
    def fast_nondominated_sort(self, population) -> list:
        FRONTs = [[]]
        for master_idx, master in enumerate(population):
            master["擁擠度"] = 0
            master["輸給幾組"] = 0
            master["推薦等級"] = None
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
        # 望小
        and_condition = all(p1["F"] <= p2["F"])
        or_condition = any(p1["F"] < p2["F"])
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
                    for k in range(1, FRONT_len - 1):
                        FRONT[k]["擁擠度"] = np.inf
                else:
                    for k in range(1, FRONT_len - 1):
                        FRONT[k]["擁擠度"] += (
                            FRONT[k + 1]["F"][j] - FRONT[k - 1]["F"][j]
                        ) / scale
        return population

    def elitist_strategy(self, population: list) -> list:
        # 初始化
        elitist = list()

        # 分群
        FRONTs = itertools.groupby(population, key=itemgetter("推薦等級"))

        # by 推薦等級
        for i, FRONT in FRONTs:
            FRONT = list(FRONT)
            FRONT_len = len(FRONT)
            if len(elitist) + FRONT_len <= self.size_pop:
                elitist += FRONT
            else:
                FRONT.sort(key=itemgetter("擁擠度"), reverse=True)
                k = self.size_pop - len(elitist)
                elitist += FRONT[:k]
            if len(elitist) == self.size_pop:
                break
        return elitist
