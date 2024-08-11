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


array=np.array(read_file(sys.argv[1]))
# Calculate the percentage ratio of Reported to Injected values
array = 100 * array

# Read the DM and width range parameters from the command-line arguments
DM_start =float(sys.argv[2])
DM_end = float(sys.argv[3])
DM_step = float(sys.argv[4])
width_start =float(sys.argv[5])
width_end = float(sys.argv[6])
width_step = float(sys.argv[7])
name = sys.argv[8]

# Calculate the number of intervals for DM and width
DM_int = (DM_end - DM_start) / DM_step + 1
width_int = (width_end - width_start) / width_step + 1

# Parameters for amount of boxs to skip for x and y ticks
Nx = 4
Ny = 5
#min and max colourmap values
Vmax = 100
Vmin = 50

if len(sys.argv) > 9:
    Nx = int(sys.argv[9])
    Ny = int(sys.argv[10])
    Vmin = int(sys.argv[11])
    Vmax = int(sys.argv[12]) 



norm = cm.colors.Normalize(vmax=Vmax, vmin=Vmin)

plt.figure(figsize=(6, 6))  
plt.imshow(array, aspect='auto', cmap=cm.coolwarm, interpolation='nearest', norm=norm)
plt.xticks(np.arange(0, width_int, Nx), np.arange(width_start, width_end + 0.5 * width_step, width_step * Nx), fontsize=15)
plt.yticks(np.arange(0, DM_int, Ny), np.arange(DM_start, DM_end + 0.5 * DM_step, DM_step * Ny), fontsize=15)

# plt.gca().invert_yaxis()
cbar = plt.colorbar()
plt.title(f"{name} search", fontsize=15)
plt.xlabel("$\sigma_{intrinsic}$ (ms)", fontsize=15)
plt.ylabel("DM (pc cm$^{-3}$)", fontsize=15)
cbar.set_label("S/N Reported/Injected (%)", fontsize=15)
plt.tight_layout()
plt.savefig(f"{name}.png")