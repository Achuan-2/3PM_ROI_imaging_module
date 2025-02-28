% 生成模拟数据
num_neurons = 10;
num_timepoints = 100;
activity_data = randn(num_neurons, num_timepoints);

% 模拟行为事件在时间点50-60
event_start = 50;
event_end = 60;

% 让某些神经元在事件发生时表现出特异性响应
specific_neurons = [2, 5, 7];
for neuron = specific_neurons
    activity_data(neuron, event_start:event_end+3) = ...
        activity_data(neuron, event_start:event_end+3) + randn(1, event_end-event_start+1+3) + 8;
end

% 最后1个神经元一直活跃
activity_data(num_neurons-1,:) = activity_data(num_neurons-1,:)+5;

% 第3个、第6个随机响应
activity_data(3, 5:20) = activity_data(3, 16)+ randn(1, 16) + 8;
activity_data(6, 70:90) = activity_data(6, 21)+ randn(1, 21) + 8;
% 筛选特异性响应的神经元
significant_neurons = [];
alpha = 0.05    ;  % 显著性水平
num_permutations = 10000;


p_values = zeros(1,num_neurons);
significant = zeros(1,num_neurons);
for neuron = 1:num_neurons
    p_value = permutation_test(activity_data(neuron, :), event_start, event_end, num_permutations);
    p_values(1,neuron) = p_value;
    if p_value < alpha
        significant(1,neuron) = 1;
        
    end
end
significant_neurons = find(significant==1);

disp('特异性响应的神经元:');
disp(significant_neurons);

% 创建表格
T = table((1:num_neurons)', p_values', significant', ...
    'VariableNames', {'NeuronNumber', 'PValue', 'Significant'});

% 保存为Excel文件
writetable(T, 'filter_specific_neurons.xlsx');
% 可视化结果
figure_size = [20,9];
fig = figure('Units','centimeters');  % 设置图形窗口大小
fig.Position(3:4) = figure_size; 
hold on;

% 绘制事件发生的区域
y_max = max(activity_data(:)) + 1;  % 使用数据的最大值加1作为区域的上限
y_min = min(activity_data(:)) - 1;  % 使用数据的最小值减1作为区域的下限
event_patch = patch([event_start event_start event_end event_end], ...
                    [y_min y_max y_max y_min], ...
                    [77, 171, 247]/255, ...
                    'FaceAlpha', 0.3, ...
                    'EdgeColor', 'none', ...
                    'DisplayName','Event');

% 将事件区域移到最底层
uistack(event_patch, 'bottom');

% 添加文字标注
text_x = (event_start + event_end) / 2;  % 文字的x坐标（区域中间）
text_y = y_max+0.5;  % 文字的y坐标（区域中间）
text(text_x, text_y, 'Event', ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle', ...
    'FontWeight', 'bold', ...
    'Color', '#000', ...
    'FontSize', 12);

% 创建colormap
colors = hsv(num_neurons);

% 绘制神经元活动
for neuron = 1:num_neurons
    plot(activity_data(neuron, :), ...
         'Color', colors(neuron, :), ...
         'DisplayName', sprintf('Neuron %d', neuron), ...
         'LineWidth', 2);
end

xlabel('Time', 'FontSize', 14);
ylabel('Activity', 'FontSize', 14);

xlim([0 num_timepoints]);
ylim([min(activity_data(:))-1, max(activity_data(:))+1]);

% 美化坐标轴
ax = gca(fig);

ax.LineWidth = 1.5;
ax.TickDir = 'out';
ax.FontSize = 12;

legend('show','Location', 'eastoutside');

movegui(fig) % make sure figure is not off-screen
hold off;

% 打乱重排测试函数
function p_value = permutation_test(activity, event_start, event_end, num_permutations)
    observed_response = mean(activity(event_start:event_end));
    permuted_responses = zeros(1, num_permutations);
    
    for i = 1:num_permutations
        permuted_activity = activity(randperm(length(activity)));
        permuted_responses(i) = mean(permuted_activity(event_start:event_end));
    end
    
    p_value = sum(permuted_responses >= observed_response) / num_permutations;
end
