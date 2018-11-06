classdef ROI_gui < handle
    %ROI Summary of this class goes here
    %   Detailed explanation goes here
    properties
        image    % image to work on, obj.image = theImageToWorkOn
        roi      % the generated ROI mask (logical)
        labels   % Connected component labens (multi ROI)
        number   % how many ROIs there are
      figw = 600 % initial window height, this is calculated on load
     roi_result  % Input object
    end
    
    properties(Access=private)
        % UI stuff
             f    % mainwindow
     imax_axes    % holds working area
    roiax_axes    % holds roid preview image
          imag    % image to work on
        roifig    % roi image 
          figh    % initial figure height - your image is scaled to fit.
                    % On change of this the window gets resized
        
        hwar = 0.85;  % aspect ratio
        
        % Class stuff
        loadmask  % mask loaded from file
        mask      % mask defined by shapes
        current   % which shape is selected
       roi_mask   % holds all the shapes to define the mask
    selectedROI   % hold
       filename
       %pathname
     currentGui   % Current Image Panel
        buttons   % Buttons
    isSubstract   % If toggle button pushed
    end
    
    %% Public Methods
    methods 
        
        function this = ROI_gui(theImage,ROIObj)    
        % constructor
            % make sure the window appears "nice" (was hard to find this
            % aspect ratio to show a well aligned UI ;)
            this.figh = this.figw*this.hwar;
            this.roi_result = ROIObj;
            % invoke the UI window
            this.createWindow;
            
            % load the image
            if nargin > 0
                this.image = theImage;
            else
                this.image = ones(100,100);
            end        

            % predefine class variables
            this.roi_mask = {};
            this.currentGui = findall(0,'Type','uipanel','Tag','imagePanelGroup');
            this.current = 0; 
            this.filename = 'roi_'; % default filename
            %this.pathname = pwd;      % current directory
            this.isSubstract = 0;
        end
        
        function delete(this)
        % destructor
            delete(this.f);
        end
        
        function set.image(this,theImage)
            this.current = 0;
        % set method for image. uses grayscale images for region selection
            if size(theImage,3) == 3
                this.image = im2double(rgb2gray(theImage));
            elseif size(theImage,3) == 1
                this.image = im2double(theImage);
            else
                error('Unknown Image size?');
            end
            this.resetImages;
           
        end
        
        function set.figh(this,height)
            this.figh = height;  
        end

        function [roi, labels, number] = getROIData(this,varargin)
        % retrieve ROI Data
            roi = this.roi;
            labels = this.labels;
            number = this.number;
        end        
    end
    
    %% private used methods 
    methods(Access=private)
        % general functions -----------------------------------------------
        function resetImages(this)   
            % load images
            this.imag = imshow(this.image,'parent',this.imax_axes); 
            this.roifig = imshow(this.image,'parent',this.roiax_axes);  
            
            % set masks to blank
            this.loadmask = zeros(size(this.image));
        end
        
        function updateROI(this, ~)
            this.mask = this.loadmask | zeros(size(this.image));
            total_size = numel(this.roi_mask);
            for i=numel(this.roi_mask):-1:1
                disp("@@@ i= "+i)
                tag = get(this.roi_mask{total_size-i+1},'Tag')
                BWadd = this.roi_mask{total_size-i+1}.createMask(this.imag);
                if tag(1)=='+'
                    this.mask = this.mask | BWadd;
                else
                    this.mask = this.mask & ~BWadd;
                end
               
            end
            set(this.roifig,'CData',this.image.*this.mask);
        end

        function newShapeCreated(this)
            if this.isSubstract == 0
                set(this.roi_mask{end},'Tag',sprintf('+imsel_%.f',numel(this.roi_mask)));
            else
                set(this.roi_mask{end},'Tag',sprintf('-imsel_%.f',numel(this.roi_mask)));
            end
            
            this.roi_mask{end}.addNewPositionCallback(@this.updateROI);
            this.updateROI;
        end

       % CALLBACK FUNCTIONS
       % window/figure
        function winpressed(this,h,e,type)
            SelObj = get(gco,'Parent');
            Tag = get(SelObj,'Tag');
            if and(~isempty(SelObj),strfind(Tag,'+imsel_'))
                this.current = str2double(regexp(Tag,'\d','match'));
                for i=1:numel(this.roi_mask)
                   if i==this.current
                       setColor(this.roi_mask{i},'red');
                   else
                       setColor(this.roi_mask{i},'blue');
                   end
                end
            end 
        end
        
        function closefig(this,~)
            delete(this);
        end
        % HELPER Functions
        function drawROI(this,mask,id)
            [~,~,axes,~] = this.findImgGui();
            set(axes(end),'Tag',id);
            id = sprintf('roi(%s)',id);
            this.roi_result.ID = id;
            this.roi_result.Mask = mask;
            this.callbkClear();
            % Mask traces
            colors=prism;
            [B,L] = bwboundaries(mask);
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
                   text(5, 5,id,'Parent',axes(end),'Color',colors(cidx,:,:));
               end
               set(h,'Color',colors(cidx,:,:),'FontSize',14,'FontWeight','bold');
            end 
            hold(axes(end),'off');
        end
        
        function [image,line,axes,text] = findImgGui(this)
            gui = findall(0,'Type','uipanel','Parent',this.currentGui,'Title','Origin');
            axes = findobj(gui,'-depth',1);
            image = findobj(axes(end).Children,'Type','Image'); %get Image
            line = findobj(axes(end).Children,'Type','Line');%get ROI Line
            text = findobj(axes(end).Children,'Type','Text');%get ROI Line
        end
        % LOAD UI button callbacks ------------------------------------------------
        function callbkLoadROI(this,src,e)
            this.selectedROI = '';
            this.selectedROI = src.Value;
        end
        
        function callbkConfirmROI(this,e)
            if isempty(this.selectedROI)
                uialert(this.currentGui.Parent,'Please choose a ROI','Invalid Load ROIs');
                return;
            end
            %disp(selectedROI)
            data = evalin('base',char(this.selectedROI));
            this.drawROI(data,this.selectedROI(5:end));
        end

        % ROI Main button callbacks ------------------------------------------------
        function callbkSave(this,e)
            if this.mask == 0
                uialert(this.currentGui.Parent,'Please choose a ROI','Invalid Load ROIs');
                return;
            end
            id = fix(clock);
            id = sprintf('%d%d%d%d%d%d', id(1)-2000, id(2), id(3), id(4), id(5), id(6));
            fname = sprintf('roi_%s', id);   
            assignin('base', fname, this.mask);
            this.drawROI(this.mask,id);
        end
        
        function callbkLoad(this,e)
             ROIData = evalin('base','who');
             flag = regexp(ROIData,'roi_');
             flag = ~cellfun('isempty',flag);
             %Check Null 
             if sum(flag)==0
                 uialert(this.currentGui.Parent,'You haven''t saved any ROIs.','Invalid Load ROIs');
                 return;
             end
             %Check Opened Figure 
             gui_load = findall(0,'Name','Load ROI');
             if ~isempty(gui_load)
                 return;
             end
             %Build Figure for saved ROI List
             popUpFigure = uifigure('Position', [0, 0, 250, 250],'Name','Load ROI','Resize','off');
             uilabel(popUpFigure,'FontColor','k','Text','Please slect ROI(s) from following files:','Position', [20 220 250 20]);
             ROIData = ROIData(flag);
             %Insert Empty Cell
             itemList = {''};
             for ii = 1:size(ROIData)
                 itemList{ii+1} = ROIData{ii};
             end
             uilistbox(popUpFigure,'Position',[20 70 220 150],'Multiselect','off','ValueChangedFcn',@this.callbkLoadROI,'Items',itemList);
             uibutton(popUpFigure,'Position',[20 30 220 30],'ButtonPushedFcn', @(btn,event)this.callbkConfirmROI(btn),'Text', 'Confirm');
        end
        
        function callbkClear(this,e)
            [~,line,~,text] = this.findImgGui();
            delete(line);
            delete(text);
        end
        
        function polyclick(this,h,e)
            this.current = 1; 
            this.roi_mask{end+1} = impoly(this.imax_axes);
            this.newShapeCreated; % add tag, and callback to new shape
        end

        function elliclick(this,h,e)
            this.current = 1; 
            this.roi_mask{end+1} = imellipse(this.imax_axes);
            this.newShapeCreated; % add tag, and callback to new shape
        end

        function freeclick(this,h,c)
            this.current = 1; 
            this.roi_mask{end+1} = imfreehand(this.imax_axes);
            this.newShapeCreated; % add tag, and callback to new shape
        end

        function rectclick(this,h,e)
            this.current = 1; 
            this.roi_mask{end+1} = imrect(this.imax_axes);
            this.newShapeCreated; % add tag, and callback to new shape
        end

        function callbkUndo(this,h,e)
            % delete currently ROI shape
            this.current
            if ~isempty(this.current) && this.current > 0 && ~isempty(this.roi_mask)
                %Delete union ROI
               
                n = findobj(this.imax_axes, 'Tag',['+imsel_', num2str(this.current)])
                disp(n)
                if n > 0 
                    delete(n);
                end
                %Delete intersection ROI
                n = findobj(this.imax_axes, 'Tag',['-imsel_', num2str(this.current)])
                disp(n)
                if n > 0
                    delete(n);
                end
                % renumbering of this.shapes: (e.g. if 3 deleted: 4=>3, 5=>4,...
                for i=this.current+1:numel(this.roi_mask)
                    tag = get(this.roi_mask{i},'Tag');
                    if tag(1) == '+'
                        set(this.roi_mask{i},'Tag',['+imsel_', num2str(i-1)]);
                    else
                        set(this.roi_mask{i},'Tag',['-imsel_', num2str(i-1)]);
                    end
                end
                %delete(this.roi_mask{this.current})
                %this.roi_mask(this.current)=[];
                delete(this.roi_mask{end})
                this.roi_mask(end)=[];
                this.current = numel(this.roi_mask);
                this.updateROI;
            else
                warndlg('You haven''t add a shape','Invalid to Undo');
            end
        end

        function add_sub(this,h,e)
            ispushed=get(h,'Value');
            if ispushed
                this.isSubstract = 1;
                [x9,~]=imread('../UIimg/sub.png');
                img=imresize(x9, [50 50]);
                set(this.buttons(9),'CData',img);
            else
                this.isSubstract = 0;
                [x9,~]=imread('../UIimg/addition.png');
                img=imresize(x9, [50 50]);
                set(this.buttons(9),'CData',img);
            end  
        end
        % UI FUNCTIONS ----------------------------------------------------
        function createWindow(this,~)
            this.f = figure('position', [0 0 this.figw this.figh],'MenuBar','none','Resize','on','Toolbar','none','Name','ROI Tool Box', ...
                'NumberTitle','off','Color',[.1 .1 .1], 'units','pixels');
            
            % buttons
            [x1,~]=imread('../UIimg/pin.png');img1=imresize(x1, [50 50]);
            [x2,~]=imread('../UIimg/load.png');img2=imresize(x2, [50 50]);
            [x3,~]=imread('../UIimg/clear.png');img3=imresize(x3, [50 50]);
            [x4,~]=imread('../UIimg/poly.png');img4=imresize(x4, [50 50]);
            [x5,~]=imread('../UIimg/ellipse.png');img5=imresize(x5, [50 50]);
            [x6,~]=imread('../UIimg/freehand.png');img6=imresize(x6, [50 50]);
            [x7,~]=imread('../UIimg/rect.png');img7=imresize(x7, [50 50]);
            [x8,~]=imread('../UIimg/undo.png');img8=imresize(x8, [50 50]);
            [x9,~]=imread('../UIimg/addition.png');img9=imresize(x9, [50 50]);
            this.buttons = [];
            this.buttons(end+1) = uicontrol('Parent',this.f,'units','normalized','BackgroundColor','w','Callback', @(h,e)this.callbkSave(e),'String', '','CData',img1,'Position', [0 0.9 0.1 0.1]);
            this.buttons(end+1) = uicontrol('Parent',this.f,'units','normalized','BackgroundColor','w','Callback', @(h,e)this.callbkLoad(e),'String', '','CData',img2,'Position', [0.1 0.9 0.1 0.1]);
            this.buttons(end+1) = uicontrol('Parent',this.f,'units','normalized','BackgroundColor','w','Callback', @(h,e)this.callbkClear(e),'String', '','CData',img3,'Position', [0.2 0.9 0.1 0.1]);
            this.buttons(end+1) = uicontrol('Parent',this.f,'units','normalized','BackgroundColor','w','Callback', @(h,e)this.polyclick(h,e),'String', '','CData',img4,'Position', [0.35 0.9 0.1 0.1]);
            this.buttons(end+1) = uicontrol('Parent',this.f,'units','normalized','BackgroundColor','w','Callback', @(h,e)this.elliclick(h,e),'String', '','CData',img5,'Position', [0.45 0.9 0.1 0.1]);          
            this.buttons(end+1) = uicontrol('Parent',this.f,'units','normalized','BackgroundColor','w','Callback', @(h,e)this.freeclick(h,e),'String', '','CData',img6,'Position', [0.55 0.9 0.1 0.1]);
            this.buttons(end+1) = uicontrol('Parent',this.f,'units','normalized','BackgroundColor','w','Callback', @(h,e)this.rectclick(h,e),'String', '','CData',img7,'Position', [0.65 0.9 0.1 0.1]);
            this.buttons(end+1) = uicontrol('Parent',this.f,'units','normalized','BackgroundColor','w','Callback', @(h,e)this.callbkUndo(h,e),'String', '','CData',img8,'Position', [0.8 0.9 0.1 0.1]);          
            %togglebutton
            this.buttons(end+1) = uicontrol('Parent',this.f,'Style','togglebutton','units','normalized','BackgroundColor','w','Callback', @(h,e)this.add_sub(h,e),'String', '','CData',img9,'Position', [0.9 0.9 0.1 0.1]);
                
            % Main image windows    
            this.roiax_axes = axes('parent',this.f,'units','normalized','position',[0 0 0.5 0.9]);
            this.imax_axes = axes('parent',this.f,'units','normalized','position',[0.5 0 0.5 0.9]);
            linkaxes([this.imax_axes this.roiax_axes]);
            
            % add listeners
            set(this.f,'WindowButtonDownFcn',@(h,e)this.winpressed(h,e,'down'));
            set(this.f,'WindowButtonUpFcn',@(h,e)this.winpressed(h,e,'up')) ;
        end
             
    end  % end private methods
end
        