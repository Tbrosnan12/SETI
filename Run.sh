#!/bin/bash

usage() {
    echo "Usage: $0 <DM> <width>"
    echo "  <DM>    : Dispersion Measure"
    echo "  <width> : Pulse width"
    echo "or for a range of DM's and width's:"
    echo "Usage: $0 range <DM_start> <DM_end> <DM_step> <width_start> <width_end> <width_step>"
    echo "If data has already been generated and you want to just re-make plots:"
    echo "Usage: $0 range <DM_start> <DM_end> <DM_step> <width_start> <width_end> <width_step> plot"
    exit 1
}

# Check if the correct number of arguments is provided
if [ "$#" -lt 2 ]; then
    echo "Error: Invalid number of arguments."
    usage
fi

# if statment here to deside waither one pulse is created or a range of pulses
if [ "$1" = "range" ]; then
        # Check if the correct number of arguments is provided
    if [ "$#" -lt 7 ]; then
    	echo "Error: Invalid number of arguments."
    	usage
    fi

    declare -A matrix
    if [ $? -ne 0 ]; then
        echo "Error: This script will only run using 'bash $0' as sh shell does not have declare -A matrix for some reason "
        exit 1
    fi
    declare -A boxcar_matrix

    DM_start=$2
    DM_end=$3
    DM_step=$4
    width_start=$5
    width_end=$6
    width_step=$7
    amp=50

    if [[ "$#" == 8 ]] && [[ "$8" == "plot" ]]; then
       echo "Remaking plots from data in output_files"
       cd output_files
    else
        if [ -d "output_files" ]; then
           rm -r "output_files"
           echo "deleted output_files"
        fi
        mkdir output_files
        cd output_files
        touch injected_snr.txt
        touch reported_snr.txt
        touch boxcar.txt

        # Create the pulses
        python ../simscript_thomas.py --dm_start ${DM_start} --dm ${DM_end} --step ${DM_step} --sig_start ${width_start} --sig_step ${width_step} --sig ${width_end} -N 1 -A $amp -s 5000
        if [ $? -ne 0 ]; then
           echo "Error: Failed to run simscript_thomas.py"
           exit 1
        fi
	for width1 in $(seq $width_start $width_step $width_end); do
	    for DM1 in $(seq $DM_start $DM_step $DM_end); do
                width=$(python ../custom_round.py $width1 1)
                DM=$(python ../custom_round.py $DM1 0)
        	# Run the prepdata command
		#echo "$width,$width_start,$width_step" 
        	prepdata -nobary -noclip -dm ${DM} -o test_single_dm${DM}_width${width} test_single_dm${DM}_width${width}.fil | grep "Writing"
        	if [ $? -ne 0 ]; then
        	    echo "Error: Failed to run prepdata"
        	    exit 1
        	fi
        	# Run the single_pulse_search.py command
        	single_pulse_search.py -b test_single_dm${DM}_width${width}.dat | grep "Found"
        	if [ $? -ne 0 ]; then
        	    echo "Error: Failed to run single_pulse_search.py"
            	    exit 1
        	fi


        	filename="test_single_dm${DM}_width${width}.singlepulse"

        	# Check if the file exists
        	if [ ! -f "$filename" ]; then
        	    echo "Error: File '$filename' not found."
        	    exit 1
        	fi

        	#extract the Sigma values from the file
		    #echo "$width,$width_start,$width_step"
		    dm_index=$(echo " ($DM - $DM_start) / $DM_step "| bc)
                width_index=$( echo "($width - $width_start) / $width_step " | bc)
		    #echo "$width_index=$width_index,dm_index=$dm_index"
       		sigma=$(awk '
                    # Skip lines starting with a comment character (#)
                    $1 ~ /^#/ { next }

                    # Print the Second column (Sigma values)
                    { print $2; exit }
                    ' "$filename")
                 if [ $? -ne 0 ]; then
                     echo "Error: Failed to extract Sigma values"
                     exit 1
                 fi
                 echo "Sigma = $sigma"
                 if [ -z "$sigma" ]; then
                      #echo "$dm_index,$width_index,$sigma"
                      matrix[$width_index,$dm_index]=0
                 else
                      #echo "$dm_index,$width_index,$sigma"
                      matrix[$width_index,$dm_index]=$sigma
		 fi
		 #echo "Values: $dm_index,$width_index, Value: ${matrix[$dm_index,$width_index]}"
                 boxcar=$(awk '
                    # Skip lines starting with a comment character (#)
                    $1 ~ /^#/ { next }

                    # Print the Second column (Sigma values)
                    { print $5; exit }
                    ' "$filename")
                echo "boxcar=$boxcar"
	        if [ -z "$boxcar" ]; then
                      #echo "$dm_index,$width_index,$sigma"
                      boxcar_matrix[$width_index,$dm_index]=0
                else
                      #echo "$dm_index,$width_index,$sigma"
                      boxcar_matrix[$width_index,$dm_index]=$boxcar
                fi
            done
	done
	dm_index=$(echo " ($DM_end - $DM_start) / $DM_step " | bc)
	width_index=$(echo " ($width_end - $width_start) / $width_step " | bc)
	for i in $(seq 0 1 $dm_index); do
		row=""
                row2=""
        	for j in $(seq 0 1 $width_index); do
			row+=" ${matrix[$j,$i]}" 
		        row2+=" ${boxcar_matrix[$j,$i]}"
                done
                echo "$row2" >> "boxcar.txt"
		echo "$row" >> "reported_snr.txt"
        done
     fi
     python ../graph.py injected_snr.txt reported_snr.txt $DM_start $DM_end $DM_step $width_start $width_end $width_step
     python ../boxcar.py boxcar.txt $DM_start $DM_end $DM_step $width_start $width_end $width_step
     if [ -f "heimdall.txt" ]; then
         python ../graph.py injected_snr.txt heimdall.txt $DM_start $DM_end $DM_step $width_start $width_end $width_step
     fi
else
	# Check if the correct number of arguments is provided
	if [ "$#" -ne 2 ]; then
    	echo "Error: Invalid number of arguments."
    	usage
	fi

        if [ -d "output_files" ]; then
           rm -r "output_files"
           echo "deleted output_files"
        fi
        mkdir output_files
        cd output_files
        touch temp1.txt
        touch ../temp2.txt

	DM=$1
	width=$2
	amp=50
        #echo "$width"
	# Run the Python script
	python ../simscript_thomas.py --dm_start $DM --dm $DM --step 100 --sig_start $width --sig_step 1 --sig $width -N 1 -A $amp -s 5000
	if [ $? -ne 0 ]; then
	    echo "Error: Failed to run simscript_thomas.py"
	    exit 1
	fi

	# Run the prepdata command
	prepdata -nobary -dm ${DM} -noclip -o test_single_dm${DM}_width${width} test_single_dm${DM}_width${width}.fil | grep "Writing"
	if [ $? -ne 0 ]; then
	    echo "Error: Failed to run prepdata"
	    exit 1
	fi
	# Run the single_pulse_search.py command
	single_pulse_search.py -b test_single_dm${DM}_width${width}.dat | grep "Found"

	if [ $? -ne 0 ]; then
	    echo "Error: Failed to run single_pulse_search.py"
	    exit 1
	fi


	filename="test_single_dm${DM}_width${width}.singlepulse"

	# Check if the file exists
	if [ ! -f "$filename" ]; then
	    echo "Error: File '$filename' not found."
	    exit 1
	fi

	#extract the DM values from the file
	reported=$(awk '
        # Skip lines starting with a comment character (#)
        $1 ~ /^#/ { next } 
        # Print the second column (sigma value) and exit
        { print $2; exit }
        ' "$filename")

	if [ $? -ne 0 ]; then
	    echo "Error: Failed to extract DM values"
	    exit 1
	fi
        #echo "reported=$reported"
        read -r injected < "temp1.txt"
        #echo "injected=$injected"
        SN_ratio=$( echo  "$reported/$injected" | bc -l)
        #echo "S/N_ratio = $reported/$injected = $SN_ratio"
        echo " $SN_ratio"  >> "../temp2.txt"
fi


