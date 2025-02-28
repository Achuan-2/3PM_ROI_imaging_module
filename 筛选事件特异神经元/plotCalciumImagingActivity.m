


function plotCalciumImagingActivity(time, neuron_data, roi_indexs,event,plot_scale_bar_time)
    % Function to plot calcium imaging activity of neurons
    
    arguments
        time % % time: vector of time points
        neuron_data % matrix where each row represents a neuron's activity
        roi_indexs  % roi_indexs: 选择哪些ROI展示
        event = struct() % 事件开始和结束、事件名称，event.start event.end,event.name
        plot_scale_bar_time = false % 是否绘制时间上的scale bar
    end
    % 配置
    signal_spacing = 5;
    scale_bar_height = 5;
    scale_bar_time = 10;
    ylim_min = -4;

    % 检查time 和neuron_data维度是否一样
    numNeurons = size(neuron_data, 1);
    if length(time) ~= size(neuron_data, 2)
        error("time和neuron data的时间维度要一致！")
    end
    % Create a figure
    figure;
    ax = gca;
    hold on;


    

    roi_indexs = sort(roi_indexs); % 排序
    valid_filter = (roi_indexs >= 1) & (roi_indexs <= numNeurons);
    roi_indexs = roi_indexs(valid_filter); % 过滤

    selected_roi_num = length(roi_indexs);

    y_ticks = zeros(1,selected_roi_num);
    % colormap
    colors = turbo(numNeurons);
    % Plot each neuron's activity
    for i = 1:selected_roi_num
        i_roi = roi_indexs(i);
        i_signal = neuron_data(i_roi,:);
        
        % get roi color: random color or fixed color
        % roi_color = '#000'
        roi_color = colors(i,:);

        % plot
        i_roi_height = (i-1)*signal_spacing;
        plot(ax,time,i_roi_height+i_signal,'Color',roi_color,'LineWidth',1.5);
        y_ticks(i) = i_roi_height;
        if i == selected_roi_num
            last_signal_height = max(i_signal);
        end
    end
    % add roi index label
    roi_names = strcat('n_', {'{'},  arrayfun(@num2str, roi_indexs, 'UniformOutput', false),{'}'});
    % Pad each label with spaces to align them
    max_length = max(cellfun(@length, roi_names));
    roi_names_padded = cellfun(@(x) sprintf('%-*s', max_length, x), roi_names, 'UniformOutput', false);
    ax.YTick = y_ticks;
    ax.YTickLabel = roi_names_padded;



    if plot_scale_bar_time
        ax.XAxis.Visible = 'off';
    else
        ax.XAxis.TickLength  = [0,0];
    end

    ax.YAxis.TickLength  = [0,0];
    pause(0.5);
    ax.YRuler.Axle.Visible = 'off';     

    % 绘制事件发生的区域
    y_max = ax.YLim(2);  % 使用数据的最大值加1作为区域的上限
    y_min = ax.YLim(1);  % 使用数据的最小值减1作为区域的下限
    if numel(fieldnames(event)) > 0
        event_patch = patch([event.start event.start event.end event.end], ...
            [y_min y_max y_max y_min], ...
            [77, 171, 247]/255, ...
            'FaceAlpha', 0.2, ...
            'EdgeColor', 'none', ...
            'DisplayName',event.name);

        % 将事件区域移到最底层
        uistack(event_patch, 'bottom');

        % 添加文字标注
        text_x = (event.start + event.end) / 2;  % 文字的x坐标（区域中间）
        text_y = y_max+0.5;  % 文字的y坐标（区域中间）
        text(text_x, text_y, 'Event', ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', ...
            'FontWeight', 'bold', ...
            'Color', '#000', ...
            'FontSize', 12);
    end



    % add scalebar  
    scalebar_position_x = time(end)-1;
    scalebar_position_y =i_roi_height+last_signal_height;
    

    if plot_scale_bar_time
        plot(ax,[scalebar_position_x-scale_bar_time scalebar_position_x  scalebar_position_x], ...
            [scalebar_position_y+scale_bar_height scalebar_position_y+scale_bar_height scalebar_position_y], ...
            'k-','linewidth',1.5);
        % time label
        text(ax,scalebar_position_x-scale_bar_time/2,scalebar_position_y+scale_bar_height+1,sprintf('%d s',scale_bar_time),'horiz','center','vert','bottom','fontsize',12);
        % signal label
        text(ax,scalebar_position_x+1,scalebar_position_y+scale_bar_height/2,sprintf('%d\\sigma',scale_bar_height),'horiz','left','vert','middle','fontsize',12); 

    else
        plot(ax,[scalebar_position_x  scalebar_position_x],[scalebar_position_y+scale_bar_height scalebar_position_y],'k-','linewidth',1);
        text(ax,scalebar_position_x-1,scalebar_position_y+scale_bar_height/2,sprintf('%d\\sigma',scale_bar_height),'horiz','right','vert','middle','fontsize',12); 

    end

    % set ylim
    ax.YLim = [ylim_min scalebar_position_y+scale_bar_height];
end
