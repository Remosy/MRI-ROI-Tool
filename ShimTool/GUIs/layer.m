if ~isempty(this.gui_ROI)
                layer_roi = de2bi(this.gui_ROI.roi_result.SelectedLayers,this.imageData.NumSlice);
                if(layer_roi(val)==1)
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