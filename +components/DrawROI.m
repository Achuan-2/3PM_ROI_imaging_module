classdef DrawROI < handle
    % 绘制ROI以及手动绘制ROI模块
    properties
        app roi_imaging_module;% roi_imaging_module app
    end

    % General mask properties 
    properties (SetAccess = public)
        mask_layer matlab.graphics.primitive.Image; % handles to display mask
        outline_layer matlab.graphics.primitive.Image % % handles to display outline of selected 
        mask_opacity double = 0.3; %  alpha value of colored mask
        mask (:,:) double; % indexed roi mask
        mask_size (:,:) double % the size of mask
        colored_mask (:,:,3) uint8 % colored roi mask
        colormaps (:,3) double; % Generate random color for ROIs


    end
    % Dependent mask properties 
    properties (Dependent, SetAccess = private)
        binary_mask (:,:) logical; % Automatic generation
        mask_alphadata (:,:) double; % Automatic generation
    end

    % Draw roi manually
    properties
        brush_size = 3;
        plot_handles;
        current_stroke;
        thresh_out = 12;
        thresh_in = 5;
    end
    
    % Click and delete
    properties
        last_selected_roi_index;
        last_selected_roi_color;
    end
    
    % Move mask
    properties
        three_fold_mask;
        three_fold_colored_mask;
        move_right =0;
        move_down = 0;
    end

    % Dilate mask
    properties
        is_dilating;
        three_fold_mask_dilate_before;
        three_fold_colored_mask_dilate_before;
    end

    methods (Hidden)
        function self = DrawROI(app)
            self.colormaps = self.create_colormap();
            self.app = app;
        end
    end

    % Add/Delete roi manually
    methods
        function handroi_start(self,x,y)
            % for dilate mask: if have dilated mask，revert it
            if self.is_dilating
                self.app.ROIdilateSpinner.Value = 0;
                self.three_fold_mask = self.three_fold_mask_dilate_before;
                self.three_fold_colored_mask = self.three_fold_colored_mask_dilate_before;
                self.move_mask_update();
            end

            
            % store start point
            self.current_stroke = [self.current_stroke;[x,y]];

            % draw a red circle at the starting point.
            plot_current_handle = plot(self.app.UIAxes,x,y, 'ro', 'MarkerSize', 8);
            self.plot_handles = [self.plot_handles, plot_current_handle];

            % set status
            self.app.UIAxes.UserData.status = "handroi_drawing";
        end

        function handroi_draw(self,x,y)

            if self.app.UIAxes.UserData.status ~= "handroi_drawing"
                return
            end

            if ~self.handroi_end()
                % Draw current point
                last_position = self.current_stroke(end,:);
                plot_current_handle = plot(self.app.UIAxes,[last_position(1), x], [last_position(2), y], 'Color', 'r','LineWidth',self.brush_size);  % 绘制红色线段
                
                % Save current point to current stroke and current handle
                self.plot_handles = [self.plot_handles, plot_current_handle];
                self.current_stroke = [self.current_stroke;[x,y]];
            else
                % Finish stroke, clear variable
                self.app.UIAxes.UserData.status = "idle";
                for i = 1:length(self.plot_handles)
                    delete(self.plot_handles(i));
                end
                self.plot_handles = [];

                % Current stroke  to a roi area
                new_mask = components.drawRoi.stroke_to_mask(self.current_stroke,self.mask_size);
                self.current_stroke = [];

                % Exclude existed roi area
                new_roi_position = (self.mask==0) .* (new_mask==1); % extract position to new
                new_roi_position = logical(new_roi_position); % to logical array
                
                % Add new roi to mask
                roi_index = max(self.three_fold_mask,[],'all') + 1;
                self.mask(new_roi_position) = roi_index; % add new roi
                
                % Add new colored roi to colored_mask
                self.colored_mask = components.drawRoi.rgb_add_area(self.colored_mask,new_roi_position,self.colormaps);

                % Update three_fold_mask
                self.update_three_fold_mask();

                % Update mask layer
                self.update_mask_layer();

            end
        end
        
        function result = handroi_end(self)
            % There must be at least four points
            if length(self.current_stroke)>3 
                % any dist> self.thresh_out && any dist < self.thresh_in → true
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
    
        function handroi_cancel(self)
            % clear relevant variable
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
        function dilate_mask(self,value)
            SE = strel('disk',value);
            self.three_fold_mask = imdilate(self.three_fold_mask_dilate_before ,SE);
            self.three_fold_colored_mask = imdilate(self.three_fold_colored_mask_dilate_before ,SE);


            % update move mask
            row = self.mask_size(1);
            col = self.mask_size(2);
            row_range = row+1:2*row;
            col_range = col+1:2*col;

            self.mask = self.three_fold_mask(row_range+self.move_down,col_range+self.move_right);
            self.colored_mask = self.three_fold_colored_mask(row_range+self.move_down,col_range+self.move_right,:);

        end
        
        function load_roi_mask(self,path,filename)
            % load mask file
            [~,~,ext] = fileparts(filename);
            switch ext
                case {'.csv','.txt'}
                    self.mask = table2array(readtable(fullfile(path,filename)));
                    if length(unique(self.mask)) == 2
                        self.mask = logical(self.mask);
                    end
                    self.mask_size = size(self.mask);
                    self.colored_mask = components.drawRoi.mask_to_rgb(self.mask,self.colormaps);
                    self.app.MaskDropDown.Value = "Binary";
                    self.reset_three_fold_mask();
                    self.update_mask_layer();
                case '.png'
                    imMask = imread(fullfile(path,filename));
                    dims = ndims(imMask);
                    if dims == 2
                        %如果导入的图片是黑白图 imMask(imMask~=0) = 1;
                        self.mask = single(imMask);
                        if length(unique(self.mask)) == 2
                            self.mask = logical(self.mask);
                        end

                    else
                        %如果导入的图片是rgb图
                        self.mask = logical(rgb2gray(imMask));
                    end
                    self.mask_size = size(self.mask);
                    self.colored_mask = components.drawRoi.mask_to_rgb(self.mask,self.colormaps);
                    self.app.MaskDropDown.Value = "Binary";
                    self.reset_three_fold_mask();
                    self.update_mask_layer();
                case '.mat'
                    S = load(fullfile(path,filename));
                    self.three_fold_mask = S.three_fold_mask;
                    self.three_fold_colored_mask = uint8(S.three_fold_colored_mask);
                    self.mask_size = size(self.three_fold_mask)/3;
                    self.move_down = S.move_down;
                    self.move_right = S.move_right;
                    self.three_fold_mask_dilate_before = self.three_fold_mask;
                    self.three_fold_colored_mask_dilate_before = self.three_fold_colored_mask;
                    % update mask layer
                    self.move_mask_update();
            end

        end

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
            self.reset_three_fold_mask();
            self.update_mask_layer();
        end
        
        function reset_three_fold_mask(self)
            self.move_right = 0;
            self.move_down = 0;
            row = self.mask_size(1);
            col = self.mask_size(2);
            row_range = row+1:2*row;
            col_range = col+1:2*col;

            % reset three_fold_mask
            self.three_fold_mask = zeros(self.mask_size*3);
            self.three_fold_colored_mask = zeros([self.mask_size*3,3]);
            self.three_fold_mask(row_range,col_range) = self.mask;
            self.three_fold_colored_mask(row_range,col_range,:) = self.colored_mask;

            % reset dilate mask
            self.three_fold_mask_dilate_before = self.three_fold_mask;
            self.three_fold_colored_mask_dilate_before = self.three_fold_colored_mask;

        end

        function update_three_fold_mask(self)
            % 新增roi的时候需要update
            row = self.mask_size(1);
            col = self.mask_size(2);
            row_range = row+1:2*row;
            col_range = col+1:2*col;
            % move mask
            self.three_fold_mask(row_range+self.move_down,col_range+self.move_right) = self.mask;
            self.three_fold_colored_mask(row_range+self.move_down,col_range+self.move_right,:) = self.colored_mask;

            % 需要考虑dilate mask吗
            self.three_fold_mask_dilate_before = self.three_fold_mask;
            self.three_fold_colored_mask_dilate_before = self.three_fold_colored_mask;
        end

        function move_mask_update(self)
            % move_mask: move binary mask and colored mask in GUI
            row = self.mask_size(1);
            col = self.mask_size(2);
            row_range = row+1:2*row;
            col_range = col+1:2*col;
            % move mask
            self.mask = self.three_fold_mask(row_range+self.move_down,col_range+self.move_right);
            self.colored_mask = self.three_fold_colored_mask(row_range+self.move_down,col_range+self.move_right,:);

            % 需要考虑dilate mask吗
            % 暂时不考虑

            % update mask layer
            self.update_mask_layer();
        end

        function update_mask_layer(self)
            arguments
                self
            end
            if self.app.MaskOnCheckBox.Value
                %% update mask layer
                value = self.app.MaskDropDown.Value;
                switch value
                    case 'Colored'
                        if isempty(self.mask_layer)
                            hold(self.app.UIAxes,'on');
                            self.mask_layer = imshow(self.colored_mask,[0,255],'parent',self.app.UIAxes,'border','tight','initialmagnification','fit');
                            self.outline_layer = imshow(uint8(zeros([self.mask_size,3])),[0,255],'parent',self.app.UIAxes,'border','tight','initialmagnification','fit');
                            self.outline_layer.AlphaData = zeros(self.mask_size);
                            axis(self.app.UIAxes,[0,self.mask_size(2),0,self.mask_size(1)]);
                            self.app.UIAxes.UserData.origin_xlim = self.app.UIAxes.XLim;
                            self.app.UIAxes.UserData.origin_ylim = self.app.UIAxes.YLim;
                        else
                            self.mask_layer.CData = self.colored_mask;
                        end

                        self.mask_layer.AlphaData = self.mask_alphadata;
                    case 'Binary'
                        if isempty(self.mask_layer)
                            hold(self.app.UIAxes,'on');
                            self.mask_layer = imshow(self.binary_mask*255,[0,255],'parent',self.app.UIAxes,'border','tight','initialmagnification','fit');
                            self.outline_layer = imshow(uint8(zeros([self.mask_size,3])),[0,255],'parent',self.app.UIAxes,'border','tight','initialmagnification','fit');
                            self.outline_layer.AlphaData = zeros(self.mask_size);
                            self.app.UIAxes.UserData.origin_xlim = self.app.UIAxes.XLim;
                            self.app.UIAxes.UserData.origin_ylim = self.app.UIAxes.YLim;
                        else
                            self.mask_layer.CData = self.binary_mask*255; %因为使用imageshow的Cdatga更改图像，scale不会改变，需要手动调整图像对比度
                        end
                        
                        self.mask_layer.AlphaData = 1;
                end
                self.last_selected_roi_index = 0;
                self.outline_layer.CData =  zeros([self.mask_size,3]);
                self.outline_layer.AlphaData = zeros(self.mask_size);

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
                    self.outline_layer.CData =  zeros([self.mask_size,3]);
                    self.outline_layer.AlphaData = zeros(self.mask_size);
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
        
        function delete_selected_cell(self,input_index)
            arguments
                self
                input_index = 0
            end
            %% delete selected cell
            if input_index
                roi_index = input_index;
            else
                roi_index = self.last_selected_roi_index;
            end

            roi_position = self.mask == roi_index;

            roi_position_3D = repmat(roi_position,1,1,3);
            self.mask(roi_position) = 0;
            self.colored_mask(roi_position_3D) = 0;
            
            %% for move mask
            row = self.mask_size(1);
            col = self.mask_size(2);
            row_range = row+1:2*row;
            col_range = col+1:2*col;
            self.three_fold_mask(row_range+self.move_down,col_range+self.move_right) = self.mask;
            self.three_fold_colored_mask(row_range+self.move_down,col_range+self.move_right,:) = self.colored_mask;
            

            
            %% renumber roi
            self.three_fold_mask = components.drawRoi.mask_reorder(self.three_fold_mask);
            self.mask = self.three_fold_mask(row_range+self.move_down,col_range+self.move_right);
            
            %% for dilate mask
            roi_dilate_before_position = self.three_fold_mask_dilate_before == roi_index;
            self.three_fold_mask_dilate_before(roi_dilate_before_position) = 0;
            roi_dilate_before_position_3D = repmat(roi_dilate_before_position,1,1,3);
            self.three_fold_colored_mask_dilate_before(roi_dilate_before_position_3D) = 0;
            self.three_fold_mask_dilate_before = components.drawRoi.mask_reorder(self.three_fold_mask_dilate_before);


            %% update layer
            self.last_selected_roi_index = 0;

            %self.update_three_fold_mask();
            self.update_mask_layer();

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



