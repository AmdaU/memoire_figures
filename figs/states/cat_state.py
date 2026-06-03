from wigner import plot_wigner, load_rho, save_rho
import qutip as qt
import matplotlib.pyplot as plt
import os
N = 60
alpha = 2.0
psi = (qt.coherent(N, alpha) + qt.coherent(N, -alpha)).unit()
rho = qt.ket2dm(psi)
save_rho(rho, 'cat_state')