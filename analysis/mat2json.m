function mat2json( filename, x )
%MAT2JSON Writes a json file containing matlab data serialized in the json
% format
%   filename is the json filename
%   x is a matlab object to be serialized

fid=fopen(filename,'w+');
if fid>0
    obj2json(fid,x)
    fclose(fid);
else
    error('cannot create %s',filename);
end

end


function obj2json(fid,x)
    if iscell(x)
        cell2json(fid,x);
    elseif ischar(x)
        str2json(fid,x);
    else
        if numel(x)==0
            null2json(fid,x);
        elseif numel(x)>1
            array2json(fid,x);
        else
            % scalar objects
            if isstruct(x)
                struct2json(fid,x);
            elseif isobject(x)
                class2json(fid,x);
            elseif isa(x,'function_handle')
                nan2json(fid,x);
            elseif isnan(x)
                nan2json(fid,x);
            elseif isnumeric(x) && ~isreal(x)
                complex2json(fid,x)
            elseif isnumeric(x) && isinf(x)
                inf2json(fid,x);
            elseif isnumeric(x)
                num2json(fid,x);
            elseif islogical(x)
                logical2json(fid,x);
            else
                warning('unsupported type');
                null2json(fid,x);
            end            
        end
    end        
end

function null2json(fid,x)
    fprintf(fid,'null');
end

function nan2json(fid,x)
    fprintf(fid,'"NaN"');
end

function inf2json(fid,x)
    if x>0
        fprintf(fid,'"+Infinity"');
    else
        fprintf(fid,'"-Infinity"');
    end
end

function logical2json(fid,x)
    if x
        fprintf(fid,'true');
    else
        fprintf(fid,'false');
    end
end

% length of first non-singleton dim
function y=array_len(x)    
    sz=size(x);
    y=sz(1);
    if(y==1)
        y=sz(2);
    end
end

% select item at index along for first nonsingleton dim
function y=array_elem(x,idx)
    sz=size(x);
    if(sz(1)==1)
        y=x(1,idx);
    else
        y=x(idx,:);
    end
end

function array2json(fid,x)
    x=squeeze(x);    
    fprintf(fid,'[');
    for i=1:array_len(x) 
        if i~=1 
            fprintf(fid,',\n');
        end            
        obj2json(fid,array_elem(x,i));
    end
    fprintf(fid,']');    
end

function cell2json(fid,x)
    x=squeeze(x);    
    fprintf(fid,'[');
    for i=1:numel(x) 
        if i~=1 
            fprintf(fid,',\n');
        end            
        obj2json(fid,x{i});
    end
    fprintf(fid,']');    
end


function struct2json(fid,x)
    fields=fieldnames(x);
    fprintf(fid,'{');
    for i=1:numel(fields)
        if i~=1 
            fprintf(fid,',\n');
        end            
        fprintf(fid,'"%s":',fields{i});
        obj2json(fid,x.(fields{i}));
    end
    fprintf(fid,'}');
end

function class2json(fid,x)
    props=properties(x);
    y=struct();
    for i=1:numel(props)
        y.(props{i})=x.(props{i});
    end
    y.klass=class(x);
    struct2json(fid,y);
end

function str2json(fid,x)
    x=strrep(x,'\','\\');
    x=strrep(x,'"','\"');
    x=strrep(x,sprintf('\n'),'\n');
    x=strrep(x,sprintf('\t'),'\t');
    x=strrep(x,sprintf('\r'),'\r');
    fprintf(fid,'"%s"',x);    
%     strverify(x);
    
end

function strverify(x)
    i=1;
    while i<=length(x)    
        if x(i)=='\'
            if ~(x(i)=='\' || x(i)=='t' || x(i)=='r' || x(i)=='n')
                strverifyerror(x,i,'bad escape');
            end            
            i=i+1;       
        elseif x(i)=='"'
            strverifyerror(x,i,'bad quote');
        elseif x(i)<32
            strverifyerror(x,i,'bad control char');
    %     else 
    %         valid
        end
        i=i+1;
    end
end

function strverifyerror(x,i,str)
    start=max(i-5,1);
    stop=min(i+5,length(x));
    error('error %s at position %d: %s',str, i, x(start:stop));
end

function complex2json(fid,x)
    fprintf(fid,'{"real":%s,"imag":%s}',mat2str(real(x)),mat2str(imag(x)));
end

function num2json(fid,x)
    fprintf(fid,'%s',mat2str(x));
end
