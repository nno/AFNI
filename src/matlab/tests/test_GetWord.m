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


    [err,w]=GetWord ('  a  bl c| l d e',1,'| l');
    assertEqual(err,0);
    assertEqual(w,'a');

    [err,w]=GetWord ('  a  bl c| l d e',2,'| l');
    assertEqual(err,0);
    assertEqual(w,'b');

    [err,w]=GetWord ('  a  bl c| l d e',3,'| l');
    assertEqual(err,0);
    assertEqual(w,'c');

    [err,w]=GetWord ('  a  bl c| l d e',4,'| l');
    assertEqual(err,0);
    assertEqual(w,'d');

    [err,w]=GetWord ('  a  bl c| l d e',5,'| l');
    assertEqual(err,0);
    assertEqual(w,'e');


    [err,w]=GetWord ('Hello Jim | Munch',2,'x');
    assertEqual(err,1);
    assertEqual(w,'');
