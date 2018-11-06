function gui_ToolBox(image)
    f = uifigure('Position', [0, 0, 250, 500],'Name','Tool Box','Resize','off');
    currentGui = findall(0,'Type','uipanel','Tag','imagePanelGroup');%Current Image Panel
    ROI_mask = 0;
    ROI_xi = 0;
    ROI_yi = 0;
    selectedROI= [];
    
    %ROI Mode
    uilabel(f,'FontColor','k','Text','ROI','Position', [20 430 100 50]);
    uibutton(f,'ButtonPushedFcn', @(btn,event)callbkAddition(btn),'BackgroundColor','w','Text', '','Icon','../UIimg/addition.png','Position', [30 400 50 50]);
    uibutton(f,'ButtonPushedFcn', @(btn,event)callbkPoly(btn),'BackgroundColor','w','Text', '','Icon','../UIimg/poly.png','Position', [80 400 50 50]);
    uibutton(f,'ButtonPushedFcn', @(btn,event)callbkCircle(btn),'BackgroundColor','w','Text', '','Icon','../UIimg/ellipse.png','Position', [130 400 50 50]);
    uibutton(f,'ButtonPushedFcn', @(btn,event)callbkSquare(btn),'BackgroundColor','w','Text', '','Icon','../UIimg/rect.png','Position', [180 400 50 50]);
    
    
    %Save/Load/Clear
    uilabel(f,'HorizontalAlignment','center','FontColor','k','Text','Save','Position', [10 130 100 50]);
    uilabel(f,'HorizontalAlignment','center','FontColor','k','Text','Load','Position', [75 130 100 50]);
    uilabel(f,'HorizontalAlignment','center','FontColor','k','Text','Clear','Position', [140 130 100 50]);
    uibutton(f,'HorizontalAlignment','center','ButtonPushedFcn', @(btn,event)callbkSave(btn),'BackgroundColor','w','Text', '','Icon','../UIimg/pin.png','Position', [40 100 50 50]);
    uibutton(f,'HorizontalAlignment','center','ButtonPushedFcn', @(btn,event)callbkLoad(btn),'BackgroundColor','w','Text', '','Icon','../UIimg/load.png','Position', [100 100 50 50]);
    uibutton(f,'HorizontalAlignment','center','ButtonPushedFcn', @(btn,event)callbkClear(btn),'BackgroundColor','w','Text', '','Icon','../UIimg/clear.png','Position', [160 100 50 50]);
    
    %Undo
    uilabel(f,'HorizontalAlignment','center','FontColor','k','Text','Undo','Position', [10 30 100 50]);
    uibutton(f,'ButtonPushedFcn', @(btn,event)callbkUndo(btn),'BackgroundColor','w','Text', '','Icon','../UIimg/undo.png','Position', [40 0 50 50]);

    %Redo
    uilabel(f,'HorizontalAlignment','center','FontColor','k','Text','Redo','Position', [140 30 100 50]);
    uibutton(f,'ButtonPushedFcn', @(btn,event)callbkRedo(btn),'BackgroundColor','w','Text', '','Icon','../UIimg/redo.png','Position', [160 0 50 50]);
    
    function drawROI(rawImg,xi,yi)
        close(gcf);
        hold(rawImg,'on');
        plot(rawImg,xi, yi,'LineWidth', 2); 
        hold(rawImg,'off');
    end

    function [image,line,axes] = findImgGui(~)
        gui = findall(0,'Type','uipanel','Parent',currentGui)
        axes = findobj(gui,'-depth',1);
        image = findobj(axes(end).Children,'Type','Image'); %get Image
        line = findobj(axes(end).Children,'Type','Line');%get ROI Line
    end

    function callbkAddition(~)
       [imaga,~,~] = findImgGui();
       roiwindow = ROI_gui(imaga.CData);
       addlistener(roiwindow,'MaskDefined',@your_roi_defined_callback);
       function your_roi_defined_callback(h,e)
            [mask, labels, n] = roiwindow.getROIData;
            ROI_mask = mask;
            delete(roiwindow); 
       end
       %drawROI(axes(end),ROI_xi,ROI_yi);
    end

    function callbkSubtraction(~)
    end

    function callbkPoly(~)
        callbkClear();
        [imaga,~,axes] = findImgGui();
        [ROI_mask,ROI_xi,ROI_yi] = roipoly(imaga.CData);
        drawROI(axes(end),ROI_xi,ROI_yi);
    end

    function callbkCircle(~)
        callbkClear();
        [imaga,~,axes] = findImgGui();
        imshow(imaga.CData);
        h = imellipse;
        position = wait(h);
        ROI_mask = createMask(h);
        ROI_xi = position(:,1);
        ROI_yi = position(:,2);
        drawROI(axes(end),ROI_xi,ROI_yi);
    end

    function callbkSquare(~)
        callbkClear();
        [imaga,~,axes] = findImgGui();
        imshow(imaga.CData);
        h = imrect;
        position = wait(h);
        x1 = position(1);
        x2 = position(1)+position(3);
        y1 = position(2);
        y2 = position(2)+position(4);
        ROI_mask = createMask(h);
        ROI_xi = [x1, x2, x2, x1, x1];
        ROI_yi = [y1, y1, y2, y2, y1];
        drawROI(axes(end),ROI_xi,ROI_yi);
    end

    function callbkSave(~)
        if(ROI_xi == 0)
            uialert(currentGui.Parent,'You haven''t made any(new) ROIs.','Invalid Save ROIs');
            return;
        end
        id = fix(clock);
        id = sprintf('%d%d%d%d%d%d', id(1)-2000, id(2), id(3), id(4), id(5), id(6));
        fname = sprintf('roi_%s', id);   
        assignin('base', fname, struct('mask',ROI_mask,'x',ROI_xi,'y',ROI_yi));
        %Clear saved data
        ROI_mask = 0;
        ROI_xi = 0;
        ROI_yi = 0;
    end
    
    function callbkLoad(~)
         ROIData = evalin('base','who');
         flag = regexp(ROIData,'roi_');
         flag = ~cellfun('isempty',flag);
         %Check Null 
         if sum(flag)==0
             uialert(currentGui.Parent,'You haven''t saved any ROIs.','Invalid Load ROIs');
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
         uilistbox(popUpFigure,'Position',[20 70 220 150],'Multiselect','off','ValueChangedFcn',@callbkLoadROI,'Items',itemList);
         uibutton(popUpFigure,'Position',[20 30 220 30],'ButtonPushedFcn', @(btn,event)callbkConfirmROI(btn),'Text', 'Confirm');
    end

    function callbkLoadROI(src,~)
        selectedROI = '';
        selectedROI = src.Value;
    end

    function callbkConfirmROI(~)
        [~,~,axes] = findImgGui();
        callbkClear();%Clear current ROI
        if isempty(selectedROI)
            uialert(currentGui.Parent,'Please choose a ROI','Invalid Load ROIs');
            return;
        end
        %disp(selectedROI)
        data = evalin('base',char(selectedROI));
        ROI_mask = data.mask;
        ROI_xi = data.x;
        ROI_yi = data.y;
        drawROI(axes(end),data.x,data.y);
    end

    function callbkClear(~)
        [~,line,~] = findImgGui();
        delete(line);
    end

    function callbkUndo(~)
    end

    function callbkRedo(~)
    end

end

