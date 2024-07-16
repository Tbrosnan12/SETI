#!/bin/bash
Docker_id=$1

docker cp /home/tbrosnan/Presto_test/ $1:/home/tbrosnan/
#docker cp /home/tbrosnan/create_pulse_image.py $1:/home/tbrosnan/
#docker cp /home/tbrosnan/spectra.py $1:/home/tbrosnan/
docker cp /home/tbrosnan/setsims $1:/home/tbrosnan/
docker cp /home/tbrosnan/sims $1:/home/tbrosnan/
#docker cp /home/tbrosnan/Disp.py $1:/home/tbrosnan/
docker cp /home/tbrosnan/invert.py $1:/home/tbrosnan/
#docker cp /home/tbrosnan/B0329+54.rawspec.0001.fil  $1:/home/tbrosnan/ 


