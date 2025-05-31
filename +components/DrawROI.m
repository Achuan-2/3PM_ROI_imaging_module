classdef DrawROI < handle
    properties
        app; % roi_imaging_module app (can contain multiple UIAxes)
        axes_list = []; % List of UIAxes to render ROIs on
        active_axes_index = 1; % Index of currently active axes
    end

    properties (SetObservable, SetAccess = public)
        roi_contours cell; % cell array storing ROI outlines
        roi_patches cell; % cell array storing patch handles for each UIAxes
        mask_size (1,2) double; % size of the canvas
        mask_color = [255,0,0]/255; % default ROI color
        binary_mask = [];            % 二进制掩膜
        labeled_mask = [];           % 标记掩膜
        selected_roi_color = [199,236,238]/255; % Corrected selected ROI color
        mask_opacity double = 0.3; % alpha value for visualization
        showRoiNumber logical = true; % Control whether to show ROI numbers
        roi_number_fontSize double = 7; % ROI number font size
        roi_number_fontColor = [255,0, 255]/255; % ROI number font color, default red
        roi_visibility logical; % 控制每个 UIAxes 上的 ROI 可见性
        drawing_enabled logical; % 控制每个 UIAxes 的绘制权限
        show_background logical = false; % 是否显示ROI背景色
    end

    properties
        brush_size = 3;
        current_stroke;
        start_plot_handles;
        main_plot_handle; % Main plot handle for drawing
        thresh_out = 5;
        thresh_in = 4;
        selected_roi_idx = 0;
        roi_numbers cell = {}; % Store ROI number text handles for each UIAxes
        original_roi_contours cell = {}; % Store original ROI contours for dilate
        dilate_level = 0; % Current dilate level
        temp_dilate_level = 0; % Temporary dilate value
        is_drawing = false; % Whether ROI is being drawn

        % 拖拽ROI相关属性
        drag_enabled = false;  % 是否启用拖拽ROI模式，默认禁用
        drag_start_x = 0;      % 拖拽起始X坐标
        drag_start_y = 0;      % 拖拽起始Y坐标
        is_dragging = false;   % 是否正在拖拽ROI

        % 随机颜色相关属性
        color_map = [];        % 存储预生成的100种颜色
        color_index = 1;       % 当前使用的颜色索引
        use_random_color = false; % 是否使用随机颜色
        roi_colors = {};       % 存储每个ROI的颜色

        % ROI编辑相关属性
        editing_roi = false;          % 是否正在编辑ROI
        editing_roi_idx = 0;          % 当前正在编辑的ROI索引
        freehand_roi = [];            % 用于编辑的Freehand ROI对象
        % 规则ROI相关属性
        adding_regular_roi = false;          % 是否正在添加规则ROI
        regular_roi_type = '';       % 规则ROI类型 ('circle', 'rectangle')
        regular_roi_obj = [];        % 规则ROI对象句柄
    end

    methods
        function self = DrawROI(app, axes_list)
            self.app = app;
            self.axes_list = axes_list; % Store list of UIAxes
            self.roi_contours = {};
            self.roi_patches = cell(1, length(axes_list)); % One cell per UIAxes
            self.original_roi_contours = {};
            self.roi_numbers = cell(1, length(axes_list)); % One cell per UIAxes
            self.roi_visibility = true(1, length(axes_list)); % 默认所有 axes 上 ROI 都可见
            self.drawing_enabled = true(1, length(axes_list)); % 默认所有 axes 都可以绘制
            self.color_map = self.create_colormap();  % 创建颜色映射
            self.roi_colors = {};  % 初始化ROI颜色存储
            for i = 1:length(axes_list)
                self.roi_patches{i} = {};
                self.roi_numbers{i} = {};
            end
        end

        % 创建随机颜色映射
        function colors = create_colormap(self) % Change to accept instance input
            numColors = 100; % Define number of colors if not defined elsewhere
            goldenRatio = 0.618033988749895; % 黄金分割比例，用于打乱色调
            h = mod((0:numColors - 1) * goldenRatio, 1); % 色调（Hue）均匀分布并打乱
            s = ones(1, numColors) * 0.8; % 饱和度（Saturation）
            v = ones(1, numColors) * 0.95; % 明度（Value）高，保证明亮
            hsvColors = [h; s; v]'; % [numColors x 3]
            colors = hsv2rgb(hsvColors); % 输出 [numColors x 3] 的RGB颜色矩阵
        end

        % mask_color setter，处理颜色变更
        function set.mask_color(self, value)
            if ischar(value) || isstring(value)
                if strcmpi(value, 'Random')
                    self.use_random_color = true;
                    self.mask_color = 'Random';
                    for i = 1:length(self.roi_colors) % Corrected loop syntax
                        i_color = mod(i,length(self.color_map));
                        if i_color==0
                            i_color = length(self.color_map);
                        end
                        self.roi_colors{i} = self.color_map(i_color, :);
                    end
                    % 重置颜色索引
                    self.color_index = length(self.roi_colors) +1;
                else
                    self.use_random_color = false;
                    self.mask_color = value;
                end
            else
                self.use_random_color = false;
                if isempty(value)
                    self.mask_color = [255,255,0]/255; % 默认黄色
                else
                    self.mask_color = value;
                end
            end

            % 如果已有ROI，更新它们的颜色
            self.update_roi_color();
        end

        % 获取当前ROI的颜色
        function color = get_current_roi_color(self,add_index)
            arguments
                self
                add_index  = true
            end
            if self.use_random_color
                % 使用预生成的随机颜色
                i_color = mod(self.color_index,size(self.color_map, 1));
                if i_color==0
                    i_color = size(self.color_map, 1);
                end
                color = self.color_map(i_color, :);
                % 更新索引，如果超出范围则循环使用
                if add_index
                    self.color_index = mod(self.color_index, size(self.color_map, 1)) + 1;
                end
            else
                color = self.mask_color;
            end
        end

        % 设置是否显示ROI背景色
        function set.show_background(self, value)
            self.show_background = value;
            % 更新所有ROI的背景色显示状态
            self.update_background_visibility();
        end

        % 更新所有ROI背景色的显示状态
        function update_background_visibility(self)
            for ax_idx = 1:length(self.axes_list)
                for roi_idx = 1:length(self.roi_patches{ax_idx})
                    if ~isempty(self.roi_patches{ax_idx}{roi_idx}) && isvalid(self.roi_patches{ax_idx}{roi_idx})
                        if self.show_background
                            % 使用ROI边缘颜色作为背景色
                            color = get(self.roi_patches{ax_idx}{roi_idx}, 'EdgeColor');
                            set(self.roi_patches{ax_idx}{roi_idx}, 'FaceColor', color, 'FaceAlpha', self.mask_opacity);
                        else
                            % 不显示背景色
                            set(self.roi_patches{ax_idx}{roi_idx}, 'FaceColor', 'none');
                        end
                    end
                end
            end
        end
    end

    % ROI Drawing Methods
    methods
        function handroi_start(self, x, y)
            % 检查当前活动轴是否允许绘制
            if ~self.drawing_enabled(self.active_axes_index)
                return;
            end

            self.is_drawing = true;
            self.temp_dilate_level = self.dilate_level;
            if self.temp_dilate_level ~= 0
                self.dilate_roi(0);
            end

            self.current_stroke = [x, y];

            % Draw on all UIAxes
            self.main_plot_handle = gobjects(1, length(self.axes_list));
            self.start_plot_handles = gobjects(1, length(self.axes_list));
            for i = 1:length(self.axes_list)
                % 只在允许绘制的轴上显示绘制过程
                if self.drawing_enabled(i)
                    self.main_plot_handle(i) = plot(self.axes_list(i), x, y, 'r-', 'LineWidth', self.brush_size);
                    self.start_plot_handles(i) = plot(self.axes_list(i), x, y, 'ro', 'MarkerSize', 8);
                    % 设置状态为绘制中
                    self.axes_list(i).UserData.status = "handroi_drawing";
                end
            end
        end

        function handroi_draw(self, x, y)
            % Check status of active axes rather than just first axes
            if self.axes_list(self.active_axes_index).UserData.status ~= "handroi_drawing"
                return
            end

            if ~self.is_handroi_end()
                self.current_stroke = [self.current_stroke; [x, y]];
                for i = 1:length(self.axes_list)
                    if self.drawing_enabled(i)
                        set(self.main_plot_handle(i), 'XData', self.current_stroke(:,1), 'YData', self.current_stroke(:,2));
                    end
                end
            else
                self.finish_drawing();
            end
        end

        function result = is_handroi_end(self)
            if size(self.current_stroke, 1) > 3
                dist = sqrt(sum((self.current_stroke(1,:) - self.current_stroke(2:end,:)).^2, 2));
                has_left = find(dist > self.thresh_out);
                if ~isempty(has_left)
                    first_left = min(has_left);
                    has_returned = any(dist(max(4, first_left+1):end) < self.thresh_in);
                    result = has_returned;
                else
                    result = false;
                end
            else
                result = false;
            end
        end

        function handroi_cancel(self)
            self.current_stroke = [];
            for i = 1:length(self.axes_list)
                if ~isempty(self.start_plot_handles) && isvalid(self.start_plot_handles(i))
                    delete(self.start_plot_handles(i));
                end
                if ~isempty(self.main_plot_handle) && isvalid(self.main_plot_handle(i))
                    delete(self.main_plot_handle(i));
                end
                % Reset status of all axes to idle
                self.axes_list(i).UserData.status = "idle";
            end
            self.start_plot_handles = [];
            self.main_plot_handle = [];
            self.restore_dilate_level();
            self.is_drawing = false;
        end

        function restore_dilate_level(self)
            if self.temp_dilate_level ~= 0
                self.dilate_roi(self.temp_dilate_level);
                self.temp_dilate_level = 0;
            end
        end

        function finish_drawing(self)
            % Check if the active axes is in drawing mode
            if strcmp(self.axes_list(self.active_axes_index).UserData.status, "handroi_drawing")
                % Reset status of all axes to idle
                for i = 1:length(self.axes_list)
                    self.axes_list(i).UserData.status = "idle";
                end

                for i = 1:length(self.axes_list)
                    if ~isempty(self.start_plot_handles) && isvalid(self.start_plot_handles(i))
                        delete(self.start_plot_handles(i));
                    end
                    if ~isempty(self.main_plot_handle) && isvalid(self.main_plot_handle(i))
                        delete(self.main_plot_handle(i));
                    end
                end
                self.start_plot_handles = [];
                self.main_plot_handle = [];
                self.add_roi(self.current_stroke);
                self.current_stroke = [];
                self.restore_dilate_level();
                self.is_drawing = false;
            end
        end

        function set_roi_visibility(self, axes_idx, visible)
            % 设置指定 axes 上 ROI 的可见性
            if axes_idx < 1 || axes_idx > length(self.axes_list)
                return;
            end

            self.roi_visibility(axes_idx) = visible;
            % 同时控制绘制权限
            self.drawing_enabled(axes_idx) = visible;

            % 如果正在该轴上绘制而现在禁用了，则取消绘制
            if ~visible && strcmp(self.axes_list(axes_idx).UserData.status, "handroi_drawing") && self.active_axes_index == axes_idx
                self.handroi_cancel();
            end

            % 设置 ROI patches 的可见性
            for i = 1:length(self.roi_patches{axes_idx})
                if ~isempty(self.roi_patches{axes_idx}{i}) && isvalid(self.roi_patches{axes_idx}{i})
                    if visible
                        set(self.roi_patches{axes_idx}{i}, 'Visible', 'on');
                    else
                        set(self.roi_patches{axes_idx}{i}, 'Visible', 'off');
                    end
                end
            end

            % 设置 ROI 编号的可见性
            for i = 1:length(self.roi_numbers{axes_idx})
                if ~isempty(self.roi_numbers{axes_idx}{i}) && isvalid(self.roi_numbers{axes_idx}{i})
                    if visible
                        set(self.roi_numbers{axes_idx}{i}, 'Visible', 'on');
                    else
                        set(self.roi_numbers{axes_idx}{i}, 'Visible', 'off');
                    end
                end
            end
        end

        % 添加规则ROI（圆形或矩形）
        function add_regular_roi(self, roi_type)
            % 检查当前活动轴是否允许绘制
            if ~self.drawing_enabled(self.active_axes_index)
                return;
            end

            % 如果当前有选择的ROI，取消选择状态
            if self.selected_roi_idx > 0
                for ax_idx = 1:length(self.axes_list)
                    if ~isempty(self.roi_patches{ax_idx}{self.selected_roi_idx}) && isvalid(self.roi_patches{ax_idx}{self.selected_roi_idx})
                        set(self.roi_patches{ax_idx}{self.selected_roi_idx}, 'EdgeColor', self.roi_colors{self.selected_roi_idx}, 'LineWidth', 1);
                    end
                end
                self.selected_roi_idx = 0;
            end

            % 如果已经在添加ROI，先完成或取消之前的操作
            if self.adding_regular_roi && ~isempty(self.regular_roi_obj) && isvalid(self.regular_roi_obj)
                self.finish_adding_regular_roi(true);
            end

            % 设置标志
            self.adding_regular_roi = true;
            self.regular_roi_type = roi_type;

            % 获取当前活动轴
            ax = self.axes_list(self.active_axes_index);

            % 计算当前视图的中心点
            x_center = mean(ax.XLim);
            y_center = mean(ax.YLim);

            % 计算ROI的大小（基于视图的1/4宽度）
            width = (ax.XLim(2) - ax.XLim(1)) / 4;
            height = (ax.YLim(2) - ax.YLim(1)) / 4;

            % 根据ROI类型创建相应的对象
            switch lower(roi_type)
                case 'circle'
                    % 创建圆形ROI
                    radius = min(width, height);
                    self.regular_roi_obj = images.roi.Circle(ax, 'Center', [x_center, y_center], 'Radius', radius);

                case 'rectangle'
                    % 创建矩形ROI
                    position = [x_center-width/2, y_center-height/2, width, height];
                    self.regular_roi_obj = images.roi.Rectangle(ax, 'Position', position);

                otherwise
                    error('不支持的ROI类型: %s', roi_type);
            end

            % 设置ROI属性
            color = self.get_current_roi_color(false);
            if ischar(color)
                color = utils.hex2matrix(color);
            end
            self.regular_roi_obj.Color = color;
            self.regular_roi_obj.LineWidth = 2;
            self.regular_roi_obj.Deletable = false; % 不允许通过UI删除
            % 设置轴状态为正在添加ROI
            ax.UserData.status = "adding_regular_roi";
        end
        function clear_patch_rois(self)
            % 检查当前活动轴是否允许绘制
            if ~self.drawing_enabled(self.active_axes_index)
                return;
            end

            % 如果当前有选择的ROI，取消选择状态
            if self.selected_roi_idx > 0
                for ax_idx = 1:length(self.axes_list)
                    if ~isempty(self.roi_patches{ax_idx}{self.selected_roi_idx}) && isvalid(self.roi_patches{ax_idx}{self.selected_roi_idx})
                        set(self.roi_patches{ax_idx}{self.selected_roi_idx}, 'EdgeColor', self.roi_colors{self.selected_roi_idx}, 'LineWidth', 1);
                    end
                end
                self.selected_roi_idx = 0;
            end

            % 如果已经在添加ROI，先完成或取消之前的操作
            if self.adding_regular_roi && ~isempty(self.regular_roi_obj) && isvalid(self.regular_roi_obj)
                self.finish_adding_regular_roi(false);
            end

            % 设置标志
            self.adding_regular_roi = true;
            self.regular_roi_type = 'clearrect';  % 特殊类型，用于识别清除操作

            % 获取当前活动轴
            ax = self.axes_list(self.active_axes_index);

            % 计算当前视图的中心点
            x_center = mean(ax.XLim);
            y_center = mean(ax.YLim);

            % 计算ROI的大小（基于视图的1/4宽度）
            width = (ax.XLim(2) - ax.XLim(1)) / 4;
            height = (ax.YLim(2) - ax.YLim(1)) / 4;

            % 创建矩形选区
            position = [x_center-width/2, y_center-height/2, width, height];
            self.regular_roi_obj = images.roi.Rectangle(ax, 'Position', position);

            % 设置ROI属性 - 使用红色表示删除
            self.regular_roi_obj.Color = [1, 0, 0];  % 红色
            self.regular_roi_obj.LineWidth = 2;
            self.regular_roi_obj.Deletable = false; % 不允许通过UI删除
            self.regular_roi_obj.Label = 'Prcess Enter to Delete ROIs in range';
            self.regular_roi_obj.LabelVisible = 'hover';

            % 设置轴状态为正在添加ROI
            ax.UserData.status = "adding_regular_roi";
        end

        function finish_adding_regular_roi(self, apply_changes)
            % 检查是否正在添加ROI
            if ~self.adding_regular_roi || isempty(self.regular_roi_obj) || ~isvalid(self.regular_roi_obj)
                return;
            end

            if apply_changes
                % 根据ROI类型将ROI转换为轮廓点或执行其他操作
                switch lower(self.regular_roi_type)
                    case 'clearrect'
                        % 清除选区内的ROI
                        rect_pos = self.regular_roi_obj.Position;
                        self.remove_rois_in_rect(rect_pos);

                    case 'circle'
                        % 对于圆形，正确获取中心点和半径
                        center = self.regular_roi_obj.Center;
                        radius = self.regular_roi_obj.Radius;

                        % 创建圆形轮廓（用64个点表示）
                        theta = linspace(0, 2*pi, 64);
                        x = radius * cos(theta) + center(1);
                        y = radius * sin(theta) + center(2);
                        contour = [x', y'];
                        self.add_roi(contour);

                    case 'rectangle'
                        % 对于矩形，直接使用四个角点
                        position = self.regular_roi_obj.Position;
                        x1 = position(1);
                        y1 = position(2);
                        x2 = position(1) + position(3);
                        y2 = position(2) + position(4);

                        contour = [
                            x1, y1;
                            x2, y1;
                            x2, y2;
                            x1, y2;
                            x1, y1
                            ];
                        self.add_roi(contour);

                    otherwise
                        error('不支持的ROI类型: %s', self.regular_roi_type);
                end
            end

            % 删除临时ROI对象
            delete(self.regular_roi_obj);
            self.regular_roi_obj = [];

            % 重置标志
            self.adding_regular_roi = false;
            self.regular_roi_type = '';

            % 恢复轴状态为idle
            self.axes_list(self.active_axes_index).UserData.status = "idle";
        end


        function cancel_adding_regular_roi(self)
            self.finish_adding_regular_roi(false);
        end

        function is_adding = is_adding_regular_roi(self)
            is_adding = self.adding_regular_roi;
        end

        function remove_rois_in_rect(self, rect_pos)
            % 获取矩形区域的边界
            x1 = rect_pos(1);
            y1 = rect_pos(2);
            x2 = x1 + rect_pos(3);
            y2 = y1 + rect_pos(4);

            % 确定哪些ROI需要删除
            to_remove = [];
            for i = 1:length(self.roi_contours)
                % 检查ROI是否完全包含在矩形内
                if self.is_roi_in_rect(i, x1, y1, x2, y2)
                    to_remove = [to_remove, i];
                end
            end

            % 从后向前删除ROI，避免索引变化问题
            to_remove = sort(to_remove, 'descend');
            for idx = to_remove
                for ax_idx = 1:length(self.axes_list)
                    if ~isempty(self.roi_patches{ax_idx}{idx}) && isvalid(self.roi_patches{ax_idx}{idx})
                        delete(self.roi_patches{ax_idx}{idx});
                    end
                    if length(self.roi_numbers{ax_idx}) >= idx && ...
                            ~isempty(self.roi_numbers{ax_idx}{idx}) && ...
                            isvalid(self.roi_numbers{ax_idx}{idx})
                        delete(self.roi_numbers{ax_idx}{idx});
                    end
                end

                % 删除相关数据
                self.roi_contours(idx) = [];
                self.original_roi_contours(idx) = [];
                self.roi_colors(idx) = [];

                for ax_idx = 1:length(self.axes_list)
                    self.roi_patches{ax_idx}(idx) = [];
                    if ~isempty(self.roi_numbers{ax_idx})
                        self.roi_numbers{ax_idx}(idx) = [];
                    end
                end
            end

            % 如果删除了当前选中的ROI，重置选中状态
            if ~isempty(to_remove) && any(to_remove == self.selected_roi_idx)
                self.selected_roi_idx = 0;
            elseif self.selected_roi_idx > 0
                % 调整选中ROI的索引（如果有必要）
                new_idx = self.selected_roi_idx;
                for i = to_remove
                    if i < self.selected_roi_idx
                        new_idx = new_idx - 1;
                    end
                end
                self.selected_roi_idx = new_idx;
            end

            % 更新ROI编号
            self.update_roi_numbers();

            % 更新UI显示
            labeled_mask = self.labeled_mask;
            binary_mask = labeled_mask > 0;
            if isprop(self.app, 'ROIsEditField')
                self.app.ROIsEditField.Value = numel(unique(labeled_mask))-1;
            end
            if isprop(self.app, 'ROIRatioEditField')
                self.app.ROIRatioEditField.Value = mean(binary_mask(:));
            end

            % 提示删除的ROI数量
            if ~isempty(to_remove)
                disp(['Removed ' num2str(length(to_remove)) ' ROIs']);
            else
                disp('No ROIs found within the rectangular region');
            end
        end

        function is_in = is_roi_in_rect(self, roi_idx, x1, y1, x2, y2)
            % 检查ROI是否有任何点位于矩形区域内
            contour = self.roi_contours{roi_idx};

            % 检查是否有任何轮廓点在矩形内
            any_point_in = any(contour(:,1) >= x1 & contour(:,1) <= x2 & ...
                contour(:,2) >= y1 & contour(:,2) <= y2);

            % 如果有任何点在矩形内，返回true
            is_in = any_point_in;
        end
    end

    % ROI Management Methods
    methods
        function selecting_roi = select_roi(self, x, y)
            self.selected_roi_idx = 0;
            selecting_roi = false;
            for i = 1:length(self.roi_contours)
                if inpolygon(x, y, self.roi_contours{i}(:,1), self.roi_contours{i}(:,2))
                    self.selected_roi_idx = i;
                    for ax_idx = 1:length(self.axes_list)
                        set(self.roi_patches{ax_idx}{i}, 'EdgeColor', self.selected_roi_color, 'LineWidth', 2);
                    end
                    selecting_roi = true;
                else
                    for ax_idx = 1:length(self.axes_list)
                        set(self.roi_patches{ax_idx}{i}, 'EdgeColor', self.roi_colors{i}, 'LineWidth', 1);
                    end
                end
            end

            % 如果启用了拖拽模式且选中了ROI，则设置拖拽起始点和状态
            if selecting_roi && self.drag_enabled
                self.is_dragging = true;
                self.drag_start_x = x;
                self.drag_start_y = y;
                % 如果启用了拖拽模式但未选中ROI，可以拖动全部ROI
            elseif self.drag_enabled && ~isempty(self.roi_contours)
                self.is_dragging = true;
                self.drag_start_x = x;
                self.drag_start_y = y;
            end
        end

        function delete_roi(self, x, y)
            idx = 0;
            for i = 1:length(self.roi_contours)
                if inpolygon(x, y, self.roi_contours{i}(:,1), self.roi_contours{i}(:,2))
                    idx = i;
                    break;
                end
            end
            if idx > 0
                for ax_idx = 1:length(self.axes_list)
                    delete(self.roi_patches{ax_idx}{idx});
                    if length(self.roi_numbers{ax_idx}) >= idx && ...
                            ~isempty(self.roi_numbers{ax_idx}{idx}) && ...
                            isvalid(self.roi_numbers{ax_idx}{idx})
                        delete(self.roi_numbers{ax_idx}{idx});
                    end
                end
                self.roi_contours(idx) = [];
                self.original_roi_contours(idx) = [];
                self.roi_colors(idx) = []; % 删除对应ROI的颜色
                for ax_idx = 1:length(self.axes_list)
                    self.roi_patches{ax_idx}(idx) = [];
                    if ~isempty(self.roi_numbers{ax_idx})
                        self.roi_numbers{ax_idx}(idx) = [];
                    end
                end
                self.update_roi_numbers();
                self.selected_roi_idx = 0;
                labeled_mask = self.labeled_mask;
                binary_mask = labeled_mask > 0;
                if isprop(self.app, 'ROIsEditField')
                    self.app.ROIsEditField.Value = numel(unique(labeled_mask))-1;
                end
                if isprop(self.app, 'ROIRatioEditField')
                    self.app.ROIRatioEditField.Value =   mean(binary_mask(:));
                end
            end
        end

        function delete_selected_roi(self)
            if self.selected_roi_idx > 0
                for ax_idx = 1:length(self.axes_list)
                    delete(self.roi_patches{ax_idx}{self.selected_roi_idx});
                    if length(self.roi_numbers{ax_idx}) >= self.selected_roi_idx && ...
                            ~isempty(self.roi_numbers{ax_idx}{self.selected_roi_idx}) && ...
                            isvalid(self.roi_numbers{ax_idx}{self.selected_roi_idx})
                        delete(self.roi_numbers{ax_idx}{self.selected_roi_idx});
                    end
                end
                self.roi_contours(self.selected_roi_idx) = [];
                self.original_roi_contours(self.selected_roi_idx) = [];
                self.roi_colors(self.selected_roi_idx) = []; % 删除对应ROI的颜色
                for ax_idx = 1:length(self.axes_list)
                    self.roi_patches{ax_idx}(self.selected_roi_idx) = [];
                    if ~isempty(self.roi_numbers{ax_idx})
                        self.roi_numbers{ax_idx}(self.selected_roi_idx) = [];
                    end
                end
                self.update_roi_numbers();
                self.selected_roi_idx = 0;
                labeled_mask = self.labeled_mask;
                binary_mask = labeled_mask > 0;
                if isprop(self.app, 'ROIsEditField')
                    self.app.ROIsEditField.Value = numel(unique(labeled_mask))-1;
                end
                if isprop(self.app, 'ROIRatioEditField')
                    self.app.ROIRatioEditField.Value =   mean(binary_mask(:));
                end
            end
        end

        function move_roi(self, dx, dy)
            if self.selected_roi_idx > 0
                self.roi_contours{self.selected_roi_idx} = ...
                    self.roi_contours{self.selected_roi_idx} + [dx, dy];
                for ax_idx = 1:length(self.axes_list)
                    set(self.roi_patches{ax_idx}{self.selected_roi_idx}, ...
                        'XData', self.roi_contours{self.selected_roi_idx}(:,1), ...
                        'YData', self.roi_contours{self.selected_roi_idx}(:,2));
                    if length(self.roi_numbers{ax_idx}) >= self.selected_roi_idx && ...
                            ~isempty(self.roi_numbers{ax_idx}{self.selected_roi_idx}) && ...
                            isvalid(self.roi_numbers{ax_idx}{self.selected_roi_idx})
                        center = mean(self.roi_contours{self.selected_roi_idx}, 1);
                        set(self.roi_numbers{ax_idx}{self.selected_roi_idx}, 'Position', [center(1), center(2), 0]);
                    end
                end
            else
                for i = 1:length(self.roi_contours)
                    self.roi_contours{i} = self.roi_contours{i} + [dx, dy];
                    for ax_idx = 1:length(self.axes_list)
                        set(self.roi_patches{ax_idx}{i}, ...
                            'XData', self.roi_contours{i}(:,1), ...
                            'YData', self.roi_contours{i}(:,2));
                        if length(self.roi_numbers{ax_idx}) >= i && ...
                                ~isempty(self.roi_numbers{ax_idx}{i}) && ...
                                isvalid(self.roi_numbers{ax_idx}{i})
                            center = mean(self.roi_contours{i}, 1);
                            set(self.roi_numbers{ax_idx}{i}, 'Position', [center(1), center(2), 0]);
                        end
                    end
                end
            end

            labeled_mask = self.labeled_mask;
            binary_mask = labeled_mask > 0;
            if isprop(self.app, 'ROIsEditField')
                self.app.ROIsEditField.Value = numel(unique(labeled_mask))-1;
            end
            if isprop(self.app, 'ROIRatioEditField')
                self.app.ROIRatioEditField.Value =   mean(binary_mask(:));
            end
        end

        function move_selected_roi(self, dx, dy)
            if self.selected_roi_idx > 0
                self.roi_contours{self.selected_roi_idx} = ...
                    self.roi_contours{self.selected_roi_idx} + [dx, dy];
                for ax_idx = 1:length(self.axes_list)
                    set(self.roi_patches{ax_idx}{self.selected_roi_idx}, ...
                        'XData', self.roi_contours{self.selected_roi_idx}(:,1), ...
                        'YData', self.roi_contours{self.selected_roi_idx}(:,2));
                    if length(self.roi_numbers{ax_idx}) >= self.selected_roi_idx && ...
                            ~isempty(self.roi_numbers{ax_idx}{self.selected_roi_idx}) && ...
                            isvalid(self.roi_numbers{ax_idx}{self.selected_roi_idx})
                        center = mean(self.roi_contours{self.selected_roi_idx}, 1);
                        set(self.roi_numbers{ax_idx}{self.selected_roi_idx}, 'Position', [center(1), center(2), 0]);
                    end
                end
            end
        end

        function clear_all_rois(self)
            if self.is_adding_regular_roi()
                self.cancel_adding_regular_roi()
            end
            for ax_idx = 1:length(self.axes_list)
                for i = 1:length(self.roi_patches{ax_idx})
                    if isvalid(self.roi_patches{ax_idx}{i})
                        delete(self.roi_patches{ax_idx}{i});
                    end
                end
            end
            self.hide_roi_numbers();
            self.roi_contours = {};
            self.roi_patches = cell(1, length(self.axes_list));
            self.roi_numbers = cell(1, length(self.axes_list));
            self.original_roi_contours = {};
            self.roi_colors = {}; % 清空ROI颜色数组
            self.selected_roi_idx = 0;
            if isprop(self.app, 'ROIsEditField')
                self.app.ROIsEditField.Value = 0;
            end
            if isprop(self.app, 'ROIRatioEditField')
                self.app.ROIRatioEditField.Value =  0;
            end
            self.color_index = 1; % 重置颜色索引
        end

        function add_roi(self, contour)
            current_level = self.dilate_level;

            % 添加ROI轮廓
            self.roi_contours{end+1} = contour;
            self.original_roi_contours{end+1} = contour;

            % 为新的ROI设置颜色并存储
            roi_color = self.get_current_roi_color();
            self.roi_colors{end+1} = roi_color;

            % 更新ROI图形对象和计数
            self.update_roi_patches();

            % 如果启用了ROI编号显示，更新编号
            if self.showRoiNumber
                self.update_roi_numbers();
            end

            % 如果有膨胀/收缩设置，应用到新ROI
            if current_level ~= 0
                self.dilate_single_roi(length(self.roi_contours), current_level);
            end
        end
        function dilate_single_roi(self, roi_idx, level)
            if roi_idx < 1 || roi_idx > length(self.original_roi_contours)
                return;
            end
        
            original_contour = self.original_roi_contours{roi_idx};
        
            if level == 0
                self.roi_contours{roi_idx} = original_contour;
            else
                % 计算ROI的质心
                centroid = mean(original_contour, 1);
                
                % 计算每个点到质心的距离和方向
                vectors = original_contour - centroid;
                distances = sqrt(sum(vectors.^2, 2));
                
                % 避免除零错误
                valid_points = distances > 0;
                
                % 初始化新的轮廓
                dilated_contour = original_contour;
                
                if any(valid_points)
                    % 计算单位方向向量
                    unit_vectors = zeros(size(vectors));
                    unit_vectors(valid_points, :) = vectors(valid_points, :) ./ distances(valid_points);
                    
                    % 沿着方向向量扩展固定像素距离
                    % level 为正数时向外扩展，负数时向内收缩
                    dilated_contour = original_contour + unit_vectors * level;
                    
                    % 对于距离质心太近的点（收缩时可能出现问题），做特殊处理
                    if level < 0
                        % 收缩时，确保不会收缩到质心内部太多
                        min_distance = abs(level);
                        too_close = distances < min_distance;
                        if any(too_close)
                            % 对于太近的点，只收缩到质心附近
                            dilated_contour(too_close, :) = centroid + unit_vectors(too_close, :) * 0.5;
                        end
                    end
                end
                
                % 确保扩展后的轮廓在图像边界内
                dilated_contour(:,1) = max(1, min(dilated_contour(:,1), self.mask_size(2)));
                dilated_contour(:,2) = max(1, min(dilated_contour(:,2), self.mask_size(1)));
                
                self.roi_contours{roi_idx} = dilated_contour;
            end
        
            % 更新显示
            for ax_idx = 1:length(self.axes_list)
                if roi_idx <= length(self.roi_patches{ax_idx}) && isvalid(self.roi_patches{ax_idx}{roi_idx})
                    set(self.roi_patches{ax_idx}{roi_idx}, 'XData', self.roi_contours{roi_idx}(:,1), ...
                        'YData', self.roi_contours{roi_idx}(:,2));
                    if length(self.roi_numbers{ax_idx}) >= roi_idx && ~isempty(self.roi_numbers{ax_idx}{roi_idx}) && isvalid(self.roi_numbers{ax_idx}{roi_idx})
                        center = mean(self.roi_contours{roi_idx}, 1);
                        set(self.roi_numbers{ax_idx}{roi_idx}, 'Position', [center(1), center(2), 0]);
                    end
                end
            end
        end
        function dilate_roi(self, level)
            if isempty(self.original_roi_contours)
                return
            end
            self.dilate_level = level;
            for i = 1:length(self.original_roi_contours)
                self.dilate_single_roi(i, level);
            end
            if isprop(self.app, 'ROIRatioEditField')
                self.app.ROIRatioEditField.Value =   mean(self.app.DrawROI.binary_mask(:));
            end
        end

        function reorder_rois(self)
            if isempty(self.roi_contours)
                return
            end
            centers = zeros(length(self.roi_contours), 2);
            for i = 1:length(self.roi_contours)
                x = self.roi_contours{i}(:,1);
                y = self.roi_contours{i}(:,2);
                centers(i,:) = [mean(x), mean(y)];
            end
            [~, y_order] = sort(centers(:,2));
            new_order = [];
            y_values = centers(y_order,2);
            unique_y = unique(round(y_values/20)*20);
            for i = 1:length(unique_y)
                row_indices = find(abs(y_values - unique_y(i)) < 20);
                if ~isempty(row_indices)
                    row = y_order(row_indices);
                    [~, x_order] = sort(centers(row,1));
                    new_order = [new_order; row(x_order)];
                end
            end
            if length(new_order) ~= length(self.roi_contours)
                new_order = y_order;
            end
            old_roi_contours = self.roi_contours;
            old_roi_patches = self.roi_patches;
            old_roi_colors = self.roi_colors;
            for ax_idx = 1:length(self.axes_list)
                self.roi_patches{ax_idx} = old_roi_patches{ax_idx}(new_order);
            end
            self.roi_contours = old_roi_contours(new_order);
            self.roi_colors = old_roi_colors(new_order);
            if self.showRoiNumber
                self.update_roi_numbers();
            end
            if self.selected_roi_idx > 0
                for i = 1:length(new_order)
                    if new_order(i) == self.selected_roi_idx
                        self.selected_roi_idx = i;
                        for ax_idx = 1:length(self.axes_list)
                            set(self.roi_patches{ax_idx}{i}, 'EdgeColor', self.selected_roi_color, 'LineWidth', 2);
                        end
                        break;
                    end
                end
            end
        end

        function set.showRoiNumber(self, value)
            self.showRoiNumber = value;
            if value
                self.show_roi_numbers();
            else
                self.hide_roi_numbers();
            end
        end

        function set.roi_number_fontSize(self, value)
            self.roi_number_fontSize = value;
            if self.showRoiNumber && ~isempty(self.roi_numbers{1})
                for ax_idx = 1:length(self.axes_list)
                    for i = 1:length(self.roi_numbers{ax_idx})
                        if ~isempty(self.roi_numbers{ax_idx}{i}) && isvalid(self.roi_numbers{ax_idx}{i})
                            set(self.roi_numbers{ax_idx}{i}, 'FontSize', value);
                        end
                    end
                end
            end
        end

        function set.roi_number_fontColor(self, value)
            self.roi_number_fontColor = value;
            if self.showRoiNumber && ~isempty(self.roi_numbers{1})
                for ax_idx = 1:length(self.axes_list)
                    for i = 1:length(self.roi_numbers{ax_idx})
                        if ~isempty(self.roi_numbers{ax_idx}{i}) && isvalid(self.roi_numbers{ax_idx}{i})
                            set(self.roi_numbers{ax_idx}{i}, 'Color', value);
                        end
                    end
                end
            end
        end

        function show_roi_numbers(self)
            self.hide_roi_numbers();
            for i = 1:length(self.roi_contours)
                center = mean(self.roi_contours{i}, 1);
                for ax_idx = 1:length(self.axes_list)
                    self.roi_numbers{ax_idx}{i} = text(self.axes_list(ax_idx), center(1), center(2), num2str(i), ...
                        'Color', self.roi_number_fontColor , 'FontWeight', 'bold', 'FontUnits','points',...
                        'FontSize', self.roi_number_fontSize, ...
                        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle','Clipping','on');

                    % 根据当前可见性设置
                    if ~self.roi_visibility(ax_idx)
                        set(self.roi_numbers{ax_idx}{i}, 'Visible', 'off');
                    end
                end
            end
        end

        function update_roi_numbers(self)
            if self.showRoiNumber
                self.show_roi_numbers();
            end
        end

        function hide_roi_numbers(self)
            for ax_idx = 1:length(self.axes_list)
                for i = 1:length(self.roi_numbers{ax_idx})
                    if ~isempty(self.roi_numbers{ax_idx}{i}) && isvalid(self.roi_numbers{ax_idx}{i})
                        delete(self.roi_numbers{ax_idx}{i});
                    end
                end
                self.roi_numbers{ax_idx} = {};
            end
        end

        % 拖拽ROI相关方法
        function start_drag(self, x, y)
            if self.drag_enabled
                self.is_dragging = true;
                self.drag_start_x = x;
                self.drag_start_y = y;
            end
        end

        function drag_move(self, x, y)
            if self.is_dragging
                dx = x - self.drag_start_x;
                dy = y - self.drag_start_y;
                if dx ~= 0 || dy ~= 0
                    self.move_roi(dx, dy);
                    self.drag_start_x = x;
                    self.drag_start_y = y;
                end
            end
        end

        function stop_drag(self)
            self.is_dragging = false;
        end

        % 设置拖拽模式
        function set_drag_mode(self, enabled)
            self.drag_enabled = enabled;
            % 如果禁用拖拽模式，同时确保停止当前拖拽
            if ~enabled
                self.is_dragging = false;
            else
                % 如果启用拖拽模式，并且当前正在编辑ROI，则取消编辑
                if self.editing_roi
                    self.cancel_edit_roi();
                end
            end
        end

        % 获取当前拖拽状态
        function dragging = is_drag_active(self)
            dragging = self.is_dragging;
        end

        function load_roi_file(self, filepath)
            % Load ROI mask from various file formats
            [~, ~, ext] = fileparts(filepath);
            switch ext
                case {'.csv', '.txt', '.xlsx'}
                    % Load mask from text file
                    mask = table2array(readtable(filepath));
                    if length(unique(mask)) == 2
                        mask = logical(mask);
                    end
                    self.load_from_mask(mask);

                case {'.png', '.jpg', '.jpeg', '.tif', '.tiff'}
                    % Load mask from image file
                    imMask = imread(filepath);
                    dims = ndims(imMask);
                    if dims == 2
                        % Gray image
                        mask = single(imMask);
                        if length(unique(mask)) == 2
                            % Binary image
                            mask = logical(mask);
                        end
                    else
                        % RGB image
                        mask = logical(rgb2gray(imMask));
                    end
                    self.load_from_mask(mask);

                case {'.mat'}
                    % Load variable from .mat file
                    loaded_data = load(filepath);
                    if isfield(loaded_data, 'roi_contours') && iscell(loaded_data.roi_contours)
                        self.clear_all_rois();
                        if isfield(loaded_data, 'original_roi_contours') && iscell(loaded_data.original_roi_contours)
                            self.original_roi_contours = loaded_data.original_roi_contours;
                        else
                            self.original_roi_contours = loaded_data.roi_contours;
                        end
                        for i = 1:length(loaded_data.roi_contours)
                            old_dilate = self.dilate_level;
                            self.dilate_level = 0;
                            self.roi_contours{end+1} = loaded_data.roi_contours{i};
                            self.update_roi_patches();
                            self.dilate_level = old_dilate;
                        end
                        if isfield(loaded_data, 'dilate_level')
                            app.DilateSpinner.Value = loaded_data.dilate_level;
                            self.dilate_level = loaded_data.dilate_level;
                            if loaded_data.dilate_level ~= 0
                                self.dilate_roi(loaded_data.dilate_level);
                            end
                        end
                    end
                case '.zip'
                    % Load ROI zip from ImageJ
                    try
                        rois = ReadImageJROI(filepath);
                        regions = ROIs2Regions(rois, self.mask_size);
                        mask = double(labelmatrix(regions)');
                        self.load_from_mask(mask);
                    catch ME
                        errordlg(strcat('Error loading ImageJ ROIs: ', ME.message), 'Error');
                        disp(ME.getReport('extended'));
                    end
            end

            % 更新 ROI 数目显示
            labeled_mask = self.labeled_mask;
            binary_mask = labeled_mask > 0;
            if isprop(self.app, 'ROIsEditField')
                self.app.ROIsEditField.Value = numel(unique(labeled_mask))-1;
            end
            if isprop(self.app, 'ROIRatioEditField')
                self.app.ROIRatioEditField.Value =   mean(binary_mask(:));
            end
        end

        function load_from_mask(self, mask)
            % Convert labeled mask to ROI contours
            self.clear_all_rois();
            self.mask_size = size(mask);

            % 如果是二值掩码，转换为标签掩码
            if islogical(mask)
                [labeled_mask, num_regions] = bwlabel(mask);
            else
                labeled_mask = mask;
                num_regions = max(labeled_mask(:));
            end

            % 提取每个 ROI 的轮廓
            for i = 1:num_regions
                roi_mask = labeled_mask == i;
                [B, ~] = bwboundaries(roi_mask, 'noholes');
                if ~isempty(B)
                    boundary = B{1};
                    contour = [boundary(:, 2), boundary(:, 1)];
                    self.add_roi(contour);
                end
            end

            % 更新 ROI 编号显示
            if self.showRoiNumber
                self.show_roi_numbers();
            end

            disp(['Loaded ' num2str(num_regions) ' ROIs from mask.']);
        end
    end

    % Visualization Methods
    methods
        function update_roi_patches(self)
            % 更新最新的roi
            idx = length(self.roi_contours);
            for ax_idx = 1:length(self.axes_list)
                if isempty(self.roi_patches{ax_idx})
                    hold(self.axes_list(ax_idx), 'on');
                end



                % 获取当前ROI的颜色
                if idx <= length(self.roi_colors) && ~isempty(self.roi_colors{idx})
                    roi_color = self.roi_colors{idx};
                else
                    roi_color = self.get_current_roi_color();
                    self.roi_colors{idx} = roi_color;
                end

                % 设置背景色
                face_color = 'none';
                face_alpha = 0;
                if self.show_background
                    face_color = roi_color;
                    face_alpha = self.mask_opacity;
                end



                % 创建新的patch对象
                self.roi_patches{ax_idx}{idx} = patch(self.axes_list(ax_idx), ...
                    self.roi_contours{idx}(:,1), self.roi_contours{idx}(:,2), ...
                    'y', 'FaceColor', face_color, 'EdgeColor', roi_color, ...
                    'LineWidth', 1, 'FaceAlpha', face_alpha);

                % 避免自动变为 'auto' 模式
                self.axes_list(ax_idx).YLimMode = 'manual';
                self.axes_list(ax_idx).XLimMode = 'manual';

                % 根据当前可见性设置
                if ~self.roi_visibility(ax_idx)
                    set(self.roi_patches{ax_idx}{idx}, 'Visible', 'off');
                end


            end

            % 更新ROI计数显示
            labeled_mask = self.labeled_mask;
            binary_mask = labeled_mask > 0;
            if isprop(self.app, 'ROIsEditField')
                self.app.ROIsEditField.Value = numel(unique(labeled_mask))-1;
            end
            if isprop(self.app, 'ROIRatioEditField')
                self.app.ROIRatioEditField.Value =   mean(binary_mask(:));
            end
            % 如果启用了ROI编号显示，为新的ROI添加编号
            if self.showRoiNumber
                center = mean(self.roi_contours{idx}, 1);
                for ax_idx = 1:length(self.axes_list)


                    self.roi_numbers{ax_idx}{idx} = text(self.axes_list(ax_idx), center(1), center(2), num2str(idx), ...
                        'Color', self.roi_number_fontColor, 'FontWeight', 'bold', 'FontUnits','points',...
                        'FontSize', self.roi_number_fontSize, ...
                        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle','Clipping','on');

                    % 根据当前可见性设置
                    if ~self.roi_visibility(ax_idx)
                        set(self.roi_numbers{ax_idx}{idx}, 'Visible', 'off');
                    end
                end
            end
        end

        function update_all_roi_patches(self)
            % 更新所有的ROI patches

            % 先清除现有的所有ROI patches和numbers
            for ax_idx = 1:length(self.axes_list)
                for i = 1:length(self.roi_patches{ax_idx})
                    if ~isempty(self.roi_patches{ax_idx}{i}) && isvalid(self.roi_patches{ax_idx}{i})
                        delete(self.roi_patches{ax_idx}{i});
                    end
                end
                self.roi_patches{ax_idx} = {};

                if self.showRoiNumber
                    for i = 1:length(self.roi_numbers{ax_idx})
                        if ~isempty(self.roi_numbers{ax_idx}{i}) && isvalid(self.roi_numbers{ax_idx}{i})
                            delete(self.roi_numbers{ax_idx}{i});
                        end
                    end
                    self.roi_numbers{ax_idx} = {};
                end

                % 确保图表处于hold状态
                hold(self.axes_list(ax_idx), 'on');
            end

            % 重新绘制所有ROI patches
            for roi_idx = 1:length(self.roi_contours)
                % 确保有足够的颜色记录
                if roi_idx > length(self.roi_colors)
                    self.roi_colors{roi_idx} = self.get_current_roi_color();
                end

                for ax_idx = 1:length(self.axes_list)
                    % 使用ROI的存储颜色
                    roi_color = self.roi_colors{roi_idx};

                    % 设置背景色
                    face_color = 'none';
                    face_alpha = 0;
                    if self.show_background
                        face_color = roi_color;
                        face_alpha = self.mask_opacity;
                    end

                    self.roi_patches{ax_idx}{roi_idx} = patch(self.axes_list(ax_idx), ...
                        self.roi_contours{roi_idx}(:,1), self.roi_contours{roi_idx}(:,2), ...
                        'y', 'FaceColor', face_color, 'EdgeColor', roi_color, ...
                        'LineWidth', 1, 'FaceAlpha', face_alpha);

                    % 避免自动变为 'auto' 模式
                    self.axes_list(ax_idx).YLimMode = 'manual';
                    self.axes_list(ax_idx).XLimMode = 'manual';

                    % 根据当前可见性设置
                    if ~self.roi_visibility(ax_idx)
                        set(self.roi_patches{ax_idx}{roi_idx}, 'Visible', 'off');
                    end

                    % 如果是被选中的ROI，设置高亮
                    if roi_idx == self.selected_roi_idx
                        set(self.roi_patches{ax_idx}{roi_idx}, 'EdgeColor', self.selected_roi_color, 'LineWidth', 2);
                    end
                end

                % 更新ROI编号显示
                if self.showRoiNumber
                    center = mean(self.roi_contours{roi_idx}, 1);
                    for ax_idx = 1:length(self.axes_list)
                        self.roi_numbers{ax_idx}{roi_idx} = text(self.axes_list(ax_idx), center(1), center(2), num2str(roi_idx), ...
                            'Color', self.roi_number_fontColor , 'FontWeight', 'bold', 'FontUnits','points',...
                            'FontSize', self.roi_number_fontSize, ...
                            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle','Clipping','on');

                        % 根据当前可见性设置
                        if ~self.roi_visibility(ax_idx)
                            set(self.roi_numbers{ax_idx}{roi_idx}, 'Visible', 'off');
                        end
                    end
                end
            end

            % 更新ROI数量显示
            labeled_mask = self.labeled_mask;
            binary_mask = labeled_mask > 0;
            if isprop(self.app, 'ROIsEditField')
                self.app.ROIsEditField.Value = numel(unique(labeled_mask))-1;
            end
            if isprop(self.app, 'ROIRatioEditField')
                self.app.ROIRatioEditField.Value =   mean(binary_mask(:));
            end
        end

        function update_roi_color(self)
            % 仅更新所有ROI的颜色（边缘和编号），不改变其他属性

            % 如果使用相同颜色且不是随机模式，确保roi_colors数组使用正确的颜色
            if ~self.use_random_color
                for i = 1:length(self.roi_contours)
                    self.roi_colors{i} = self.mask_color;
                end
            end

            % 更新每个ROI的边缘颜色
            for roi_idx = 1:length(self.roi_contours)
                for ax_idx = 1:length(self.axes_list)
                    if roi_idx <= length(self.roi_patches{ax_idx}) && ~isempty(self.roi_patches{ax_idx}{roi_idx}) && isvalid(self.roi_patches{ax_idx}{roi_idx})
                        % 设置颜色：如果是选中的ROI，使用高亮颜色；否则使用ROI存储的颜色
                        if roi_idx == self.selected_roi_idx
                            edge_color = self.selected_roi_color;
                            set(self.roi_patches{ax_idx}{roi_idx}, 'EdgeColor', edge_color);
                        else
                            edge_color = self.roi_colors{roi_idx};
                            set(self.roi_patches{ax_idx}{roi_idx}, 'EdgeColor', edge_color);
                        end

                        % 更新背景色
                        if self.show_background
                            set(self.roi_patches{ax_idx}{roi_idx}, 'FaceColor', edge_color, 'FaceAlpha', self.mask_opacity);
                        else
                            set(self.roi_patches{ax_idx}{roi_idx}, 'FaceColor', 'none');
                        end
                    end
                end
            end

            % 如果启用了ROI编号显示，更新每个编号的颜色
            if self.showRoiNumber
                for ax_idx = 1:length(self.axes_list)
                    for roi_idx = 1:length(self.roi_numbers{ax_idx})
                        if ~isempty(self.roi_numbers{ax_idx}{roi_idx}) && isvalid(self.roi_numbers{ax_idx}{roi_idx})
                            set(self.roi_numbers{ax_idx}{roi_idx}, 'Color', self.roi_number_fontColor , 'FontSize', self.roi_number_fontSize);
                        end
                    end
                end
            end
        end

        function labeled_mask = generate_labeled_mask(self)
            labeled_mask = zeros(self.mask_size);
            for i = 1:length(self.roi_contours)
                roi_mask = poly2mask(self.roi_contours{i}(:,1), self.roi_contours{i}(:,2), ...
                    self.mask_size(1), self.mask_size(2));
                labeled_mask(roi_mask) = i;
            end
        end
        function labeled_mask = get.labeled_mask(self)
            labeled_mask = zeros(self.mask_size);
            for i = 1:length(self.roi_contours)
                roi_mask = poly2mask(self.roi_contours{i}(:,1), self.roi_contours{i}(:,2), ...
                    self.mask_size(1), self.mask_size(2));
                labeled_mask(roi_mask) = i;
            end
        end
        function binary_mask = get.binary_mask(self)
            % 生成二值掩码
            binary_mask = zeros(self.mask_size);
            for i = 1:length(self.roi_contours)
                roi_mask = poly2mask(self.roi_contours{i}(:,1), self.roi_contours{i}(:,2), ...
                    self.mask_size(1), self.mask_size(2));
                binary_mask(roi_mask) = 1;
            end
        end
    end

    % ROI 编辑相关方法
    methods
        function start_edit_roi(self, x, y)
            % 如果已经在编辑ROI，先结束编辑
            if self.editing_roi
                self.finish_edit_roi(true);
                return;
            end

            % 如果当前处于拖拽模式，不允许编辑ROI
            if self.drag_enabled
                return;
            end
            self.temp_dilate_level = self.dilate_level;
            if self.temp_dilate_level ~= 0
                self.dilate_roi(0);
            end
            % 检查点击位置是否在某个ROI内
            for i = 1:length(self.roi_contours)
                if inpolygon(x, y, self.roi_contours{i}(:,1), self.roi_contours{i}(:,2))
                    self.editing_roi_idx = i;
                    self.editing_roi = true;

                    % 只隐藏当前活动轴上的ROI patch对象
                    if ~isempty(self.roi_patches{self.active_axes_index}{i}) && isvalid(self.roi_patches{self.active_axes_index}{i})
                        set(self.roi_patches{self.active_axes_index}{i}, 'Visible', 'off');
                    end

                    % 获取当前ROI的颜色
                    roi_color = self.roi_colors{i};

                    % 在活动轴上创建Freehand ROI对象，使用相同的颜色设置
                    ax = self.axes_list(self.active_axes_index);
                    position = self.roi_contours{i};
                    self.freehand_roi = images.roi.Freehand(ax, 'Position', position, 'Color', roi_color, 'LineWidth', 2);



                    % 设置轴状态为正在编辑ROI
                    ax.UserData.status = "roi_editing";

                    break;
                end
            end

        end

        function finish_edit_roi(self, apply_changes)
            if ~self.editing_roi || isempty(self.freehand_roi) || ~isvalid(self.freehand_roi)
                return;
            end

            if apply_changes
                % 获取修改后的ROI边界
                new_position = self.freehand_roi.Position;

                % 更新ROI轮廓
                self.roi_contours{self.editing_roi_idx} = new_position;
                self.original_roi_contours{self.editing_roi_idx} = new_position;

                % 如果有扩展/收缩，重新应用
                if self.dilate_level ~= 0
                    self.dilate_single_roi(self.editing_roi_idx, self.dilate_level);
                end

                % 更新所有轴上的显示
                for ax_idx = 1:length(self.axes_list)
                    if ~isempty(self.roi_patches{ax_idx}{self.editing_roi_idx}) && isvalid(self.roi_patches{ax_idx}{self.editing_roi_idx})
                        set(self.roi_patches{ax_idx}{self.editing_roi_idx}, ...
                            'XData', self.roi_contours{self.editing_roi_idx}(:,1), ...
                            'YData', self.roi_contours{self.editing_roi_idx}(:,2), ...
                            'Visible', 'on');
                    end

                    % 更新ROI编号位置（如果存在）
                    if length(self.roi_numbers{ax_idx}) >= self.editing_roi_idx && ...
                            ~isempty(self.roi_numbers{ax_idx}{self.editing_roi_idx}) && ...
                            isvalid(self.roi_numbers{ax_idx}{self.editing_roi_idx})
                        center = mean(self.roi_contours{self.editing_roi_idx}, 1);
                        set(self.roi_numbers{ax_idx}{self.editing_roi_idx}, ...
                            'Position', [center(1), center(2), 0], ...
                            'Visible', self.showRoiNumber && self.roi_visibility(ax_idx));
                    end
                end
            else
                % 不应用变更，仅恢复显示
                for ax_idx = 1:length(self.axes_list)
                    if ~isempty(self.roi_patches{ax_idx}{self.editing_roi_idx}) && isvalid(self.roi_patches{ax_idx}{self.editing_roi_idx})
                        set(self.roi_patches{ax_idx}{self.editing_roi_idx}, 'Visible', 'on');
                    end

                    % 恢复ROI编号显示（如果存在）
                    if length(self.roi_numbers{ax_idx}) >= self.editing_roi_idx && ...
                            ~isempty(self.roi_numbers{ax_idx}{self.editing_roi_idx}) && ...
                            isvalid(self.roi_numbers{ax_idx}{self.editing_roi_idx})
                        set(self.roi_numbers{ax_idx}{self.editing_roi_idx}, ...
                            'Visible', self.showRoiNumber && self.roi_visibility(ax_idx));
                    end
                end
            end

            % 删除Freehand对象
            if ~isempty(self.freehand_roi) && isvalid(self.freehand_roi)
                delete(self.freehand_roi);
            end
            self.freehand_roi = [];

            % 重置编辑状态
            self.editing_roi = false;

            % 恢复轴状态为空闲
            self.axes_list(self.active_axes_index).UserData.status = "idle";
            if self.temp_dilate_level ~= 0
                self.dilate_roi(self.temp_dilate_level);
                self.temp_dilate_level = 0;
            end
        end

        function cancel_edit_roi(self)
            self.finish_edit_roi(false);
        end

        function is_editing = is_roi_editing(self)
            is_editing = self.editing_roi;
        end
    end
end