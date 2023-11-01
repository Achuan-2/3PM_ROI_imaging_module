classdef DrawROI < handle
    % 绘制ROI以及手动绘制ROI模块
    % mask
    properties (SetAccess = public)
        mask_layer matlab.graphics.primitive.Image
        mask_opacity double = 0.3 
        mask (:,:) uint8
        mask_size (:,:) double
        colored_mask (:,:,3) uint8 
        mask_alphadata
    end
    % draw
    properties
        current_plot
        start_drawing
        start_position
        last_position
        n_ROI = 0;
        strokes
        current_stroke
        brush_size = 4;
        plot_handles;
        plot_current_handle
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
        function result = get.mask_alphadata(self)
            result = self.binary_mask*self.mask_opacity;
        end
    end

end



