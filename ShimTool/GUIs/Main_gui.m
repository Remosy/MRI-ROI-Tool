classdef Main_gui < handle
    properties
        figh = 768; % initial figure height - your image is scaled to fit.
                    % On change of this the window gets resized
        figw = 1280    % initial window height, this is calculated on load
    end
    
    properties (GetAccess = ?ImageData)
        imageData    % Foreign data from ImagaData class
    end
    
    properties(Access=private)
       % UI stuff
                   f    % Mainwindow
             gui_ROI = [];
      pickLayer_list = {};
           mainEvent = [];
         isFirstShim = 0;
                 pos = 0; %pos for Shim bar graph and images
                  CN = []; %input of channel
         channel_fig = [];
       current_layer = 1;
     current_channel = 1;
            shimList = [];
        shimList_B1p = [];
            mask_shm = [];
                hwar = 1.7;   % aspect ratio
       %TopTab
            topGroup
            tab_home
          tab_editor
            tab_help
       %ImagePanel
     imagePanelGroup
             channel
      slider_channel
           layerFrom
             layerTo
        slider_layer
   button_angleState
       %ButtomTab
       imageTabGroup     
   end
     
    %% Public Methods
    methods
        
        function this = Main_gui()                
            % invoke the UI window
            this.createWindow;
        end
        
        function delete(this)
        % destructor
            delete(this.f);
        end
        
        function set.figh(this,height)
            this.figh = height;   
        end
    end
     %% private used methods 
    methods(Access=private)
    % HELPER FUNCTIONS -----------------------------------------------
    %Draw the ROI
        function helper_drawROI(this,axes)
            if ~isempty(this.gui_ROI)
                layer_roi = de2bi(this.gui_ROI.roi_result.SelectedLayers,this.imageData.NumSlice);
                if(layer_roi(this.current_layer)==1)
                    % Mask traces
                    colors=prism;
                    [B,L] = bwboundaries(this.gui_ROI.roi_result.Mask);
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
                           text(5, 5,this.gui_ROI.roi_result.ID,'Parent',axes(end),'Color',colors(cidx,:,:));
                       end
                       set(h,'Color',colors(cidx,:,:),'FontSize',14,'FontWeight','bold');
                    end 
                    hold(axes(end),'off');
                end
            end
        end
    %Display Channel image on imagePanel
        function DisplayChannelImage(this,value)
            if isempty(this.imageData)
                return;
            end
            gui = findall(0,'Type','uipanel','Title','Origin');
            axes = findobj(gui,'-depth',1);
            img = this.imageData.ImageSignal; 
            if this.button_angleState.Value == 1
               img = angle(img);
            end
            this.current_channel = value;
            Out = abs(img(:,:,this.current_layer,value))./max(max(abs(img(:,:,this.current_layer,value))));
            imshow(Out,'Parent',axes(end));
            if ~isempty(this.imageData.ROI)
                this.helper_drawROI(axes);
            end
        end

         %Display Slice image on imagePanel
        function DisplayLayerImage(this,val)
            if isempty(this.imageData)
                return;
            end
            gui = findall(0,'Type','uipanel','Title','Origin');
            axes = findobj(gui,'-depth',1);
            img = this.imageData.ImageSignal;
            %size(img)
            if this.button_angleState.Value == 1
               img = angle(img);
            end
            this.current_layer = val;
            Out = abs(img(:,:,val,round(this.slider_channel.Value)))./max(max(abs(img(:,:,val,round(this.slider_channel.Value)))));
            %Out = Out(:,:,round(slider_channel.Value));
            imshow(Out,'Parent',axes(end));
            this.helper_drawROI(axes);
            getShimPanels = findall(0,'Parent',this.imagePanelGroup,'Tag','Shim','Type','uiPanel');
            if ~isempty(getShimPanels)
                this.helper_ShimSlider(val,getShimPanels);
            end
        end

        function callbkLayer1(this,textarea)
            value = str2double(textarea.Value);
            if isempty(this.imageData) || value <= 0
                return;
            end
            
            if value < this.slider_layer.Limits(1) || value > this.slider_layer.Limits(2)
                uialert(this.f,'Please check the range of layer','Invalid Layer');
                return;
            end
            this.slider_layer.Value = round(value);
            this.DisplayLayerImage(round(this.slider_layer.Value));
        end

        %Display Layer image with current Channel on imagePanel
        function callbkLayer(this,event)
            if isempty(this.imageData)
                return;
            end
            val = round(event.Value);
            this.layerFrom.Value = num2str(val);
            this.layerTo.Value = num2str(val);
            this.DisplayLayerImage(val);
        end

        function callbkChannel1(this,textarea)
            if isempty(this.imageData)
                return;
            end
            value = str2double(textarea.Value);
            if value < this.slider_channel.Limits(1) || value > this.slider_channel.Limits(2)
                uialert(this.f,'Please check the range of channel','Invalid Channel');
                return;
            end
            this.slider_channel.Value = round(value);
            this.DisplayChannelImage(round(this.slider_channel.Value));
        end

        function callbkChannel2(this,event)
            if isempty(this.imageData)
                return;
            end
            this.channel.Value = num2str(round(event.Value));
            this.DisplayChannelImage(round(event.Value));
        end

        % Layer Selected callback
        function updateROIonLayers(this,src,event) 
             this.pickLayer_list = src.Items;
             this.pickLayer_list = ismember(this.pickLayer_list,src.Value);
        end

        % Layer Updated callback
        function callbkUpdateROIonLayers(this,~) 
            if ~isempty(this.pickLayer_list)
                this.gui_ROI.roi_result.SelectedLayers = bi2de(this.pickLayer_list==1);
            end
            this.callbkAddShim(this);
        end

        %Display patient's basic information on imagePanel
        function DisplayBasicInfo(this,name,str_folder,str_size,str_date,str_format)
            t = findall(0,'Parent',this.imageTabGroup, 'Title', name);
            if ~isempty(t)
                delete(t);
            end
            t = uitab(this.imageTabGroup, 'Title', name);
            lbox = uilistbox(t,'Position',[50 120 500 100]);
            str_ID = strcat('ID: ',this.imageData.ID);
            str_Channel = strcat('Number Of Channel: ',num2str(this.imageData.NumChannel));
            lbox.Items = {str_ID, str_Channel, char(str_folder),char(str_size),char(str_date),char(str_format)};
            roi_lbox = uilistbox(t,'ValueChangedFcn', @this.updateROIonLayers,'Position',[600 70 110 150]); 
            for ii = 1 : this.slider_layer.Limits(2)
                 cell = strcat('Layer_',num2str(ii));
                 roi_lbox.Items{ii} = cell;
            end
            roi_lbox.Multiselect = 'on';
            uibutton(t,'ButtonPushedFcn', @(btn,event)this.callbkUpdateROIonLayers(btn),'Position', [600 20 100 50],'Text','Update ROIs');
        end
        
        function [text_inhomo,text_efficiency] = helper_ProcessShimResult(this,shim,val)
            %Calculate Differences & Inhomogeneity
             diff = abs(shim(this.mask_shm)) - mean(abs(shim(this.mask_shm)));
             inhomogeneity = sqrt(mean(diff.^2))./mean(abs(shim(this.mask_shm)));
             text_inhomo = sprintf('Inhomogeneity = %s',num2str(inhomogeneity));
             %Calculate Efficiency
             b1_PO = this.shimList_B1p(:,:,val,3);%Phase_Only
             b1_shim = shim(:,:,val);
             efficiency = mean(abs(b1_shim(this.mask_shm(:,:,val))))./mean(abs(b1_PO(this.mask_shm(:,:,val))));
             text_efficiency = sprintf('Efficiency = %s',num2str(efficiency));
             %[crpimg,crpimg_angle]=CropShimImg(shim(:,:,val));
             %imshow(crpimg,[],'Parent',get_leftAxes); hold(axes,'on'); 
             %imshow(crpimg_angle,[],'Parent',get_rightAxes); hold(axes,'off');

        end

        function helper_ShimSlider(this,val,getShimPanels)
             numShim = size(getShimPanels,1);
             for ii = 1:numShim
                get_leftAxes = findall(0,'Parent',getShimPanels(numShim+1-ii),'Tag','abs(shim)');
                get_rightAxes = findall(0,'Parent',getShimPanels(numShim+1-ii),'Tag','angle(shim)');
                panel = findall(0,'Parent',getShimPanels(numShim+1-ii));
                efficiency_label = panel(1);
                inhomogeneity_label = panel(2);
                layer_channel = panel(3);
                %layer_channel = 
                shim = this.shimList_B1p(:,:,:,ii);            
                [text1,text2] = helper_ProcessShimResult(this,shim,val)
                set(inhomogeneity_label,'Text',text1);
                set(efficiency_label,'Text',text2);
                text3 = sprintf('Layer %s',num2str(val));
                set(layer_channel,'Text',text3);

                imshow(abs(shim(:,:,val)),[],'Parent',get_leftAxes); hold(axes,'on'); 
                imshow(angle(shim(:,:,val)),[],'Parent',get_rightAxes); hold(axes,'off');
            end
            close(gcf);
        end

        %ShimSlider Helper
        function callbkShimSlider(this,event)
            val = round(event.Value);
            getShimPanels = findall(0,'Parent',this.imagePanelGroup,'Tag','Shim','Type','uiPanel');
            this.helper_ShimSlider(val,getShimPanels);
        end

        function [crpimg,crpimg_angle]=CropShimImg(this,shim)
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

        function DisplayShim(this,mask_shm,shim,shim_name)
            panel = findall(0,'Parent',this.imagePanelGroup,'Title',shim_name);
            axes_abs = findall(0,'Parent',panel,'Tag','abs(shim)');
            axes_angle = findall(0,'Parent',panel,'Tag','angle(shim)');
            layer_channel = findall(0,'Parent',panel,'Type','uiLabel','Tag','layer_channel');
            inhomogeneity_label = findall(0,'Parent',panel,'Type','uiLabel','Tag','inhomogeneity');
            efficiency_label = findall(0,'Parent',panel,'Type','uiLabel','Tag','efficiency');
            if(isempty(panel))
                this.pos = this.imagePanelGroup.Children(1).Position(1);
                if(~isempty(this.imagePanelGroup.Children(1))&& this.isFirstShim == 0)
                    this.pos = this.pos+400;
                else
                    this.pos = this.pos+310;
                end
                panel = uipanel('Parent',this.imagePanelGroup,'Title',shim_name,'FontSize',18,'Position',[this.pos 5 300 390],'Tag','Shim');
            end
            if(isempty(axes_abs) && isempty(axes_angle)) && isempty(layer_channel)
                axes_abs = uiaxes(panel,'Position',[0 0 185 390],'Box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[],'Tag','abs(shim)');
                axes_angle = uiaxes(panel,'Position',[155 0 185 390],'Box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[],'Tag','angle(shim)');
                layer_channel = uilabel('Position',[50 300 200 30],'Parent',panel,'FontSize',14,'FontWeight','bold','FontColor','[0 0.4470 0.7410]','Tag','layer_channel');
                inhomogeneity_label = uilabel('Position',[50 30 200 30],'Parent',panel,'FontSize',14,'FontWeight','bold','FontColor','[0 0.4470 0.7410]','Tag','inhomogeneity');
                efficiency_label = uilabel('Position',[50 0 200 30],'Parent',panel,'FontSize',14,'FontWeight','bold','FontColor','[0 0.4470 0.7410]','Tag','efficiency');
            end
            val = find(de2bi(this.gui_ROI.roi_result.SelectedLayers)==1,1,'first');
            [text1,text2] = helper_ProcessShimResult(this,shim,val)
            set(inhomogeneity_label,'Text',text1);
            set(efficiency_label,'Text',text2);
            text3 = sprintf('Layer %s',num2str(val));
            set(layer_channel,'Text',text3);
            %Display Info
            imshow(abs(shim(:,:,1)),[],'Parent',axes_abs); hold(axes,'on'); 
            imshow(angle(shim(:,:,1)),[],'Parent',axes_angle); hold(axes,'off');
            close(gcf);%Close unknown figure
        end

        function PlotShimBar(this,shim,shim_name)
            gui = findall(0,'Title','Applied Shim');
            panel = findall(0,'Parent',gui,'Title',shim_name);
            axes = findall(0,'Parent',panel);
            if(isempty(gui))
                gui = uitab(this.imageTabGroup, 'Title', 'Applied Shim');
                %Slider to update shim figures
                uilabel('Position',[50 200 200 30],'Text','Slice Controller','Parent',gui,'FontSize',14,'FontWeight','bold','FontColor','[.1 .1 .1 .1]');
                uislider(gui,'ValueChangedFcn',@(sld,event)this.callbkShimSlider(event),'Limit',[1 this.imageData.NumSlice],'Position', [100 170 250 3],'MinorTicks',[],'FontSize',14);
            end
            if(isempty(panel))
                panel = uipanel(gui,'Title',shim_name,'FontSize',12,'Position',[this.pos 0 250 250]);
            end
            if(isempty(axes))
                x_channel = cell(1,this.imageData.NumChannel);
                for i = 1: this.imageData.NumChannel
                    x_channel{1,i} = num2str(i);
                end
                axes = uiaxes(panel,'Position',[0 0 250 250],'Box','off','XTickLabel',x_channel,'XTick',[],'YTick',[],'YLim',[-1 1]);
                %axes = uiaxes(panel,'Position',[0 0 250 250],'Box','off','XTickLabel',{'1', '2', '3', '4', '5', '6', '7', '8'},'XTick',[],'YTick',[],'YLim',[-1 1]);
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
        function RemoveImage(this,title,tag,type)
            delete_obj = findall(0,'Type',type,'Title',title,'tag',tag);
            if(~isempty(delete_obj))
                delete(delete_obj);
            end
            %gui_image = findall(0,'Type','uipanel','Title',title);
            %gui_tab = findall(0,'Type','uitab','Title',title);
            %gui_shim_tab = findall(0,'Type','uitab','Title','Applied Shim');
            %gui_shims = findall(0,'Type','uipanel','Tag','Shim');
            %delete(gui_image);
            %delete(gui_tab);
            %if(~isempty(gui_shim_tab))
                %delete(gui_shim_tab);
            %end
            %if(~isempty(gui_shims))
                %delete(gui_shims)
            %end
        end

        %Display image on imagePanel
        function DisplayImage(this,name,img)
            %Create a panel
            p = uipanel(this.imagePanelGroup,'Title',name,'FontSize',18,'BackgroundColor','white','Position', [0 40 340 360]);
            this.mainEvent = [this.mainEvent,name];
            p_axes = uiaxes(p,'Box','off','Position',[-20 -50 390 390],'BackgroundColor','white');
            imshow(img,'Parent',p_axes);
        end

        function callbkAngleImage(this,event)
            if isempty(findall(0,'Parent',this.imagePanelGroup,'Title','Origin'))
                return;
            end
            val = round(this.slider_channel.Value);
            img = this.imageData.ImageSignal; 
            event.Value
            if event.Value == true
                img = angle(img);
            end
            img = abs(img(:,:,val))./max(max(abs(img(:,:,val))));%Default

            %Remove current Image
            this.RemoveImage('Origin','','uipanel');
            %Add Angle Image
            this.DisplayImage('Origin',img);
        end

        %LoadFile 
         function callbkInputCN(this,~,folderPath,folderContent,index_divide,folderSize)
            [ImagSig,numChannel,numSlice] = LoadFile(folderPath,{folderContent(:).name},index_divide,this.CN.Value);
            delete(this.channel_fig);
            if size(ImagSig)~=0  
                this.imageData.ImageSignal = ImagSig;
                this.imageData.NumChannel = numChannel;
                this.imageData.NumSlice = numSlice;
                set(this.slider_channel,'Limit',[1 numChannel]);
                if this.imageData.NumSlice > 1
                    set(this.slider_layer,'Limit',[1 numSlice]);
                    set(this.slider_layer,'Enable','on');
                else
                    set(this.slider_layer,'Enable','off');
                end

                img = abs(ImagSig(:,:,1))./max(max(abs(ImagSig(:,:,1))));%Default 

                %Tab UI
                this.DisplayImage('Origin',img);

                str_folder = strcat('Folder Path: ',folderPath);
                str_size = strcat('Total Number of File: ', num2str(folderSize));
                str_date = strcat('Date: ', folderContent(1).date);
                ftype = strsplit(folderContent(1).name,'.');
                str_format = strcat('Format: ',ftype(2));
                this.DisplayBasicInfo('Origin',str_folder,str_size,str_date,str_format);

            else
                uialert(this.f,'This folder is exceed/incompleted','Invalid Folder');
                return;
            end
         end

        %Export HELPER
        function exportHelper(this,shim)
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
            create_pTXRFPulse3_2(afGradient, afRFPulse, dopt)
        end

        %Export
        function callbkExport(this,~)
            if size(this.shimList)==0
                uialert(this.f,'You need to apply shims first.','Invalid Action');
                return;
            end
            this.exportHelper(this.shimList(:,:,1));
            pause(1);%Ensure the independent file names
            this.exportHelper(this.shimList(:,:,2));
            pause(1);%Ensure the independent file names
            this.exportHelper(this.shimList(:,:,3));
        end

        function callbkAddShim(this,~)
            gui = findall(0,'Type','uipanel','Parent',this.imagePanelGroup,'Title','Origin');
            axes = findobj(gui,'-depth',1);

            if ~isempty(get(axes(end),'Tag')) && ~isempty(this.gui_ROI)
                roi_id = get(axes(end),'Tag');
                addpath(genpath('../Process'));
                %Get ROI ID
                roi_id = sprintf('roi_%s',roi_id);
                this.mask_shm = evalin('base',char(roi_id));
                if size(this.mask_shm,1)~=size(this.imageData.ImageSignal,1)
                    uialert(this.f,'ROI should have the same image size as imported file','Wrong Mask');
                    return;
                end
                roi_layers = de2bi(this.gui_ROI.roi_result.SelectedLayers,this.imageData.NumSlice);
                Fullmask = zeros(size(this.mask_shm,1),size(this.mask_shm,2),size(roi_layers,2))
                for ii = 1:size(roi_layers,2)
                    if roi_layers(ii)==1
                        Fullmask(:,:,ii) = this.mask_shm;
                    else
                        Fullmask(:,:,ii) = zeros(size(this.mask_shm,1),size(this.mask_shm,2));
                    end
                end

                [B1p,B1pGauss] = GaussFilter(this.imageData.ImageSignal,Fullmask,this.imageData.NumChannel);
                [this.shimList_B1p,this.shimList,this.mask_shm] = Shim(Fullmask,B1p,B1pGauss,this.imageData.ImageSignal);

                this.DisplayShim(this.mask_shm,this.shimList_B1p(:,:,:,1),'Shimming within ROI');
                this.isFirstShim = 1;%Set special position for the fist graph
                this.PlotShimBar(this.shimList(:,:,1),'Shimming within ROI');

                this.DisplayShim(this.mask_shm,this.shimList_B1p(:,:,:,2),'MLS shimming within ROI');
                this.PlotShimBar(this.shimList(:,:,2),'MLS shimming within ROI');

                this.DisplayShim(this.mask_shm,this.shimList_B1p(:,:,:,3),'Phase-only shimming within ROI');
                this.PlotShimBar(this.shimList(:,:,3),'Phase-only shimming within ROI');

            else
                uialert(this.f,'ROI needed','Invalid Action');
                return;
            end
         end

        %Patient 
        function callbkPatient(this,~)
            %RemoveImage(title, tag, type)
            this.RemoveImage('Origin','','uipanel');
            this.RemoveImage('Origin','','uitab');
            this.RemoveImage('Applied Shim','','uitab');
            delete(findall(0,'Type','uipanel','tag','Shim'));
            %gui_image = findall(0,'Type','uipanel','Title',title);
            %gui_tab = findall(0,'Type','uitab','Title',title);
            %gui_shim_tab = findall(0,'Type','uitab','Title','Applied Shim');
            %gui_shims = findall(0,'Type','uipanel','Tag','Shim');
            this.imageData = ImageData;
            eventName = num2str(datenum(clock));
            eventName = strrep(eventName,'.','_');%Generate Event Name
            this.imageData.ID = eventName;
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
                uialert(this.f,'This folder is exceed/incompleted','Invalid Folder');
                return;
            end
            folderContent = folderContent(~ismember({folderContent.name},{'.','..'}));

            %Acquire Channel from Users
            this.channel_fig = uifigure('Position', [0 0 300 100],'Name','How many channel did your files use?');
            this.CN = uieditfield(this.channel_fig,'numeric','Position', [100 50 50 30],'Limits',[1 20],'Value', 8);
            uibutton(this.channel_fig,'ButtonPushedFcn', @(btn,event)this.callbkInputCN(btn,folderPath,folderContent,index_divide,folderSize),'BackgroundColor','w','Text', 'Confirm','Position', [155 50 50 30]);
        end

        %Shim Lists
        function callbkShimLists(this,~)
            gui = findall(0,'Name','Shim Lists');
            if isempty(gui)
              gui_ShimLists();
            end

        end

        %ROI ToolBox
        function callbkROIToolBox(this,~)
            gui = findall(0,'Name','ROI Tool Box');
            image_panel = findall(0,'Title','Origin','Type','uipanel');
            if ~isempty(gui) || isempty(image_panel)
                return;
            end
            gui = findall(0,'Type','uipanel','Title','Origin');
            axes = findobj(gui,'-depth',1);
            imaga = findobj(axes(end).Children,'Type','Image'); %get Image
            this.gui_ROI = ROI_gui(imaga.CData,this.imageData.ROI);
            %gui_ROI = CROIEditor(imaga.CData);
        end

        %Analysis
        function callbkAnalysis(this,~)
            gui = findall(0,'Name','Add Analysis');
            if isempty(gui)
              gui_Analysis();
            end
        end
        
    % UI FUNCTIONS ----------------------------------------------------
        function createWindow(this, w, h)
            %Add to class:ImageData
            addpath(genpath('../Process'));
            this.f = uifigure('Position', [0 0 this.figw this.figh],'Name','Shim Tool','units','pixels');
            %TopTab
            this.topGroup = uitabgroup(this.f,'Position',[0 668 1280 100]);

            this.tab_home = uitab(this.topGroup, 'Title', 'HOME');
            this.tab_home.BackgroundColor = [.1 .1 .1];

            this.tab_editor = uitab(this.topGroup, 'Title', 'EDITOR');
            this.tab_editor.BackgroundColor = [.1 .1 .1];

            %TopTab______HOME
            uibutton(this.tab_home,'ButtonPushedFcn', @(btn,event)this.callbkPatient(),'BackgroundColor',[.1 .1 .1],'Text', '','Icon','../UIimg/patient.png','Position', [50 20 50 50]);
            uilabel(this.tab_home,'HorizontalAlignment','center','FontColor','w','Text','Patient','Position', [50 -30 50 50]);

            uibutton(this.tab_home,'ButtonPushedFcn', @(btn,event)this.callbkExport(btn),'BackgroundColor',[.1 .1 .1],'Text', '','Icon', '../UIimg/export.png','Position', [200 20 50 50]);
            uilabel(this.tab_home,'HorizontalAlignment','center','FontColor','w','Text','Export','Position', [200 -30 50 50]);

            %TopTab______EDITOR
            uibutton(this.tab_editor,'ButtonPushedFcn', @(btn,event)this.callbkAddShim(btn),'BackgroundColor',[.1 .1 .1],'Text', '','Icon','../UIimg/add.png','Position', [50 20 50 50]);
            uilabel(this.tab_editor,'FontColor','w','Text','Add Shim','Position', [50 -30 100 50]);

            uibutton(this.tab_editor,'ButtonPushedFcn', @(btn,event)this.callbkShimLists(btn),'BackgroundColor',[.1 .1 .1],'Text', '','Icon', '../UIimg/list.png','Position', [200 20 50 50]);
            uilabel(this.tab_editor,'FontColor','w','Text','Shim Lists','Position', [200 -30 100 50]);

            uibutton(this.tab_editor,'ButtonPushedFcn', @(btn,event)this.callbkROIToolBox(btn),'BackgroundColor',[.1 .1 .1],'Text', '','Icon', '../UIimg/drawroi.png','Position', [350 20 50 50]);
            uilabel(this.tab_editor,'FontColor','w','Text','Draw ROI','Position', [350 -30 100 50]);

            uibutton(this.tab_editor,'ButtonPushedFcn', @(btn,event)this.callbkAnalysis(btn),'BackgroundColor',[.1 .1 .1],'Text', '','Icon', '../UIimg/compare.png','Position', [500 20 50 50]);
            uilabel(this.tab_editor,'FontColor','w','Text','Analysis','Position', [500 -30 100 50]);

            %ImagePanel
            this.imagePanelGroup = uipanel(this.f,'Position', [0 270 1280 400],'Tag','imagePanelGroup');
                %Channel
                uilabel(this.imagePanelGroup,'FontColor','k','Text','Channel','Position', [30 10 50 20]);
                this.channel = uitextarea(this.imagePanelGroup,'Position', [80 10 30 20],'ValueChangedFcn',@(textarea,event) this.callbkChannel1(textarea));
                this.slider_channel = uislider(this.imagePanelGroup,'ValueChangedFcn',@(sld,event)this.callbkChannel2(event),'Limit',[1 8],'Position', [120 30 200 3],'MinorTicks',[]);
                %Layer(s)
                uilabel(this.imagePanelGroup,'FontColor','k','Text','Layer(s): ','Position', [350 360 50 20]);
                this.layerFrom = uitextarea(this.imagePanelGroup,'Position', [350 340 30 20],'ValueChangedFcn',@(textarea,event) this.callbkLayer1(textarea));
                this.slider_layer = uislider(this.imagePanelGroup,'ValueChangingFcn',@(sld,event)this.callbkLayer(event),'Limit',[1 8],'Position', [350 110 200 3],'Orientation','Vertical');
                this.button_angleState = uibutton(this.imagePanelGroup,'state','ValueChangedFcn', @(value,event)this.callbkAngleImage(event),'BackgroundColor',[1 1 1],'Text','','Icon', '../UIimg/angleImg.png','Position', [340 10 50 50]);
             this.imageTabGroup = uitabgroup(this.f,'Position',[0, 0, 1280 270]); 
        end
             
    end  % end private methods
end