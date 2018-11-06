classdef ImageData
   properties
      ID
      ImageSignal
      NumSlice
      NumChannel
      ROI ROIMask
   end
   
   methods 
       
     function obj = ImageData(~)
            if nargin == 0
               obj.ROI = ROIMask;
            end
     end
     
     function obj = set.ImageSignal(obj,imageSignal)
         obj.ImageSignal = imageSignal;
     end
     
     function obj = set.ROI(obj,roi)
         %assert(isa(roi,'ROI'),'IMageData Constructor Error:  roi is the class %s, not a ROI object.', class(roi));
         obj.ROI = roi;
     end 
      
   end
end