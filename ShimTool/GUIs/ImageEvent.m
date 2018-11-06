classdef ImageEvent
    %IMAGEEVENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ROI_id
        ROI_mask
        ROI_xi
        ROI_yi
    end
    
    methods
        function obj = set.ROI_id(obj,value)
            obj.ROI_id = value;
            %obj.ImageDataList = [obj.ImageDataList, imageData];
        end
        function obj = set.ROI_mask(obj,value)
            obj.ROI_mask = value;
            %obj.ImageDataList = [obj.ImageDataList, imageData];
        end
        function obj = set.ROI_xi(obj,value)
            obj.ROI_xi = value;
            %obj.ImageDataList = [obj.ImageDataList, imageData];
        end
        function obj = set.ROI_yi(obj,value)
            obj.ROI_yi = value;
            %obj.ImageDataList = [obj.ImageDataList, imageData];
        end
    end
    
end

