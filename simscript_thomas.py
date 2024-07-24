import dynspec
import matplotlib.pyplot as plt
import numpy as np
import math as m
from matplotlib import cm

def _main():
    from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
    parser = ArgumentParser(description='Script description', formatter_class=ArgumentDefaultsHelpFormatter)
    parser.add_argument('-l', '--label',type=str, default="test",help='Output File Name, no suffix')
    parser.add_argument('-m', '--mode',type=str, default="single",help='Injection modes: single, scat, boxcar')
    parser.add_argument('-A','--amplitude',type=float, default=50,help='Injection : fluence or snr')
    parser.add_argument('-t','--tbin',type=int, default=10,help='time samples per bin during simulation')
    parser.add_argument('-f','--fbin',type=int, default=10,help='freq channels per bin during simulation')
    parser.add_argument('-s','--samples',type=int, default=20000,help='injection block sample length')
    parser.add_argument('--nchan',type=int, default=336,help='number of channels')
    parser.add_argument('--tsamp',type=int, default=1,help='time resolution (ms)')
    parser.add_argument('--fch1',type=int, default=1100,help='first channel center freq')
    parser.add_argument('--bwchan',type=int, default=1,help='injection block sample length, can be negative')
    parser.add_argument('-N','--npulse',type=int, default=50,help='number of pulses to inject')
    parser.add_argument('--dm_start',type=float, default=0,help='min dm (pc cm-3)')
    parser.add_argument('--step',type=float, default=50,help='step dm (pc cm-3)')
    parser.add_argument('--dm',type=float, default=3000,help='max dm (pc cm-3)')
    parser.add_argument('--sig_start',type=float, default=0.5,help='starting pulse width sigma (ms)')
    parser.add_argument('--sig_step',type=float, default=0.5,help='starting pulse width sigma (ms)')
    parser.add_argument('--sig',type=float, default=0.5,help='max pulse width sigma (ms)')
    values = parser.parse_args()
    sigmarange=np.arange(values.sig_start,values.sig+0.5*values.sig_step,values.sig_step)
    dmrange=np.arange(values.dm_start,values.dm+0.5*values.step,values.step)
    sig_start=custom_round(float(values.sig_start),1)
    sig=custom_round(float(values.sig),1)
    sig_step=custom_round(float(values.sig_step),2)
    dm_start=custom_round(float(values.dm_start),0)
    dm=custom_round(float(values.dm),0)
    step=custom_round(float(values.step),0)
    tbin=values.tbin
    fbin=values.fbin
    fch1=values.fch1
    bwchan=values.bwchan
    nchan=values.nchan
    tsamp=values.tsamp
    nsamp=values.samples
    mode=values.mode
    label=values.label
    npulse=values.npulse
    ampl=values.amplitude
    snrbatch(fch1,bwchan,nchan,tsamp,mode,label,nsamp,npulse,sigmarange,dmrange,tbin,fbin,ampl,sig_start,sig,sig_step,dm_start,dm,step)

def custom_round(value, decimals):
    rounded_value = np.round(value, decimals)
    if decimals >= 0 and rounded_value == int(rounded_value):
        return int(rounded_value)
    return rounded_value

def snrbatch(fch1,bwchan,nchan,tsamp,mode,label,nsamp,npulse,sigmarange,dmrange,tbin,fbin,ampl,sig_start,sig,sig_step,dm_start,dm,step):
    ## this script generates 1 pulse for each parameter
    model=dynspec.spectra(fch1=fch1,nchan=nchan,bwchan=bwchan,tsamp=tsamp,tbin=tbin,fbin=fbin)
    testname=f"{label}_{mode}"
    w=open(f"{testname}.txt",'w')
    ### create file
    SN_array=np.zeros((int((dm-dm_start)/step)+1,int((sig-sig_start)/sig_step)+1))
    mask=np.zeros(nchan)
    mask[nchan//6*2:nchan//6*3]=1
    printloop=0
    if bwchan>0:
        tstart=nsamp*0.75*tsamp
    else:
        tstart=nsamp*0.25*tsamp
    print("starting injection\n")
    for i in sigmarange:  ### intrinsic standard deviation sigma
        for j in dmrange:  ### DM
            model.create_filterbank(f"{testname}_dm{custom_round(j, 0)}_width{custom_round(i,2)}",std=18,base=127)
            print(f"created file {testname}_dm{custom_round(j,0)}_width{custom_round(i, 2)}")
            # w=open(f"{testname}_dm{np.round(j,0)}_width{np.round(i,1).txt",'w')
            # print (f"make DM{i} width{j}\n")
            xset=np.random.rand()-0.5
            model.writenoise(nsamp=nsamp)
            model.writenoise(nsamp=nsamp)
            base1,base2=model.burst(t0=tstart,dm=j,A=20,width=i,mode=mode,nsamp=nsamp,offset=xset,tau=0)
            #print(N)
            # print(model.L2_snr())
            # print(i)
            # print(model.L2_snr()[0][:-2]+";"+str(dynspec.L2_snr(base2/model.L2_snr()[1]*50))+"\n")
            for printloop in range(npulse):  ### how many pulses in the data
                model.writenoise(nsamp=nsamp)
                #print(model.write_snr()[1],i,j)
                model.inject(base1/model.write_snr()[1]*ampl)
                w.write(model.write_snr()[0][:-2]+";"+str(dynspec.L2_clean(base2/model.write_snr()[1]*50))+f";{xset}"+"\n")
                # print(f" {np.round(i,1)}/11.1 completed", end = "\r")
                #print(int(round((j-dm_start)/step)),int(round((i-sig_start)/sig_step)))
                SN_array[int(round((j-dm_start)/step)),int(round((i-sig_start)/sig_step))]=float(dynspec.L2_clean(base2/model.write_snr()[1]*50))
                model.writenoise(nsamp=nsamp)
            model.writenoise(nsamp=nsamp) ## write noise
            model.closefile()
    w.close()

    #norm = cm.colors.Normalize(vmax=base1.max(), vmin=0)
    #plt.figure(figsize=(6, 6))
    #plt.imshow(base1, aspect='auto', cmap=cm.coolwarm, interpolation='nearest', norm=norm)
    #cbar = plt.colorbar()
    #plt.title("PRESTO single_pulse_search", fontsize=15)
    #plt.xlabel("freq", fontsize=15)
    #plt.ylabel("time", fontsize=15)
    #cbar.set_label("Pulse strength", fontsize=15)
    #plt.tight_layout()
    #plt.savefig("base1.png")

    # Open a file in write mode
    with open('injected_snr.txt', 'w') as file:
      for row in SN_array:
         # Join elements of the row with spaces and write to the file
         file.write(' '.join(map(str, row)) + '\n')
    print("\nFinished creating filterbanks ")


##########

if __name__ == '__main__':
    _main()
