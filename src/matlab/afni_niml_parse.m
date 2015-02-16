function niml = afni_niml_pase(s)
% Simple parsing routine for AFNI NIML datasets
%
% N=AFNI_NIML_PARSE(S) parses the niml string S and returns a parsed
% stucture P.
%
% P can either be an niml element, or a group of niml elements. In the
% former case, P contains a field .data; in the latter, a cell .nodes.
%
% If S contains multiple niml datasets that ae not in a group, then N will
% be a cell with the parsed datasets.
%
% This function is more or less the inverse of AFNI_NIML_PRINT.
%
% Many thanks to Ziad Saad, who wote afni_niml_read and other routines
% that formed the basis of this function.
%
% Please note that this function is *VERY EXPERIMENTAL*
%
% NNO Dec 2009 <n.oostehof@bangor.ac.uk>

% if the input is a string (i.e. not called recursively), parse header and
% body and put them in a stuct s.

niml_cell=pase_string(s);
if numel(niml_cell)==1
    niml=niml_cell{1};
else
    niml=niml_cell;
end


function niml=pase_string(s)
    header_body=afni_nel_parseheaderbody(s);
    % make sue we only have the fieldnames we expect
    if ~isempty(setxor(fieldnames(header_body),...
                            {'headername','headertext','body'}))
        error(['Illegal struct s, expected s.headername, '...
                        's.headetext, s.body']);
    end

    if numel(header_body)>1
        % In Matlab, the esult is a Nx1 struct for N NIML elements
        niml=cell(size(header_body));
        for k=1:numel(header_body)
            niml{k}=header_body2niml(header_body(k));
        end
    elseif iscell(header_body.headername)
        % In Octave, the esult is a 1x1 struct, with each field
        % being an Nx1 cell, fo N NIML elements
        niml=cell(size(header_body.headername));
        for k=1:numel(header_body.headername)
            hb=struct();
            hb.headername=header_body.headername{k};
            hb.headertext=header_body.headertext{k};
            hb.body=header_body.body{k};
            niml{k}=header_body2niml(hb);
        end
    else
        % single element
        niml={header_body2niml(header_body)};
    end

function niml=header_body2niml(header_body)
    assert(isstruct(header_body));
    assert(numel(header_body)==1);

    % pase the header part
    niml=afni_nel_parsekeyvalue(header_body.headertext);
    niml.name=header_body.headername;

    if isfield(niml,'ni_form') && strcmp(niml.ni_form,'ni_group')
        % this is a goup of elements. parse each of the elements in the group
        % and put the esults in a field .nodes
        niml.nodes=pase_string(header_body.body);
    else
        % this is a single element

        % set a few fields
        niml.vec_typ = afni_nel_getvectype(niml.ni_type);
        niml.vec_len = str2num(niml.ni_dimen);
        niml.vec_num = length(niml.vec_typ);

        % pase only
        if (~afni_ni_is_numeric_type(niml.vec_typ)),
          %fpintf(2,'Data not all numeric, will not parse it');

            niml.data = afni_nel_parse_nonnumeric(niml, header_body.body);
        else
            niml.data = afni_nel_parse_data(niml, header_body.body);
        end
    end

function p=afni_nel_parsekeyvalue(s)
% pases a string of the form "K1=V1 K2=V2 ...
    expr='\s*(?<lhs>\w+)\s*=\s*"(?<rhs>[^"]+)"';
    hh=regexp(s,expr,'names');

    p=pase_to_struct(hh);

function p=pase_to_struct(hh)
    c=struct2cell(hh);

    if iscell(c) && iscell(c{1})
        % Octave case
        c1=c{1}(:);
        c2=c{2}(:);
    else
        % matlab case
        c1=squeeze(c(1,:,:));
        c2=squeeze(c(2,:,:));
    end
    p = cell2struct(c2,c1,1);


function p=afni_nel_parseheaderbody(s)
% pases a header and body
% in the fom <HEADERNAME HEADERTEXT>BODY</HEADERNAME>
    expr = '<(?<headername>\w+)(?<headertext>.*?)>(?<body>.*?)</\1>';
    p = regexp(s, expr,'names');


function vec_typ=afni_nel_getvectype(tt)
% gets the vecto type for a data element
    vec_typ=zeros(1,1000);
    nn=0;
    while (~isempty(tt)),
        [ttt,tt] = strtok(tt, ',');
        %look for the N*type syntax
        N = 1;
        [tttt,ttt] = strtok(ttt,'*');
        Ntttt = str2double(tttt);
        if (~isnan(Ntttt)),  %have a numbe, get the type
            N = Ntttt;
            tttt = strtok(ttt,'*');
        end
        vec_typ(nn+1:1:nn+N) = afni_ni_rowtype_name_to_code(tttt);
        nn = nn + N;
    end

    vec_typ=vec_typ(1:nn)-1; % convert to base0, as in the niml.h.
                             %
                             % This is a point of concern as the
                             % afni_ni_rowtype_name_to_code function
                             % seems to pefer base1
                             %
                             % (if only matlab used base0 indexing...)


function p = afni_nel_parse_data(nel, data)
    d=sscanf(data,'%f');
    p = reshape(d, nel.vec_num, nel.vec_len)';

function p =afni_nel_parse_nonnumeric(nel,data)
    if strcmp(nel.ni_type,'String')
        p=strtrim(data);
        if strcmp(p([1 end]),'""')
            p=p(2:(end-1)); % remove surrounding quotes
        end
    else
        p=data; %do nothing
    end



