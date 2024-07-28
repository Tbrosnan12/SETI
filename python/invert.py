from sigpyproc.Readers import FilReader
from sigpyproc.Filterbank import Filterbank
import sys
myFil = FilReader(sys.argv[1])

myFil.invertFreq()
