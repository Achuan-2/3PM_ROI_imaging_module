% a = components.DrawROI()
% 1. 鼠标右键添加起始点，起始点要有一个大圆圈示意
% 2. 鼠标移动轨迹绘制
% 3. 轨迹闭合，停止绘制
% 4. 把轨迹变为ROI mask,roi颜色不一致:  mask = poly2mask(a.strokes{1}(:,1),a.strokes{1}(:,2),512,512)
% 5. 支持删除roi mask
classdef DrawROI2 < handle
    properties(SetAccess=public)
        fig;
        isDrawing = false;
        lastPosition = [0, 0];
        startPosition = [0,0];
        nRoi  =0;
        strokes;
        current_stroke; % ROI路径
        brush_size =4;
        hs = [];
        h;
    end
    methods (Hidden)
        function self = DrawROI2()
            assignin("base","self",self)
            self.fig = figure;

            xlim([1,512]);
            ylim([1,512]);% 指定范围

            random = rand(512, 512, 3);
            imshow(random,[]);

            hold on;
    
           im = imread('cellpose_test.tif');
           self.h = imshow(im);
            [M,N] = size(im);
            block_size = 50;
            P = ceil(M / block_size);
            Q = ceil(N / block_size);
            alpha = checkerboard(block_size,P, Q) > 0;
                alpha = alpha(1:M, 1:N);
            set(self.h, 'AlphaData', alpha);
            set(self.fig, 'WindowButtonDownFcn', @self.start_drawing);

            set(self.fig, 'WindowButtonMotionFcn', @self.mouse_move);
        end

        function start_drawing(self,~, ~)
            % TODO:现在是随意点击右键都会激发这个函数
            if ~self.isDrawing
                if strcmp(get(self.fig,'SelectionType'),'extend')
                    self.isDrawing = true;

                    currentPosition = get(gca, 'CurrentPoint');
                    x = currentPosition(1,1);
                    y = currentPosition(1,2);
                    self.startPosition = [x,y];
                    self.lastPosition = [x,y];
                    self.current_stroke = [self.current_stroke;self.startPosition];

                    h = plot(x,y, 'ro', 'MarkerSize', 8);  % 绘制起始点的红色圆圈
                    self.hs = [self.hs, h];
                    axis([1,512,1,512]);
                end
            end
        end
        function mouse_move(self,~,~)
            % 鼠标移动过程中的绘图
            if self.isDrawing
                currentPosition = get(gca, 'CurrentPoint');
                x = currentPosition(1,1);
                y = currentPosition(1,2);
                hold on;
                
                if ~self.is_at_start()
                    % draw stroke
                    h = plot([self.lastPosition(1), x], [self.lastPosition(2), y],Color='r',LineWidth=3);  % 绘制红色线段
                    self.hs = [self.hs, h];
                    self.lastPosition = [x, y];
                    axis([1,512,1,512]);

                    self.current_stroke = [self.current_stroke;[x,y]];
                else
                    % end stroke
                    %disp("end stroke")
                    self.isDrawing = false;
                    self.lastPosition = zeros(1,2);
                    self.startPosition = [];

                    self.nRoi = self.nRoi + 1;

                    for i = 1:length(self.hs)
                        set(self.hs(i), 'Visible', 'off');
                    end
                    
                    hRoi = images.roi.Freehand(gca,'Position',self.current_stroke,'Color',rand(1, 3),'MarkerSize',6,'LineWidth',2.25,'SelectedColor',"red");
                    temp = hRoi.Waypoints;
                    hRoi.Waypoints(1:end) = false;
                    % 添加自定义UIContextMenu
                    hMenu = get(hRoi, 'ContextMenu');
                    % 删除第一个菜单项
                    delete(hMenu.Children(1));
                    %item1 = uimenu(hMenu, 'Text', 'Show/Hide Waypoints', 'Callback', @waypoints_event);
                    %hRoi.UIContextMenu = hMenu;


                    self.strokes{self.nRoi} = self.current_stroke;
                    self.current_stroke = [];
                    self.hs = [];
                end
            end

            function waypoints_event(~,~)
                if any(hRoi.Waypoints)
                    %有waypoints，说明需要隐藏
                    hRoi.Waypoints(1:end) = false;
                else
                    hRoi.Waypoints(1:end) = temp;
                end
            end
        end

        function result = is_at_start(self)
            % 需要设置至少距离大于多少后，才去判断是否靠近起始点，否则一开始画就end stroke了
            thresh_out = max(6,self.brush_size*3); %max(6,self.brush_size*3);
            thresh_in = 4; %max(3,self.brush_size*1.8);
            if length(self.current_stroke)>3
                
                dist = sqrt(sum((self.current_stroke(1,:)-self.current_stroke(2:end,:)).^2, 2));
                dist = dist(:);
                has_left = find(dist > thresh_out);
                if ~isempty(has_left)
                    first_left = min(has_left);
                    has_returned = sum(dist(max(4, first_left+1):end) < thresh_in);
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
    end

end



