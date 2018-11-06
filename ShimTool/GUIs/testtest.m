uidropdown(tab_editor, 'Items',{'Ellipse','Rectangle','Polygon'},'ValueChangedFcn',@(dd, event)roiSelected(dd),'Position', [150 40 80 30]);
    modleButton = uibuttongroup(tab_editor,'BackgroundColor',[0 0 0],'OuterPosition',[150 10 100 22],'SelectionChangedFcn',@(dd)roiModelSelected(dd));
    uitogglebutton(modleButton,'Text','Merge','Position', [0 0 100 22]);
    uilabel(tab_editor,'HorizontalAlignment','center','FontColor','w','Text','Shape','Position', [50 30 80 30]);
    uilabel(tab_editor,'HorizontalAlignment','center','FontColor','w','Text','Shape Mode','Position', [50 0 80 30]);
    
     %ImagePanel
    panel1 = uipanel('Parent',f,'Position', [0 245 420 420],'title','Slices');
    panel2 = uipanel('Parent',f,'Position',[430 245 420 420]);
    panel3 = uipanel('Parent',f,'Position',[860 245 420 420]);
    
    table_phase1 = uitable(bpanel1,'ColumnEditable',false,'Data',randi(8,8,1),'ColumnName',{'Phase'},'ColumnEditable',true,'Position',[50 10 100 180]);
    table_phase2 = uitable(bpanel2,'ColumnEditable',false,'Data',randi(8,8,2),'ColumnName',{'Amplitude','Phase'},'ColumnEditable',true,'Position',[50 10 200 180]);
    table_phase3 = uitable(bpanel3,'ColumnEditable',false,'Data',randi(8,8,3),'ColumnName',{'Amplitude','Phase','Gradient'},'ColumnEditable',true,'Position',[50 10 300 180]);
    

     
    imageData = ImageData;
    function callbkPatient(~)
        fileName = uigetfile({'*.dcm'},'Select patient''s files','MultiSelect', 'on');
        disp(fileName);
        if size(fileName)~=0  
            imageData = ImageData(fileName,0,0);
            disp(imageData);
            comMaps = ImageData.getComMap(imageData);
            displayImg(comMaps);
        end
    end
    
    function callbk_run(~)
        newPhase = table_phase1.Data;
        newAmplitude = zeros(size(newPhase));
        setPhase(newPhase);
        
    end

    function setPhase(phase)
        phase = ImageData.setImagePhase(imageData,phase);
        disp(phase);
    end

    function displayImg(comMaps)      
        panel1_axes = uiaxes(panel1);
        imshow(abs(comMaps),[0,3000],'Parent',panel1_axes);
    end

    function roiSelected(dd)
        cursor = imellipse;
        val = dd.Value;
        switch val
            case "Ellipse"
                disp('Ellipse');
                
            case "Rectangle"
                disp('Rectangle');
                cursor = imrect;
                
             case "Polygon"
                disp('Polygon');
                cursor = impoly;
        end
        %selectedROI = createMask(cursor,abs(ImageData.getComMap(imageData)));
        %figure, imshow(selectedROI); 
    end

    function roiModelSelected(dd,lmp)
        
    end

function reload(~)
         B1shim = zeros(size(obj.B1Mat,1),size(obj.B1Mat,2));
         for ii = 1:8
             B1shim = B1shim + obj.B1Mat(:,:,ii).*exp(-1i.*obj.imagePhase);
         end
end
     
[Row, Col] = size(mask_ana);
        Out = zeros(Row,Col); 
        for ii = 1:Row
            for jj = 1:Col
                if mask_ana(ii,jj)==1
                    Out(ii,jj) = imaga.CData(ii,jj);
                else
                    Out(ii,jj) = 0;
                end
            end
        end
        p = uipanel(currentGui,'Title','ROI','FontSize',18,'BackgroundColor','white','Position', [400 0 400 400]);
        p_axes = uiaxes(p,'Box','off','Position',[0 -30 400 400]);
        imshow(Out,'Parent',p_axes);
       
        
        
        
         function callbkLayerFrom(event)
        val = round(event.Value);
        layerFrom.Value = num2str(val);
        slider_to.Limits = [val layerMax];
    end

    function callbkLayerTo(event)
        layerTo.Value = num2str(round(event.Value));
    end
    
        %Color
    uilabel(f,'HorizontalAlignment','center','FontColor','k','Text','Color','Position', [20 210 100 50]);
    uibutton(f,'ButtonPushedFcn', @(btn,event)callbkRed(btn),'BackgroundColor','r','Text', '','Position', [40 210 20 20]);
    uibutton(f,'ButtonPushedFcn', @(btn,event)callbkCyan(btn),'BackgroundColor','c','Text', '','Position', [60 210 20 20]);
    uibutton(f,'ButtonPushedFcn', @(btn,event)callbkYellow(btn),'BackgroundColor','y','Text', '','Position', [80 210 20 20]);
    uibutton(f,'ButtonPushedFcn', @(btn,event)callbkGreen(btn),'BackgroundColor','g','Text', '','Position', [100 210 20 20]);
    uibutton(f,'ButtonPushedFcn', @(btn,event)callbkBlue(btn),'BackgroundColor','b','Text', '','Position', [120 210 20 20]);
    uibutton(f,'ButtonPushedFcn', @(btn,event)callbkMagenta(btn),'BackgroundColor','m','Text', '','Position', [140 210 20 20]);