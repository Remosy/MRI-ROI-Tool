function [ImagSig,numChannel,numLayer] = LoadFile(folderPath,files,devide_index,CN)
    MagSig = [];
    PhaSig = [];
    files = sort_nat(files);%Sort file names
    folderPath = strcat(folderPath,'/');
    numChannel = CN;
    numLayer = devide_index/numChannel
    %Get B1 Mag
    for ii = 1 : numLayer*numChannel
        fstring = strcat(folderPath,char(files{ii}));
        MagSig = cat(3, MagSig, double(dicomread(fstring)));
    end
    
    %Get Phase
    for ii = 1 + numLayer*numChannel : 2*numLayer*numChannel
        fstring = strcat(folderPath,char(files{ii}));
        pha = double(dicomread(fstring));
        PhaSig = cat(3, PhaSig, (( pha-(2048-1800) )./(1800*2).*(2.*pi)) - pi );
    end
    
    if numLayer > 1
        fstring = strcat(folderPath,char(files{1}));
        SIZ = size(dicomread(fstring))
        ImagSig = reshape(MagSig.*exp(1i.*PhaSig), [SIZ(1), SIZ(2), numChannel, numLayer]);
        ImagSig = permute(ImagSig, [1,2,4,3]);   % Alter channel -> last dimension
    else
        ImagSig = MagSig.*exp(1i.*PhaSig);
    end
    
end