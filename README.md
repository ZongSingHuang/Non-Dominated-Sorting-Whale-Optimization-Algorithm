# Non-Dominated Sorting Whale Optimization Algorithm (NSWOA): A Multi-Objective Optimization algorithm for Solving Engineering Design Problems

1. 我改成 python code

2. 原本的 matlab code，我只有調整 NSWOA.m，原因如下:

   2.1 有些代碼是無效的\n

   2.2 支配判定我改用更貼近柏拉圖定理的方式進行改寫

   2.3 加入中文註解
  
3. 速度沒有比原作者快

4. 收斂結果近似原作者

# PAPER
Dr. Pradeep Jangir and Narottam Jangir, “Non-Dominated Sorting Whale Optimization Algorithm (NSWOA): A Multi-Objective Optimization algorithm for Solving Engineering Design Problems”, GJRE, vol. 17, no. F4, pp. 15–42, Mar. 2017.

http://dx.doi.org/10.19080/ETOAJ.2018.02.555579

# reimplement from
Dr. Pradeep Jangir (2023). MULTI OBJECTIVE NON SORTED WHALE OPTIMIZER (MOWOA) (NSWOA) (https://www.mathworks.com/matlabcentral/fileexchange/75261-multi-objective-non-sorted-whale-optimizer-mowoa-nswoa), MATLAB Central File Exchange. Retrieved February 26, 2023.

還是說明下 NSWOA 的流程，下面描述可能與代碼架構略有不同

還是說明下 NSWOA 的流程，下面描述可能與代碼架構略有不同

# 主流程:
1. 生成父代
2. 計算父代適應值
3. 對父代進行非支配排序
4. 計算父代擁擠度
5. 開始迭代
    1. 生成子代
        1. 歷遍父代(鯨魚i)
        2. 從第一前緣解隨機挑一條鯨魚 whale_best
            1. 以鯨魚i及whale_best生成whale_new1
            2. 計算whale_new1的適應值
            3. 如果whale_new1優於鯨魚i，則鯨魚i移動到子代i；whale_new1移動到父代i
            4. 否則whale_new1移動到子代i
        3. 從父代隨機挑選一隻鯨魚j，j!=i，名為whale_rand
            1. 以鯨魚i、whale_rand及whale_best生成whale_new2
            2. 計算whale_new2的適應值
            3. 如果whale_new2優於鯨魚i，則鯨魚i移動到子代i；whale_new2移動到父代i
            4. 否則whale_new2移動到子代i
        4. 從父代隨機挑選一隻鯨魚j，j!=i，名為whale_rand
            1. 對鯨魚i進行突變，生成whale_new3
            2. 計算whale_new3的適應值
            3. 如果whale_new3優於whale_rand，則whale_rand移動到子代i；whale_new3移動到父代i
            4. 否則whale_new3移動到子代i
    2. 家族 = 父代與子代合併
    3. 對家族進行快速非支配排序
    4. 計算家族擁擠度
    5. 對家族採菁英策略，產生新的父代
    6. 保留父代中推薦等級為 0 的鯨魚作為當代最適解
