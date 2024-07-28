import numpy as np
import sys

def custom_round(value, decimals):
    rounded_value = np.round(value, decimals)
    if decimals >= 0 and rounded_value == int(rounded_value):
        return int(rounded_value)
    return rounded_value


print(custom_round(float(sys.argv[1]),int(sys.argv[2])))
