import numpy as np
import sys
import matplotlib.pyplot as plt
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-file', dest='filename', help='name of 1-D file of numbers to plot')
parser.add_argument('-nbins', type=int, dest='nbins', help='set the number of bins in histogram (default: 20)', default=20)
args = parser.parse_args()

file = open(args.filename, "r")
data = np.genfromtxt(file)
nbins = args.nbins
plt.ylabel("Number of counts")
plt.xlabel("% S/N recovered")
plt.hist(data,bins=nbins)
plt.savefig("histogram.png")
