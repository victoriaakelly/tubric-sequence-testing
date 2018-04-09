import os

def create_key(template, outtype=('nii.gz',), annotation_classes=None):
    if template is None or not template:
        raise ValueError('Template must be a valid format string')

    return template, outtype, annotation_classes

#0005: fmap/sub-<label>[_ses-<session_label>][_acq-<label>][_run-<run_index>]_magnitude1.nii[.gz]
#0006: fmap/sub-<label>[_ses-<session_label>][_acq-<label>][_run-<run_index>]_phasediff.nii[.gz]

def infotodict(seqinfo):
    t1w_64 = create_key('sub-{subject}/anat/sub-{subject}_acq-64ch_T1w')
    t1w_20 = create_key('sub-{subject}/anat/sub-{subject}_acq-20ch_T1w')
    t2w_20 = create_key('sub-{subject}/anat/sub-{subject}_acq-20ch_T2w')

    mag_64 = create_key('sub-{subject}/fmap/sub-{subject}_acq-64ch_magnitude')
    phase_64 = create_key('sub-{subject}/fmap/sub-{subject}_acq-64ch_phasediff')
    mag_20 = create_key('sub-{subject}/fmap/sub-{subject}_acq-20ch_magnitude')
    phase_20 = create_key('sub-{subject}/fmap/sub-{subject}_acq-20ch_phasediff')

    tapping = create_key('sub-{subject}/func/sub-{subject}_task-tapping_run-{item:02d}_bold')
    reward = create_key('sub-{subject}/func/sub-{subject}_task-reward_run-{item:02d}_bold')

    info = {t1w_64: [], t1w_20: [], t2w_20: [], tapping: [], reward: [], mag_64: [], phase_64: [], mag_20: [], phase_20: []}

    for s in seqinfo:

        #structurals and fieldmaps for the 20-channel coil. using [acq-<label>] designation
        if (s.dim3 == 72) and (s.dim4 == 1) and ('20ch_gre_field' in s.protocol_name):
            info[mag_20] = [s.series_id]
        if (s.dim3 == 36) and (s.dim4 == 1) and ('20ch_gre_field' in s.protocol_name):
            info[phase_20] = [s.series_id]
        if (s.dim3 == 256) and (s.dim4 == 1) and ('20ch_t1' in s.protocol_name):
            info[t1w_20] = [s.series_id]
        if (s.dim3 == 192) and (s.dim4 == 1) and ('20ch_t2' in s.protocol_name):
            info[t2w_20] = [s.series_id]

        #structurals and fieldmaps for the 64-channel coil. using [acq-<label>] designation
        if (s.dim3 == 72) and (s.dim4 == 1) and ('64ch_gre_field' in s.protocol_name):
            info[mag_64] = [s.series_id]
        if (s.dim3 == 36) and (s.dim4 == 1) and ('64ch_gre_field' in s.protocol_name):
            info[phase_64] = [s.series_id]
        if (s.dim3 == 256) and (s.dim4 == 1) and ('64ch_t1' in s.protocol_name):
            info[t1w_64] = [s.series_id]

        #functionals for both acqs. three runs of FT and four runs of reward (only the first acq had both reward runs)
        #skipping the run with 63 time points. I assume that isn't valid
        if (135 < s.dim4 < 145) and ('ep2d_bold' in s.protocol_name):
            info[tapping].append({'item': s.series_id})
        if (180 < s.dim4 < 195) and ('ep2d_bold' in s.protocol_name):
            info[reward].append({'item': s.series_id})


    return info
