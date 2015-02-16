function test_suite=test_GetWord()
    % requires MOxUnit or Matlab xUnit
    % see https://github.com/nno/MOxUnit
    initTestSuite


function test_GetWord_basics()
    [err,w]=GetWord ('Hello Jim | Munch',2);
    assertEqual(err,0);
    assertEqual(w,'Jim');

    [err,w]=GetWord ('Hello Jim | Munch',2,'|');
    assertEqual(err,0);
    assertEqual(w,' Munch');

    [err,w]=GetWord ('Hello Jim | Munch',2,'| l');
    assertEqual(err,0);
    assertEqual(w,'o');


    expected_words={'a','b','c','ddd','e'};
    for k=1:numel(expected_words)
        for nspaces=[0 2]
            s=[ repmat(' ',1,nspaces) '  a  bl c| l ddd e'];
            [err,w]=GetWord (s,k,'| l');
            assertEqual(err,0);
            assertEqual(w,expected_words{k});
        end
    end


    [err,w]=GetWord ('Hello Jim | Munch',2,'x');
    assertEqual(err,1);
    assertEqual(w,'');
