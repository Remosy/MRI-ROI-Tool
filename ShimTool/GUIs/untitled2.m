this.f = figure('Position', [0, 0, 700, 330],'Name','ROI','Resize','off','NumberTitle','off','Color','white', 'units','pixels');

            % buttons
            [x1,~]=imread('../UIimg/poly.png');img1=imresize(x1, [50 50]);
            [x2,~]=imread('../UIimg/ellipse.png');img2=imresize(x2, [50 50]);
            [x3,~]=imread('../UIimg/freehand.png');img3=imresize(x3, [50 50]);
            [x4,~]=imread('../UIimg/rect.png');img4=imresize(x4, [50 50]);
            [x5,~]=imread('../UIimg/toolBox_clear.png');img5=imresize(x5, [50 50]);
            [x6,~]=imread('../UIimg/apply.png');img6=imresize(x6, [50 50]);
            buttons = [];
            buttons(end+1) = uicontrol('Parent',this.f,'BackgroundColor','w','Callback', @(h,e)this.polyclick(h,e),'String', '','CData',img1,'Position', [0.5 0.8 0.5 0.5]);
            buttons(end+1) = uicontrol('Parent',this.f,'BackgroundColor','w','Callback', @(h,e)elliclick(h,e),'String', '','CData',img2,'Position', [0.01 0.65 0.15 0.15]);
            buttons(end+1) = uicontrol('Parent',this.f,'BackgroundColor','w','Callback', @(h,e)freeclick(h,e),'String', '','CData',img3,'Position', [0.01 0.5 0.15 0.15]);
            buttons(end+1) = uicontrol('Parent',this.f,'BackgroundColor','w','Callback', @(h,e)rectclick(h,e),'String', '','CData',img4,'Position', [0.01 0.35 0.15 0.15]);
            buttons(end+1) = uicontrol('Parent',this.f,'BackgroundColor','w','Callback', @(h,e)delete(h,e),'String', '','CData',img5,'Position', [0.01 0.2 0.15 0.15]);          
            buttons(end+1) = uicontrol('Parent',this.f,'BackgroundColor','w','Callback', @(h,e)add_sub(h,e),'String', '','CData',img6,'Position', [0.01 0.05 0.15 0.15]);
            % Main image windows    
            %imax = uipanel(this.f,'Position',[0 0 320 330],'Title','Working Area');
            this.imax_axes = axes('parent',this.f,'units','normalized','position',[0 0 320 320]);
            %roiax = uipanel(this.f,'Position',[320 0 320 330],'Title','ROI Preview');
            this.roiax_axes = axes('parent',this.f,'units','normalized','position',[320 0 320 320]);
            linkaxes([this.imax_axes this.roiax_axes]);