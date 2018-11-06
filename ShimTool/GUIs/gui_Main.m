function gui_Main
    %Variables
    f = uifigure('Position', [0 0 1280 768],'Name','Shim Tool');
    imageData = [];
    gui_ROI = [];
    pickLayer_list = {};
    mainEvent = [];
    isFirstShim = 0;
    pos = 0; %pos for Shim bar graph and images
    CN = []; %input of channel
    channel_fig =[];
    current_layer = 1;
    current_channel = 1;
    shimList = [];
    shimList_B1p =[];
    mask_shm = [];
    %Add to class:ImageData
    addpath(genpath('../Process'));
    
    %TopTab
    topGroup = uitabgroup(f,'Position',[0 668 1280 100]);
    
    tab_home = uitab(topGroup, 'Title', 'HOME');
    tab_home.BackgroundColor = [.1 .1 .1];
    
    tab_editor = uitab(topGroup, 'Title', 'EDITOR');
    tab_editor.BackgroundColor = [.1 .1 .1];
    
    tab_help = uitab(topGroup, 'Title', 'HELP');
    tab_help.BackgroundColor = [.1 .1 .1];

    %TopTab______HOME
    uibutton(tab_home,'ButtonPushedFcn', @(btn,event)callbkPatient(btn),'BackgroundColor',[.1 .1 .1],'Text', '','Icon','../UIimg/patient.png','Position', [50 20 50 50]);
    uilabel(tab_home,'HorizontalAlignment','center','FontColor','w','Text','Patient','Position', [50 -30 50 50]);

    uibutton(tab_home,'ButtonPushedFcn', @(btn,event)callbkRefresh(btn),'BackgroundColor',[.1 .1 .1],'Text', '','Icon', '../UIimg/refresh.png','Position', [200 20 50 50]);
    uilabel(tab_home,'HorizontalAlignment','center','FontColor','w','Text','Refresh','Position', [200 -30 50 50]);
    
    uibutton(tab_home,'ButtonPushedFcn', @(btn,event)callbkSave(btn),'BackgroundColor',[.1 .1 .1],'Text', '','Icon', '../UIimg/save.png','Position', [350 20 50 50]);
    uilabel(tab_home,'HorizontalAlignment','center','FontColor','w','Text','Save','Position', [350 -30 50 50]);

    uibutton(tab_home,'ButtonPushedFcn', @(btn,event)callbkExport(btn),'BackgroundColor',[.1 .1 .1],'Text', '','Icon', '../UIimg/export.png','Position', [500 20 50 50]);
    uilabel(tab_home,'HorizontalAlignment','center','FontColor','w','Text','Export','Position', [500 -30 50 50]);
        
    %TopTab______EDITOR
    uibutton(tab_editor,'ButtonPushedFcn', @(btn,event)callbkAddShim(btn),'BackgroundColor',[.1 .1 .1],'Text', '','Icon','../UIimg/add.png','Position', [50 20 50 50]);
    uilabel(tab_editor,'FontColor','w','Text','Add Shim','Position', [50 -30 100 50]);

    uibutton(tab_editor,'ButtonPushedFcn', @(btn,event)callbkShimLists(btn),'BackgroundColor',[.1 .1 .1],'Text', '','Icon', '../UIimg/list.png','Position', [200 20 50 50]);
    uilabel(tab_editor,'FontColor','w','Text','Shim Lists','Position', [200 -30 100 50]);
    
    uibutton(tab_editor,'ButtonPushedFcn', @(btn,event)callbkROIToolBox(btn),'BackgroundColor',[.1 .1 .1],'Text', '','Icon', '../UIimg/drawroi.png','Position', [350 20 50 50]);
    uilabel(tab_editor,'FontColor','w','Text','Draw ROI','Position', [350 -30 100 50]);

    uibutton(tab_editor,'ButtonPushedFcn', @(btn,event)callbkAnalysis(btn),'BackgroundColor',[.1 .1 .1],'Text', '','Icon', '../UIimg/compare.png','Position', [500 20 50 50]);
    uilabel(tab_editor,'FontColor','w','Text','Analysis','Position', [500 -30 100 50]);

    %TopTab______HELP
    uibutton(tab_help,'ButtonPushedFcn', @(btn,event)callbkErrors(btn),'BackgroundColor',[.1 .1 .1],'Text', '','Icon', '../UIimg/error.png','Position', [50 20 50 50]);
    uilabel(tab_help,'HorizontalAlignment','center','FontColor','w','Text','Errors','Position', [50 -30 50 50]);

    uibutton(tab_help,'ButtonPushedFcn', @(btn,event)callbkGuide(btn),'BackgroundColor',[.1 .1 .1],'Text', '','Icon', '../UIimg/guide.png','Position', [200 20 50 50]);
    uilabel(tab_help,'HorizontalAlignment','center','FontColor','w','Text','Guide','Position', [200 -30 50 50]);

    %ImagePanel
    imagePanelGroup = uipanel(f,'Position', [0 270 1280 400],'Tag','imagePanelGroup');
        %Channel
        uilabel(imagePanelGroup,'FontColor','k','Text','Channel','Position', [30 10 50 20]);
        channel = uitextarea(imagePanelGroup,'Position', [80 10 30 20],'ValueChangedFcn',@(textarea,event) callbkChannel1(textarea));
        slider_channel = uislider(imagePanelGroup,'ValueChangedFcn',@(sld,event)callbkChannel2(event),'Limit',[1 8],'Position', [120 30 200 3],'MinorTicks',[]);
        %Layer(s)
        uilabel(imagePanelGroup,'FontColor','k','Text','Layer(s): ','Position', [350 360 50 20]);
        layerFrom = uitextarea(imagePanelGroup,'Position', [350 340 30 20],'ValueChangedFcn',@(textarea,event) callbkLayer1(textarea));
        slider_layer = uislider(imagePanelGroup,'ValueChangingFcn',@(sld,event)callbkLayer(event),'Limit',[1 8],'Position', [350 110 200 3],'Orientation','Vertical');
        button_angleState = uibutton(imagePanelGroup,'state','ValueChangedFcn', @(value,event)callbkAngleImage(event),'BackgroundColor',[1 1 1],'Text','','Icon', '../UIimg/angleImg.png','Position', [340 10 50 50]);
     imageTabGroup = uitabgroup(f,'Position',[0, 0, 1280 270]); 
    
    %Display Channel image on imagePanel
    function DisplayChannelImage(value)
        if isempty(imageData)
            return;
        end
        gui = findall(0,'Type','uipanel','Title','Origin');
        axes = findobj(gui,'-depth',1);
        img = imageData.ImageSignal; 
        if button_angleState.Value == 1
           img = angle(img);
        end
        current_channel = value;
        Out = abs(img(:,:,current_layer,value))./max(max(abs(img(:,:,current_layer,value))));
        imshow(Out,'Parent',axes(end));
    end
    
     %Display Slice image on imagePanel
    function DisplayLayerImage(val)
        if isempty(imageData)
            return;
        end
        gui = findall(0,'Type','uipanel','Title','Origin');
        axes = findobj(gui,'-depth',1);
        img = imageData.ImageSignal;
        %size(img)
        if button_angleState.Value == 1
           img = angle(img);
        end
        current_layer = val;
        Out = abs(img(:,:,val,round(slider_channel.Value)))./max(max(abs(img(:,:,val,round(slider_channel.Value)))));
        %Out = Out(:,:,round(slider_channel.Value));
        imshow(Out,'Parent',axes(end));
        if ~isempty(gui_ROI)
            layer_roi = de2bi(gui_ROI.roi_result.SelectedLayers,imageData.NumSlice);
            if(layer_roi(val)==1)
                % Mask traces
                colors=prism;
                [B,L] = bwboundaries(gui_ROI.roi_result.Mask);
                hold(axes(end),'on');
                for k = 1:length(B)
                   boundary = B{k};
                   cidx = mod(k,length(colors))+1;
                   plot(axes(end),boundary(:,2), boundary(:,1),'Color',colors(cidx,:,:), 'LineWidth', 2);
                   %randomize text position for better visibility
                   rndRow = ceil(length(boundary)/(mod(rand*k,7)+1));
                   col = boundary(rndRow,2); row = boundary(rndRow,1);
                   h = text(col+1, row-1,num2str(L(row,col)),'Parent',axes(end));
                   if(k==length(B))
                       text(5, 5,gui_ROI.roi_result.ID,'Parent',axes(end),'Color',colors(cidx,:,:));
                   end
                   set(h,'Color',colors(cidx,:,:),'FontSize',14,'FontWeight','bold');
                end 
                hold(axes(end),'off');
            end
        end
        getShimPanels = findall(0,'Parent',imagePanelGroup,'Tag','Shim','Type','uiPanel');
        if ~isempty(getShimPanels)
            helper_ShimSlider(val,getShimPanels);
        end
    end

    function callbkLayer1(textarea)
        if isempty(imageData)
            return;
        end
        value = str2double(textarea.Value);
        if value < slider_layer.Limits(1) || value > slider_layer.Limits(2)
            uialert(f,'Please check the range of layer','Invalid Layer');
            return;
        end
        slider_layer.Value = round(value);
        DisplayLayerImage(round(slider_layer.Value));
    end

    %Display Layer image with current Channel on imagePanel
    function callbkLayer(event)
        if isempty(imageData)
            return;
        end
        val = round(event.Value);
        layerFrom.Value = num2str(val);
        layerTo.Value = num2str(val);
        DisplayLayerImage(val);
    end

    

    function callbkChannel1(textarea)
        if isempty(imageData)
            return;
        end
        value = str2double(textarea.Value);
        if value < slider_channel.Limits(1) || value > slider_channel.Limits(2)
            uialert(f,'Please check the range of channel','Invalid Channel');
            return;
        end
        slider_channel.Value = round(value);
        DisplayChannelImage(round(slider_channel.Value));
    end

    function callbkChannel2(event)
        if isempty(imageData)
            return;
        end
        channel.Value = num2str(round(event.Value));
        DisplayChannelImage(round(event.Value));
    end

    % Layer Selected callback
    function updateROIonLayers(src,event) 
         pickLayer_list = src.Items;
         pickLayer_list = ismember(pickLayer_list,src.Value);
    end

    % Layer Updated callback
    function callbkUpdateROIonLayers(src,event) 
        if ~isempty(pickLayer_list)
            gui_ROI.roi_result.SelectedLayers = bi2de(pickLayer_list==1)
        end
        callbkAddShim();
    end

    %Display patient's basic information on imagePanel
    function DisplayBasicInfo(name,str_folder,str_size,str_date,str_format)
        t = findall(0,'Parent',imageTabGroup, 'Title', name);
        if ~isempty(t)
            delete(t);
        end
        t = uitab(imageTabGroup, 'Title', name);
        lbox = uilistbox(t,'Position',[50 120 500 100]);
        str_ID = strcat('ID: ',imageData.ID);
        str_Channel = strcat('Number Of Channel: ',num2str(imageData.NumChannel));
        lbox.Items = {str_ID, str_Channel, char(str_folder),char(str_size),char(str_date),char(str_format)};
        roi_lbox = uilistbox(t,'ValueChangedFcn', @updateROIonLayers,'Position',[600 70 110 150]); 
        for ii = 1 : slider_layer.Limits(2)
             cell = strcat('Layer_',num2str(ii));
             roi_lbox.Items{ii} = cell;
        end
        roi_lbox.Multiselect = 'on';
        uibutton(t,'ButtonPushedFcn', @(btn,event)callbkUpdateROIonLayers(btn),'Position', [600 20 100 50],'Text','Update ROIs');
    end

    function helper_ShimSlider(val,getShimPanels)
         numShim = size(getShimPanels,1);
         for ii = 1:numShim
            get_leftAxes = findall(0,'Parent',getShimPanels(numShim+1-ii),'Tag','abs(shim)');
            get_rightAxes = findall(0,'Parent',getShimPanels(numShim+1-ii),'Tag','angle(shim)');
            panel = findall(0,'Parent',getShimPanels(numShim+1-ii));
            efficiency_label = panel(1);
            inhomogeneity_label = panel(2);
            shim = shimList_B1p(:,:,:,ii);
           
            %Calculate Differences & Inhomogeneity
            diff = abs(shim(mask_shm)) - mean(abs(shim(mask_shm)));
            inhomogeneity = sqrt(mean(diff.^2))./mean(abs(shim(mask_shm)))
            text1 = sprintf('Inhomogeneity = %s',num2str(inhomogeneity));
            set(inhomogeneity_label,'Text',text1);
            
            %Calculate Efficiency
            b1_PO = shimList_B1p(:,:,val,3);%Phase_Only
            b1_shim = shim(:,:,val);
            efficiency = mean(abs(b1_shim(mask_shm(:,:,val))))./mean(abs(b1_PO(mask_shm(:,:,val))))
            
            text2 = sprintf('Efficiency = %s',num2str(efficiency));
            set(efficiency_label,'Text',text2);
            %[crpimg,crpimg_angle]=CropShimImg(shim(:,:,val));
            %imshow(crpimg,[],'Parent',get_leftAxes); hold(axes,'on'); 
            %imshow(crpimg_angle,[],'Parent',get_rightAxes); hold(axes,'off');
            imshow(abs(shim(:,:,val)),[],'Parent',get_leftAxes); hold(axes,'on'); 
            imshow(angle(shim(:,:,val)),[],'Parent',get_rightAxes); hold(axes,'off');
        end
        close(gcf);
    end

    %ShimSlider Helper
    function callbkShimSlider(event)
        val = round(event.Value);
        getShimPanels = findall(0,'Parent',imagePanelGroup,'Tag','Shim','Type','uiPanel');
        helper_ShimSlider(val,getShimPanels);
    end

    function [crpimg,crpimg_angle]=CropShimImg(shim)
        structBoundaries = bwboundaries(abs(shim));
        xy=structBoundaries{1}; % Get n by 2 array of x,y coordinates.
        x = xy(:, 2); % Columns.
        y = xy(:, 1); % Rows.
        topLine = min(x);
        bottomLine = max(x);
        leftColumn = min(y);
        rightColumn = max(y);
        width = bottomLine - topLine + 1;
        height = rightColumn - leftColumn + 1;
        crpimg = imcrop(abs(shim), [topLine, leftColumn, width, height]);
        crpimg_angle = imcrop(angle(shim), [topLine, leftColumn, width, height]);  
    end

    function DisplayShim(mask_shm,shim,shim_name)
        panel = findall(0,'Parent',imagePanelGroup,'Title',shim_name);
        axes_abs = findall(0,'Parent',panel,'Tag','abs(shim)');
        axes_angle = findall(0,'Parent',panel,'Tag','angle(shim)');
        inhomogeneity_label = findall(0,'Parent',panel,'Type','uiLabel','Tag','inhomogeneity');
        efficiency_label = findall(0,'Parent',panel,'Type','uiLabel','Tag','efficiency');
        if(isempty(panel))
            pos = imagePanelGroup.Children(1).Position(1);
            if(~isempty(imagePanelGroup.Children(1))&& isFirstShim == 0)
                pos = pos+400;
            else
                pos = pos+310;
            end
            panel = uipanel('Parent',imagePanelGroup,'Title',shim_name,'FontSize',18,'Position',[pos 5 300 390],'Tag','Shim');
        end
        if(isempty(axes_abs) && isempty(axes_angle))
            axes_abs = uiaxes(panel,'Position',[0 0 185 390],'Box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[],'Tag','abs(shim)');
            axes_angle = uiaxes(panel,'Position',[155 0 185 390],'Box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[],'Tag','angle(shim)');
            inhomogeneity_label = uilabel('Position',[50 30 200 30],'Parent',panel,'FontSize',14,'FontWeight','bold','FontColor','[0 0.4470 0.7410]','Tag','inhomogeneity');
            efficiency_label = uilabel('Position',[50 0 200 30],'Parent',panel,'FontSize',14,'FontWeight','bold','FontColor','[0 0.4470 0.7410]','Tag','efficiency');
        end
        
        %Calculate Differences & Inhomogeneity
        diff = abs(shim(mask_shm)) - mean(abs(shim(mask_shm)));
        inhomogeneity = sqrt(mean(diff.^2))./mean(abs(shim(mask_shm)));
        text1 = sprintf('Inhomogeneity = %s',num2str(inhomogeneity));
        set(inhomogeneity_label,'Text',text1);
        
        %Calculate Efficiency
        init_pos = find(de2bi(gui_ROI.roi_result.SelectedLayers)==1,1,'first');
        default_b1 = shim(:,:,init_pos);
        b1_PO = shimList_B1p(:,:,init_pos,3); %Phase_Only
        efficiency = mean(abs(default_b1(mask_shm(:,:,init_pos))))./mean(abs(b1_PO(mask_shm(:,:,init_pos))))
        text2 = sprintf('Efficiency = %s',num2str(efficiency));
        set(efficiency_label,'Text',text2);
        
        %Display Info
        %[crpimg,crpimg_angle]=CropShimImg(shim(:,:,1));
        %imshow(crpimg,[],'Parent',axes_abs); hold(axes,'on'); 
        %imshow(crpimg_angle,[],'Parent',axes_angle); hold(axes,'off');
        imshow(shim(:,:,1),[],'Parent',axes_abs); hold(axes,'on'); 
        imshow(angle(shim(:,:,1)),[],'Parent',axes_angle); hold(axes,'off');
        close(gcf);%Close unknown figure
    end

    function PlotShimBar(shim,shim_name)
        gui = findall(0,'Title','Applied Shim');
        panel = findall(0,'Parent',gui,'Title',shim_name);
        axes = findall(0,'Parent',panel);
        if(isempty(gui))
            gui = uitab(imageTabGroup, 'Title', 'Applied Shim');
            %Slider to update shim figures
            uilabel('Position',[50 200 200 30],'Text','Slice Controller','Parent',gui,'FontSize',14,'FontWeight','bold','FontColor','[.1 .1 .1 .1]');
            uislider(gui,'ValueChangedFcn',@(sld,event)callbkShimSlider(event),'Limit',[1 imageData.NumSlice],'Position', [100 170 250 3],'MinorTicks',[],'FontSize',14);
        end
        if(isempty(panel))
            panel = uipanel(gui,'Title',shim_name,'FontSize',12,'Position',[pos 0 250 250]);
        end
        if(isempty(axes))
            axes = uiaxes(panel,'Position',[0 0 250 250],'Box','off','XTickLabel',{'1' '2' '3' '4' '5' '6' '7' '8'},'XTick',[],'YTick',[],'YLim',[-1 1]);
        end
        y_categories = {'360^{\circ}' '180^{\circ}' '0' '0.5' '1'};
        set(axes,'YTickLabel',y_categories);
        [abs(shim)./max(abs(shim)),(angle(shim)+pi).*180./pi]
        bar(axes,abs(shim)./max(abs(shim)),0.4,'FaceColor',[0 0.4470 0.7410]);
        hold(axes,'on');
        bar(axes,-((angle(shim)+pi)/2/pi),0.4,'FaceColor',[0.3010 0.7450 0.9330]);
        hold(axes,'off');
    end

    %Remove image from imagePanel
    function RemoveImage(name)
        gui_image = findall(0,'Type','uipanel','Title',name);
        gui_tab = findall(0,'Type','uitab','Title',name);
        delete(gui_image);
        delete(gui_tab);
    end
    
    %Display image on imagePanel
    function DisplayImage(name,img)
        %Create a panel
        p = uipanel(imagePanelGroup,'Title',name,'FontSize',18,'BackgroundColor','white','Position', [0 40 340 360]);
        mainEvent = [mainEvent,name];
        p_axes = uiaxes(p,'Box','off','Position',[-20 -50 390 390],'BackgroundColor','white');
        imshow(img,'Parent',p_axes);
    end

    function callbkAngleImage(event)
        if isempty(findall(0,'Parent',imagePanelGroup,'Title','Origin'))
            return;
        end
        val = round(slider_channel.Value);
        img = imageData.ImageSignal; 
        event.Value
        if event.Value == true
            img = angle(img);
        end
        img = abs(img(:,:,val))./max(max(abs(img(:,:,val))));%Default
        
        %Remove current Image
        RemoveImage('Origin');
        %Add Angle Image
        DisplayImage('Origin',img);
    end

    %LoadFile 
     function callbkInputCN(~,folderPath,folderContent,index_divide,folderSize)
        [ImagSig,numChannel,numSlice] = LoadFile(folderPath,{folderContent(:).name},index_divide,CN.Value);
        delete(channel_fig);
        if size(ImagSig)~=0  
            imageData.ImageSignal = ImagSig;
            imageData.NumChannel = numChannel;
            imageData.NumSlice = numSlice;
            set(slider_channel,'Limit',[1 numChannel]);
            if imageData.NumSlice > 1
                set(slider_layer,'Limit',[1 numSlice]);
                set(slider_layer,'Enable','on');
            else
                set(slider_layer,'Enable','off');
            end
        
            img = abs(ImagSig(:,:,1))./max(max(abs(ImagSig(:,:,1))));%Default 
           
            %Tab UI
            DisplayImage('Origin',img);
             
            str_folder = strcat('Folder Path: ',folderPath);
            str_size = strcat('Total Number of File: ', num2str(folderSize));
            str_date = strcat('Date: ', folderContent(1).date);
            ftype = strsplit(folderContent(1).name,'.');
            str_format = strcat('Format: ',ftype(2));
            DisplayBasicInfo('Origin',str_folder,str_size,str_date,str_format);
            
        else
            uialert(f,'This folder is exceed/incompleted','Invalid Folder');
            return;
        end
    end
    
    %Refresh
    function callbkRefresh(~)
        
    end

    %Save
    function callbkSave(~)
        
    end
    
    %Export HELPER
    function exportHelper(shim)
        NumPulses = 1;
        p_tau = 500;  % pulse duration in us
        extfname = ['pTXComposite_KT_P', num2str(NumPulses), ' ', strrep(datestr(now), ' ', '_')];
        extfname = strrep(extfname, ':','_');
        extfname = strrep(extfname, ' ','_');
        extfname = strrep(extfname, '-','_');
        emptyfname = ['pTX composite pulse KT ',num2str(NumPulses), ' ', strrep(datestr(now), ' ', '_')];
        dopt.type='SBBCompPulses';
        dopt.fileName=extfname;
        dopt.NominalFlipAngle=90;
        dopt.SampleTime=p_tau.*1e6; %divide the length of RF pulse and scale to us
        dopt.PulseName=emptyfname;
        dopt.Comment='OLS spokes';
        % afGradient = [Gm_opt; zeros(1, NumPulses-1)];
        % afRFPulse = reshape(V_opt, NC, NumPulses);
        afGradient = [];
        afRFPulse = shim; % REPLACE WITH SHIM (e.g., shim2 shim4)
        create_pTXRFPulse3_2( afGradient, afRFPulse, dopt)
    end

    %Export
    function callbkExport(~)
        if size(shimList)==0
            uialert(f,'You need to apply shims first.','Invalid Action');
            return;
        end
        exportHelper(shimList(:,:,1));
        pause(1);%Ensure the independent file names
        exportHelper(shimList(:,:,2));
        pause(1);%Ensure the independent file names
        exportHelper(shimList(:,:,3));
    end

    function callbkAddShim(~)
        gui = findall(0,'Type','uipanel','Parent',imagePanelGroup,'Title','Origin');
        axes = findobj(gui,'-depth',1);
       
        if ~isempty(get(axes(end),'Tag')) && ~isempty(gui_ROI)
            roi_id = get(axes(end),'Tag');
            addpath(genpath('../Process'));
            %Get ROI ID
            roi_id = sprintf('roi_%s',roi_id);
            mask_shm = evalin('base',char(roi_id));
            roi_layers = de2bi(gui_ROI.roi_result.SelectedLayers,imageData.NumSlice);
            Fullmask = zeros(size(mask_shm,1),size(mask_shm,2),size(roi_layers,2))
            for ii = 1:size(roi_layers,2)
                if roi_layers(ii)==1
                    Fullmask(:,:,ii) = mask_shm;
                else
                    Fullmask(:,:,ii) = zeros(size(mask_shm,1),size(mask_shm,2));
                end
            end
             
            [B1p,B1pGauss] = GaussFilter(imageData.ImageSignal,Fullmask,imageData.NumChannel);
            [shimList_B1p,shimList,mask_shm] = Shim(Fullmask,B1p,B1pGauss,imageData.ImageSignal);
            
            DisplayShim(mask_shm,shimList_B1p(:,:,:,1),'Shimming within ROI');
            isFirstShim = 1;%Set special position for the fist graph
            PlotShimBar(shimList(:,:,1),'Shimming within ROI');
            
            DisplayShim(mask_shm,shimList_B1p(:,:,:,2),'MLS shimming within ROI');
            PlotShimBar(shimList(:,:,2),'MLS shimming within ROI');
            
            DisplayShim(mask_shm,shimList_B1p(:,:,:,3),'Phase-only shimming within ROI');
            PlotShimBar(shimList(:,:,3),'Phase-only shimming within ROI');
            
        else
            uialert(f,'ROI needed','Invalid Action');
            return;
        end
     end
    
    %Patient 
    function callbkPatient(~)
        RemoveImage('Origin');
        imageData = ImageData;
        eventName = num2str(datenum(clock));
        eventName = strrep(eventName,'.','_');%Generate Event Name
        imageData.ID = eventName;
        folderPath = uigetdir();
        disp(folderPath);
        if folderPath == 0
            return;
        end
        folderContent = dir(folderPath);
        fileNames = regexpi({folderContent.name},'.*IMA|.*DICM|.*DCM','match'); %Check file type
        fileNames = fileNames(~cellfun('isempty',fileNames)); %Remove dir element
        folderSize = size(fileNames,2); %Num of IMA/DICM files
        index_divide = folderSize/2;
        if folderSize < 2 || floor(index_divide)~=index_divide
            uialert(f,'This folder is exceed/incompleted','Invalid Folder');
            return;
        end
        folderContent = folderContent(~ismember({folderContent.name},{'.','..'}));
        
        %Acquire Channel from Users
        channel_fig = uifigure('Position', [0 0 300 100],'Name','How many channel did your files use?');
        CN = uieditfield(channel_fig,'numeric','Position', [100 50 50 30],'Limits',[1 20],'Value', 8);
        uibutton(channel_fig,'ButtonPushedFcn', @(btn,event)callbkInputCN(btn,folderPath,folderContent,index_divide,folderSize),'BackgroundColor','w','Text', 'Confirm','Position', [155 50 50 30]);
    end

    %Shim Lists
    function callbkShimLists(~)
        gui = findall(0,'Name','Shim Lists');
        if isempty(gui)
          gui_ShimLists();
        end
        
    end

    %ROI ToolBox
    function callbkROIToolBox(~)
        gui = findall(0,'Name','ROI Tool Box');
        image_panel = findall(0,'Title','Origin','Type','uipanel');
        if ~isempty(gui) || isempty(image_panel)
            return;
        end
        gui = findall(0,'Type','uipanel','Title','Origin');
        axes = findobj(gui,'-depth',1);
        imaga = findobj(axes(end).Children,'Type','Image'); %get Image
        gui_ROI = ROI_gui(imaga.CData,imageData.ROI);
        %gui_ROI = CROIEditor(imaga.CData);
    end

    %Analysis
    function callbkAnalysis(~)
        gui = findall(0,'Name','Add Analysis');
        if isempty(gui)
          gui_Analysis();
        end
    end

    %Errors
    function callbkErrors(~)
        
    end
   
    %Guide
    function callbkGuide(~)
        
    end

end