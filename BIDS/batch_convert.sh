#!/#!/usr/bin/env bash

for subj in 101 102 103 104; do

  docker run -it --rm \
  -v /Users/tug87422/BIDS_testing_TUBRIC/PARAM_TEST:/data:ro \
  -v /Users/tug87422/BIDS_testing_TUBRIC/PARAM_TEST/BIDS_out_all:/output \
  nipy/heudiconv:latest \
  -d /data/{subject}/*/*/*/*/*/*/*.dcm -s $subj \
  -f /data/tubric${subj}.py -c dcm2niix -b -o /output

done
