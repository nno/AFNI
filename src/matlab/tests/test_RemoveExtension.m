function test_suite=test_RemoveExtension()
    % requires MOxUnit or Matlab xUnit
    % see https://github.com/nno/MOxUnit
    initTestSuite


function test_RemoveExtension_basics()
    %assert_output=@(output,varargin) assertEqual(output,...
     %                               RemoveExtension(varargin{:}));
    % test without arguments
    assert_output('foo','','foo');
    assert_output('fo','.o .b','fo.o .b');
    assert_output('foo','.1D.1D','foo.1D.1D');
    assert_output('fo','.o.1D.1D','fo.o.1D.1D');
    
    % simple arguments
    assert_output('foo','','foo',[]);
    assert_output('foo','','foo','.1D');
    assert_output('foo','.1D','foo.1D','.1D');
    
    % repeat of extension
    assert_output('foo.1D.1D','.1D','foo.1D.1D.1D','.1D');
    assert_output('foo','.1D','foo.1D.1D','.1D|.1D');
    
    % multiple dots
    assert_output('foo.1D','.1D.niml','foo.1D.1D.niml','.1D.niml');
    
    % test order of different delimeter strings
    assert_output('foo.1D.niml','','foo.1D.niml','.1D|.1D');
    assert_output('foo.1D','.niml','foo.1D.niml','.1D|.niml');
    assert_output('foo','.1D','foo.1D.niml','.niml|.1D');
    
    % no conflict with regular expressions
    assert_output('foo.1D','.niml','foo.1D.niml','.niml|.1D^');
    assert_output('foo.1D','.niml','foo.1D.niml','.niml|.1D$');
    assert_output('foo.','','foo.','.niml');
    
    % trailing spaces in input should not be ignored
    assert_output('foo.1D.niml ','','foo.1D.niml ','.niml');
    
    % spaces in separator should be trimmed if at beginning or end
    assert_output('foo','.1D','foo.1D',...
                                    sprintf(' .1D \t '));
    assert_output('foo.1D','.niml','foo.1D.niml',...
                                    sprintf(' .1D \t |\t .niml  '));
    assert_output('foo','.1D','foo.1D.niml',...
                                    sprintf(' .niml \t |\t .1D  '));
    
    assert_output('foo','.1D  E','foo.1D  E',' .1D  E ');
    assert_output('foo','.1D  E','foo.1D  E',' .1D  E | ba r | ba z ');
    assert_output('foo.','ba  r','foo.ba  r',' .1D  E | ba  r | ba  z ');
    assert_output('foo.','ba  r','foo.ba  rb  z',' b  z | a b | ba  r ');
                                
    % deal with empty input
    assert_output([],'',[],[]);
    
function assert_output(a,b,varargin)
    % first two arguments contain what RemoveExtension should return;
    % remaining arguments are input for RemoveExtension
    [a_returned,b_returned]=RemoveExtension(varargin{:});
    assertEqual(a,a_returned);
    assertEqual(b,b_returned);