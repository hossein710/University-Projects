# In Each Section, First Part Refers to built_in Functions & Second one is Self_written Program.
# --------------------------------------------------------------------------------------------
# a,b
import matplotlib.pyplot as plt
import numpy as np
# from scipy.linalg import lu
# from math import sqrt

A = np.array([[0.1,0.25],[0.6,-0.4]])
b = np.array([10000,0])


print('\nWe Assume "x" as Blue-Chip & "y" as High-Tech\n\n')
x,y = np.linalg.solve(A,b)
print(f'Built_in answer For 5.a:\t x = {x}\ty = {y}')
print(f'Total (Minimum) Investment:\t{x+y}')
print('-'*20)
# --------------------------------------------------------------------------------------------
A_ = [[0.1,0.25],[-0.6,0.4]]
b_ = [10000,0]

def inverse2(A):
    det = A[0][0] * A[1][1] - A[0][1] * A[1][0]
    A_inv = [[A[1][1]/det,-A[0][1]/det],[-A[1][0]/det,A[0][0]/det]]
    return A_inv

ans = [0,0]
B = inverse2(A_)
for i in range(2):
    for j in range(2):
        ans[i] += B[i][j] * b_[j]

print(f'Self_made answer For 5.a:\t x = {ans[0]}\ty = {ans[1]}')
print(f'Total (Minimum) Investment:\t{ans[0]+ans[1]}')
print('-'*20)
# --------------------------------------------------------------------------------------------
# c: LU

import numpy as np

def lu_gauss(A):
    """ we have to take factor from a21/a11 = -6 in marix A and eliminate a21 to have U matrix and then with
    inverse of E1 = [[1,0],[-6,1]] we will have L."""
    A = np.array(A, dtype=float)
    n = A.shape[0]
    L = np.eye(n)
    U = A.copy()

    for i in range(n - 1):
        for j in range(i + 1, n):
            factor = U[j, i] / U[i, i]
            L[j, i] = factor
            U[j, i:] = U[j, i:] - factor * U[i, i:]
    
    return L, U

L, U = lu_gauss(A)

print("L =\n", L)
print("U =\n", U)
print(f'verify(A):\n{L@U}')
# ------------------------------------------------------------------------------
# we assume Ly = b & Ux = y Because we Know Ax = b So we have LUx = b
y1,y2 = np.linalg.solve(L,b)
y = [y1,y2]
x1,x2 = np.linalg.solve(U,y)

print(f'x = {x1}\ty = {x2}')
print('-'*20)
print('As we see, Answers Are Equal with Part b.')
print('-'*20)
# -------------------------------------------------------------------------------
# 5.d) cholesky: we need to ensure that A is definite positive and also A = A.T(transpose of A)
# But in this matrix A != A.T, So We can't Find Cholesky Decomposition.
# -------------------------------------------------------------------------------
# 5.e) We Have Calculated A_inverse In Part a as 'B'
# part 2)
x_new = [0,0]
new_b = np.array([10000+5000,0])
for i in range(2):
    for j in range(2):
        x_new[i] += B[i][j] * new_b[j]
# Or we could use 'np.linalg.solve' directly.
print('investment increased by 5000$.\n')
print(f'New x: {x_new[0]}\tNew y:{x_new[1]}')
print(f'New Total Investment:\t{sum(x_new)}')
print('-'*30)
#Total Investment Increased By 1.5x
# part 3)
x = 0.7
c = 0
while(c<4):
    print(f'investment CAP(High-Tech)(10k $): {x}')
    A_new = np.array([[0.1,0.25],[x,x-1]])
    A_new_inverse = inverse2(A_new)
    x_new2 = [0,0]
    for i in range(2):
        for j in range(2):
            x_new2[i] += A_new_inverse[i][j] * b[j]
    print(f'New x: {x_new2[0]}\tNew y:{x_new2[1]}')
    print(f'New(2) Total Investment if trader invests 10k $:\t{sum(x_new2)}')
    print('-'*30)
    x -= 0.1
    c += 1
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------

R = 10000  # required annual return
p = np.linspace(0.4, 0.7, 100)  # High-Tech cap range
T = 200000 / (3*p + 2)          # total investment formul (from A)

plt.figure(figsize=(7,5))
plt.plot(p, T, 'b-o', linewidth=2, markersize=5, label='Total Investment')

plt.title('Total Investment vs High-Tech Cap', fontsize=14, weight='bold')
plt.xlabel('High-Tech Cap (fraction of total)', fontsize=12)
plt.ylabel('Total Investment ($)', fontsize=12)
plt.grid(True, linestyle='--', alpha=0.6)
plt.legend()

# key Points
for cap in [0.4, 0.5, 0.6, 0.7]:
    Ti = 200000 / (3*cap + 2)
    plt.text(cap, Ti + 1500, f"${Ti:,.0f}", ha='center', fontsize=10)

plt.tight_layout()
plt.show()