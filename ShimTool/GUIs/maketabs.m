function maketabs()
    hfig = figure;

    %// Create the tabgroup to hold all tabs
    tabs = uitabgroup('Parent', hfig, 'Position', [0.2 0 0.8 1]);

    %// Create the button to add a new tab
    uicontrol('String', 'Add Tab', ...
               'Units', 'Normalized', ...
               'Callback', @(s,e)addTabCallback(tabs), ...
               'Position', [0 0.5 0.2 0.1]);

    function addTabCallback(parent)
        %// Figure out how many tabs there already are
        ntabs = numel(findall(parent, 'type', 'uitab'));

        %// Create a new uitab in this group
        uitab('Parent', parent, 'Title', sprintf('Tab %d', ntabs+1));
    end
end