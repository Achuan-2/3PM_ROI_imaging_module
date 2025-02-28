classdef Segmentation < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        cellpose_model_folder='./cellposeModels'; % Path to store the cellpose model.
        enable logical = false; % seg_enable: Whether cell segmentation is enabled
        auto_rerun logical = false; % % seg_adjust_enable: 是否可以调节阈值重新生成分割图，当run model的时候改为true，重新修改model的时候，设置为false
    end
    
    methods
        function self = Segmentation()
        end
        
    end
end

