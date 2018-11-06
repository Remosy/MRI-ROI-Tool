function create_pTXRFPulse3( afGradient, afRFPulse, dopt)
%% ------------- CONFIGURATION ----------------
VERSION = 'v2.0, 12-02-12';         % version info
FCTNAME = 'create_pTXRFPulse.m'; 

% TYPE: string(1) float(2) integer(3)
% REQUIRED: required(1) optional(0)
%
options = struct('name',{},'type',{},'req',{});
%      GROUP   NAME         TYPE,REQUIRED
addParam(1,'NUsedChannels'   ,3,1);     % [1]
addParam(1,'MaxAbsRF'        ,2,1);     % [V] or [V*ms]
addParam(1,'Samples'         ,3,1);     % [1]
addParam(1,'PulseName'       ,1,1);     %           set by user
addParam(1,'Comment'         ,1,1);     %           set by user
% for SBBCompPulses
addParam(2,'SampleTime'      ,2,1);     % [us]      set by user
addParam(2,'NominalFlipAngle',2,1);     % [°]       set by user
% for SBBExcitationPtx
addParam(3,'Oversampling'    ,3,0);     % [1]
addParam(3,'NominalFlipAngle',2,1);     % [°]       set by user

switch dopt.type
    case 'SBBCompPulses'
        groups = [1 2];
    case 'SBBExcitationPtx'
        groups = [1 3];
    case 'RFShim'
        groups = 1;
    otherwise
        error('No pulse type specified');
end

%% ------------------ WRITE FILE ---------------------
strFileName = sprintf('%s.ini', dopt.fileName);
fid = fopen( strFileName, 'w');

% header at start
fprintf(fid, '#pTXRFPulse - created by: <%s><%s>\n', FCTNAME, VERSION);

%% Fill implicit parameters
if(~isempty(afGradient))
    dopt.Samples = size(afGradient,2);
    dopt.Oversampling = size(afRFPulse,2)/size(afGradient,2);
else
    dopt.Samples = size(afRFPulse,2);
end
dopt.NUsedChannels = size(afRFPulse,1);
dopt.MaxAbsRF = max(abs(afRFPulse(:)));
% scale RF between 0 and 1
afRFPulse = afRFPulse ./ dopt.MaxAbsRF;


%% write global paramters

fprintf(fid,'[pTXPulse]\n\n');
for g=groups % go through all groups
    for v=1:size(options(g).name,2) % go through all values  
        if(~isfield(dopt,options(g).name(v)) && options(g).req(v)==1)
            error('required field is not set');
        end
        if(isfield(dopt,options(g).name(v)))
            switch options(g).type(v)
                case 1
                    fmt = '%-20s = %s\n';
                case 2
                    fmt = '%-20s = %g\n';
                case 3
                    fmt = '%-20s = %d\n';
            end
            fprintf(fid,fmt, cell2mat(options(g).name(v)), dopt.(cell2mat(options(g).name(v))));
        end
    end
end

%% write gradients
if(~isempty(afGradient))
   fprintf(fid,'\n[Gradient]\n\n');
   for s=1:size(afGradient,2)
       fprintf(fid,'G[%d]= %0.1g\t %0.1g\t %0.1g\n', s-1, afGradient(1,s), afGradient(2,s), afGradient(3,s));
   end
end

%% write RF

for c=1:dopt.NUsedChannels
    fprintf(fid,['\n[pTXPulse_ch' num2str(c-1) ']\n\n']);
    for s=1:size(afRFPulse,2)
        fprintf(fid,'RF[%d]=  %0.4g\t %0.4g\n',s-1,abs(afRFPulse(c,s)),angle(afRFPulse(c,s))+pi);
    end
end

fprintf(fid,'\n#EOF\n');
fclose(fid);

%% helper functions

function addParam(group, name, type, required)
    try
        sz=size(options(group).name,2);
%         sz = 0;
    catch
        sz = 0;
    end
    options(group).name{sz+1} = name;
    options(group).type(sz+1) = type;
    options(group).req(sz+1) = required;
end
end