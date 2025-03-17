.globl _start

_start:
       # 初始化寄存器
    andi x2, x2, 0
    addi x2, x2, 5
    addi x1, x0, 0    # x1用于存储当前斐波那契数列的前一个数，初始为F(0)
    addi x3, x0, 1    # x3用于存储当前斐波那契数列的数，初始为F(1)
    addi x4, x0, 1    # x4用于计数和循环控制，从1开始

loop:
    # 检查是否达到了N次计算
    bge x4, x2, end  # 如果 x4 >= N，跳转到结束

    # 计算下一个斐波那契数
    add x5, x1, x3   # x5 = x1 + x3
    addi x1, x3, 0   # 更新x1为当前的斐波那契数
    addi x3, x5, 0   # 更新x3为新计算的斐波那契数
    addi x4, x4, 1   # 更新循环计数器

    j loop           # 跳回循环开始

end:
ebreak
