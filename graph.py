import matplotlib.pyplot as plt 
import sys
from matplotlib import cm
import numpy as np

def read_file(filename):
    with open(filename, 'r') as file:
        array = []
        for line in file:
            # Strip any leading/trailing whitespace and split by spaces
            row = line.strip().split()
            # Convert the row from strings to integers (or floats if needed)
            row = [float(num) for num in row]
            # Append the row to the array
            array.append(row)
    return array

Reported = read_file(sys.argv[2])
Injected = read_file(sys.argv[1])
DM_start=int(sys.argv[3])
DM_end=int(sys.argv[4])
DM_step=int(sys.argv[5])
width_start=int(sys.argv[6])
width_end=int(sys.argv[7])
width_step=int(sys.argv[8])

DM_int=(DM_end-DM_start)/DM_step+1
width_int=(width_end-width_start)/width_step+1

N1=2
N2=10
array = 100*np.divide(Reported,Injected)

#print(DM_int,DM_start,DM_end+.5*DM_step,DM_step)

norm=cm.colors.Normalize(vmax=100, vmin=0)
plt.figure(figsize=(6,6))
plt.imshow(array, aspect='auto', cmap=cm.coolwarm, interpolation='nearest', norm=norm)
plt.xticks(np.arange(0,width_int,N1),np.arange(width_start,width_end+.5*width_step,width_step*N1),fontsize=15)
plt.yticks(np.arange(0,DM_int,N2),np.arange(DM_start,DM_end+.5*DM_step,DM_step*N2),fontsize=15)
#plt.gca().invert_yaxis()
cbar=plt.colorbar()
plt.title("PRESTO single_pulse_search",fontsize=15)
plt.xlabel("$\sigma_{intrinsic}$ (ms)",fontsize=15)
plt.ylabel("DM (pc cm$^{-3}$)",fontsize=15)
cbar.set_label("S/N Reported/Injected (%)",fontsize=15)
plt.tight_layout()
plt.savefig("output.png")
