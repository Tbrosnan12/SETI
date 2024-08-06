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

snr=0
for i in np.arange(1,len(sys.argv),1):
    snr += np.array(read_file(sys.argv[i]))
snr=snr*100/(len(sys.argv)-1)



snr = snr.flatten()
xaxis=np.arange(0,len(snr),1)
N1=3

plt.xticks(np.arange(0, len(snr), N1/0.1), np.arange(1, 25 + 0.5 * 1, 1* N1), fontsize=15)
plt.plot(xaxis,snr)
plt.xlabel("width")
plt.ylabel("Ratio of S/N recovered")
plt.title("0 DM recovery for Presto")
plt.savefig(f"boxcar_snr.png")
