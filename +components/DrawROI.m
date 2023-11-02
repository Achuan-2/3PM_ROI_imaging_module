classdef DrawROI < handle
    % 绘制ROI以及手动绘制ROI模块
    % mask
    properties (SetAccess = public)
        mask_layer matlab.graphics.primitive.Image
        mask_opacity double = 0.3 
        mask (:,:) uint8
        mask_size (:,:) double
        colored_mask (:,:,3) uint8 
        mask_alphadata;
        colormaps;
        
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
            self.colormaps = self.create_colormap();
        end
    end

    methods
        function result = create_colormap(~)
            % colormap hsv的矩阵的维度是256*3，RGB通道一通道值都为1，一个通道值都为0，另一个通道为0-1的小数
            height = 43;
            colormap_matrix = zeros(height,3);
            % 创建一个空矩阵用于存储拼接后的结果
            result = zeros(height*6,3);
            colormap_matrix(:,1) = 1;
            colormap_matrix(:,2) = 0;
            colormap_matrix(:,3) = linspace(0,1,height);

            permutations = perms(1:3);

            % 遍历每个排列组合
            for i = 1:size(permutations, 1) % 6种排列组合
                % 获取当前排列组合的列索引
                indices = permutations(i, :);

                % 按照列索引重新排列矩阵的列
                permuted_matrix = colormap_matrix(:, indices);

                % 拼接矩阵
                rowRange = ((i-1)*height+1):(i*height);
                result(rowRange,:) = permuted_matrix;
            end

            % 二维矩阵按行进行去重，如果有重复的行，则删除(因为1，0，0排列组合只有3个，[1,0,1]排列组合只有3个，而默认按6种排列组合进行排列，会有重复
            result = unique(result, 'rows', 'stable');
            randomIdx = randperm(size(result,1));
            result = result(randomIdx,:);
            result = result*255;
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



