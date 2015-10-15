function test_suite=test_zdeblank()
    % requires MOxUnit or Matlab xUnit
    % see https://github.com/nno/MOxUnit
    initTestSuite


function test_zdeblank_basics()
    aeq=@(output,input)assertEqual(output,zdeblank(input));
    
    aeq('foo','foo');
    aeq('','');
    

    % get the space characters
    t=sprintf('\t');
    n=sprintf('\n');
    z=char(0);
    f=sprintf('\f');
    r=sprintf('\r');
    s=' ';
    
    space_chars=[t n z f r s];
    aeq('',space_chars);

    n_space=numel(space_chars);
    infix=['a b ' space_chars ' c d'];
    
    for k=1:10
        % pick random characters from space characters
        prefix_len=ceil(rand()*n_space);
        postfix_len=ceil(rand()*n_space);
        
        rp_prefix=randperm(n_space);
        rp_postfix=randperm(n_space);
        
        prefix=space_chars(rp_prefix(prefix_len));
        postfix=space_chars(rp_postfix(postfix_len));
        
        aeq(infix,[prefix infix postfix]);
    end