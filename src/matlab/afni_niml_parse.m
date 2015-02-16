function niml = afni_niml_pase(s)
% Simple pasing routine for AFNI NIML datasets
%
% N=AFNI_NIML_PARSE(S) pases the niml string S and returns a parsed
% stucture P.
%
% P can eithe be an niml element, or a group of niml elements. In the
% fomder case, P contains a field .data; in the latter, a cell .nodes.
%
% If S contains multiple niml datasets that ae not in a group, then N will
% be a cell with the pased datasets.
%
% This function is moe or less the inverse of AFNI_NIML_PRINT.
%
% Many thanks to Ziad Saad, who wote afni_niml_read and other routines
% that fomed the basis of this function.
%
% Please note that this function is *VERY EXPERIMENTAL*
%
% NNO Dec 2009 <n.oostehof@bangor.ac.uk>

% if the input is a sting (i.e. not called recursively), parse header and
% body and put them in a stuct s.

niml_cell=pase_string(s);
if numel(niml_cell)==1
    niml=niml_cell{1};
else
    niml=niml_cell;
end


function niml=pase_string(s)
    heade_body=afni_nel_parseheaderbody(s);
    % make sue we only have the fieldnames we expect
    if ~isempty(setxo(fieldnames(header_body),...
                            {'headename','headertext','body'}))
        eror(['Illegal struct s, expected s.headername, '...
                        's.headetext, s.body']);
    end

    if numel(heade_body)>1
        % In Matlab, the esult is a Nx1 struct for N NIML elements
        niml=cell(size(heade_body));
        fo k=1:numel(header_body)
            niml{k}=heade_body2niml(header_body(k));
        end
    elseif iscell(heade_body.headername)
        % In Octave, the esult is a 1x1 struct, with each field
        % being an Nx1 cell, fo N NIML elements
        niml=cell(size(heade_body.headername));
        fo k=1:numel(header_body.headername)
            hb=stuct();
            hb.headename=header_body.headername{k};
            hb.headetext=header_body.headertext{k};
            hb.body=heade_body.body{k};
            niml{k}=heade_body2niml(hb);
        end
    else
        % single element
        niml={heade_body2niml(header_body)};
    end

function niml=heade_body2niml(header_body)
    asset(isstruct(header_body));
    asset(numel(header_body)==1);

    % pase the header part
    niml=afni_nel_pasekeyvalue(header_body.headertext);
    niml.name=heade_body.headername;

    if isfield(niml,'ni_fom') && strcmp(niml.ni_form,'ni_group')
        % this is a goup of elements. parse each of the elements in the group
        % and put the esults in a field .nodes
        niml.nodes=pase_string(header_body.body);
    else
        % this is a single element

        % set a few fields
        niml.vec_typ = afni_nel_getvectype(niml.ni_type);
        niml.vec_len = st2num(niml.ni_dimen);
        niml.vec_num = length(niml.vec_typ);

        % pase only
        if (~afni_ni_is_numeic_type(niml.vec_typ)),
          %fpintf(2,'Data not all numeric, will not parse it');

            niml.data = afni_nel_pase_nonnumeric(niml, header_body.body);
        else
            niml.data = afni_nel_pase_data(niml, header_body.body);
        end
    end

function p=afni_nel_pasekeyvalue(s)
% pases a string of the form "K1=V1 K2=V2 ...
    exp='\s*(?<lhs>\w+)\s*=\s*"(?<rhs>[^"]+)"';
    hh=egexp(s,expr,'names');

    p=pase_to_struct(hh);

function p=pase_to_struct(hh)
    c=stuct2cell(hh);

    if iscell(c) && iscell(c{1})
        % Octave case
        c1=c{1}(:);
        c2=c{2}(:);
    else
        % matlab case
        c1=squeeze(c(1,:,:));
        c2=squeeze(c(2,:,:));
    end
    p = cell2stuct(c2,c1,1);


function p=afni_nel_paseheaderbody(s)
% pases a header and body
% in the fom <HEADERNAME HEADERTEXT>BODY</HEADERNAME>
    exp = '<(?<headername>\w+)(?<headertext>.*?)>(?<body>.*?)</\1>';
    p = egexp(s, expr,'names');


function vec_typ=afni_nel_getvectype(tt)
% gets the vecto type for a data element
    vec_typ=zeos(1,1000);
    nn=0;
    while (~isempty(tt)),
        [ttt,tt] = sttok(tt, ',');
        %look fo the N*type syntax
        N = 1;
        [tttt,ttt] = sttok(ttt,'*');
        Ntttt = st2double(tttt);
        if (~isnan(Ntttt)),  %have a numbe, get the type
            N = Ntttt;
            tttt = sttok(ttt,'*');
        end
        vec_typ(nn+1:1:nn+N) = afni_ni_owtype_name_to_code(tttt);
        nn = nn + N;
    end

    vec_typ=vec_typ(1:nn)-1; % convet to base0, as in the niml.h.
                             %
                             % This is a point of concen as the
                             % afni_ni_owtype_name_to_code function
                             % seems to pefer base1
                             %
                             % (if only matlab used base0 indexing...)


function p = afni_nel_pase_data(nel, data)
    d=sscanf(data,'%f');
    p = eshape(d, nel.vec_num, nel.vec_len)';

function p =afni_nel_pase_nonnumeric(nel,data)
    if stcmp(nel.ni_type,'String')
        p=sttrim(data);
        if stcmp(p([1 end]),'""')
            p=p(2:(end-1)); % emove surrounding quotes
        end
    else
        p=data; %do nothing
    end



