import os

def create_key(template, outtype=('nii.gz',), annotation_classes=None):
    if template is None or not template:
        raise ValueError('Template must be a valid format string')

    return template, outtype, annotation_classes

#0005: fmap/sub-<label>[_ses-<session_label>][_acq-<label>][_run-<run_index>]_magnitude1.nii[.gz]
#0006: fmap/sub-<label>[_ses-<session_label>][_acq-<label>][_run-<run_index>]_phasediff.nii[.gz]

def infotodict(seqinfo):

    t1w = create_key('sub-{subject}/anat/sub-{subject}_T1w')
    t2w = create_key('sub-{subject}/anat/sub-{subject}_T2w')
    mag = create_key('sub-{subject}/fmap/sub-{subject}_magnitude')
    phase = create_key('sub-{subject}/fmap/sub-{subject}_phasediff')
    tapping = create_key('sub-{subject}/func/sub-{subject}_task-tapping_run-{item:02d}_bold')
    reward = create_key('sub-{subject}/func/sub-{subject}_task-reward_run-{item:02d}_bold')
    rest = create_key('sub-{subject}/func/sub-{subject}_task-rest_run-{item:02d}_bold')

    info = {t1w: [], t2w: [], tapping: [], reward: [], mag: [], phase: [], rest: []}

    for s in seqinfo:
        if (s.dim3 == 72) and (s.dim4 == 1) and ('gre_field' in s.protocol_name):
            info[mag] = [s.series_id]
        if (s.dim3 == 36) and (s.dim4 == 1) and ('gre_field' in s.protocol_name):
            info[phase] = [s.series_id]
        if (s.dim3 == 256) and (s.dim4 == 1) and ('t1' in s.protocol_name):
            info[t1w] = [s.series_id]
        if (s.dim3 == 256) and (s.dim4 == 1) and ('t2' in s.protocol_name):
            info[t2w] = [s.series_id]


        #functionals. Not sure why the first FT is long
        if (135 < s.dim4 < 235) and ('ep2d_FT' in s.protocol_name):
            info[tapping].append({'item': s.series_id})
        if ((s.dim4 == 280) or (s.dim4 == 468)) and ('ep2d_RT' in s.protocol_name):
            info[reward].append({'item': s.series_id})

        #resting param tests. Check against notes from Liz
        if (s.dim4 == 75) and ('ep2d' in s.protocol_name):
            info[rest].append({'item': s.series_id})



    return info
