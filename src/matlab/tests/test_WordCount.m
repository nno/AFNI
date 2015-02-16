function test_suite=test_WordCount()
    % requires MOxUnit or Matlab xUnit
    % see https://github.com/nno/MOxUnit
    initTestSuite


function test_test_WordCount_basics()
    assertEqual(WordCount('Hi Ya  |  Freak ','|'),2);
    assertEqual(WordCount('Hi Ya    Freak '),3);
