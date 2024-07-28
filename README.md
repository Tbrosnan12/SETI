# Single pulse test 

Single pulse test is a pipeline for testing the efficancy of single pulse detection algorithms. 
The pipeline injects synthetic guassian pulses and records the fraction of S/N recovered by a given single pulse algorithm for different dispersion measures (DM) and guassian widths (characterised by the sigma of the guassian). 





# Dependencies

The synthetic pulses are createsd useing [dynspec](https://github.com/hqiu-nju/simfred)

sigpyproc is also needed to invert the filterbanks if not allready installed this can be cloned from [here](https://github.com/telegraphic/sigpyproc) (dont do this if you allready have sigpyproc it can mess things up)

There currently are scripts to test [Presto](https://github.com/scottransom/presto), [Transientx](https://github.com/ypmen/TransientX), [Heimdall](https://sourceforge.net/projects/heimdall-astro/) and [destroy](https://github.com/evanocathain/destroy_gutted/)
