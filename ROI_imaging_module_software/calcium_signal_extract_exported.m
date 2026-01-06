classdef calcium_signal_extract_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        FileMenu                      matlab.ui.container.Menu
        LoadConfigMenu                matlab.ui.container.Menu
        SaveConfigMenu                matlab.ui.container.Menu
        SettingMenu                   matlab.ui.container.Menu
        MaskSettingsMenu              matlab.ui.container.Menu
        ContrastSlider                matlab.ui.control.RangeSlider
        ContrastSlider_2Label         matlab.ui.control.Label
        ContrastSlider_2              matlab.ui.control.RangeSlider
        ContrastSliderLabel_2         matlab.ui.control.Label
        neddrewriteCheckBox           matlab.ui.control.CheckBox
        SyncUIaxes1                   matlab.ui.control.Button
        SyncUIaxes2                   matlab.ui.control.Button
        MaskSettingsButton            matlab.ui.control.Button
        ROIIDLabel_2                  matlab.ui.control.Label
        SaveButton                    matlab.ui.control.Button
        windowsEditField              matlab.ui.control.NumericEditField
        windowsEditFieldLabel         matlab.ui.control.Label
        smoothCheckBox                matlab.ui.control.CheckBox
        LoadButton                    matlab.ui.control.Button
        ShowROINumbersCheckBox        matlab.ui.control.CheckBox
        DragROIsButton                matlab.ui.control.StateButton
        UIAxesHomeButton_2            matlab.ui.control.Button
        MeasureButton                 matlab.ui.control.Button
        DiameterSpinner               matlab.ui.control.Spinner
        DiameterSpinnerLabel          matlab.ui.control.Label
        ManualRegButton               matlab.ui.control.Button
        Spinner                       matlab.ui.control.Spinner
        Button_2                      matlab.ui.control.Button
        Button                        matlab.ui.control.Button
        OnlyPlotButton                matlab.ui.control.Button
        XLimsEditField_2              matlab.ui.control.EditField
        XLimsEditField_2Label         matlab.ui.control.Label
        EventRangesEditField          matlab.ui.control.EditField
        EventRangesEditFieldLabel     matlab.ui.control.Label
        sortCheckBox                  matlab.ui.control.CheckBox
        ROIintervalSpinner            matlab.ui.control.Spinner
        ROIintervalSpinnerLabel       matlab.ui.control.Label
        F0BaselinecorrectionCheckBox  matlab.ui.control.CheckBox
        F0Label                       matlab.ui.control.Label
        BeforeeventEditFieldLabel_2   matlab.ui.control.Label
        ROILabel                      matlab.ui.control.Label
        ColormapColorDropDown         matlab.ui.control.DropDown
        ColorDropDown_2Label          matlab.ui.control.Label
        PlotHeatemapLabel             matlab.ui.control.Label
        PlotTraceLabel                matlab.ui.control.Label
        AverageEditField              matlab.ui.control.EditField
        AverageEditFieldLabel         matlab.ui.control.Label
        F0TypeEventCheckBox           matlab.ui.control.CheckBox
        SignalLabel                   matlab.ui.control.Label
        UseZProjectionButton          matlab.ui.control.Button
        AlphaSpinner                  matlab.ui.control.Spinner
        useNormalF0CheckBox           matlab.ui.control.CheckBox
        EventLabel                    matlab.ui.control.Label
        showrefImageCheckBox          matlab.ui.control.CheckBox
        FramesEditField               matlab.ui.control.EditField
        FramesEditFieldLabel          matlab.ui.control.Label
        ZProjectionButton             matlab.ui.control.Button
        ROIPrefixLabelEditField       matlab.ui.control.EditField
        ROILabelEditFieldLabel        matlab.ui.control.Label
        EventColorEditField           matlab.ui.control.EditField
        EventColorEditFieldLabel      matlab.ui.control.Label
        EventNameEditField            matlab.ui.control.EditField
        EventNameEditFieldLabel       matlab.ui.control.Label
        XTickIntervalsEditField       matlab.ui.control.NumericEditField
        SignalTypeDropDownLabel       matlab.ui.control.Label
        XTickIntervalsEditFieldLabel  matlab.ui.control.Label
        SignalTypeDropDown            matlab.ui.control.DropDown
        ScabarTypeDropDown            matlab.ui.control.DropDown
        ScabarTypeDropDownLabel       matlab.ui.control.Label
        ReorderROIsButton             matlab.ui.control.Button
        Label_3                       matlab.ui.control.Label
        Label_2                       matlab.ui.control.Label
        F0EndEditField                matlab.ui.control.NumericEditField
        F0StartEditField              matlab.ui.control.NumericEditField
        ROIMaskLabel                  matlab.ui.control.Label
        TraceFixedColor               matlab.ui.control.EditField
        TraceColorDropDown            matlab.ui.control.DropDown
        ColorDropDownLabel            matlab.ui.control.Label
        TiffMaskCheckBox              matlab.ui.control.CheckBox
        ContrastSliderLabel           matlab.ui.control.Label
        DropDown                      matlab.ui.control.DropDown
        SelectedROIEditField          matlab.ui.control.EditField
        SelectedROIEditFieldLabel     matlab.ui.control.Label
        ScalebarLabel                 matlab.ui.control.Label
        ClearROIsButton               matlab.ui.control.Button
        FrameRateEditField            matlab.ui.control.NumericEditField
        FrameRateEditFieldLabel       matlab.ui.control.Label
        TimeScalebarSpinner           matlab.ui.control.Spinner
        FF_0Label_2                   matlab.ui.control.Label
        FScalebarSpinner              matlab.ui.control.Spinner
        FF_0Label                     matlab.ui.control.Label
        filenameLabel                 matlab.ui.control.Label
        SliderLabel                   matlab.ui.control.Label
        Slider                        matlab.ui.control.Slider
        SaveAllButton                 matlab.ui.control.Button
        LoadTiffStackButton           matlab.ui.control.Button
        RunSegButton                  matlab.ui.control.Button
        ThresholdSpinner              matlab.ui.control.Spinner
        ThresholdSpinnerLabel         matlab.ui.control.Label
        ModelsDropDown                matlab.ui.control.DropDown
        ROIsEditFieldLabel            matlab.ui.control.Label
        ModelsDropDownLabel           matlab.ui.control.Label
        ROIsEditField                 matlab.ui.control.NumericEditField
        SaveROIsButton                matlab.ui.control.Button
        LoadROIsButton                matlab.ui.control.Button
        MaskOnCheckBox                matlab.ui.control.CheckBox
        MaskDropDownLabel             matlab.ui.control.Label
        ExtractsignalButton           matlab.ui.control.Button
        UIAxesHomeButton              matlab.ui.control.Button
        ImageUIAxes1                  matlab.ui.control.UIAxes
        ImageUIAxes2                  matlab.ui.control.UIAxes
    end


    properties
        dir = ''; % app当前运行路径
        % TODO 把这些tiff变量用tiff结构体数组来封装，方便查看
        last_selected_folder = '';% 上次选中的文件夹
        tiff_path =''; %tiff路径
        tiff_filename = '';
        tiff_memmap % Description
        tiff_stack_data (:,:,:);
        tiff_stack_data_adjusted (:,:,:);
        tiff_all_frames;
        tiff_current_frame = 1;
        ImageUIAxes1_image_layer;
        ImageUIAxes1_refImg_layer;
        ImageUIAxes1_refImg_layer_alphaData;
        tiff_contrast_value  = [0 400];
        tiff_seg_data;
        tiff_seh_data_autoscale_contrast logical = false;
        tiff_mean_img;
        tiff_std_img;
        tiff_max_img;
        ImageUIAxes2_image_layer;
        plot_signal_handles;


        ROIMaskSettingsApp % Description
    end
    % ROI mask
    properties (Access = public)
        DrawROI = components.DrawROI.empty; % DrawROI模块;
    end

    % extract calcium signal
    properties
        signal_raw;
        signal_delta;
        signal_zscore_delta;
        signal_raw_corrected;
        signal_bias = 2.2204e-16;
        fig_trace;
        fig_heatmap;
    end

    properties
        seg_enable;
        seg_adjust_enable;
        drawroi_enable logical = false;


        Segmentation = components.Segmentation.empty;
    end

    methods
        function config_read(app)
            text = fileread(fullfile(app.dir,'config.json'));
            config = jsondecode(text);

            if isfield(config, 'last_tiff_path')
                app.last_selected_folder = config.last_tiff_path;
            end
        end

        function config_save(app)
            config.last_tiff_path = app.last_selected_folder;
            json_data = jsonencode(config,'PrettyPrint',true);
            % disp(fullfile(app.dir,'config.json'));
            fileID = fopen(fullfile(app.dir,'config.json'), 'w');
            fprintf(fileID, "%s",json_data);
            fclose(fileID);
        end
        
        
        function windowButtonDown(app, ~, ~)
            if ~isempty(app.DrawROI)
                pt = get(app.UIFigure, 'CurrentPoint');
                pos1 = getpixelposition(app.ImageUIAxes1);
                pos2 = getpixelposition(app.ImageUIAxes2);
                if pt(1) >= pos1(1) && pt(1) <= pos1(1)+pos1(3) && pt(2) >= pos1(2) && pt(2) <= pos1(2)+pos1(4)
                    app.UIFigure.UserData.activeAxes = app.ImageUIAxes1;
                    app.DrawROI.active_axes_index = 1;  % 设置DrawROI的活动轴索引
                elseif pt(1) >= pos2(1) && pt(1) <= pos2(1)+pos2(3) && pt(2) >= pos2(2) && pt(2) <= pos2(2)+pos2(4)
                    app.UIFigure.UserData.activeAxes = app.ImageUIAxes2;
                    app.DrawROI.active_axes_index = 2;  % 设置DrawROI的活动轴索引
                else
                    return;
                end
                % 如果当前活动轴不允许绘制，并且是右键点击（开始绘制ROI的操作），则直接返回
                if ~app.DrawROI.drawing_enabled(app.DrawROI.active_axes_index) && strcmp(app.UIFigure.SelectionType, 'alt')
                    % 如果不是Ctrl+左键（用于删除ROI），则阻止操作
                    if ~app.UIFigure.UserData.CtrlPressed
                        return;
                    end
                end
                currentPosition = app.UIFigure.UserData.activeAxes.CurrentPoint;
                x = currentPosition(1,1);
                y = currentPosition(1,2);

                if x >= app.UIFigure.UserData.activeAxes.XLim(1) && x <= app.UIFigure.UserData.activeAxes.XLim(2) && ...
                        y >= app.UIFigure.UserData.activeAxes.YLim(1) && y <= app.UIFigure.UserData.activeAxes.YLim(2)

                    % 强制平移模式下，当左键点击时，进入平移状态（按空格+左键）
                    if app.UIFigure.UserData.forcePanMode && strcmp(app.UIFigure.SelectionType, 'normal')
                        app.UIFigure.UserData.activeAxes.UserData.status = "axes_paning";
                        app.UIFigure.UserData.Pan.previous_point = app.UIFigure.UserData.activeAxes.CurrentPoint;
                        return;
                    end

                    switch app.UIFigure.SelectionType
                        case 'normal' % 左键点击
                            % 可取消当前绘制
                            if strcmp(app.UIFigure.UserData.activeAxes.UserData.status, "handroi_drawing")
                                app.DrawROI.handroi_cancel();
                            end
                            app.UIFigure.UserData.CtrlPressed = false;
                            app.DrawROI.select_roi(x, y);
                            % 如果正在添加规则ROI，不进入平移模式
                            if ~app.DrawROI.is_drag_active() && ~app.DrawROI.is_roi_editing() && ~app.DrawROI.is_adding_regular_roi()
                                app.UIFigure.UserData.activeAxes.UserData.status = "axes_paning";
                                app.UIFigure.UserData.Pan.previous_point = app.UIFigure.UserData.activeAxes.CurrentPoint;
                            end
                        case 'alt' % 代表 Ctrl+ 左键，或者单击右键；
                            if app.UIFigure.UserData.CtrlPressed % Ctrl + Click 删除ROI
                                app.DrawROI.delete_roi(x, y);
                            else % 右键点击，开始绘制ROI
                                % 只有当前轴允许绘制时才开始绘制
                                if strcmp(app.UIFigure.UserData.activeAxes.UserData.status, "idle") && app.DrawROI.drawing_enabled(app.DrawROI.active_axes_index)
                                    app.DrawROI.handroi_start(x, y);
                                end
                            end
                        case 'open' % 双击鼠标左键
                            % 检查是否点击在某个ROI上，如果是，则开始编辑该ROI
                            if app.DrawROI.is_adding_regular_roi()
                                app.DrawROI.finish_adding_regular_roi(true);
                            else
                                app.DrawROI.start_edit_roi(x, y);
                            end

                        case 'extend' % 代表 Shift+ 左键、鼠标中键或左右键一起按
                            return
                    end
                end
            end
        end

        function windowMotion(app, ~, ~)
            if isempty(app.UIFigure.UserData.activeAxes)
                return;
            end
            if isempty(app.DrawROI)
                return;
            end
            % 检查鼠标是否在任一UIAxes内
            pt = get(app.UIFigure, 'CurrentPoint');
            pos1 = getpixelposition(app.ImageUIAxes1);
            pos2 = getpixelposition(app.ImageUIAxes2);

            % 判断鼠标是否在任一UIAxes内

            if pt(1) >= pos1(1) && pt(1) <= pos1(1)+pos1(3) && pt(2) >= pos1(2) && pt(2) <= pos1(2)+pos1(4)
                app.UIFigure.UserData.mouseInAxes = true;
                % 当鼠标移入UIAxes1时，自动设为活动轴
                if app.UIFigure.UserData.activeAxes ~= app.ImageUIAxes1
                    app.UIFigure.UserData.activeAxes = app.ImageUIAxes1;
                    app.DrawROI.active_axes_index = 1; % 更新DrawROI的活动轴索引
                end
            elseif pt(1) >= pos2(1) && pt(1) <= pos2(1)+pos2(3) && pt(2) >= pos2(2) && pt(2) <= pos2(2)+pos2(4)
                app.UIFigure.UserData.mouseInAxes = true;
                % 当鼠标移入UIAxes2时，自动设为活动轴
                if app.UIFigure.UserData.activeAxes ~= app.ImageUIAxes2
                    app.UIFigure.UserData.activeAxes = app.ImageUIAxes2;
                    app.DrawROI.active_axes_index = 2; % 更新DrawROI的活动轴索引
                end
            else
                app.UIFigure.UserData.mouseInAxes = false;
            end

            currentPosition = app.UIFigure.UserData.activeAxes.CurrentPoint;
            x = currentPosition(1,1);
            y = currentPosition(1,2);

            if  x >= app.UIFigure.UserData.activeAxes.XLim(1) && x <= app.UIFigure.UserData.activeAxes.XLim(2) && ...
                    y >= app.UIFigure.UserData.activeAxes.YLim(1) && y <= app.UIFigure.UserData.activeAxes.YLim(2)
                switch app.UIFigure.UserData.activeAxes.UserData.status
                    case "axes_paning"
                        % 如果正在添加ROI，则不执行平移
                        % if ~app.DrawROI.is_adding_regular_roi()
                        app.pan_move();
                        % end
                    case "handroi_drawing"
                        if ~isempty(app.DrawROI)
                            app.DrawROI.handroi_draw(x, y);
                        end
                    otherwise
                        % 使用DrawROI的拖拽方法
                        if ~isempty(app.DrawROI)
                            app.DrawROI.drag_move(x, y);
                        end
                end
            end
        end

        function pan_move(app)
            current_position = app.UIFigure.UserData.activeAxes.CurrentPoint;
            xlim_range = get(app.UIFigure.UserData.activeAxes, 'xlim');
            ylim_range = get(app.UIFigure.UserData.activeAxes, 'ylim');
            delta_points = current_position - app.UIFigure.UserData.Pan.previous_point;
            set(app.UIFigure.UserData.activeAxes, 'Xlim', xlim_range - delta_points(1));
            set(app.UIFigure.UserData.activeAxes, 'Ylim', ylim_range - delta_points(3));
            app.UIFigure.UserData.Pan.previous_point = app.UIFigure.UserData.activeAxes.CurrentPoint;
        end

        function windowScrollWheel(app, ~, event)
            if isempty(app.UIFigure.UserData.activeAxes)
                return;
            end
            currentPosition = app.UIFigure.UserData.activeAxes.CurrentPoint;
            x = currentPosition(1,1);
            y = currentPosition(1,2);
            if x >= app.UIFigure.UserData.activeAxes.XLim(1) && x <= app.UIFigure.UserData.activeAxes.XLim(2) && ...
                    y >= app.UIFigure.UserData.activeAxes.YLim(1) && y <= app.UIFigure.UserData.activeAxes.YLim(2)
                if event.VerticalScrollCount > 0
                    scale = 1.1;
                else
                    scale = 1/1.1;
                end
                xlim_range = get(app.UIFigure.UserData.activeAxes, 'xlim');
                ylim_range = get(app.UIFigure.UserData.activeAxes, 'ylim');
                app.UIFigure.UserData.activeAxes.XLim = (xlim_range - x) * scale + x;
                app.UIFigure.UserData.activeAxes.YLim = (ylim_range - y) * scale + y;
            end
        end

        function windowButtonUp(app, ~, ~)
            % 只有当DrawROI对象存在且处于拖拽模式时，才停止拖拽
            if ~isempty(app.DrawROI) && app.DrawROI.is_drag_active()
                app.DrawROI.stop_drag();
            end

            if strcmp(app.UIFigure.UserData.activeAxes.UserData.status, "axes_paning")
                % 无论是否在强制平移模式，松开鼠标左键后都应停止平移
                app.UIFigure.UserData.activeAxes.UserData.status = "idle";
                % 但在强制平移模式下保持手形光标
                if app.UIFigure.UserData.forcePanMode
                    set(app.UIFigure, 'Pointer', 'hand');
                else
                    set(app.UIFigure, 'Pointer', 'arrow');
                end
            end
        end

        function keyPress(app, ~, event)
            switch event.Key
                case 'control'
                    app.UIFigure.UserData.CtrlPressed = true;
                case 'shift'
                    app.UIFigure.UserData.ShiftPressed = true;
                case 'alt'
                    app.UIFigure.UserData.AltPressed = true;
                case 'space' % 空格键按下，激活强制平移模式
                    app.UIFigure.UserData.SpacePressed = true;
                    app.UIFigure.UserData.forcePanMode = true;
                    set(app.UIFigure, 'Pointer', 'hand'); % 改变鼠标指针样式以提示用户

                case 'delete'
                    if app.DrawROI.selected_roi_idx > 0
                        app.DrawROI.delete_selected_roi();
                    end
                case 'uparrow'
                    % 只有当鼠标在UIAxes区域内时才响应方向键
                    if app.UIFigure.UserData.mouseInAxes
                        if ~app.UIFigure.UserData.ShiftPressed
                            app.DrawROI.move_roi(0, -1);
                        else
                            app.DrawROI.move_roi(0, -5);
                        end
                    end
                case 'downarrow'
                    % 只有当鼠标在UIAxes区域内时才响应方向键
                    if app.UIFigure.UserData.mouseInAxes
                        if ~app.UIFigure.UserData.ShiftPressed
                            app.DrawROI.move_roi(0, 1);
                        else
                            app.DrawROI.move_roi(0, 5);
                        end
                    end
                case 'leftarrow'
                    % 只有当鼠标在UIAxes区域内时才响应方向键
                    if app.UIFigure.UserData.mouseInAxes
                        if ~app.UIFigure.UserData.ShiftPressed
                            app.DrawROI.move_roi(-1, 0);
                        else
                            app.DrawROI.move_roi(-5, 0);
                        end
                    end
                case 'rightarrow'
                    % 只有当鼠标在UIAxes区域内时才响应方向键
                    if app.UIFigure.UserData.mouseInAxes
                        if ~app.UIFigure.UserData.ShiftPressed
                            app.DrawROI.move_roi(1, 0);
                        else
                            app.DrawROI.move_roi(5, 0);
                        end
                    end
                case 'return'
                    % 检查是否在编辑ROI模式
                    if app.DrawROI.is_roi_editing()
                        app.DrawROI.finish_edit_roi(true);
                        % 检查是否在添加规则ROI模式
                    elseif app.DrawROI.is_adding_regular_roi()
                        app.DrawROI.finish_adding_regular_roi(true);
                        if app.ShowROINumbersCheckBox.Value
                            app.DrawROI.show_roi_numbers();
                        end
                        % 使用活动轴的状态判断，而不是固定使用第一个轴
                    elseif strcmp(app.UIFigure.UserData.activeAxes.UserData.status, "handroi_drawing")
                        app.DrawROI.finish_drawing();
                        if app.ShowROINumbersCheckBox.Value
                            app.DrawROI.show_roi_numbers();
                        end
                    end
                case 'escape'
                    % 检查是否在编辑ROI模式
                    if app.DrawROI.is_roi_editing()
                        app.DrawROI.cancel_edit_roi();
                        % 检查是否在添加规则ROI模式
                    elseif app.DrawROI.is_adding_regular_roi()
                        app.DrawROI.cancel_adding_regular_roi();
                        % 使用活动轴的状态判断，而不是固定使用第一个轴
                    elseif strcmp(app.UIFigure.UserData.activeAxes.UserData.status, "handroi_drawing")
                        app.DrawROI.handroi_cancel();
                    end
            end
        end

        function keyRelease(app, ~, event)
            switch event.Key
                case 'control'
                    app.UIFigure.UserData.CtrlPressed = false;
                case 'shift'
                    app.UIFigure.UserData.ShiftPressed = false;
                case 'alt'  % Alt键释放，退出强制平移模式
                    app.UIFigure.UserData.AltPressed = false;
                    app.UIFigure.UserData.forcePanMode = false;
                    set(app.UIFigure, 'Pointer', 'arrow'); % 恢复默认鼠标指针
                    % 如果没有按住鼠标左键，则恢复idle状态
                    if strcmp(app.UIFigure.UserData.activeAxes.UserData.status, "axes_paning")
                        % 检查鼠标左键是否按下
                        if ~strcmp(get(app.UIFigure, 'SelectionType'), 'normal')
                            app.UIFigure.UserData.activeAxes.UserData.status = "idle";
                        end
                    end
                case 'space'  % 空格键释放，退出强制平移模式
                    app.UIFigure.UserData.SpacePressed = false;
                    app.UIFigure.UserData.forcePanMode = false;
                    set(app.UIFigure, 'Pointer', 'arrow'); % 恢复默认鼠标指针
                    % 如果没有按住鼠标左键，则恢复idle状态
                    if strcmp(app.UIFigure.UserData.activeAxes.UserData.status, "axes_paning")
                        % 检查鼠标左键是否按下
                        if ~strcmp(get(app.UIFigure, 'SelectionType'), 'normal')
                            app.UIFigure.UserData.activeAxes.UserData.status = "idle";
                        end
                    end

                case 'escape'
                    app.UIFigure.UserData.CtrlPressed = false;
                    app.UIFigure.UserData.ShiftPressed = false;
                    app.UIFigure.UserData.AltPressed = false;
                    app.UIFigure.UserData.SpacePressed = false; % 也重置空格键状态
                    app.UIFigure.UserData.forcePanMode = false;
                    set(app.UIFigure, 'Pointer', 'arrow');
                    if strcmp(app.UIFigure.UserData.activeAxes.UserData.status, "axes_paning")
                        app.UIFigure.UserData.activeAxes.UserData.status = "idle";
                    end
            end
        end


        function plot_signal(app)
            switch app.SignalTypeDropDown.Value
                case 'ΔF/F'
                    data = app.signal_delta;
                case 'zscore'
                    data = app.signal_zscore_delta;
                case 'raw'
                    data = app.signal_raw;
            end
            if isempty(data)
                uialert(app.UIFigure,'No ROI signal','Error','Icon','error','Modal',false);
                return
            end

            % Parse even data
            eventRange = app.EventRangesEditField.Value;
            if ~strcmp(eventRange,'0')
                if contains(eventRange, ':')
                    % 处理包含"end"的情况
                    eventRange = strrep(eventRange, 'end', num2str(app.tiff_all_frames/app.FrameRateEditField.Value));

                    % 格式为 'start:end'
                    parts = split(eventRange, ':');
                    expri_event.start = str2double(parts{1});
                    expri_event.end = str2double(parts{2});

                elseif strlength(eventRange)>0
                    % 格式为单个数字，表示取前N帧
                    expri_event.start= str2double(eventRange);
                    expri_event.end = 0;
                else
                    expri_event.start=0;
                    expri_event.end=0;
                end
            else
                expri_event.start=0;
                expri_event.end=0;
            end

            expri_event.color=app.EventColorEditField.Value;
            expri_event.name = app.EventNameEditField.Value;

            % parse
            % get roi color: random color or fixed color
            if app.TraceColorDropDown.Value == "fixed"
                trace_colormap =app.TraceFixedColor.Value;
            else
                trace_colormap = app.TraceColorDropDown.Value;
            end
            % 绘制信号


            switch app.ScabarTypeDropDown.Value
                case 'time and signal'
                    plot_scale_bar_time  = true;
                case 'only signal'
                    plot_scale_bar_time = false;
            end


            % 创建或更新fig_trace
            if isempty(app.fig_trace) || ~isvalid(app.fig_trace)
                app.fig_trace = figure("Name","Plot Trace");
                % else
                %     figure(app.fig_trace);
                %     clf(app.fig_trace);
            end

            % 创建或更新fig_heatmap
            if isempty(app.fig_heatmap) || ~isvalid(app.fig_heatmap)
                app.fig_heatmap = figure("Name","Plot Heatmap");
                % else
                %     figure(app.fig_heatmap);
                %     clf(app.fig_heatmap);
            end

            % 绘制信号图
            plot.plot_signal(data, ...
                'frame_rate', app.FrameRateEditField.Value,...
                "scalebar_signal",app.FScalebarSpinner.Value,...
                "scalebar_time",app.TimeScalebarSpinner.Value,...
                "color_map",trace_colormap,...
                "plot_scale_bar_time", plot_scale_bar_time,...
                "signal_type",app.SignalTypeDropDown.Value,...
                "selected_roi_str", app.SelectedROIEditField.Value,...
                "roi_prefix",app.ROIPrefixLabelEditField.Value,...
                "xlim", app.XLimsEditField_2.Value,'xtick_interval',app.XTickIntervalsEditField.Value,...
                "event", expri_event,...
                "roi_interval", app.ROIintervalSpinner.Value, ...
                "sort",app.sortCheckBox.Value,...
                "fig", app.fig_trace);

            % % 绘制热图
            plot.plotHeatmap(data, ...
                "selected_roi_str",app.SelectedROIEditField.Value, ...
                'frame_rate',app.FrameRateEditField.Value, ...
                "signal_type",app.SignalTypeDropDown.Value,...
                "xlim", app.XLimsEditField_2.Value,'xtick_interval',app.XTickIntervalsEditField.Value,...
                "colormap",app.ColormapColorDropDown.Value,...
                "event", expri_event,...,
                "sort",app.sortCheckBox.Value,...
                "fig", app.fig_heatmap);
        end

    end


    methods (Access = private)

        function save_mask(app)
            try
                % save matfile
                data.roi_contours = app.DrawROI.roi_contours;
                data.original_roi_contours = app.DrawROI.original_roi_contours;
                data.dilate_level = app.DrawROI.dilate_level;
                data.roi_labeled_mask = uint16(app.DrawROI.generate_labeled_mask());
    
                save(fullfile(app.last_selected_folder,[app.tiff_filename,'_roiMask.mat']), ...
                    "-struct", ...
                    "data");
                % imwrite(data.roi_labeled_mask,fullfile(app.last_selected_folder,[app.tiff_filename,'_roiMask.png']));
                % save roi mask to imageJ
                utils.save_roiContour_to_imagej(app.DrawROI.roi_contours,fullfile(app.last_selected_folder,strcat(app.tiff_filename,'_roiMask.zip')));

                app.ImageUIAxes2.XLim = app.ImageUIAxes2.UserData.origin_xlim;
                app.ImageUIAxes2.YLim = app.ImageUIAxes2.UserData.origin_ylim;
    
    
                exportgraphics(app.ImageUIAxes2, ...
                    fullfile(app.last_selected_folder, ...
                    [app.tiff_filename,'_roiMask.pdf']), ...
                    'Resolution',600);
    
    
                exportgraphics(app.ImageUIAxes2, ...
                    fullfile(app.last_selected_folder, ...
                    [app.tiff_filename,'_roiMask.png']), ...
                    'Resolution',600);
            catch ME
                % 捕获并显示错误信息
                errordlg(ME.message, 'Error');
                fprintf(2,'%s\n', ME.getReport('extended'));
            end
        end

        function update_frame(app)
            app.tiff_current_frame = round(app.Slider.Value);
            app.Spinner.Value = app.tiff_current_frame;
            app.ImageUIAxes1_image_layer.CData = app.tiff_memmap.Data(app.tiff_current_frame).channel1';
            drawnow

        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)


            % assignin("base",'calcium_signal_extract_app',app);
            assignin("base",'app',app);
            app.dir = fileparts(mfilename('fullpath'));
            addpath(genpath(fullfile(app.dir,'libs')))
            if isfile(fullfile(app.dir,'config.json'))
                app.config_read()
            end

            for ax = [app.ImageUIAxes1, app.ImageUIAxes2]
                ax.YDir = "reverse";
                ax.UserData.status = "idle";
                ax.Toolbar.Visible = 'off';
                axis(ax, 'equal');
            end

            app.UIFigure.UserData.CtrlPressed = false;
            app.UIFigure.UserData.ShiftPressed = false;
            app.UIFigure.UserData.AltPressed = false;
            app.UIFigure.UserData.SpacePressed = false;

            % 将原属性初始化到UserData中
            app.UIFigure.UserData.Pan = struct('previous_point', [0 0 0 0]);
            app.UIFigure.UserData.activeAxes = app.ImageUIAxes1; % 默认活动轴
            app.UIFigure.UserData.mouseInAxes = false;
            app.UIFigure.UserData.forcePanMode = false;

            set(app.UIFigure, 'WindowButtonDownFcn', @app.windowButtonDown);
            set(app.UIFigure, 'WindowButtonMotionFcn', @app.windowMotion);
            set(app.UIFigure, 'WindowButtonUpFcn', @app.windowButtonUp);
            set(app.UIFigure, 'WindowKeyPressFcn', @app.keyPress);
            set(app.UIFigure, 'WindowKeyReleaseFcn', @app.keyRelease);
            set(app.UIFigure, 'WindowScrollWheelFcn', @app.windowScrollWheel);


        end

        % Value changed function: Slider
        function SliderValueChanged(app, event)
            update_frame(app);
        end

        % Value changing function: Slider
        function SliderValueChanging(app, event)
            value = event.Value;
            app.tiff_current_frame = round(value);
            app.Spinner.Value = app.tiff_current_frame;
            app.ImageUIAxes1_image_layer.CData =app.tiff_memmap.Data(app.tiff_current_frame).channel1';
            %drawnow
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            % 关闭app之前需要保存config
            app.config_save();
            if ~isempty(app.ROIMaskSettingsApp)
                delete(app.ROIMaskSettingsApp);
            end
            % close app
            delete(app)

        end

        % Button pushed function: LoadTiffStackButton
        function LoadTiffStackButtonPushed(app, event)
            % 选择Tiff
            [filename,path] = utils.select_file({'*.tif'},app.last_selected_folder);

            if filename ~= 0
                % clear tiff_memmap, 释放memmapfile文件资源
                app.tiff_memmap = [];
                % create progress dialog
                d = uiprogressdlg(app.UIFigure,'Title','Loading Image',...
                    'Indeterminate','on');
                drawnow
                % get filename
                app.filenameLabel.Text = filename;
                [~,name,~] = fileparts(filename);
                app.tiff_filename = name;
                % save path for next click
                app.last_selected_folder = path;

                %% load tiff
                app.tiff_path = fullfile(app.last_selected_folder,filename);
                app.tiff_current_frame  = 1;
                rewrite = app.neddrewriteCheckBox.Value;
                if ~rewrite
                    try
                        app.tiff_memmap= memory_map_tiff(app.tiff_path,[],1,true); % 不能直接memory_map_tiff(app.tiff_path,[],1,true).Data，这样相当于读取所有数据会非常卡
                        app.tiff_all_frames = length(app.tiff_memmap.Data);
                    catch
                        d.Message = "Try rewrite image";

                        fid=fopen(app.tiff_path,'r');
                        fseek(fid,0,'eof');
                        len=ftell(fid);
                        fclose(fid);

                        info=readtifftags(data);
                        if isfield(info,'ImageDescription')
                            desc=info(1).ImageDescription;
                        else
                            desc=[];
                        end
                        newfile = fullfile(app.last_selected_folder,strcat(name,'_rewrite.tif'));


                        if len/1e9<3.99
                            TiffWriter=Fast_Tiff_Write(newfile,info(1).Xresolution,0,desc);
                        else
                            TiffWriter=Fast_BigTiff_Write(newfile,info(1).Xresolution,0,desc);
                        end

                        t = Tiff(app.tiff_path,'r');
                        app.tiff_all_frames = length(info);
                        for i = 1:app.tiff_all_frames
                            t.setDirectory(i);
                            img = t.read();
                            TiffWriter.WriteIMG(img');
                        end

                        t.close();
                        app.tiff_memmap= memory_map_tiff(newfile,[],1,true);
                        app.tiff_path = newfile;

                    end
                else
                        fid=fopen(app.tiff_path,'r');
                        fseek(fid,0,'eof');
                        len=ftell(fid);
                        fclose(fid);

                        info=readtifftags(app.tiff_path);
                        if isfield(info,'ImageDescription')
                            desc=info(1).ImageDescription;
                        else
                            desc=[];
                        end
                        newfile = fullfile(app.last_selected_folder,strcat(name,'_rewrite.tif'));


                        if len/1e9<3.99
                            TiffWriter=Fast_Tiff_Write(newfile,info(1).Xresolution,0,desc);
                        else
                            TiffWriter=Fast_BigTiff_Write(newfile,info(1).Xresolution,0,desc);
                        end

                        t = Tiff(app.tiff_path,'r');
                        app.tiff_all_frames = length(info);
                        for i = 1:app.tiff_all_frames
                            t.setDirectory(i);
                            img = t.read();
                            TiffWriter.WriteIMG(img');
                        end
                        close(TiffWriter);
                        t.close();
                        app.tiff_memmap= memory_map_tiff(newfile,[],1,true);
                        app.tiff_path = newfile;
                end


                % update tiff info
                app.Slider.Value =1;
                app.Slider.Enable = 'on';
                if app.tiff_all_frames > 1
                    app.Slider.Limits = [1,app.tiff_all_frames];
                else
                    app.Slider.Enable = 'off';

                end
                app.SliderLabel.Text = sprintf("/%d",app.tiff_all_frames);
                app.Spinner.Value = app.tiff_current_frame;
                app.Spinner.Limits = [1 app.tiff_all_frames];

                % clear old signal axes and old data
                cla(app.ImageUIAxes1);
                cla(app.ImageUIAxes2);
                app.DrawROI = [];
                app.signal_raw = [];
                app.signal_delta = [];
                app.signal_zscore_delta = [];
                app.signal_raw_corrected = [];
                hold(app.ImageUIAxes1,'on');

                %% init ImageUIAxes1
                % create image layer
                app.ImageUIAxes1_image_layer = imshow(app.tiff_memmap.Data(app.tiff_current_frame).channel1',[],'parent',app.ImageUIAxes1,'border','tight','initialmagnification','fit');
                app.ContrastSlider.Limits = [double(min(app.ImageUIAxes1_image_layer.CData,[],'all')),double(max(app.ImageUIAxes1_image_layer.CData,[],'all'))];
                app.ContrastSlider.Value = get(app.ImageUIAxes1,"Clim");
                drawnow
                %create ref image layer
                ref_img =app.tiff_memmap.Data(app.tiff_current_frame).channel1';
                if isa(ref_img,'int16')
                    ref_img = uint16(ref_img);
                end
                ref_img_size = size(ref_img);
                app.ImageUIAxes1_refImg_layer_alphaData = imadjust(ref_img);
                ref_img_RGB = cat(3, zeros(ref_img_size), app.ImageUIAxes1_refImg_layer_alphaData, zeros(ref_img_size));
                app.ImageUIAxes1_refImg_layer = imshow(ref_img_RGB, [0.05 0.95],'parent',app.ImageUIAxes1,'border','tight','initialmagnification','fit');
                app.ImageUIAxes1_refImg_layer.AlphaData = 0 ;
                app.ImageUIAxes1.CLim = app.ContrastSlider.Value; % 修复加载帧对比度初始化不对的问题
                %% init ImageUIAxes2
                img_size=size(app.tiff_memmap.Data(app.tiff_current_frame).channel1');
                hold(app.ImageUIAxes2, 'off');
                app.ImageUIAxes2_image_layer = imshow(zeros(img_size),[],'parent',app.ImageUIAxes2,'border','tight','initialmagnification','fit');
                app.ImageUIAxes2_image_layer.AlphaData = 0;
                hold(app.ImageUIAxes2, 'on');

                for ax = [app.ImageUIAxes1, app.ImageUIAxes2]
                    ax.UserData.origin_xlim = [0 img_size];
                    ax.UserData.origin_ylim = [0 img_size];
                end
                %% init DrawROI component
                app.DrawROI = components.DrawROI(app, [app.ImageUIAxes1, app.ImageUIAxes2]);
                app.DrawROI.mask_size = img_size;
                % 设置UIAxes的初始视图限制
                app.ImageUIAxes1.UserData.status = "idle";
                app.ImageUIAxes2.UserData.status = "idle";
                app.ImageUIAxes1.UserData.origin_xlim = [0 app.DrawROI.mask_size(2)];
                app.ImageUIAxes1.UserData.origin_ylim = [0 app.DrawROI.mask_size(1)];
                app.ImageUIAxes2.UserData.origin_xlim = [0 app.DrawROI.mask_size(2)];
                app.ImageUIAxes2.UserData.origin_ylim = [0 app.DrawROI.mask_size(1)];

                % 默认选择第一个轴作为活动轴
                app.UIFigure.UserData.activeAxes = app.ImageUIAxes1;
                app.DrawROI.active_axes_index = 1;

                % 重置ROI计数
                app.ROIsEditField.Value = 0;
                % enable components
                app.MaskOnCheckBox.Value = true;
                app.drawroi_enable  = true;
                app.seg_enable = true;
                app.seg_adjust_enable = false;


                % close the dialog box
                close(d);


            end
        end

        % Button pushed function: RunSegButton
        function RunSegButtonPushed(app, event)

            if ~app.seg_enable
                return
            end

            % process bar
            progressDlg = uiprogressdlg(app.UIFigure,'Title','Running neuron segmentation',...
                'Indeterminate','on');
            drawnow


            model_type = app.ModelsDropDown.Value;
            flow_threshold = app.ThresholdSpinner.Value;
            cp = cellpose(Model=model_type);
            labeled_mask = segmentCells2D(cp,app.tiff_seg_data,ImageCellDiameter=app.DiameterSpinner.Value,CellThreshold=0,FlowErrorThreshold=flow_threshold); %ImageCellDiameter=56


            app.MaskOnCheckBox.Value = true;
            app.DrawROI.load_from_mask(labeled_mask);
            % close the dialog box
            close(progressDlg);

        end

        % Value changed function: MaskOnCheckBox
        function MaskOnCheckBoxValueChanged(app, event)
            value = app.MaskOnCheckBox.Value;
            app.DrawROI.set_roi_visibility(2, value);
        end

        % Button pushed function: UIAxesHomeButton
        function UIAxesHomeButtonPushed(app, event)
            ax = app.ImageUIAxes2;
            ax.XLim = ax.UserData.origin_xlim;
            ax.YLim = ax.UserData.origin_ylim;
        end

        % Button pushed function: ExtractsignalButton
        function ExtractsignalButtonPushed(app, event)
            if app.ROIsEditField.Value == 0
                return
            end
            roi_mask = app.DrawROI.generate_labeled_mask();
            roi_num = length(unique(roi_mask))-1;
            if roi_num == 0
                return % 如果没有 ROI，直接返回
            end
            d = uiprogressdlg(app.UIFigure,'Title','Extracting Value',...
                'Indeterminate','on');
            drawnow
            % 初始化信号矩阵
            n_frames = app.tiff_all_frames; % 存储了总帧数
            % 不需要重复生成raw data信号，直接利用新的
            % if ~isempty(app.signal_raw) && ~app.signal_need_generate_raw_data
            % else
            %
            % end
            app.signal_raw = zeros(roi_num, n_frames);
            app.signal_delta = zeros(roi_num, n_frames);

            % 逐帧读取raw signal
            for frame_index = 1:n_frames
                frameData = double(app.tiff_memmap.Data(frame_index).channel1'); % 从内存映射中读取当前帧数据 (假设 channel1)
                for roi_index = 1:roi_num
                    % 提取 ROI 区域的像素值
                    roi_position = roi_mask == roi_index;
                    roi_pixels = frameData(roi_position); % 获取ROI区域内所有像素值
                    
                    % 排序像素值（降序），取前30%最亮的像素
                    sorted_pixels = sort(roi_pixels, 'descend');
                    top_30_percent_count = ceil(length(sorted_pixels) * 0.3); % 计算30%对应的像素数量
                    top_30_percent_pixels = sorted_pixels(1:top_30_percent_count); % 取前30%最亮的像素
                    
                    % 计算前30%像素的平均值作为ROI信号
                    roi_raw_signal = mean(top_30_percent_pixels);
                    app.signal_raw(roi_index, frame_index) = roi_raw_signal; % 存储当前帧的 raw signal
                end
            end

            % F0 = average
            % 解析帧范围字符串
            if app.F0BaselinecorrectionCheckBox.Value
                for roi_index = 1:roi_num
                    roi_raw_signal = app.signal_raw(roi_index,:); % 获取当前 ROI 的所有帧的 raw signal
                    % 定义时间点（帧数）
                    time_points = 1:n_frames;

                    % 选择多项式拟合的阶数
                    polynomial_degree = 2; % 使用二次多项式拟合

                    % 使用 polyfit 函数进行多项式拟合
                    coefficients = polyfit(time_points, roi_raw_signal, polynomial_degree);

                    % 使用 polyval 函数计算拟合的基线
                    baseline = polyval(coefficients, time_points);

                    % 基线校正：从原始荧光数据中减去拟合的基线
                    app.signal_raw_corrected(roi_index, :) = roi_raw_signal - baseline;
                end
                % 如果勾选基线校正，则先把基线校正的结果赋值给ΔF/F信号
                app.signal_delta = app.signal_raw_corrected;
            else
                app.signal_raw_corrected = app.signal_raw; % 如果不使用平滑基线去除，直接赋值
            end
            
            % 计算ΔF/F
            if app.useNormalF0CheckBox.Value
                % F0 = xx%-xx%
                for roi_index = 1:roi_num
                    roi_raw_signal = app.signal_raw_corrected(roi_index,:); % 获取当前 ROI 的所有帧的 raw signal
                    % 计算 baseline
                    [sorted_sig, ~] = sort(roi_raw_signal);
                    F0_start_range = app.F0StartEditField.Value / 100;
                    F0_end_range = app.F0EndEditField.Value / 100;
                    baseline = mean(sorted_sig(floor(F0_start_range * n_frames):floor(F0_end_range * n_frames))); % baseline = 设定百分比范围内的平均值
                    dff = (roi_raw_signal - baseline) / (baseline+app.signal_bias);
                    app.signal_delta(roi_index, :) = dff;
                end
            elseif app.F0TypeEventCheckBox.Value
                frameRange = app.AverageEditField.Value;
                if contains(frameRange, ':')
                    % 处理包含"end"的情况
                    frameRange = strrep(frameRange, 'end', num2str(n_frames));

                    % 格式为 'start:end'
                    parts = split(frameRange, ':');
                    startFrame = str2double(parts{1});
                    endFrame = str2double(parts{2});
                    selectedFrames = startFrame:endFrame;
                else
                    % 格式为单个数字，表示取前N帧
                    numFrames = str2double(frameRange);
                    selectedFrames = 1:min(numFrames, n_frames);
                end

                % 确保帧范围有效
                selectedFrames = selectedFrames(selectedFrames >= 1 & selectedFrames <= n_frames);
                if isempty(selectedFrames)
                    error('指定的帧范围无效或超出可用帧范围(1-%d)', totalFrames);
                end
                mean_values = mean(app.signal_raw_corrected(:, selectedFrames),2);
                app.signal_delta = (app.signal_raw_corrected -mean_values)./ mean_values;

            end

            if app.smoothCheckBox.Value
                app.signal_delta = smoothdata(app.signal_delta,2, 'gaussian', app.windowsEditField.Value); % 计算高斯平滑，窗口大小为3
            end
            % zscore 计算每个ROI的信号
            app.signal_zscore_delta = zscore(app.signal_delta,0,2);
            

            app.OnlyPlotButtonPushed();
            close(d);
        end

        % Button pushed function: SaveAllButton
        function SaveAllButtonPushed(app, event)
            app.SaveAllButton.Enable = 'off';
            try
                d = uiprogressdlg(app.UIFigure,'Title','Saving',...
                    'Indeterminate','on');
                drawnow

                %save mask
                save_mask(app);
                % save signal
                if isempty(app.fig_trace) || ~isvalid(app.fig_trace) || isempty(app.fig_heatmap) || ~isvalid(app.fig_heatmap)
                    app.ExtractsignalButtonPushed();
                end
                

                exportgraphics(app.fig_trace, ...
                    fullfile(app.last_selected_folder,[app.tiff_filename,'_PlotTraces.pdf']),'ContentType','vector');
                saveas(app.fig_trace, ...
                    fullfile(app.last_selected_folder,[app.tiff_filename,'_PlotTrace.fig']));
                exportgraphics(app.fig_heatmap, ...
                    fullfile(app.last_selected_folder,[app.tiff_filename,'_PlotHeatmap.pdf']),'ContentType','vector');
                saveas(app.fig_heatmap, ...
                    fullfile(app.last_selected_folder,[app.tiff_filename,'_PlotHeatmap.fig']));

                % save data to mat
                % data.roi_contours = app.DrawROI.roi_contours;
                % data.original_roi_contours = app.DrawROI.original_roi_contours;
                % data.dilate_level = app.DrawROI.dilate_level;
                % data.roi_labeled_mask = app.DrawROI.generate_labeled_mask();
                data.raw_sig = app.signal_raw;
                data.dff_sig = app.signal_delta;
                data.raw_corrected_sig = app.signal_raw_corrected;
                data.zscore_sig = app.signal_zscore_delta;
                save(fullfile(app.last_selected_folder,[app.tiff_filename,'_signalData.mat']), ...
                    "-struct", ...
                    "data");

                %% Save the extracted calcium signal as Excel
                % extract filename
                filename_excel = fullfile(app.last_selected_folder, [app.tiff_filename,'_signalData.xlsx']);
                % matrix to table
                header = strcat('ROI_',  string(1:size(data.dff_sig,1)));
                dff_table = array2table(data.dff_sig', 'VariableNames', header);
                raw_table = array2table(data.raw_sig', 'VariableNames', header);
                raw_corrected_table = array2table(data.raw_corrected_sig', 'VariableNames', header);
                zscore_table = array2table(data.zscore_sig', 'VariableNames', header);
                % write to excel
                writetable(raw_table, ...
                    filename_excel, ...
                    Sheet='raw_sig',WriteMode='replacefile');
                writetable(raw_corrected_table, ...
                    filename_excel, ...
                    Sheet='raw_corrected_sig',WriteMode='inplace');
                writetable(dff_table, ...
                    filename_excel, ...
                    Sheet='dff_sig',WriteMode='inplace');
                writetable(zscore_table, ...
                    filename_excel, ...
                    Sheet='zscore_sig',WriteMode='inplace');


                %% hint: done
                close(d)
                selection = uiconfirm(app.UIFigure, 'Saved successfully.', 'Save Done', ...
                    'Options', {'OK', 'Open Export Folder'}, ...
                    'DefaultOption', 1, ... % Default button is OK
                    'Icon', 'success');
                if strcmp(selection, 'Open Export Folder')
                    if isfolder(app.last_selected_folder)
                        winopen(app.last_selected_folder); % Open folder in Windows
                        % For macOS or Linux compatibility, you can use open(exportFolderPath);
                    else
                        uialert(app.UIFigure, 'Invalid export folder path!', 'Error', 'Icon', 'error','Modal',false);
                    end
                end
            catch ME
                    errordlg(ME.message, 'Error');
                    fprintf(2,'%s\n', ME.getReport('extended'));
                    app.SaveAllButton.Enable = 'on';
            end
            app.SaveAllButton.Enable = 'on';

        end

        % Button pushed function: SaveROIsButton
        function SaveROIsButtonPushed(app, event)
            d = uiprogressdlg(app.UIFigure,'Title','Saving',...
                'Indeterminate','on');
            drawnow
            save_mask(app);
            close(d);
            % hint: done
            selection = uiconfirm(app.UIFigure, 'Saved successfully.', 'Save Mask Done', ...
                'Options', {'OK', 'Open Export Folder'}, ...
                'DefaultOption', 1, ... % Default button is OK
                'Icon', 'success');
            if strcmp(selection, 'Open Export Folder')
                if isfolder(app.last_selected_folder)
                    winopen(app.last_selected_folder); % Open folder in Windows
                    % For macOS or Linux compatibility, you can use open(exportFolderPath);
                else
                    uialert(app.UIFigure, 'Invalid export folder path!', 'Error', 'Icon', 'error','Modal',false);
                end
            end
        end

        % Button pushed function: LoadROIsButton
        function LoadROIsButtonPushed(app, event)
            % disable LoadMaskButton
            app.LoadROIsButton.Enable = 'off';
            app.LoadROIsButton.FontColor = [1.00,1.00,1.00];
            app.LoadROIsButton.BackgroundColor = [0.96,0.65,0.11];
            % load mask
            [filename,path] = utils.select_file({ ...
                '*.mat;*.zip', 'ROI Mask files (*.mat, *.zip, *.png)'; ...
                '*.mat', 'MAT files (*.mat)'; ...
                '*.zip', 'Image ROI files (*.zip)'; ...
                '*.png;*.csv;*.txt;*.xlsx','Custom files (*.png;*.csv;*.txt;*.xlsx)'; ...
                '*.*', 'All Files (*.*)'}, ...
                app.last_selected_folder);


            if filename ~= 0 % 如果不选择文件返回为0
                % save path for next click

                % create progress dialog
                d = uiprogressdlg(app.UIFigure,'Title','Loading ROI Mask',...
                    'Indeterminate','on');
                drawnow


                % load roi
                try
                    app.DrawROI.load_roi_file(fullfile(path,filename));
                catch ME
                    errordlg(ME.message, 'Error');
                    fprintf(2,'%s\n', ME.getReport('extended'));
                    app.LoadROIsButton.Enable = 'on';
                    app.LoadROIsButton.FontColor = [0,0,0];
                    app.LoadROIsButton.BackgroundColor = [0.96,0.96,0.96];
                    return 
                end
                app.MaskOnCheckBox.Value = true;
                % enable draw roi
                app.seg_enable = true;
                app.seg_adjust_enable = false;


                % close the dialog box
                close(d);
            end

            %% update ui
            % enable load mask button
            app.LoadROIsButton.Enable = 'on';
            app.LoadROIsButton.FontColor = [0,0,0];
            app.LoadROIsButton.BackgroundColor = [0.96,0.96,0.96];
        end

        % Button pushed function: ClearROIsButton
        function ClearROIsButtonPushed(app, event)
            if ~isempty(app.DrawROI)
                choice = questdlg('Are you sure you want to clear all ROIs?', ...
                    'Clear ROIs', 'Yes', 'No', 'No');
                if strcmp(choice, 'Yes')
                    app.DrawROI.clear_all_rois();
                end
            end
        end

        % Value changed function: FScalebarSpinner
        function FScalebarSpinnerValueChanged(app, event)
            % app.OnlyPlotButtonPushed();
        end

        % Value changed function: TimeScalebarSpinner
        function TimeScalebarSpinnerValueChanged(app, event)
            % app.OnlyPlotButtonPushed();
        end

        % Value changed function: FrameRateEditField
        function FrameRateEditFieldValueChanged(app, event)
            % app.OnlyPlotButtonPushed();
        end

        % Value changed function: DropDown
        function DropDownValueChanged(app, event)
            value = app.DropDown.Value;
            if ~isempty(app.tiff_seg_data)
                switch value
                    case 'Mean'
                        app.tiff_seg_data = app.tiff_mean_img;
                    case 'Std'
                        app.tiff_seg_data = app.tiff_std_img;
                    case 'Max'
                        app.tiff_seg_data = app.tiff_max_img;
                end
                app.ImageUIAxes2_image_layer.CData = app.tiff_seg_data;

            end
        end

        % Callback function
        function ContrastSliderValueChanged(app, event)
            % 更改对比度slider
            value = app.ContrastSlider.Value;
            if value(1) ~= value(2)
                app.ImageUIAxes1.CLim = value;
            end

        end

        % Callback function
        function ContrastSliderValueChanging(app, event)
            % 更改对比度slider
            value = event.Value;
            if value(1) ~= value(2)
                app.ImageUIAxes1.CLim = value;
            end
        end

        % Callback function
        function ROIMaskColorEditFieldValueChanged(app, event)
            % 更改mask颜色将直接更新mask颜色
            if ~isempty(app.DrawROI)
                app.DrawROI.mask_color = utils.hex2matrix(app.ROIMaskColorEditField.Value);
                app.MaskOnCheckBox.Value = true;
                app.DrawROI.update_roi_color()
            end
        end

        % Value changed function: TraceColorDropDown
        function TraceColorDropDownValueChanged(app, event)
            % 更改ΔF/F颜色
            value = app.TraceColorDropDown.Value;
            if strcmp(value, 'fixed')
                app.TraceFixedColor.Visible = 'on';
            else
                app.TraceFixedColor.Visible = 'off';
            end
            app.OnlyPlotButtonPushed();

        end

        % Value changed function: TiffMaskCheckBox
        function TiffMaskCheckBoxValueChanged(app, event)
            value = app.TiffMaskCheckBox.Value;
            app.DrawROI.set_roi_visibility(1, value);
        end

        % Callback function
        function spacingEditFieldValueChanged(app, event)
            app.OnlyPlotButtonPushed();
        end

        % Value changed function: ScabarTypeDropDown
        function ScabarTypeDropDownValueChanged(app, event)
            switch app.ScabarTypeDropDown.Value
                case 'time and signal'
                    app.XTickIntervalsEditField.Enable = 'on';
                case 'only signal'
                    app.XTickIntervalsEditField.Enable = 'off';
            end
            app.OnlyPlotButtonPushed();
        end

        % Value changed function: XTickIntervalsEditField
        function XTickIntervalsEditFieldValueChanged(app, event)
            app.OnlyPlotButtonPushed();
        end

        % Value changed function: SignalTypeDropDown
        function SignalTypeDropDownValueChanged(app, event)
            app.OnlyPlotButtonPushed();
        end

        % Value changed function: EventNameEditField
        function EventNameEditFieldValueChanged(app, event)
            app.OnlyPlotButtonPushed();
        end

        % Value changed function: EventColorEditField
        function EventColorEditFieldValueChanged(app, event)
            app.OnlyPlotButtonPushed();
        end

        % Button down function: ImageUIAxes1
        function ImageUIAxes1ButtonDown(app, event)

        end

        % Callback function
        function ContrastSlider_2ValueChanged(app, event)
            value = app.ContrastSlider_2.Value;
            if value(1) ~= value(2)
                app.ImageUIAxes2.CLim =value;
            end
        end

        % Callback function
        function ContrastSlider_2ValueChanging(app, event)
            value = event.Value;

            if value(1) ~= value(2)
                app.ImageUIAxes2.CLim =value;
            end

        end

        % Button pushed function: ZProjectionButton
        function ZProjectionButtonPushed(app, event)

            d = uiprogressdlg(app.UIFigure,'Title','Loading Image',...
                'Indeterminate','on');
            drawnow

            % calculateProjections
            [app.tiff_mean_img,app.tiff_max_img,app.tiff_std_img] = calculateProjections(app.tiff_memmap,app.FramesEditField.Value);
            app.tiff_mean_img = app.tiff_mean_img;
            app.tiff_std_img = app.tiff_std_img;

            app.tiff_max_img =mat2gray(app.tiff_max_img);

            % show avg image
            switch app.DropDown.Value
                case 'Mean'

                    app.tiff_seg_data = app.tiff_mean_img;
                case 'Std'
                    app.tiff_seg_data = app.tiff_std_img;
                case 'Max'
                    app.tiff_seg_data = app.tiff_max_img;
            end

            % update structure image
            app.ImageUIAxes2_image_layer.CData = app.tiff_seg_data;
            app.ImageUIAxes2_image_layer.AlphaData = 1;
            app.ContrastSlider_2.Limits = [double(min(app.tiff_seg_data,[],"all")), double(max(app.tiff_seg_data,[],"all"))];
            app.ContrastSlider_2.Value = app.ContrastSlider_2.Limits;

            app.ImageUIAxes2.CLim = app.ContrastSlider_2.Value;
            % uiprogressdlg
            close(d)
        end

        % Value changed function: showrefImageCheckBox
        function showrefImageCheckBoxValueChanged(app, event)
            value = app.showrefImageCheckBox.Value;
            if value
                app.ImageUIAxes1_refImg_layer.AlphaData  = app.ImageUIAxes1_refImg_layer_alphaData * app.AlphaSpinner.Value;
            else

                app.ImageUIAxes1_refImg_layer.AlphaData = 0 ;
            end
        end

        % Value changed function: AlphaSpinner
        function AlphaSpinnerValueChanged(app, event)

            if app.showrefImageCheckBox.Value
                app.ImageUIAxes1_refImg_layer.AlphaData  = app.ImageUIAxes1_refImg_layer_alphaData * app.AlphaSpinner.Value;
            end
        end

        % Button pushed function: UseZProjectionButton
        function UseZProjectionButtonPushed(app, event)
            if isempty(app.tiff_seg_data)
                ZProjectionButtonPushed(app)
            end
            ref_img = app.tiff_seg_data;
            ref_img_size = size(app.tiff_seg_data);
            app.ImageUIAxes1_refImg_layer_alphaData = imadjust(ref_img);
            ref_img_RGB = cat(3, zeros(ref_img_size), app.ImageUIAxes1_refImg_layer_alphaData, zeros(ref_img_size));
            app.ImageUIAxes1_refImg_layer.CData = ref_img_RGB;
            app.ImageUIAxes1_refImg_layer.AlphaData = app.ImageUIAxes1_refImg_layer_alphaData *app.AlphaSpinner.Value ;
        end

        % Button pushed function: OnlyPlotButton
        function OnlyPlotButtonPushed(app, event)
            plot_signal(app);
        end

        % Value changed function: useNormalF0CheckBox
        function useNormalF0CheckBoxValueChanged(app, event)
            value = app.useNormalF0CheckBox.Value;
            if value
                app.F0TypeEventCheckBox.Value = false;
            end
            % app.ExtractsignalButtonPushed();
        end

        % Value changed function: F0BaselinecorrectionCheckBox
        function F0BaselinecorrectionCheckBoxValueChanged(app, event)
            value = app.F0BaselinecorrectionCheckBox.Value;
            % app.ExtractsignalButtonPushed();
        end

        % Value changed function: F0TypeEventCheckBox
        function F0TypeEventCheckBoxValueChanged(app, event)
            value = app.F0TypeEventCheckBox.Value;
            if value
                app.useNormalF0CheckBox.Value = false;
            end
            % app.ExtractsignalButtonPushed();
        end

        % Button pushed function: Button_2
        function Button_2Pushed(app, event)
            app.Slider.Value = app.Slider.Value+1;
            update_frame(app);
        end

        % Button pushed function: Button
        function ButtonPushed(app, event)
            app.Slider.Value = app.Slider.Value-1;
            update_frame(app);
        end

        % Value changed function: Spinner
        function SpinnerValueChanged(app, event)
            value = app.Spinner.Value;
            app.Slider.Value = value;
            update_frame(app)
        end

        % Value changing function: Spinner
        function SpinnerValueChanging(app, event)
            changingValue = event.Value;
            app.Slider.Value = changingValue;
            app.tiff_current_frame = changingValue;
            app.ImageUIAxes1_image_layer.CData = app.tiff_memmap.Data(app.tiff_current_frame).channel1';

        end

        % Button pushed function: ManualRegButton
        function ManualRegButtonPushed(app, event)
            if isfile(app.tiff_path)
                ManualImageRegistration(app.tiff_path);
            end
        end

        % Button pushed function: MeasureButton
        function MeasureButtonPushed(app, event)
            imageViewer(app.tiff_seg_data);
        end

        % Button pushed function: UIAxesHomeButton_2
        function UIAxesHomeButton_2Pushed(app, event)
            ax = app.ImageUIAxes1;
            ax.XLim = ax.UserData.origin_xlim;
            ax.YLim = ax.UserData.origin_ylim;
        end

        % Value changed function: DragROIsButton
        function DragROIsButtonValueChanged(app, event)
            if ~isempty(app.DrawROI)
                if app.DragROIsButton.Value
                    app.DragROIsButton.BackgroundColor = [0.8, 0.8, 1];
                    app.DrawROI.set_drag_mode(true);
                else
                    app.DragROIsButton.BackgroundColor = [0.94, 0.94, 0.94];
                    app.DrawROI.set_drag_mode(false);
                end
            end

        end

        % Value changed function: ShowROINumbersCheckBox
        function ShowROINumbersCheckBoxValueChanged(app, event)
            if ~isempty(app.DrawROI)
                app.DrawROI.showRoiNumber = app.ShowROINumbersCheckBox.Value;
            end
        end

        % Button pushed function: ReorderROIsButton
        function ReorderROIsButtonPushed(app, event)
            if isempty(app.DrawROI.roi_contours) || length(app.DrawROI.roi_contours) < 2
                return;
            end
            try
                app.DrawROI.reorder_rois();
                disp(['Reordered ' num2str(length(app.DrawROI.roi_contours)) ' ROIs.']);
            catch ME
                errordlg(['Reorder ROIs error: ' ME.message], 'Error');
                disp(ME.getReport('extended'));
            end
        end

        % Value changed function: ModelsDropDown
        function ModelsDropDownValueChanged(app, event)
            value = app.ModelsDropDown.Value;
            
        end

        % Callback function
        function FontSizeEditFieldValueChanged(app, event)

            if ~isempty(app.DrawROI)
                value = app.FontSizeEditField.Value;
                app.DrawROI.roi_number_fontSize = value;
                app.MaskOnCheckBox.Value = true;
            end
        end

        % Callback function
        function LoadImageButtonValueChanged(app, event)
            value = app.LoadButton.Value;
            [filename,path] = utils.select_file({'*.tif','*.tiff'},app.last_selected_folder);

            if filename ~= 0
                app.tiff_seg_data = utils.tiff_read(fullfile(path,filename));
                app.ImageUIAxes2_image_layer.CData = app.tiff_seg_data;
                app.ImageUIAxes2_image_layer.AlphaData = 1;
                
                app.ContrastSlider_2.Limits = [0, round(double(max(app.tiff_seg_data,[],"all")))];
                app.ContrastSlider_2.Value = [0, round(double(max(app.tiff_seg_data,[],"all")))];
                app.ImageUIAxes2.CLim = app.ContrastSlider_2.Value;
            end
        end

        % Button pushed function: LoadButton
        function LoadButtonPushed(app, event)


            [filename,path] = utils.select_file({'*.tif','*.tiff'},app.last_selected_folder);

            if filename ~= 0
                d = uiprogressdlg(app.UIFigure,'Title','Loading Image',...
                    'Indeterminate','on');
                drawnow
                app.tiff_seg_data = utils.tiff_read(fullfile(path,filename));
                if size(app.tiff_seg_data,3) >1
                    app.tiff_seg_data = mean(app.tiff_seg_data,3);
                end
                app.ImageUIAxes2_image_layer.CData = app.tiff_seg_data;
                app.ImageUIAxes2_image_layer.AlphaData = 1;
                app.ContrastSlider_2.Limits = [0, round(double(max(app.tiff_seg_data,[],"all")))];
                app.ContrastSlider_2.Value = [0, round(double(max(app.tiff_seg_data,[],"all")))];

                app.ImageUIAxes2.CLim = app.ContrastSlider_2.Value;
                close(d);
            end
            

        end

        % Callback function
        function ROIMaskColorDropDownValueChanged(app, event)
            value = app.ROIMaskColorDropDown.Value;
            switch value
                case 'Fixed'
                    app.ROIMaskColorEditField.Visible = 'on';
                    if ~isempty(app.DrawROI)
                        app.DrawROI.mask_color = app.ROIMaskColorEditField.Value;
                    end
                case 'Random'
                    app.ROIMaskColorEditField.Visible = 'off';
                    app.DrawROI.mask_color = 'Random';
            end
        end

        % Callback function
        function ColorEditFieldValueChanged(app, event)
            
             if ~isempty(app.DrawROI)
                value = app.ColorEditField.Value;
                app.DrawROI.roi_number_fontColor  = value;
                app.MaskOnCheckBox.Value = true;

            end
        end

        % Button pushed function: MaskSettingsButton
        function MaskSettingsButtonPushed(app, event)
            app.ROIMaskSettingsApp=subapp.ROIMaskSettings(app);
        end

        % Menu selected function: MaskSettingsMenu
        function MaskSettingsMenuSelected(app, event)
            app.ROIMaskSettingsApp=subapp.ROIMaskSettings(app);
        end

        % Button pushed function: SyncUIaxes2
        function SyncUIaxes2Pushed(app, event)
            
            app.ImageUIAxes2.XLim = app.ImageUIAxes1.XLim;
            app.ImageUIAxes2.YLim = app.ImageUIAxes1.YLim;
        end

        % Button pushed function: SyncUIaxes1
        function SyncUIaxes1ButtonPushed(app, event)
            app.ImageUIAxes1.XLim = app.ImageUIAxes2.XLim;
            app.ImageUIAxes1.YLim = app.ImageUIAxes2.YLim;
        end

        % Value changed function: ThresholdSpinner
        function ThresholdSpinnerValueChanged(app, event)
            value = app.ThresholdSpinner.Value;
            
        end

        % Value changed function: ContrastSlider
        function ContrastSliderValueChanged2(app, event)
            % 更改对比度slider
            value = app.ContrastSlider.Value;
            if value(1) ~= value(2)
                app.ImageUIAxes1.CLim = value;
            end

        end

        % Value changed function: ContrastSlider_2
        function ContrastSlider_2ValueChanged2(app, event)
            value = app.ContrastSlider_2.Value;
            if value(1) ~= value(2)
                app.ImageUIAxes2.CLim =value;
            end
        end

        % Value changing function: ContrastSlider
        function ContrastSliderValueChanging2(app, event)
            % 更改对比度slider
            value = event.Value;
            if value(1) ~= value(2)
                app.ImageUIAxes1.CLim = value;
            end
        end

        % Value changing function: ContrastSlider_2
        function ContrastSlider_2ValueChanging2(app, event)
            value = event.Value;

            if value(1) ~= value(2)
                app.ImageUIAxes2.CLim =value;
            end

        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Color = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.UIFigure.Position = [10 100 1347 761];
            app.UIFigure.Name = 'Calcium Signal Extract';
            app.UIFigure.Resize = 'off';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create FileMenu
            app.FileMenu = uimenu(app.UIFigure);
            app.FileMenu.Text = 'File';

            % Create LoadConfigMenu
            app.LoadConfigMenu = uimenu(app.FileMenu);
            app.LoadConfigMenu.Text = 'Load Config';

            % Create SaveConfigMenu
            app.SaveConfigMenu = uimenu(app.FileMenu);
            app.SaveConfigMenu.Text = 'Save Config';

            % Create SettingMenu
            app.SettingMenu = uimenu(app.UIFigure);
            app.SettingMenu.Text = 'Setting';

            % Create MaskSettingsMenu
            app.MaskSettingsMenu = uimenu(app.SettingMenu);
            app.MaskSettingsMenu.MenuSelectedFcn = createCallbackFcn(app, @MaskSettingsMenuSelected, true);
            app.MaskSettingsMenu.Text = 'Mask Settings';

            % Create ImageUIAxes2
            app.ImageUIAxes2 = uiaxes(app.UIFigure);
            app.ImageUIAxes2.PlotBoxAspectRatio = [1 1 1];
            app.ImageUIAxes2.XLimitMethod = 'tight';
            app.ImageUIAxes2.YLimitMethod = 'tight';
            app.ImageUIAxes2.ZLimitMethod = 'tight';
            app.ImageUIAxes2.XTick = [];
            app.ImageUIAxes2.YTick = [];
            app.ImageUIAxes2.BoxStyle = 'full';
            app.ImageUIAxes2.LineWidth = 1;
            app.ImageUIAxes2.Box = 'on';
            app.ImageUIAxes2.Position = [563 159 512 512];

            % Create ImageUIAxes1
            app.ImageUIAxes1 = uiaxes(app.UIFigure);
            app.ImageUIAxes1.PlotBoxAspectRatio = [1 1 1];
            app.ImageUIAxes1.XLimitMethod = 'tight';
            app.ImageUIAxes1.YLimitMethod = 'tight';
            app.ImageUIAxes1.ZLimitMethod = 'tight';
            app.ImageUIAxes1.XTick = [];
            app.ImageUIAxes1.YTick = [];
            app.ImageUIAxes1.BoxStyle = 'full';
            app.ImageUIAxes1.LineWidth = 1;
            app.ImageUIAxes1.Box = 'on';
            app.ImageUIAxes1.ButtonDownFcn = createCallbackFcn(app, @ImageUIAxes1ButtonDown, true);
            app.ImageUIAxes1.Position = [50 159 512 512];

            % Create UIAxesHomeButton
            app.UIAxesHomeButton = uibutton(app.UIFigure, 'push');
            app.UIAxesHomeButton.ButtonPushedFcn = createCallbackFcn(app, @UIAxesHomeButtonPushed, true);
            app.UIAxesHomeButton.Icon = fullfile(pathToMLAPP, '+assets', 'home.svg');
            app.UIAxesHomeButton.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.UIAxesHomeButton.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.UIAxesHomeButton.Position = [1018 676 53 23];
            app.UIAxesHomeButton.Text = '';

            % Create ExtractsignalButton
            app.ExtractsignalButton = uibutton(app.UIFigure, 'push');
            app.ExtractsignalButton.ButtonPushedFcn = createCallbackFcn(app, @ExtractsignalButtonPushed, true);
            app.ExtractsignalButton.Icon = fullfile(pathToMLAPP, '+assets', 'signal.svg');
            app.ExtractsignalButton.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.ExtractsignalButton.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ExtractsignalButton.Position = [1099 49 100 23];
            app.ExtractsignalButton.Text = 'Extract signal';

            % Create MaskDropDownLabel
            app.MaskDropDownLabel = uilabel(app.UIFigure);
            app.MaskDropDownLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.MaskDropDownLabel.Position = [565 676 58 22];
            app.MaskDropDownLabel.Text = 'ROI Mask';

            % Create MaskOnCheckBox
            app.MaskOnCheckBox = uicheckbox(app.UIFigure);
            app.MaskOnCheckBox.ValueChangedFcn = createCallbackFcn(app, @MaskOnCheckBoxValueChanged, true);
            app.MaskOnCheckBox.Text = '';
            app.MaskOnCheckBox.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.MaskOnCheckBox.Position = [631 676 14 22];
            app.MaskOnCheckBox.Value = true;

            % Create LoadROIsButton
            app.LoadROIsButton = uibutton(app.UIFigure, 'push');
            app.LoadROIsButton.ButtonPushedFcn = createCallbackFcn(app, @LoadROIsButtonPushed, true);
            app.LoadROIsButton.Icon = fullfile(pathToMLAPP, '+assets', 'upload.svg');
            app.LoadROIsButton.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.LoadROIsButton.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.LoadROIsButton.Tooltip = {'Load external mask  '};
            app.LoadROIsButton.Position = [580 84 87 23];
            app.LoadROIsButton.Text = 'Load ROIs';

            % Create SaveROIsButton
            app.SaveROIsButton = uibutton(app.UIFigure, 'push');
            app.SaveROIsButton.ButtonPushedFcn = createCallbackFcn(app, @SaveROIsButtonPushed, true);
            app.SaveROIsButton.Icon = fullfile(pathToMLAPP, '+assets', 'save.svg');
            app.SaveROIsButton.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.SaveROIsButton.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.SaveROIsButton.Tooltip = {'choose where to save mask as .mat and .jpg'};
            app.SaveROIsButton.Position = [678 84 95 23];
            app.SaveROIsButton.Text = 'Save ROIs';

            % Create ROIsEditField
            app.ROIsEditField = uieditfield(app.UIFigure, 'numeric');
            app.ROIsEditField.Limits = [0 Inf];
            app.ROIsEditField.ValueDisplayFormat = '%.0f';
            app.ROIsEditField.Editable = 'off';
            app.ROIsEditField.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ROIsEditField.Position = [693 676 51 22];

            % Create ModelsDropDownLabel
            app.ModelsDropDownLabel = uilabel(app.UIFigure);
            app.ModelsDropDownLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ModelsDropDownLabel.Position = [677 46 44 22];
            app.ModelsDropDownLabel.Text = 'Models';

            % Create ROIsEditFieldLabel
            app.ROIsEditFieldLabel = uilabel(app.UIFigure);
            app.ROIsEditFieldLabel.HorizontalAlignment = 'right';
            app.ROIsEditFieldLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ROIsEditFieldLabel.Position = [656 676 28 22];
            app.ROIsEditFieldLabel.Text = 'ROIs';

            % Create ModelsDropDown
            app.ModelsDropDown = uidropdown(app.UIFigure);
            app.ModelsDropDown.Items = {'cyto2', 'cyto'};
            app.ModelsDropDown.ValueChangedFcn = createCallbackFcn(app, @ModelsDropDownValueChanged, true);
            app.ModelsDropDown.Tooltip = {'segmentation model'};
            app.ModelsDropDown.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ModelsDropDown.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.ModelsDropDown.Position = [732 46 81 22];
            app.ModelsDropDown.Value = 'cyto2';

            % Create ThresholdSpinnerLabel
            app.ThresholdSpinnerLabel = uilabel(app.UIFigure);
            app.ThresholdSpinnerLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ThresholdSpinnerLabel.Position = [826 46 58 22];
            app.ThresholdSpinnerLabel.Text = 'Threshold';

            % Create ThresholdSpinner
            app.ThresholdSpinner = uispinner(app.UIFigure);
            app.ThresholdSpinner.Step = 0.05;
            app.ThresholdSpinner.LowerLimitInclusive = 'off';
            app.ThresholdSpinner.Limits = [0 3];
            app.ThresholdSpinner.ValueChangedFcn = createCallbackFcn(app, @ThresholdSpinnerValueChanged, true);
            app.ThresholdSpinner.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ThresholdSpinner.Tooltip = {'set  higher to get more cells, in range from (0,3]'};
            app.ThresholdSpinner.Position = [898 46 55 22];
            app.ThresholdSpinner.Value = 0.1;

            % Create RunSegButton
            app.RunSegButton = uibutton(app.UIFigure, 'push');
            app.RunSegButton.ButtonPushedFcn = createCallbackFcn(app, @RunSegButtonPushed, true);
            app.RunSegButton.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.RunSegButton.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.RunSegButton.Position = [578 45 88 23];
            app.RunSegButton.Text = 'Run Seg';

            % Create LoadTiffStackButton
            app.LoadTiffStackButton = uibutton(app.UIFigure, 'push');
            app.LoadTiffStackButton.ButtonPushedFcn = createCallbackFcn(app, @LoadTiffStackButtonPushed, true);
            app.LoadTiffStackButton.Icon = fullfile(pathToMLAPP, '+assets', 'folder-open.svg');
            app.LoadTiffStackButton.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.LoadTiffStackButton.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.LoadTiffStackButton.Position = [50 704 30 23];
            app.LoadTiffStackButton.Text = '';

            % Create SaveAllButton
            app.SaveAllButton = uibutton(app.UIFigure, 'push');
            app.SaveAllButton.ButtonPushedFcn = createCallbackFcn(app, @SaveAllButtonPushed, true);
            app.SaveAllButton.Icon = fullfile(pathToMLAPP, '+assets', 'save.svg');
            app.SaveAllButton.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.SaveAllButton.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.SaveAllButton.Position = [1099 12 100 23];
            app.SaveAllButton.Text = 'Save All';

            % Create Slider
            app.Slider = uislider(app.UIFigure);
            app.Slider.MajorTicks = [];
            app.Slider.ValueChangedFcn = createCallbackFcn(app, @SliderValueChanged, true);
            app.Slider.ValueChangingFcn = createCallbackFcn(app, @SliderValueChanging, true);
            app.Slider.MinorTicks = [];
            app.Slider.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.Slider.Position = [66 147 490 3];

            % Create SliderLabel
            app.SliderLabel = uilabel(app.UIFigure);
            app.SliderLabel.HorizontalAlignment = 'center';
            app.SliderLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.SliderLabel.Position = [341 115 69 22];
            app.SliderLabel.Text = '/1000';

            % Create filenameLabel
            app.filenameLabel = uilabel(app.UIFigure);
            app.filenameLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.filenameLabel.Position = [92 705 425 22];
            app.filenameLabel.Text = 'filename';

            % Create FF_0Label
            app.FF_0Label = uilabel(app.UIFigure);
            app.FF_0Label.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FF_0Label.Position = [1099 634 38 22];
            app.FF_0Label.Text = 'Signal';

            % Create FScalebarSpinner
            app.FScalebarSpinner = uispinner(app.UIFigure);
            app.FScalebarSpinner.Limits = [0 Inf];
            app.FScalebarSpinner.ValueDisplayFormat = '%g';
            app.FScalebarSpinner.ValueChangedFcn = createCallbackFcn(app, @FScalebarSpinnerValueChanged, true);
            app.FScalebarSpinner.HorizontalAlignment = 'left';
            app.FScalebarSpinner.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FScalebarSpinner.Position = [1152 634 55 22];
            app.FScalebarSpinner.Value = 5;

            % Create FF_0Label_2
            app.FF_0Label_2 = uilabel(app.UIFigure);
            app.FF_0Label_2.HorizontalAlignment = 'right';
            app.FF_0Label_2.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FF_0Label_2.Position = [1222 634 49 22];
            app.FF_0Label_2.Text = 'Time (s)';

            % Create TimeScalebarSpinner
            app.TimeScalebarSpinner = uispinner(app.UIFigure);
            app.TimeScalebarSpinner.Limits = [0 Inf];
            app.TimeScalebarSpinner.ValueDisplayFormat = '%.0f';
            app.TimeScalebarSpinner.ValueChangedFcn = createCallbackFcn(app, @TimeScalebarSpinnerValueChanged, true);
            app.TimeScalebarSpinner.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.TimeScalebarSpinner.Position = [1274 634 55 22];
            app.TimeScalebarSpinner.Value = 100;

            % Create FrameRateEditFieldLabel
            app.FrameRateEditFieldLabel = uilabel(app.UIFigure);
            app.FrameRateEditFieldLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FrameRateEditFieldLabel.Position = [1099 688 68 22];
            app.FrameRateEditFieldLabel.Text = 'Frame Rate';

            % Create FrameRateEditField
            app.FrameRateEditField = uieditfield(app.UIFigure, 'numeric');
            app.FrameRateEditField.ValueDisplayFormat = '%.4f';
            app.FrameRateEditField.ValueChangedFcn = createCallbackFcn(app, @FrameRateEditFieldValueChanged, true);
            app.FrameRateEditField.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.FrameRateEditField.Position = [1182 688 62 22];
            app.FrameRateEditField.Value = 3.61;

            % Create ClearROIsButton
            app.ClearROIsButton = uibutton(app.UIFigure, 'push');
            app.ClearROIsButton.ButtonPushedFcn = createCallbackFcn(app, @ClearROIsButtonPushed, true);
            app.ClearROIsButton.Icon = fullfile(pathToMLAPP, '+assets', 'clear.svg');
            app.ClearROIsButton.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.ClearROIsButton.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ClearROIsButton.Tooltip = {'Load external mask  '};
            app.ClearROIsButton.Position = [783 84 86 23];
            app.ClearROIsButton.Text = 'Clear ROIs';

            % Create ScalebarLabel
            app.ScalebarLabel = uilabel(app.UIFigure);
            app.ScalebarLabel.FontSize = 14;
            app.ScalebarLabel.FontWeight = 'bold';
            app.ScalebarLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ScalebarLabel.Position = [1099 717 68 22];
            app.ScalebarLabel.Text = 'Scalebar:';

            % Create SelectedROIEditFieldLabel
            app.SelectedROIEditFieldLabel = uilabel(app.UIFigure);
            app.SelectedROIEditFieldLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.SelectedROIEditFieldLabel.Position = [1099 366 76 22];
            app.SelectedROIEditFieldLabel.Text = 'Selected ROI';

            % Create SelectedROIEditField
            app.SelectedROIEditField = uieditfield(app.UIFigure, 'text');
            app.SelectedROIEditField.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.SelectedROIEditField.Placeholder = 'e.g.  5,10:14,19:24';
            app.SelectedROIEditField.Position = [1202 368 129 22];

            % Create DropDown
            app.DropDown = uidropdown(app.UIFigure);
            app.DropDown.Items = {'Std', 'Mean', 'Max'};
            app.DropDown.ValueChangedFcn = createCallbackFcn(app, @DropDownValueChanged, true);
            app.DropDown.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.DropDown.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.DropDown.Position = [811 707 66 22];
            app.DropDown.Value = 'Mean';

            % Create ContrastSliderLabel
            app.ContrastSliderLabel = uilabel(app.UIFigure);
            app.ContrastSliderLabel.HorizontalAlignment = 'right';
            app.ContrastSliderLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ContrastSliderLabel.Position = [61 94 50 22];
            app.ContrastSliderLabel.Text = 'Contrast';

            % Create TiffMaskCheckBox
            app.TiffMaskCheckBox = uicheckbox(app.UIFigure);
            app.TiffMaskCheckBox.ValueChangedFcn = createCallbackFcn(app, @TiffMaskCheckBoxValueChanged, true);
            app.TiffMaskCheckBox.Text = '';
            app.TiffMaskCheckBox.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.TiffMaskCheckBox.Position = [115 670 25 22];
            app.TiffMaskCheckBox.Value = true;

            % Create ColorDropDownLabel
            app.ColorDropDownLabel = uilabel(app.UIFigure);
            app.ColorDropDownLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ColorDropDownLabel.Position = [1099 161 34 22];
            app.ColorDropDownLabel.Text = 'Color';

            % Create TraceColorDropDown
            app.TraceColorDropDown = uidropdown(app.UIFigure);
            app.TraceColorDropDown.Items = {'hsv', 'prism', 'turbo', 'jet', 'lines', 'random', 'fixed'};
            app.TraceColorDropDown.ValueChangedFcn = createCallbackFcn(app, @TraceColorDropDownValueChanged, true);
            app.TraceColorDropDown.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.TraceColorDropDown.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.TraceColorDropDown.Position = [1139 161 79 22];
            app.TraceColorDropDown.Value = 'hsv';

            % Create TraceFixedColor
            app.TraceFixedColor = uieditfield(app.UIFigure, 'text');
            app.TraceFixedColor.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.TraceFixedColor.Visible = 'off';
            app.TraceFixedColor.Position = [1226 162 59 22];
            app.TraceFixedColor.Value = '#FF0000';

            % Create ROIMaskLabel
            app.ROIMaskLabel = uilabel(app.UIFigure);
            app.ROIMaskLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ROIMaskLabel.Position = [50 670 58 22];
            app.ROIMaskLabel.Text = 'ROI Mask';

            % Create F0StartEditField
            app.F0StartEditField = uieditfield(app.UIFigure, 'numeric');
            app.F0StartEditField.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.F0StartEditField.Position = [1122 466 27 22];
            app.F0StartEditField.Value = 5;

            % Create F0EndEditField
            app.F0EndEditField = uieditfield(app.UIFigure, 'numeric');
            app.F0EndEditField.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.F0EndEditField.Position = [1170 466 27 22];
            app.F0EndEditField.Value = 15;

            % Create Label_2
            app.Label_2 = uilabel(app.UIFigure);
            app.Label_2.HorizontalAlignment = 'center';
            app.Label_2.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.Label_2.Position = [1151 466 21 22];
            app.Label_2.Text = '~';

            % Create Label_3
            app.Label_3 = uilabel(app.UIFigure);
            app.Label_3.HorizontalAlignment = 'center';
            app.Label_3.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.Label_3.Position = [1201 466 25 22];
            app.Label_3.Text = '%';

            % Create ReorderROIsButton
            app.ReorderROIsButton = uibutton(app.UIFigure, 'push');
            app.ReorderROIsButton.ButtonPushedFcn = createCallbackFcn(app, @ReorderROIsButtonPushed, true);
            app.ReorderROIsButton.Icon = fullfile(pathToMLAPP, '+assets', 'reorder.svg');
            app.ReorderROIsButton.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.ReorderROIsButton.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ReorderROIsButton.Position = [879 84 103 23];
            app.ReorderROIsButton.Text = 'Reorder ROIs';

            % Create ScabarTypeDropDownLabel
            app.ScabarTypeDropDownLabel = uilabel(app.UIFigure);
            app.ScabarTypeDropDownLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ScabarTypeDropDownLabel.Position = [1099 661 72 22];
            app.ScabarTypeDropDownLabel.Text = 'Scabar Type';

            % Create ScabarTypeDropDown
            app.ScabarTypeDropDown = uidropdown(app.UIFigure);
            app.ScabarTypeDropDown.Items = {'time and signal', 'only signal'};
            app.ScabarTypeDropDown.ValueChangedFcn = createCallbackFcn(app, @ScabarTypeDropDownValueChanged, true);
            app.ScabarTypeDropDown.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ScabarTypeDropDown.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.ScabarTypeDropDown.Position = [1185 661 100 22];
            app.ScabarTypeDropDown.Value = 'only signal';

            % Create SignalTypeDropDown
            app.SignalTypeDropDown = uidropdown(app.UIFigure);
            app.SignalTypeDropDown.Items = {'ΔF/F', 'zscore', 'raw'};
            app.SignalTypeDropDown.ValueChangedFcn = createCallbackFcn(app, @SignalTypeDropDownValueChanged, true);
            app.SignalTypeDropDown.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.SignalTypeDropDown.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.SignalTypeDropDown.Position = [1180 535 59 22];
            app.SignalTypeDropDown.Value = 'ΔF/F';

            % Create XTickIntervalsEditFieldLabel
            app.XTickIntervalsEditFieldLabel = uilabel(app.UIFigure);
            app.XTickIntervalsEditFieldLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.XTickIntervalsEditFieldLabel.Position = [1099 608 91 22];
            app.XTickIntervalsEditFieldLabel.Text = 'XTick Interval(s)';

            % Create SignalTypeDropDownLabel
            app.SignalTypeDropDownLabel = uilabel(app.UIFigure);
            app.SignalTypeDropDownLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.SignalTypeDropDownLabel.Position = [1099 535 68 22];
            app.SignalTypeDropDownLabel.Text = 'Signal Type';

            % Create XTickIntervalsEditField
            app.XTickIntervalsEditField = uieditfield(app.UIFigure, 'numeric');
            app.XTickIntervalsEditField.ValueDisplayFormat = '%g';
            app.XTickIntervalsEditField.ValueChangedFcn = createCallbackFcn(app, @XTickIntervalsEditFieldValueChanged, true);
            app.XTickIntervalsEditField.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.XTickIntervalsEditField.Position = [1195 608 50 22];
            app.XTickIntervalsEditField.Value = 100;

            % Create EventNameEditFieldLabel
            app.EventNameEditFieldLabel = uilabel(app.UIFigure);
            app.EventNameEditFieldLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.EventNameEditFieldLabel.Position = [1099 272 71 22];
            app.EventNameEditFieldLabel.Text = 'Event Name';

            % Create EventNameEditField
            app.EventNameEditField = uieditfield(app.UIFigure, 'text');
            app.EventNameEditField.ValueChangedFcn = createCallbackFcn(app, @EventNameEditFieldValueChanged, true);
            app.EventNameEditField.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.EventNameEditField.Position = [1201 272 46 22];

            % Create EventColorEditFieldLabel
            app.EventColorEditFieldLabel = uilabel(app.UIFigure);
            app.EventColorEditFieldLabel.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.EventColorEditFieldLabel.Position = [1099 248 68 22];
            app.EventColorEditFieldLabel.Text = 'Event Color';

            % Create EventColorEditField
            app.EventColorEditField = uieditfield(app.UIFigure, 'text');
            app.EventColorEditField.ValueChangedFcn = createCallbackFcn(app, @EventColorEditFieldValueChanged, true);
            app.EventColorEditField.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.EventColorEditField.Position = [1201 248 63 22];
            app.EventColorEditField.Value = '#808083';

            % Create ROILabelEditFieldLabel
            app.ROILabelEditFieldLabel = uilabel(app.UIFigure);
            app.ROILabelEditFieldLabel.Position = [1099 343 93 22];
            app.ROILabelEditFieldLabel.Text = 'ROI Prefix Label';

            % Create ROIPrefixLabelEditField
            app.ROIPrefixLabelEditField = uieditfield(app.UIFigure, 'text');
            app.ROIPrefixLabelEditField.Position = [1202 343 78 22];
            app.ROIPrefixLabelEditField.Value = 'c';

            % Create ZProjectionButton
            app.ZProjectionButton = uibutton(app.UIFigure, 'push');
            app.ZProjectionButton.ButtonPushedFcn = createCallbackFcn(app, @ZProjectionButtonPushed, true);
            app.ZProjectionButton.Position = [565 707 82 23];
            app.ZProjectionButton.Text = 'Z Projection';

            % Create FramesEditFieldLabel
            app.FramesEditFieldLabel = uilabel(app.UIFigure);
            app.FramesEditFieldLabel.HorizontalAlignment = 'right';
            app.FramesEditFieldLabel.Position = [749 707 46 22];
            app.FramesEditFieldLabel.Text = 'Frames';

            % Create FramesEditField
            app.FramesEditField = uieditfield(app.UIFigure, 'text');
            app.FramesEditField.Placeholder = '1:end';
            app.FramesEditField.Position = [659 707 85 22];
            app.FramesEditField.Value = '1:1000';

            % Create showrefImageCheckBox
            app.showrefImageCheckBox = uicheckbox(app.UIFigure);
            app.showrefImageCheckBox.ValueChangedFcn = createCallbackFcn(app, @showrefImageCheckBoxValueChanged, true);
            app.showrefImageCheckBox.Text = 'show ref Image';
            app.showrefImageCheckBox.Position = [179 36 104 22];

            % Create EventLabel
            app.EventLabel = uilabel(app.UIFigure);
            app.EventLabel.FontSize = 14;
            app.EventLabel.FontWeight = 'bold';
            app.EventLabel.Position = [1099 318 43 22];
            app.EventLabel.Text = 'Event';

            % Create useNormalF0CheckBox
            app.useNormalF0CheckBox = uicheckbox(app.UIFigure);
            app.useNormalF0CheckBox.ValueChangedFcn = createCallbackFcn(app, @useNormalF0CheckBoxValueChanged, true);
            app.useNormalF0CheckBox.Text = '';
            app.useNormalF0CheckBox.Position = [1099 466 25 22];
            app.useNormalF0CheckBox.Value = true;

            % Create AlphaSpinner
            app.AlphaSpinner = uispinner(app.UIFigure);
            app.AlphaSpinner.Step = 0.1;
            app.AlphaSpinner.Limits = [0 1];
            app.AlphaSpinner.ValueChangedFcn = createCallbackFcn(app, @AlphaSpinnerValueChanged, true);
            app.AlphaSpinner.Tooltip = {'Alpha of Ref Image Layer '};
            app.AlphaSpinner.Position = [282 36 55 22];
            app.AlphaSpinner.Value = 0.3;

            % Create UseZProjectionButton
            app.UseZProjectionButton = uibutton(app.UIFigure, 'push');
            app.UseZProjectionButton.ButtonPushedFcn = createCallbackFcn(app, @UseZProjectionButtonPushed, true);
            app.UseZProjectionButton.Position = [349 36 101 23];
            app.UseZProjectionButton.Text = 'Use Z Projection';

            % Create SignalLabel
            app.SignalLabel = uilabel(app.UIFigure);
            app.SignalLabel.FontSize = 14;
            app.SignalLabel.FontWeight = 'bold';
            app.SignalLabel.Position = [1099 559 47 22];
            app.SignalLabel.Text = 'Signal';

            % Create F0TypeEventCheckBox
            app.F0TypeEventCheckBox = uicheckbox(app.UIFigure);
            app.F0TypeEventCheckBox.ValueChangedFcn = createCallbackFcn(app, @F0TypeEventCheckBoxValueChanged, true);
            app.F0TypeEventCheckBox.Text = '';
            app.F0TypeEventCheckBox.Position = [1099 442 25 22];

            % Create AverageEditFieldLabel
            app.AverageEditFieldLabel = uilabel(app.UIFigure);
            app.AverageEditFieldLabel.Position = [1121 442 49 22];
            app.AverageEditFieldLabel.Text = 'Average';

            % Create AverageEditField
            app.AverageEditField = uieditfield(app.UIFigure, 'text');
            app.AverageEditField.Placeholder = '1:end';
            app.AverageEditField.Position = [1179 442 45 22];
            app.AverageEditField.Value = '1:180';

            % Create PlotTraceLabel
            app.PlotTraceLabel = uilabel(app.UIFigure);
            app.PlotTraceLabel.FontSize = 14;
            app.PlotTraceLabel.FontWeight = 'bold';
            app.PlotTraceLabel.Position = [1099 221 72 22];
            app.PlotTraceLabel.Text = 'Plot Trace';

            % Create PlotHeatemapLabel
            app.PlotHeatemapLabel = uilabel(app.UIFigure);
            app.PlotHeatemapLabel.FontSize = 14;
            app.PlotHeatemapLabel.FontWeight = 'bold';
            app.PlotHeatemapLabel.Position = [1099 133 102 22];
            app.PlotHeatemapLabel.Text = 'Plot Heatemap';

            % Create ColorDropDown_2Label
            app.ColorDropDown_2Label = uilabel(app.UIFigure);
            app.ColorDropDown_2Label.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ColorDropDown_2Label.Position = [1099 105 34 22];
            app.ColorDropDown_2Label.Text = 'Color';

            % Create ColormapColorDropDown
            app.ColormapColorDropDown = uidropdown(app.UIFigure);
            app.ColormapColorDropDown.Items = {'jet', 'gray', 'sky', 'hsv', 'turbo', 'hot'};
            app.ColormapColorDropDown.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ColormapColorDropDown.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.ColormapColorDropDown.Position = [1139 105 79 22];
            app.ColormapColorDropDown.Value = 'gray';

            % Create ROILabel
            app.ROILabel = uilabel(app.UIFigure);
            app.ROILabel.FontSize = 14;
            app.ROILabel.FontWeight = 'bold';
            app.ROILabel.Position = [1099 391 30 22];
            app.ROILabel.Text = 'ROI';

            % Create BeforeeventEditFieldLabel_2
            app.BeforeeventEditFieldLabel_2 = uilabel(app.UIFigure);
            app.BeforeeventEditFieldLabel_2.Position = [1236 442 46 22];
            app.BeforeeventEditFieldLabel_2.Text = 'Frames';

            % Create F0Label
            app.F0Label = uilabel(app.UIFigure);
            app.F0Label.Position = [1100 515 29 22];
            app.F0Label.Text = 'F0 =';

            % Create F0BaselinecorrectionCheckBox
            app.F0BaselinecorrectionCheckBox = uicheckbox(app.UIFigure);
            app.F0BaselinecorrectionCheckBox.ValueChangedFcn = createCallbackFcn(app, @F0BaselinecorrectionCheckBoxValueChanged, true);
            app.F0BaselinecorrectionCheckBox.Tooltip = {'smoothspline'};
            app.F0BaselinecorrectionCheckBox.Text = 'Baseline correction';
            app.F0BaselinecorrectionCheckBox.Position = [1099 492 124 22];

            % Create ROIintervalSpinnerLabel
            app.ROIintervalSpinnerLabel = uilabel(app.UIFigure);
            app.ROIintervalSpinnerLabel.Position = [1099 192 68 22];
            app.ROIintervalSpinnerLabel.Text = 'ROI interval';

            % Create ROIintervalSpinner
            app.ROIintervalSpinner = uispinner(app.UIFigure);
            app.ROIintervalSpinner.Position = [1182 192 45 22];
            app.ROIintervalSpinner.Value = 1;

            % Create sortCheckBox
            app.sortCheckBox = uicheckbox(app.UIFigure);
            app.sortCheckBox.Text = 'sort';
            app.sortCheckBox.Position = [1100 82 42 22];

            % Create EventRangesEditFieldLabel
            app.EventRangesEditFieldLabel = uilabel(app.UIFigure);
            app.EventRangesEditFieldLabel.Position = [1099 295 88 22];
            app.EventRangesEditFieldLabel.Text = 'Event Range(s)';

            % Create EventRangesEditField
            app.EventRangesEditField = uieditfield(app.UIFigure, 'text');
            app.EventRangesEditField.Position = [1201 295 87 22];

            % Create XLimsEditField_2Label
            app.XLimsEditField_2Label = uilabel(app.UIFigure);
            app.XLimsEditField_2Label.Position = [1099 582 46 22];
            app.XLimsEditField_2Label.Text = 'XLim(s)';

            % Create XLimsEditField_2
            app.XLimsEditField_2 = uieditfield(app.UIFigure, 'text');
            app.XLimsEditField_2.Placeholder = '0:end';
            app.XLimsEditField_2.Position = [1160 582 100 22];
            app.XLimsEditField_2.Value = '0:end';

            % Create OnlyPlotButton
            app.OnlyPlotButton = uibutton(app.UIFigure, 'push');
            app.OnlyPlotButton.ButtonPushedFcn = createCallbackFcn(app, @OnlyPlotButtonPushed, true);
            app.OnlyPlotButton.Position = [1207 49 57 23];
            app.OnlyPlotButton.Text = 'Only Plot';

            % Create Button
            app.Button = uibutton(app.UIFigure, 'push');
            app.Button.ButtonPushedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.Button.Icon = fullfile(pathToMLAPP, '+assets', '向左.svg');
            app.Button.Position = [70 119 39 23];
            app.Button.Text = '';

            % Create Button_2
            app.Button_2 = uibutton(app.UIFigure, 'push');
            app.Button_2.ButtonPushedFcn = createCallbackFcn(app, @Button_2Pushed, true);
            app.Button_2.Icon = fullfile(pathToMLAPP, '+assets', '向右.svg');
            app.Button_2.FontName = 'Arial';
            app.Button_2.Position = [516 119 39 23];
            app.Button_2.Text = '';

            % Create Spinner
            app.Spinner = uispinner(app.UIFigure);
            app.Spinner.ValueChangingFcn = createCallbackFcn(app, @SpinnerValueChanging, true);
            app.Spinner.ValueDisplayFormat = '%.0f';
            app.Spinner.ValueChangedFcn = createCallbackFcn(app, @SpinnerValueChanged, true);
            app.Spinner.Position = [270 115 72 22];
            app.Spinner.Value = 1;

            % Create ManualRegButton
            app.ManualRegButton = uibutton(app.UIFigure, 'push');
            app.ManualRegButton.ButtonPushedFcn = createCallbackFcn(app, @ManualRegButtonPushed, true);
            app.ManualRegButton.Position = [66 36 100 23];
            app.ManualRegButton.Text = 'Manual Reg';

            % Create DiameterSpinnerLabel
            app.DiameterSpinnerLabel = uilabel(app.UIFigure);
            app.DiameterSpinnerLabel.HorizontalAlignment = 'right';
            app.DiameterSpinnerLabel.Position = [578 13 54 22];
            app.DiameterSpinnerLabel.Text = 'Diameter';

            % Create DiameterSpinner
            app.DiameterSpinner = uispinner(app.UIFigure);
            app.DiameterSpinner.Position = [647 13 56 22];
            app.DiameterSpinner.Value = 10;

            % Create MeasureButton
            app.MeasureButton = uibutton(app.UIFigure, 'push');
            app.MeasureButton.ButtonPushedFcn = createCallbackFcn(app, @MeasureButtonPushed, true);
            app.MeasureButton.Position = [719 13 66 23];
            app.MeasureButton.Text = 'Measure';

            % Create UIAxesHomeButton_2
            app.UIAxesHomeButton_2 = uibutton(app.UIFigure, 'push');
            app.UIAxesHomeButton_2.ButtonPushedFcn = createCallbackFcn(app, @UIAxesHomeButton_2Pushed, true);
            app.UIAxesHomeButton_2.Icon = fullfile(pathToMLAPP, '+assets', 'home.svg');
            app.UIAxesHomeButton_2.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];
            app.UIAxesHomeButton_2.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.UIAxesHomeButton_2.Position = [502 674 53 23];
            app.UIAxesHomeButton_2.Text = '';

            % Create DragROIsButton
            app.DragROIsButton = uibutton(app.UIFigure, 'state');
            app.DragROIsButton.ValueChangedFcn = createCallbackFcn(app, @DragROIsButtonValueChanged, true);
            app.DragROIsButton.Icon = fullfile(pathToMLAPP, '+assets', 'drag.svg');
            app.DragROIsButton.Text = 'Drag ROIs';
            app.DragROIsButton.Position = [992 84 91 23];

            % Create ShowROINumbersCheckBox
            app.ShowROINumbersCheckBox = uicheckbox(app.UIFigure);
            app.ShowROINumbersCheckBox.ValueChangedFcn = createCallbackFcn(app, @ShowROINumbersCheckBoxValueChanged, true);
            app.ShowROINumbersCheckBox.Tooltip = {'Show ROI number'};
            app.ShowROINumbersCheckBox.Text = '';
            app.ShowROINumbersCheckBox.Position = [807 675 25 22];
            app.ShowROINumbersCheckBox.Value = true;

            % Create LoadButton
            app.LoadButton = uibutton(app.UIFigure, 'push');
            app.LoadButton.ButtonPushedFcn = createCallbackFcn(app, @LoadButtonPushed, true);
            app.LoadButton.Icon = fullfile(pathToMLAPP, '+assets', 'upload.svg');
            app.LoadButton.Position = [891 707 73 23];
            app.LoadButton.Text = 'Load';

            % Create smoothCheckBox
            app.smoothCheckBox = uicheckbox(app.UIFigure);
            app.smoothCheckBox.Text = 'smooth';
            app.smoothCheckBox.Position = [1099 414 61 22];

            % Create windowsEditFieldLabel
            app.windowsEditFieldLabel = uilabel(app.UIFigure);
            app.windowsEditFieldLabel.Position = [1171 414 51 22];
            app.windowsEditFieldLabel.Text = 'windows';

            % Create windowsEditField
            app.windowsEditField = uieditfield(app.UIFigure, 'numeric');
            app.windowsEditField.Position = [1237 414 54 22];
            app.windowsEditField.Value = 5;

            % Create SaveButton
            app.SaveButton = uibutton(app.UIFigure, 'push');
            app.SaveButton.Icon = fullfile(pathToMLAPP, '+assets', 'save.svg');
            app.SaveButton.Position = [973 707 71 23];
            app.SaveButton.Text = 'Save';

            % Create ROIIDLabel_2
            app.ROIIDLabel_2 = uilabel(app.UIFigure);
            app.ROIIDLabel_2.Position = [762 676 45 22];
            app.ROIIDLabel_2.Text = 'ROI ID ';

            % Create MaskSettingsButton
            app.MaskSettingsButton = uibutton(app.UIFigure, 'push');
            app.MaskSettingsButton.ButtonPushedFcn = createCallbackFcn(app, @MaskSettingsButtonPushed, true);
            app.MaskSettingsButton.Icon = fullfile(pathToMLAPP, '+assets', '', 'setting.svg');
            app.MaskSettingsButton.Position = [842 675 111 23];
            app.MaskSettingsButton.Text = 'Mask Settings';

            % Create SyncUIaxes2
            app.SyncUIaxes2 = uibutton(app.UIFigure, 'push');
            app.SyncUIaxes2.ButtonPushedFcn = createCallbackFcn(app, @SyncUIaxes2Pushed, true);
            app.SyncUIaxes2.Icon = fullfile(pathToMLAPP, '+assets', 'sync.svg');
            app.SyncUIaxes2.Tooltip = {'Sync View'};
            app.SyncUIaxes2.Position = [973 675 38 23];
            app.SyncUIaxes2.Text = '';

            % Create SyncUIaxes1
            app.SyncUIaxes1 = uibutton(app.UIFigure, 'push');
            app.SyncUIaxes1.ButtonPushedFcn = createCallbackFcn(app, @SyncUIaxes1ButtonPushed, true);
            app.SyncUIaxes1.Icon = fullfile(pathToMLAPP, '+assets', 'sync.svg');
            app.SyncUIaxes1.Tooltip = {'Sync View'};
            app.SyncUIaxes1.Position = [455 674 38 23];
            app.SyncUIaxes1.Text = '';

            % Create neddrewriteCheckBox
            app.neddrewriteCheckBox = uicheckbox(app.UIFigure);
            app.neddrewriteCheckBox.Text = 'nedd rewrite';
            app.neddrewriteCheckBox.Position = [50 738 88 22];

            % Create ContrastSliderLabel_2
            app.ContrastSliderLabel_2 = uilabel(app.UIFigure);
            app.ContrastSliderLabel_2.HorizontalAlignment = 'right';
            app.ContrastSliderLabel_2.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ContrastSliderLabel_2.Position = [579 141 50 22];
            app.ContrastSliderLabel_2.Text = 'Contrast';

            % Create ContrastSlider_2
            app.ContrastSlider_2 = uislider(app.UIFigure, 'range');
            app.ContrastSlider_2.Limits = [0 255];
            app.ContrastSlider_2.ValueChangedFcn = createCallbackFcn(app, @ContrastSlider_2ValueChanged2, true);
            app.ContrastSlider_2.ValueChangingFcn = createCallbackFcn(app, @ContrastSlider_2ValueChanging2, true);
            app.ContrastSlider_2.Position = [651 150 413 3];
            app.ContrastSlider_2.Value = [0 255];

            % Create ContrastSlider_2Label
            app.ContrastSlider_2Label = uilabel(app.UIFigure);
            app.ContrastSlider_2Label.HorizontalAlignment = 'right';
            app.ContrastSlider_2Label.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.ContrastSlider_2Label.Position = [61 94 50 22];
            app.ContrastSlider_2Label.Text = 'Contrast';

            % Create ContrastSlider
            app.ContrastSlider = uislider(app.UIFigure, 'range');
            app.ContrastSlider.Limits = [0 2500];
            app.ContrastSlider.ValueChangedFcn = createCallbackFcn(app, @ContrastSliderValueChanged2, true);
            app.ContrastSlider.ValueChangingFcn = createCallbackFcn(app, @ContrastSliderValueChanging2, true);
            app.ContrastSlider.Position = [133 103 413 3];
            app.ContrastSlider.Value = [0 400];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = calcium_signal_extract_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end