
import matplotlib.pyplot as plt
import sys
from matplotlib import cm
import numpy as np

def read_file(filename):
    with open(filename, 'r') as file:
        array = []
        for line in file:
            row = line.strip().split()
            row = [float(num) for num in row]
            array.append(row)
    return array

snr=np.array(read_file(sys.argv[1])) / np.array(read_file(sys.argv[2]))
xaxis=np.zeros(round(len(snr)))
for i in range(round(len(snr))):
    xaxis[i]=i

plt.plot(xaxis,snr)
plt.savefig(f"boxcar_snr.png")
