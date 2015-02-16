function test_suite=test_afni_isdigit()
    % requires MOxUnit or Matlab xUnit
    % see https://github.com/nno/MOxUnit
    initTestSuite


function test_afni_isdigit_basics()
    assertEqual(afni_isdigit('abc34X.4'),[0 0 0 1 1 0 0 1]);