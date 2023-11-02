classdef Segmentation < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        img_nparray
        ops
        seg_mask = [];
        seg_flow = [];
        seg_mask_matlab = [];
        adjust_threshold = false; % 是否可以调节阈值重新生成分割图，当run model的时候改为true，重新修改model的时候，设置为false

    end
    
    methods
        function self = Segmentation(img,model_type,flow_threshold)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            self.ops = py.segmodule.seg_default_ops();
            self.ops{'model_type'} =model_type;
            self.ops{'flow_threshold'} =flow_threshold;
            self.img_nparray = components.segmentation.mat2nparray(img);
        end
        
        function [mask_matlab]= run(self)
            diameter = py.segmodule.cal_diam(self.img_nparray,self.ops);
            self.ops{'diameter'} =diameter;

            % run segmentation
            results = py.segmodule.seg(self.img_nparray,self.ops);
            
            
            % segment result

            self.seg_mask = results{1};
            self.seg_flow = results{2};
            mask_matlab = uint8(self.seg_mask);
            self.seg_mask_matlab = mask_matlab;
        end

        function mask_matlab = change_threshold(self,threshold)

            self.ops{'flow_threshold'} = threshold;
            self.seg_mask = py.segmodule.dynamic_compute( ...
                self.seg_mask, ...
                self.seg_flow, ...
                self.ops);
            mask_matlab = uint8(self.seg_mask);
        end
    end
end

