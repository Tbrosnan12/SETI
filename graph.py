import matplotlib.pyplot as plt
import sys
from matplotlib import cm
import numpy as np

# Function to read the data from a file and convert it to a 2D array
def read_file(filename):
    with open(filename, 'r') as file:
        array = []
        for line in file:
            row = line.strip().split()
            row = [float(num) for num in row]
            array.append(row)
    return array

# Read the data from the files specified in the command-line arguments
Reported = read_file(sys.argv[2])
Injected = read_file(sys.argv[1])

# Read the DM and width range parameters from the command-line arguments
DM_start =float(sys.argv[3])
DM_end = float(sys.argv[4])
DM_step = float(sys.argv[5])
width_start =float(sys.argv[6])
width_end = float(sys.argv[7])
width_step = float(sys.argv[8])

# Calculate the number of intervals for DM and width
DM_int = (DM_end - DM_start) / DM_step + 1
width_int = (width_end - width_start) / width_step + 1

# Parameters for amont of boxs to skip for ticks
N1 = 1
N2 = 1

# Calculate the percentage ratio of Reported to Injected values
array = 100 * np.divide(Reported, Injected)


norm = cm.colors.Normalize(vmax=100, vmin=0)
plt.figure(figsize=(6, 6))
plt.imshow(array, aspect='auto', cmap=cm.coolwarm, interpolation='nearest', norm=norm)
plt.xticks(np.arange(0, width_int, N1), np.arange(width_start, width_end + 0.5 * width_step, width_step * N1), fontsize=15)
plt.yticks(np.arange(0, DM_int, N2), np.arange(DM_start, DM_end + 0.5 * DM_step, DM_step * N2), fontsize=15)

# plt.gca().invert_yaxis()
cbar = plt.colorbar()
plt.title("PRESTO single_pulse_search", fontsize=15)
plt.xlabel("$\sigma_{intrinsic}$ (ms)", fontsize=15)
plt.ylabel("DM (pc cm$^{-3}$)", fontsize=15)
cbar.set_label("S/N Reported/Injected (%)", fontsize=15)
plt.tight_layout()
plt.savefig("output.png")

