function gui_ShimLists
    f = uifigure('Position', [0, 0, 300, 500],'Name','Shim Lists','Resize','off');
    
    shimList = uilistbox(f,'Position', [10, 310, 280, 180],'ValueChangedFcn', @updateEditField);
    
    uilabel(f,'HorizontalAlignment','center','FontColor','k','FontSize',18,'Text','Event Lists','Position', [100 240 100 50]);
    uilabel(f,'HorizontalAlignment','center','FontColor','k','Text','Order By: ','Position', [10 230 100 30]);
    uidropdown(f, 'Items',{'Newest','Name'},'ValueChangedFcn',@(dd, event)callbkOrderBy(dd),'Position', [110 230 100 30]);
    uilistbox(f,'Position', [10, 20, 280, 200]);
    loadShimList();
    
    function loadShimList(~)
        shimList.Items = {'First','Second','Third'};
    end

    function loadEventList(~)
    end
    
    function updateEditField(src,event) 
        disp(src.Value);
    end

    function callbkOrderBy(dd)
       disp(dd);
    end
end