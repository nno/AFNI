function test_suite=test_CheckBrikHead
    % requires MOxUnit or Matlab xUnit
    % see https://github.com/nno/MOxUnit
    %
    % test I/O for AFNI NIML data
    initTestSuite

function test_CheckBrikHead_missing_fields()
    nsamples=4;
    afni_info=struct();
    afni_info.SCENE_DATA=[0,11,0];
    afni_info.TYPESTRING='3DIM_HEAD_ANAT';
    afni_info.DATASET_RANK=[3 nsamples];
    afni_info.DATASET_DIMENSIONS=[40 30 20];
    afni_info.ORIENT_SPECIFIC=[1 2 5];
    afni_info.DELTA=[3 3 3];
    afni_info.ORIGIN=[-10 -10 -20];

    % should pass
    pass_code=0;
    assertEqual(CheckBrikHEAD(afni_info),pass_code);

    % save warning state
    warning_state=warning();
    warning_resetter=onCleanup(@()warning(warning_state));
    warning('off')

    % removing any field throws an error
    fns=fieldnames(afni_info);
    error_code=1;
    for k=1:numel(fns)
        afni_info_missing_field=rmfield(afni_info,fns{k});
        assertEqual(CheckBrikHEAD(afni_info_missing_field,false),...
                            error_code);
    end




