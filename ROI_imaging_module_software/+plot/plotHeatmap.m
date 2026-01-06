function fig = plotHeatmap(matrix_data, ops)
    % matrix_data: the data matrix to plot
    % ops.savePath: directory where the plot will be saved (optional)
    % ops.saveFileName: name of the file to save the plot as (optional)
    arguments
        matrix_data
        ops.savePath = '' % 默认为空字符串，表示不保存
        ops.saveFileName = '' % 默认为空字符串，表示不保存
        ops.selected_roi_str = '' % string of selected ROIs
        ops.frame_rate = 1 % frame rate for time calculation
        ops.event = struct('start', 0, 'end', 0, 'name', '', 'color', '#000000') % event details in seconds
        ops.sort = false % whether to sort the data
        ops.xlim = '0:end' % x-axis limits in seconds, can be a string like '0:end', '1:10' or a numeric array [start, end]
        ops.xtick_interval = [] % interval for x-axis ticks in seconds
        ops.colormap = 'jet' % colormap for the heatmap
        ops.fig = [] % figure handle for plotting
        ops.signal_type = 'ΔF/F' % type of signal: 'ΔF/F', 'zscore', or 'raw'
    end
    
    [numNeurons, n_frame] = size(matrix_data);
    time = (1:n_frame) / ops.frame_rate;
    
    % Determine ROI indices
    if isempty(ops.selected_roi_str)
        roi_indexs = 1:numNeurons;
    else
        specified_roi = sort(str2num(ops.selected_roi_str));
        index_filter = (specified_roi >= 1) & (specified_roi <= numNeurons);
        roi_indexs = specified_roi(index_filter);
    end
    
    % Sort the data if needed
    if ops.sort
        % Calculate the pairwise distance between rows
        distance_matrix = pdist(matrix_data, 'euclidean');
        % Perform hierarchical clustering
        linkage_tree = linkage(distance_matrix, 'average');
        % Determine the order of rows based on clustering
        cluster_order = optimalleaforder(linkage_tree, distance_matrix);
        % Reverse the cluster order
        cluster_order = flip(cluster_order);
        % Sort the matrix data based on clustering
        matrix_data = matrix_data(cluster_order, :);
        
        % Adjust filename to indicate sorting
        suffix = '_sorted';
    else
        suffix = '';
    end
    
    % 绘制热图
    data = matrix_data(roi_indexs, :);
    
    % 创建图形
    figure_size = [20, 9];
    if isempty(ops.fig)
        fig = figure('Units', 'centimeters');
        fig.Position(3:4) = figure_size;
    else
        fig = ops.fig;
        figure(fig); % 激活传入的figure对象
        clf(fig); % 清除当前figure的内容
        fig.Units = 'centimeters';
        % fig.Position(3:4) = figure_size;
    end
    
    imagesc(time, 1:size(data, 1), data); % Plot heatmap with time on x-axis
    
    % Add labels
    xlabel('Time(s)');
    ylabel('Cell Number');
    box off;
    ax = gca;
    ax.TickDir = 'out';
    
    % Set X-axis tick marks if interval is specified
    if ~isempty(ops.xtick_interval) && ops.xtick_interval > 0
        xtick = 0:ops.xtick_interval:time(end);
        ax.XTick = xtick;
    end
    
    % Set X-axis limits if specified
    % 处理 xlim 参数
    if ischar(ops.xlim) || isstring(ops.xlim)
        if strcmpi(ops.xlim, '0:end') || strcmpi(ops.xlim, '') || strcmpi(ops.xlim, '0')
            % 默认情况：显示全部范围
            ax.XLim = [0, time(end)];
        else
            % 尝试解析字符串格式的范围，如 '1:10'
            try
                parts = split(ops.xlim, ':');
                if length(parts) == 2
                    xlim_start = str2double(parts{1});
                    if strcmpi(parts{2}, 'end')
                        xlim_end = time(end);
                    else
                        xlim_end = str2double(parts{2});
                    end
                    
                    % 确保范围有效
                    xlim_start = max(0, xlim_start);
                    xlim_end = min(time(end), xlim_end);
                    if xlim_start < xlim_end
                        ax.XLim = [xlim_start, xlim_end];
                    else
                        ax.XLim = [0, time(end)];
                    end
                else
                    ax.XLim = [0, time(end)];
                end
            catch
                ax.XLim = [0, time(end)];
            end
        end
    elseif isnumeric(ops.xlim) && length(ops.xlim) == 2
        % 数值型 xlim [start, end]
        xlim_start = max(0, ops.xlim(1));
        xlim_end = min(time(end), ops.xlim(2));
        if xlim_start < xlim_end
            ax.XLim = [xlim_start, xlim_end];
        else
            ax.XLim = [0, time(end)];
        end
    else
        % 默认情况
        ax.XLim = [0, time(end)];
    end
    
    
    % Set colormap: parula, jet
    colormap(ops.colormap);
    % clim([-0.5, 0.5]);
    % Add colorbar
    c = colorbar;
    % set(c, 'Ticks', [-0.5,-0.4,-0.3,-0.2,-0.1, 0, 0.1, 0.2, 0.3, 0.4, 0.5]);
    
    % Set colorbar label based on signal type
    switch ops.signal_type
        case 'ΔF/F'
            title(c, '\DeltaF/F');
        case 'zscore'
            title(c, 'z-score');
        case 'raw'
            title(c, 'Pixel Value');
        otherwise
            title(c, '\DeltaF/F'); % 默认标签
    end
    
    % Handle event marking
    hold on; % Retain current plot
    y_limits = ylim; % Get y-axis limits
    
    % 设置 Y 轴只显示整数刻度（神经元编号）
    num_cells = size(data, 1);
    if num_cells <= 20
        % 如果神经元数量较少，全部显示
        yticks(1:num_cells);
    else
        % 如果神经元数量较多，适当间隔显示
        step = max(1, round(num_cells/20));
        ytick_values = 1:step:num_cells;
        % if ytick_values(end) < num_cells
        %     ytick_values = [ytick_values, num_cells]; % 确保显示最后一个神经元的编号
        % end
        yticks(ytick_values);
    end
    
    % Mark event according to event structure
    if ops.event.start > 0 && ops.event.end > 0
        % Create a patch for the event region
        patch([ops.event.start, ops.event.start, ops.event.end, ops.event.end], ...
            [y_limits(1), y_limits(2), y_limits(2), y_limits(1)], ...
            utils.hex2matrix(ops.event.color) / 255, ...
            'FaceAlpha', 0.2, 'EdgeColor', 'none', 'DisplayName', ops.event.name);
        
        if ~isempty(ops.event.name)
            text_x = (ops.event.start + ops.event.end) / 2;
            text_y = 0.4; % Adjust y position for text
            text(text_x, text_y, ops.event.name, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
                'FontWeight', 'bold', 'Color', '#000', 'FontSize', 12);
        end
    elseif ops.event.start > 0 && ops.event.end == 0
        % Draw a vertical line at event start
        line([ops.event.start ops.event.start], y_limits, 'Color', ops.event.color, 'LineStyle', '--', 'LineWidth', 1.5);
        
        if ~isempty(ops.event.name)
            text(ops.event.start, 0.4, ops.event.name, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
                'FontWeight', 'bold', 'Color', '#000', 'FontSize', 12);
        end
    end
    
    hold off;
    
    % Save the figure if savePath and saveFileName are provided
    if ~isempty(ops.savePath) && ~isempty(ops.saveFileName)
        % Ensure savePath exists
        if ~exist(ops.savePath, 'dir')
            mkdir(ops.savePath);
        end
        
        % Save the figure
        saveas(fig, fullfile(ops.savePath, strcat(ops.saveFileName, '_heatmap', suffix, '.png')));
        saveas(fig, fullfile(ops.savePath, strcat(ops.saveFileName, '_heatmap', suffix, '.pdf')));
        saveas(fig, fullfile(ops.savePath, strcat(ops.saveFileName, '_heatmap', suffix, '.fig')));
    end
    
    % Note: We don't close the figure automatically now, so the user can continue working with it
end
