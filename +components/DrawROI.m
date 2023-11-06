classdef DrawROI < handle
    % 绘制ROI以及手动绘制ROI模块
    % mask
    properties
        app
    end
    properties (SetAccess = public)
        mask_layer matlab.graphics.primitive.Image
        outline_layer matlab.graphics.primitive.Image
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

    % draw roi manually
    properties
        enable logical = false; % 判断是否开启手动圈选
        current_plot;
        start_drawing;
        start_position;
        last_position;
        n_ROI = 0;
        strokes;
        current_stroke;
        brush_size = 4;
        plot_handles;
        plot_current_handle;
        thresh_out = 12;
        thresh_in = 5;
        
    end
    % click and delete
    properties
        last_selected_roi_index;
        last_selected_roi_color;
    end
    
    % move mask
    properties
        three_fold_mask;
        three_fold_colored_mask;
        move_right =0;
        move_down = 0;
    end

    % dilate mask
    properties
        mask_dilate_before;
        colored_mask_dilate_before;
    end

    methods (Hidden)
        function self = DrawROI(app)
            self.colormaps = self.create_colormap();
            self.app = app;
        end
    end

    % add/delete roi manually
    methods
        function handroi_start(self,x,y)
            % 手动圈选ROI 绘制起点
            if self.app.UIAxes.UserData.status ~= "handroi_drawing" && self.enable
                % start draw flag set true
                self.app.UIAxes.UserData.status = "handroi_drawing";

                self.start_position = [x,y];
                self.last_position = [x,y];
                self.current_stroke = [self.current_stroke;self.start_position];

                % draw a red circle at the starting point.
                self.plot_current_handle = plot(self.app.UIAxes,x,y, 'ro', 'MarkerSize', 8);
                self.plot_handles = [self.plot_handles, self.plot_current_handle];
                self.start_drawing = true;
            end
        end

        function handroi_motion(self,x,y)

            if ~self.start_drawing
                return
            end
            if ~self.is_at_start()
                % draw stroke
                self.plot_current_handle = plot(self.app.UIAxes,[self.last_position(1), x], [self.last_position(2), y],Color='r',LineWidth=3);  % 绘制红色线段
                self.plot_handles = [self.plot_handles, self.plot_current_handle];
                self.last_position = [x, y];
                %axis([1,512,1,512]);

                self.current_stroke = [self.current_stroke;[x,y]];
            else
                % end stroke
                self.app.UIAxes.UserData.status = "idle";

                self.last_position = zeros(1,2);
                self.start_position = [];
                self.start_drawing = false;

                self.n_ROI = self.n_ROI + 1;

                for i = 1:length(self.plot_handles)
                    delete(self.plot_handles(i));
                end


                self.plot_handles = [];

                % stroke point to roi area
                new_mask = components.drawRoi.stroke_to_mask(self.current_stroke,self.mask_size);
                self.strokes{self.n_ROI} = self.current_stroke;
                self.current_stroke = [];

                % exclude existed roi area
                if isempty(self.mask)
                    self.mask = zeros(self.mask_size);
                    self.colored_mask = zeros([self.mask_size,3]);
                end
                new_roi_position =(self.mask==0) .* (new_mask==1); % extract position to new
                new_roi_position = logical(new_roi_position); % to logical array
                % add roi to seg_mask
                roi_index = max(self.three_fold_mask,[],'all')+1;
                self.mask(new_roi_position) = roi_index; % add new roi

                % add new roi area to previous mask
                self.colored_mask = components.drawRoi.rgb_add_area(self.colored_mask,new_roi_position,self.colormaps);

                % for move mask

                row = self.mask_size(1);
                col = self.mask_size(2);
                row_range = row+1:2*row;
                col_range = col+1:2*col;
                self.three_fold_mask(row_range+self.move_down,col_range+self.move_right) = self.mask;
                self.three_fold_colored_mask(row_range+self.move_down,col_range+self.move_right,:) = self.colored_mask;

                % Update mask layer
                self.update_mask_layer();

            end
        end
        
        function result = is_at_start(self)
            % There must be at least four points
            if length(self.current_stroke)>3 

                dist = sqrt(sum((self.current_stroke(1,:)-self.current_stroke(2:end,:)).^2, 2));
                dist = dist(:);
                has_left = find(dist > self.thresh_out);
                if ~isempty(has_left)
                    first_left = min(has_left);
                    has_returned = sum(dist(max(4, first_left+1):end) < self.thresh_in); 
                    if has_returned > 0
                        result = true;
                    else
                        result = false;
                    end
                else
                    result = false;
                end
            else
                result =false;
            end
        end
    
        function cancel_handroi(self)
            % 取消手动圈选
            self.current_stroke = [];
            for i = 1:length(self.plot_handles)
                delete(self.plot_handles(i));
            end
            self.plot_handles = [];
            self.app.UIAxes.UserData.status = "idle";

        end
    end

    % update mask functions
    methods

        function threshold_update_mask(self,new_mask)
            result = logical(new_mask)-logical(self.mask);
            add_area = result>0;
            delete_area = result<0;


            %% Delete roi first
            if any(delete_area,'all')
                %获取要删除的编号
                delete_indexes = unique(self.mask(delete_area),'sort');
                for i = 1:length(delete_indexes)
                    % 获取要删除的roi的位置
                    roi_position = self.mask==delete_indexes(i);
                    roi_position_3D = repmat(roi_position,1,1,3);
                    % 在 mask 里删除 roi
                    self.mask(roi_position) =0;
                    self.colored_mask(roi_position_3D) = 0;
                end
                % 由于删除后，需要对seg mask进行重新排序
                self.mask = components.drawRoi.mask_reorder(self.mask);


            end
            %  Caculate the num of roi
            n_roi = max(self.mask,[],'all');
            %% Add roi
            if any(add_area,'all')
                % 获取新增roi的位置
                add_indexes = unique(new_mask(add_area),'sort');
                for i = 1:length(add_indexes)
                    % 获取要增加的roi的位置
                    new_roi_position = new_mask==add_indexes(i);
                    % add roi to seg_mask
                    n_roi = n_roi + 1;
                    self.mask(new_roi_position) = n_roi; % add new roi
                    % add new roi area to previous mask
                    self.colored_mask = components.drawRoi.rgb_add_area(self.colored_mask,new_roi_position,self.colormaps);

                end
            end


            %% update mask layer
            self.update_mask_layer(move_mask_reset=true);
        end
        
        function move_mask_update(self)
            % move_mask: move binary mask and colored mask in GUI
            row = self.mask_size(1);
            col = self.mask_size(2);
            row_range = row+1:2*row;
            col_range = col+1:2*col;

            if ~any(self.three_fold_mask,'all')
                self.three_fold_mask(row_range,col_range) = self.mask;
                self.three_fold_colored_mask(row_range,col_range,:) = self.colored_mask;
            end

            % move mask
            self.mask = self.three_fold_mask(row_range+self.move_down,col_range+self.move_right);
            self.colored_mask = self.three_fold_colored_mask(row_range+self.move_down,col_range+self.move_right,:);

            % update mask layer
            self.update_mask_layer();
        end

        function update_mask_layer(self,ops)
            arguments
                self
                ops.move_mask_reset logical = false;
            end
            if self.app.MaskOnCheckBox.Value
                value = self.app.MaskDropDown.Value;
                switch value
                    case 'Colored'
                        self.mask_layer.CData = self.colored_mask;
                        self.mask_layer.AlphaData = self.mask_alphadata;
                    case 'Binary'
                        self.mask_layer.CData = self.binary_mask*255; %因为使用imageshow的Cdatga更改图像，scale不会改变，需要手动调整图像对比度
                        self.mask_layer.AlphaData = 1;
                end
                self.last_selected_roi_index = 0;
                self.outline_layer.CData =  zeros([size(self.mask_size),3]);
                self.outline_layer.AlphaData = 0;

                %% update move mask
                if ops.move_mask_reset
                    %% update three_fold_mask for mask move
                    self.move_right = 0;
                    self.move_down = 0;

                    row = self.mask_size(1);
                    col = self.mask_size(2);
                    row_range = row+1:2*row;
                    col_range = col+1:2*col;
                    self.three_fold_mask(row_range,col_range) = self.mask;
                    self.three_fold_colored_mask(row_range,col_range,:) = self.colored_mask;
                end

                %% Caculate roi info

                self.app.ROIsEditField.Value = length(unique(self.app.DrawROI.mask))-1;
                roiRatio = round(length(find(self.app.DrawROI.mask>0))/numel(self.app.DrawROI.mask),4);
                self.app.ROIRatioEditField_2.Value = roiRatio;
                self.app.ROIRatioEditField.Value = roiRatio;

            end
        end
        
        function selecting_roi = select_cell(self,x,y)
        % Click on ROI to make it white
            % Get the roi index of current position
            try
                roi_index = self.mask(round(y),round(x));
            catch
                % 当缩小figure，x，y可能会超过image size
                selecting_roi = false;
                return
            end
            if  self.last_selected_roi_index
                if roi_index ~= self.last_selected_roi_index
                    % Update layer
                    self.outline_layer.CData =  zeros([size(self.mask_size),3]);
                    self.outline_layer.AlphaData = 0;
                end
            end
            if roi_index % Roi index has to be >0
                %fprintf("ROI:%d Selected\n",roi_index);
                % Get the position of selected roi
                roi_position = self.mask == roi_index;

                outline = components.drawRoi.mask_to_outline(roi_position);
                SE = strel('square',2);
                outline = imdilate(outline ,SE);
                outline_3D = repmat(outline,1,1,3);
                % Selected roi assign white color
                outline_mask = zeros([size(outline),3]);
                if self.app.MaskOnCheckBox.Value
                    switch self.app.MaskDropDown.Value
                        case 'Colored'
                            outline_mask(outline_3D) = repmat([255,255,255],sum(outline,'all'),1);
                        case 'Binary'
                            outline_mask(outline_3D) = repmat([255,0,0],sum(outline,'all'),1);
                    end
                end
                % Update layer
                self.outline_layer.CData = outline_mask;
                self.outline_layer.AlphaData = outline;

                % Save selected roi index
                selecting_roi = true;
                self.last_selected_roi_index = roi_index;
            else
                % Click on the blank space, mask
                selecting_roi = false;
                self.last_selected_roi_index = 0;
            end
        end

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
            
            % for move mask
            row = self.mask_size(1);
            col = self.mask_size(2);
            row_range = row+1:2*row;
            col_range = col+1:2*col;
            self.three_fold_mask(row_range+self.move_down,col_range+self.move_right) = self.mask;
            self.three_fold_colored_mask(row_range+self.move_down,col_range+self.move_right,:) = self.colored_mask;
                    

            % renumber roi
            self.three_fold_mask = components.drawRoi.mask_reorder(self.three_fold_mask);
            self.mask = self.three_fold_mask(row_range+self.move_down,col_range+self.move_right);


            % update layer
            self.last_selected_roi_index = 0;

            self.update_mask_layer();

            self.outline_layer.CData =  zeros([size(self.mask_size),3]);
            self.outline_layer.AlphaData = 0;
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

    % internal set and get function
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
        
        function set.move_down(self,value)
            rows = self.mask_size(1);
            if value > rows
                value = rows;
            elseif value < -rows
                value = -rows;
            end
            self.move_down = value;
        end
        
        function set.move_right(self,value)
            cols = self.mask_size(2);
            if value > cols
                value = cols;
            elseif value < -cols
                value = -cols;
            end
            self.move_right = value;
        end
    end

end



