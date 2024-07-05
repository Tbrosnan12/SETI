#!/bin/bash

usage() {
    echo "Usage: $0 <DM> <width>"
    echo "  <DM>    : Dispersion Measure"
    echo "  <width> : Pulse width"
    echo "or for a range of DM's and width's:"
    echo "Usage: $0 range <DM_start> <DM_end> <DM_step> <width_start> <width_end> <width_step>"	
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
        if [ "$#" -ne 7 ]; then
        	echo "Error: Invalid number of arguments."
        	usage
        fi

	mkdir output_files
	cd output_files
	declare -A matrix
	if [ $? -ne 0 ]; then
            echo "Error: This script will only run using 'bash $0' as sh shell does not have declare -A matrix for some reason "
            exit 1
        fi
        touch temp1.txt
	touch temp2.txt
	temp="temp2.txt"

	DM_start=$2
	DM_end=$3
	DM_step=$4
    width_start=$5
	width_end=$6
	width_step=$7
        amp=50

        # Create the pulses
	injected_sn= python ../simscript_thomas.py --dm_start ${DM_start} --dm ${DM_end} --step ${DM_step} --sig_start ${width_start} --sig_step ${width_step} --sig ${width_end} -N 1 -A $amp -s 5000
        if [ $? -ne 0 ]; then
            echo "Error: Failed to run simscript_thomas.py"
            exit 1
        fi
	for width1 in $(seq $width_start $width_step $width_end); do
	   for DM1 in $(seq $DM_start $DM_step $DM_end); do
		width=$(python ../custom_round.py $width1 1)
		DM=$(python ../custom_round.py $DM1 0)
        	# Run the prepdata command
		echo "$width,$width_start,$width_step" 
        	prepdata -nobary -dm ${DM} -o test_single_dm${DM}_width${width} test_single_dm${DM}_width${width}.fil | grep "Writing"
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
       		result=$(awk '
                    # Skip lines starting with a comment character (#)
                    $1 ~ /^#/ { next }

                    # Print the Second column (Sigma values)
                    { print $2; exit }
                ' "$filename")
                if [ $? -ne 0 ]; then
                    echo "Error: Failed to extract Sigma values"
                    exit 1
                fi
		echo "Sigma = $result"
		if [ -z "$result" ]; then
			#echo "$dm_index,$width_index,$result"
			matrix[$width_index,$dm_index]=0
		else
			#echo "$dm_index,$width_index,$result"
			matrix[$width_index,$dm_index]=$result
		fi
		#echo "Values: $dm_index,$width_index, Value: ${matrix[$dm_index,$width_index]}"
	   done
	done
	dm_index=$(echo " ($DM_end - $DM_start) / $DM_step " | bc)
	width_index=$(echo " ($width_end - $width_start) / $width_step " | bc)
	for i in $(seq 0 1 $dm_index); do
		row=""
        	for j in $(seq 0 1 $width_index); do
			row+=" ${matrix[$j,$i]}" 
		done
		echo "$row" >> "$temp"
	done
	python ../graph.py temp1.txt temp2.txt $DM_start $DM_end $DM_step $width_start $width_end $width_step
else
	# Check if the correct number of arguments is provided
	if [ "$#" -ne 2 ]; then
    		echo "Error: Invalid number of arguments."
    		usage
	fi

	DM=$1
	width=$2
	amp=50

	# Run the Python script
	python simscript_thomas.py --dm_start $DM --dm $DM --step 100 --sig_start $width --sig_step 1 --sig $width -N 1 -A $amp -s 5000
	if [ $? -ne 0 ]; then
	    echo "Error: Failed to run simscript_thomas.py"
	    exit 1
	fi

	# Run the prepdata command
	prepdata -nobary -dm ${DM} -o test_single_dm${DM}_width${width} test_single_dm${DM}_width${width}.fil | grep "Writing"
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
	awk '
	    # Skip lines starting with a comment character (#)
	    $1 ~ /^#/ { next }

	    # Print the first column (DM values)
	    { print "DM value of pulse = " $1 }
	    { print "Sigma value of pulse = " $2 }
	' "$filename"
	if [ $? -ne 0 ]; then
	    echo "Error: Failed to extract DM values"
	    exit 1
	fi

fi


