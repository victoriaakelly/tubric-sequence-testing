# Imaging processing code for TUBRIC tests
This repo contains the code I used to to convert the data to BIDS format and run relevant BIDS apps (MRIQC and FMRIPREP).

I converted the DICOMS to BIDS format with [heudiconv][1]. The batch_convert.sh script shows the syntax I used. Note that I renamed to the scanner folders to have subject numbers instead of names. For real data collection, we'll have a specific naming scheme like the one suggested by [Dartmouth][2].

The heuristics folder contains the subject-specific heuristic files. These were made based on the notes from Victoria/Liz and also the information in the dicominfo_examples folder. Note that I ran heudiconv twice. The first corresponded to their "dry pass" step just so I could get the dicominfo.tsv files and revise the heuristic.py files accordingly. Just remember to delete old output before attempting to re-run heudiconv with new settings.

I ran [MRIQC][3] and [FMRIPREP][4] using the code found in mriqc_example.sh and fmriprep_example.sh, respectively. For FMRIPREP, I opted to turn off slice-timing correction and turn on ICA-AROMA.


[1]: https://github.com/nipy/heudiconv
[2]: https://docs.google.com/document/d/1EivqiAnbTGPRjav3eOsmqbOMJR5phdLrto5gFNBFpdE/edit
[3]: https://mriqc.readthedocs.io/en/latest/about.html
[4]: http://fmriprep.readthedocs.io/en/latest/index.html
