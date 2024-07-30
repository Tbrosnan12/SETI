# Single pulse test 

Single pulse test is a pipeline for testing the effciancy of single pulse detection algorithms. 
The pipeline injects synthetic guassian pulses and records the fraction of S/N recovered by a given single pulse algorithm for different dispersion measures (DM) and guassian widths (characterised by the sigma of the guassian). 

# Dependencies

The synthetic pulses are createsd useing [Simfred](https://github.com/hqiu-nju/simfred)

sigpyproc is also needed to invert the filterbanks if not allready installed this can be cloned from [here](https://github.com/telegraphic/sigpyproc) (dont do this if you allready have sigpyproc it can mess things up)

There currently are scripts to test [Presto](https://github.com/scottransom/presto), [Transientx](https://github.com/ypmen/TransientX), [Heimdall](https://sourceforge.net/projects/heimdall-astro/) and [destroy](https://github.com/evanocathain/destroy_gutted/)

# Usage

The fake filterbanks containing pulses can created using create.sh. This can be done with the following command: 

```
bash create.sh <DM_start> <DM_end> <DM_step> <width_start> <width_end> <width_step>
```

This will create and store the filterbanks in a directory called output_files. The filterbanks can then be searched with any of the search algorithms by running their respective bash script. For example to search with Presto you just have to run: 
```
bash presto.sh
```
This can be done in the main folder you do not need to enter ```output_files```. The output image of the plot generated is named ```model.png```, based on whatever model you used to search and is stored in ```output_files```. 

Once data is generated the specifics of the plot can be changed in ```graph.py``` and the data replotted by running ```bash model.sh plot``` for any of the models. 


Since the filterbanks are injected along with noise, the results of one iteration can vary from the true result. This makes it advantageous to run and average out the test several times. 
For this purpose there are scripts in the ``` multi_run ``` directory to automate this process using [schedtool](https://man.archlinux.org/man/schedtool.8.en) (apt install schedtool), running on multible cpu cores at once. 

First ```cd muilti_run```, then change the values of the parameters at the top of ```multi_core.sh``` to your liking. This includes the range of DM's and widths you want to search over, the cpu cores you want to use aswell as the model you want to search with. Then just run the script (in the ```multi_run``` directory) to start:
```
bash multi_core.sh
```
This will generate an averaged plot named ```model.png``` in the ```multi_run``` directory. 

If you wish to remake the plot you can change the specifics in ```graph_multi.py``` and then run ``` bash refine.sh plot ```

# Example output plot

![image](https://github.com/user-attachments/assets/4adff139-23fa-4863-b3a1-513dd6f381a8)

