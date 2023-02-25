import numpy as np


def ztd1(population: list) -> list:
    for idx, chromosome in enumerate(population):
        X = chromosome["X"]
        F = np.zeros(2)
        n = len(X)
        g = 1 + 9 * np.sum(X[1:]) / (n - 1)
        F[0] = X[0]
        F[1] = 1 - np.sqrt(X[0] / g)
        population[idx]["F"] = F
    return population
