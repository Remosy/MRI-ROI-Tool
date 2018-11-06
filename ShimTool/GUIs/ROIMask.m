classdef ROIMask
    %ROI Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
      ID
      Mask
      SelectedLayers
      SelectedChannels
   end
    
    methods 
        function obj = ROIMask(id,mask)
            if nargin == 0
               obj.SelectedLayers = 2047; %default 11 selected layer:[1 1 1 1 1 1 1 1 1 1 1]
               obj.SelectedChannels = 1;
            else
                obj.ID = id;
                obj.Mask = mask;
            end
        end
        
        function obj = set.ID(obj,id)
         obj.ID = id;
        end
        
        function obj = set.Mask(obj,mask)
         obj.Mask = mask;
        end
        
        function obj = set.SelectedLayers(obj,slctLys)
         obj.SelectedLayers = slctLys;
        end
     
        function obj = set.SelectedChannels(obj,slctChls)
         obj.SelectedChannels = slctChls;
        end
     
    end
    
end

