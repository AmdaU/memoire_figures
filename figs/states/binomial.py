from wigner import plot_wigner, load_rho, save_rho
import qutip as qt
import matplotlib.pyplot as plt
import os
N = 60
psi = (qt.fock(N, 0) + qt.fock(N, 4)).unit()
rho = qt.ket2dm(psi)
save_rho(rho, 'binomial')