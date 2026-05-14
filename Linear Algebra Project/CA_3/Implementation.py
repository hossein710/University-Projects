import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.decomposition import PCA
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import mean_squared_error, r2_score


df = pd.read_csv('Housing_Price.csv')
X = df.iloc[:, :-1].values
y = df.iloc[:, -1].values

scaler = StandardScaler()
X_normalized = scaler.fit_transform(X)

X_b = np.c_[np.ones((X_normalized.shape[0], 1)), X_normalized]

X_train, X_test, y_train, y_test = train_test_split(X_b, y, test_size=0.2, random_state=42)

# Part 2: Normal Equation
def normal_equation(X, y):
    return np.linalg.inv(X.T @ X) @ X.T @ y

theta_normal = normal_equation(X_train, y_train)

def gradient_descent(X, y, lr=0.01, iterations=1000):
    m = len(y)
    theta = np.zeros(X.shape[1])
    history = []
    theta_path = []

    for _ in range(iterations):
        gradients = (2/m) * X.T @ (X @ theta - y)
        theta = theta - lr * gradients
        mse = np.mean((X @ theta - y)**2)
        history.append(mse)
        theta_path.append(theta.copy())
        
    return theta, history, np.array(theta_path)

theta_gd, gd_history, gd_path = gradient_descent(X_train, y_train)

def plot_gdd(cost_history,n_iterations=1000):
    plt.figure(figsize=(10, 6))
    plt.plot(range(n_iterations), cost_history, color='red', linewidth=2)
    plt.title('MSE show for gd descent')
    plt.xlabel('Iterations')
    plt.ylabel('(MSE)')
    plt.grid(True)
    plt.show()
    
# plot_gdd(gd_history)

# XtX = X_train.T @ X_train
# cond_XtX = np.linalg.cond(XtX)
# cond2 = np.linalg.cond(X.T @ X)

# print(f"Condition number of X^T X: {cond_XtX}")
# print(cond2,'<--- if we did not normalize.\n\n\n')


def newton_method(X, y, iterations=10):
    m = len(y)
    theta = np.zeros(X.shape[1])
    theta_path = []
    
    # Hessian is constant for Linear Regression
    H = (2/m) * (X.T @ X)
    H_inv = np.linalg.inv(H)
    
    for _ in range(iterations):
        grad = (2/m) * X.T @ (X @ theta - y)
        theta = theta - H_inv @ grad
        theta_path.append(theta.copy())
        
    return theta, np.array(theta_path)

theta_newton, newton_path = newton_method(X_train, y_train)

pca = PCA(n_components=3)
X_reduced = pca.fit_transform(X_normalized)
# print('PCA Model will give:\n',X_reduced,'\n\n\n\n\n')

def evaluate(theta, X, y, name):
    preds = X @ theta
    print(f"{name} -> MSE: {mean_squared_error(y, preds):.4f}, R2: {r2_score(y, preds):.4f}")

evaluate(theta_normal, X_test, y_test, "Normal Eq")
evaluate(theta_gd, X_test, y_test, "GD")
evaluate(theta_newton, X_test, y_test, "Newton")



pca2 = PCA(n_components=2)
X_pca = pca2.fit_transform(X_normalized)
X_pca_b = np.c_[np.ones((X_pca.shape[0], 1)), X_pca]
X_train_pca, X_test_pca, y_train, y_test = train_test_split(
    X_pca_b, y, test_size=0.2, random_state=42
)

theta_normal_pca = normal_equation(X_train_pca, y_train)

theta_gd_pca, gd_history_pca, gd_path_pca = gradient_descent(
    X_train_pca, y_train
)
theta_newton_pca, newton_path_pca = newton_method(
    X_train_pca, y_train
)



def plot_3d_contour_trajectory(gd_path, newton_path, X, y):
    w_final = gd_path[-1]
    
    
    w1_range = np.linspace(w_final[1] - 3, w_final[1] + 3, 50)
    w2_range = np.linspace(w_final[2] - 3, w_final[2] + 3, 50)
    W1, W2 = np.meshgrid(w1_range, w2_range)
    Z = np.zeros(W1.shape)

    
    for i in range(len(w1_range)):
        for j in range(len(w2_range)):
            w_tmp = w_final.copy()
            w_tmp[1] = W1[i, j]
            w_tmp[2] = W2[i, j]
            Z[i, j] = np.mean((X @ w_tmp - y)**2)

    
    fig = plt.figure(figsize=(14, 10))
    ax = fig.add_subplot(111, projection='3d')

    
    surf = ax.plot_surface(W1, W2, Z, cmap='viridis', alpha=0.4, antialiased=True)

    
    ax.contour(W1, W2, Z, zdir='z', offset=np.min(Z)-2, cmap='viridis')

    
    gd_path = np.array(gd_path)
    gd_z = [np.mean((X @ p - y)**2) for p in gd_path]
    ax.plot(gd_path[:, 1], gd_path[:, 2], gd_z, color='red', 
            marker='o', markersize=4, label='GD Path', linewidth=2)

    
    newton_path = np.array(newton_path)
    newton_z = [np.mean((X @ p - y)**2) for p in newton_path]
    ax.plot(newton_path[:, 1], newton_path[:, 2], newton_z, color='blue', 
            marker='x', markersize=8, label='Newton Path', linewidth=2)

    ax.set_xlabel('Weight for Feature 1')
    ax.set_ylabel('Weight for Feature 2')
    ax.set_zlabel('Cost (MSE)')
    ax.set_title('3D Error Surface with Projected Contours')
    ax.legend()
    
    ax.view_init(elev=30, azim=120)
    
    plt.colorbar(surf, shrink=0.5, aspect=5)
    plt.show()

# plot_3d_contour_trajectory(gd_path, newton_path, X_train, y_train)
# plot_3d_contour_trajectory(gd_path_pca, newton_path_pca, X_train_pca, y_train)
