classdef DrawROI < handle
    % 绘制ROI以及手动绘制ROI模块
    % mask
    properties (SetAccess = public)
        mask_layer matlab.graphics.primitive.Image
        mask_opacity double = 0.3 
        mask (:,:) uint8
        mask_size (:,:) double
        colored_mask (:,:,3) uint8 
        colormaps;
    end
    properties (Dependent, SetAccess = private)
        binary_mask (:,:) logical
        mask_alphadata;
    end

    % draw
    properties
        flag logical = false; % 判断是否开启手动圈选
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
    % click and delete
    properties
        last_selected_roi_index;
        last_selected_roi_color;
    end


    methods (Hidden)
        function self = DrawROI()
            self.colormaps = self.create_colormap();
        end
    end

    methods
        function delete_cell(self,x,y)
            % Ctrl+Click to delete cell
            % Get the roi index of current position
            roi_index = self.mask(round(y),round(x));
            if roi_index % Roi index has to be >0
                % Get the position of selected roi
                self.delete_selected_cell(roi_index);
            end      
        end
        function delete_selected_cell(self,roi_index)
            arguments
                self
                roi_index = 0
            end
            % delete selected cell
            if roi_index
                roi_position = self.mask == roi_index;
            else
                roi_position = self.mask == self.last_selected_roi_index;
            end
            roi_position_3D = repmat(roi_position,1,1,3);
            self.mask(roi_position) = 0;
            self.colored_mask(roi_position_3D) = 0;
            % renumber roi
            self.mask = components.drawRoi.mask_reorder(self.mask);
            % update layer
            self.mask_layer.CData = self.colored_mask;
            self.mask_layer.AlphaData(roi_position) = 0;
            self.last_selected_roi_index = 0;
        end
        function select_cell(self,x,y)
        % Click on ROI to make it white
            % Get the roi index of current position
            roi_index = self.mask(round(y),round(x));
            if  self.last_selected_roi_index
                if roi_index ~= self.last_selected_roi_index
                    % If had chosen ROI last time, recover it.
                    last_roi_position = self.mask == self.last_selected_roi_index;
                    last_outline = components.drawRoi.mask_to_outline(last_roi_position);
                    last_outline_3D = repmat(last_outline,1,1,3);
                    self.colored_mask(last_outline_3D) = repmat(self.last_selected_roi_color,sum(last_outline,'all'),1);
                    % Update layer
                    self.mask_layer.CData = self.colored_mask;
                    self.mask_layer.AlphaData(last_outline) = self.mask_opacity;
                end
            end
            if roi_index % Roi index has to be >0
                % Get the position of selected roi
                roi_position = self.mask == roi_index;

                outline = components.drawRoi.mask_to_outline(roi_position);
                
                outline_3D = repmat(outline,1,1,3);
                % Selected roi assign white color
                self.last_selected_roi_color = self.colored_mask(round(y),round(x),:);
                self.colored_mask(outline_3D) = repmat([255,255,255],sum(outline,'all'),1);
                self.mask_layer.AlphaData(outline) = 1;
                % Update layer
                self.mask_layer.CData = self.colored_mask;
                % Save selected roi index
                self.last_selected_roi_index = roi_index;
            else
                % Click on the blank space, mask
                self.last_selected_roi_index = 0;
            end
        end
        function result = create_colormap(~)
            % colormap hsv的矩阵的维度是256*3，RGB通道一通道值都为1，一个通道值都为0，另一个通道为0-1的小数
            height = 43;
            colormap_matrix = zeros(height,3);
            % 创建一个空矩阵用于存储拼接后的结果
            result = zeros(height*6,3);
            colormap_matrix(:,1) = 1;
            colormap_matrix(:,2) = 0;
            colormap_matrix(:,3) = linspace(0,1,height);

            % 6种排列组合
            permutations = perms(1:3);
            % 遍历每个排列组合
            for i = 1:size(permutations, 1) 
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
            % 随机排序
            randomIdx = randperm(size(result,1));
            result = result(randomIdx,:);
            % 0-1 变为 0-255
            result = result*255; 
        end
    end
    methods
        function set.mask(self,value)
            self.mask = value;
        end
        function result = get.binary_mask(self)
            result = logical(self.mask);
        end
        function result = get.mask_alphadata(self)
            result = self.binary_mask*self.mask_opacity;
        end
    end

end



