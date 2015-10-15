function test_suite=test_afni_niml_io
    % requires MOxUnit or Matlab xUnit
    % see https://github.com/nno/MOxUnit
    %
    % test I/O for AFNI NIML data
    initTestSuite

function test_afni_niml_io_basics()
    nverts=100;

    s=struct();
    s.labels={'Hello','World'};
    s.stats={'Zscore()','none'};
    s.data=[randn(nverts,1) rand(nverts,1)];
    s.node_indices=randperm(nverts)';

    % write with all info
    s_copy=write_and_read(s,@afni_niml_readsimple);
    keys=fieldnames(s);
    assert(isempty(setdiff(keys,fieldnames(s_copy))));

    for k=1:numel(keys)
        key=keys{k};
        switch key
            case 'data'
                compare=@(x,y)assertElementsAlmostEqual(x,y,...
                                                'absolute',1e-4);
            otherwise
                compare=@(x,y)assertEqual(x,y);
        end
        compare(s.(key),s_copy.(key));
    end

    s_copy=write_and_read(s.data,@afni_niml_readsimple);

    assertElementsAlmostEqual(s.data,s_copy.data,'absolute',1e-4);

    p=write_and_read(s,@afni_niml_read);
    assert(numel(p)==1);
    p=p{1};
    assertEqual(p.name,'AFNI_dataset');
    assertEqual(p.ni_form,'ni_group');
    assert(numel(p.nodes)==7);
    assertIsNode(p.nodes{1},...
                    'Node_Bucket_data',[],...
                    '2*float',num2str(nverts),'SPARSE_DATA',...
                    [3 3],nverts,2,s.data);
    assertIsNode(p.nodes{2},...
                    'Node_Bucket_node_indices',[],...
                    'int',num2str(nverts),'INDEX_LIST',...
                    2,nverts,1,s.node_indices);
    assertIsNode(p.nodes{3},...
                    [],'COLMS_RANGE',...
                    'String','1','AFNI_atr',...
                    8,1,1,[]);
    assertIsNode(p.nodes{4},...
                    [],'COLMS_LABS',...
                    'String','1','AFNI_atr',...
                    8,1,1,{{'Hello;World'}});
    assertIsNode(p.nodes{5},...
                    [],'COLMS_TYPE',...
                    'String','1','AFNI_atr',...
                    8,1,1,{{'Generic_Float;Generic_Float'}});
    assertIsNode(p.nodes{6},...
                    [],'COLMS_STATSYM',...
                    'String','1','AFNI_atr',...
                    8,1,1,{{'Zscore();none'}});
    assertIsNode(p.nodes{7},...
                    [],'HISTORY_NOTE',...
                    'String','1','AFNI_atr',...
                    8,1,1,[]);
    pp=afni_niml_parse(afni_niml_print(p));
    assertEqual({p},pp);

    % just write the data
    %afni_niml_writesimple(s.data,[myrootfn '_2.niml.dset']);

function assertIsNode(v,data_type,atr_name,ni_type,ni_dimen,name,...
                    vec_typ,vec_len,vec_num,data)
    if ~isempty(data_type)
        assertEqual(data_type,v.data_type);
    end
    if ~isempty(atr_name)
        assertEqual(atr_name,v.atr_name);
    end
    assertEqual(ni_type,v.ni_type);
    assertEqual(ni_dimen,v.ni_dimen);
    assertEqual(name,v.name);
    assertEqual(vec_typ,v.vec_typ);
    assertEqual(vec_len,v.vec_len);
    assertEqual(vec_num,v.vec_num);

    if ~isempty(data)
        if isnumeric(data)
            assertElementsAlmostEqual(data,v.data,'absolute',1e-4);
        else
            assertEqual(data,v.data);
        end
    end

function result=write_and_read(data,reader)
    % get temporary file
    tmpfn=get_temporary_file();

    % ensure temporay file is deleted afterwards
    cleaner=onCleanup(@()delete(tmpfn));

    afni_niml_writesimple(data,tmpfn);
    result=reader(tmpfn);

function tmpfn=get_temporary_file()
    pos=0;
    while true
        tmpfn=sprintf('niml_io_test_%d.niml.dset',pos);
        if ~exist(tmpfn,'file')
            break
        end
        pos=pos+1;
    end



