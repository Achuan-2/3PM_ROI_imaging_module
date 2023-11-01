classdef DrawROI < handle
    properties (SetAccess = public)
        mask_layer matlab.graphics.primitive.Image
        mask_alpha double = 0.3 
        mask (:,:) uint8
        colored_mask (:,:,3) uint8 
    end

    properties (Dependent, SetAccess = private)
        binary_mask (:,:) logical
    end

    methods (Hidden)
        function self = DrawROI()
        end
    end

    methods
        function result = get.binary_mask(self)
            result = logical(self.mask);
        end
    end

end



