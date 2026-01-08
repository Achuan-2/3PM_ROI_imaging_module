classdef simulation_veritical_stripe_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        SimulationofVerticalStripeROIImagingUIFigure  matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        LeftPanel                       matlab.ui.container.Panel
        SvaeMatrixButton                matlab.ui.control.Button
        SaveImageButton                 matlab.ui.control.Button
        TestParamterPanel               matlab.ui.container.Panel
        BidirectionalscanningCheckBox   matlab.ui.control.CheckBox
        Turnaroundright2pixelsSpinner   matlab.ui.control.Spinner
        ScanBackRightpixelLabel         matlab.ui.control.Label
        Turnaroundleft2pixelsSpinner    matlab.ui.control.Spinner
        ScanBackLeftpixelLabel          matlab.ui.control.Label
        PulseperpixelSpinner            matlab.ui.control.Spinner
        PulseperpixelSpinnerLabel       matlab.ui.control.Label
        ImagesizeDropDown               matlab.ui.control.DropDown
        ImagesizeDropDownLabel          matlab.ui.control.Label
        WaitpulseSpinner                matlab.ui.control.Spinner
        WaitpulseSpinnerLabel           matlab.ui.control.Label
        ActualParamterPanel             matlab.ui.container.Panel
        ActualScanFlipCheckBox          matlab.ui.control.CheckBox
        ActualScanBackRightpixelSpinner  matlab.ui.control.Spinner
        ScanBackRight2pixelLabel        matlab.ui.control.Label
        ActualScanBackLeftpixelSpinner  matlab.ui.control.Spinner
        ScanBackLeft2pixelLabel         matlab.ui.control.Label
        ActualWaitpulseSpinner          matlab.ui.control.Spinner
        WaitpulseSpinner_2Label         matlab.ui.control.Label
        RightPanel                      matlab.ui.container.Panel
        UIAxes_2                        matlab.ui.control.UIAxes
        UIAxes                          matlab.ui.control.UIAxes
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    
    properties (Access = private)
        pulseOff = 1;% 代表激光关
        pulseOn = 0; % 代表激光开
        imageSize;
        frameImage;
        roiMask % Description
    end
    
    methods (Access = private)
        
        function main(app)
            get_image_size(app);
            framePulse= create_frame_pulse(app);
            app.frameImage = create_frame_image(app,framePulse);
            plot_figure(app,app.frameImage)

        end
        function plot_figure(app,frameImage)

            imagesc(app.UIAxes,frameImage); 
            drawnow;
            colormap(app.UIAxes,gray());
            app.UIAxes.XLim = [0,app.imageSize];
            app.UIAxes.YLim = [0,app.imageSize];
            set(app.UIAxes_2,'DataAspectRatio',[0.8980099502487562,0.8980099502487562,1])


        end
        
        function get_image_size(app)
            value = app.ImagesizeDropDown.Value;
            switch value
                case '512*512'
                    app.imageSize = 512;
                case '256*256'
                    app.imageSize = 256;
            end
        end

        function create_roi_mask(app)
            
            vectors = [repmat(app.pulseOn,1,32) repmat(app.pulseOff,1,32)]; % 白黑条纹是32个1和32个0，
            binary_im_1d = repmat(vectors,1,app.imageSize*app.imageSize/64); % 组成的图像
            app.roiMask  = ~reshape(binary_im_1d,app.imageSize,app.imageSize)';
        end

        function framePulse= create_frame_pulse(app)
            % 为每一帧生成调制的脉冲
            waitTry = app.WaitpulseSpinner.Value; % unit: pulse
            scanBackLeftPixelDouble = app.Turnaroundleft2pixelsSpinner.Value; % unit: pixel
            scanBackRightPixelDouble = app.Turnaroundright2pixelsSpinner.Value; % unit: pixel
            pulsePerPixel = app.PulseperpixelSpinner.Value;
            

            % Generate ROI mask
            roiMaskPulse = repelem(~app.roiMask, 1, pulsePerPixel); % Each pixel has several pulses, so the signal needs to be repeated
            
            
            % 是否将偶数行信号翻转
            if app.BidirectionalscanningCheckBox.Value

                  roiMaskPulse  = flip_matrix(app,roiMaskPulse);
                  %roiMaskPulse(2:2:end, :) = fliplr(roiMaskPulse(2:2:end, :)); % Because of bidirectional scanning, the laser is scanned from left to right in the first line, and the second line is directly scanned from right, so even rows need to be mirrored
            end

            
            % Add scan right to odd rows
            oddLineSignal = [roiMaskPulse(1:2:end, :) repmat(app.pulseOff, app.imageSize / 2, scanBackRightPixelDouble)];
            
            % Add scan left to even rows
            evenLineSignal = [roiMaskPulse(2:2:end, :) repmat(app.pulseOff, app.imageSize / 2, scanBackLeftPixelDouble)];
            
            % Then the odd row matrix and the even row matrix are pasted together in sequence and reduced to 1*n (considering the impact of changing the length of the array dynamically in the loop on performance, so use this method to optimize)
            signalPulse = reshape([oddLineSignal evenLineSignal]', 1, []);
            
            % Compose the final framePusle
            waitPulse = repmat(app.pulseOff, 1, waitTry); % Add wait time in front
            scanleftFirstPulse = repmat(app.pulseOff, 1, round(scanBackLeftPixelDouble / 2));
            framePulse = [waitPulse, scanleftFirstPulse, signalPulse(1:end - round(scanBackRightPixelDouble / 2))]; % The first scanleft is missing, the last scanright is extra
        end
        
        function [frameImage,imageWidth,leftPaddingActual,rightPaddingActual]= create_frame_image(app,framePulse)
            waitActual = app.ActualWaitpulseSpinner.Value;
            leftPaddingActual = app.ActualScanBackLeftpixelSpinner.Value;
            rightPaddingActual = app.ActualScanBackRightpixelSpinner.Value;
            

            imageWidth = app.imageSize+(leftPaddingActual+rightPaddingActual)/2;
            
            
            % 考虑waitActual
            framePixel = framePulse(waitActual+1:end); % 用于实际成像的pixel信号
            
            % 减去第一个scan left
            framePixel = framePixel(round(leftPaddingActual/2)+1:end);

            % 加上最后一个scanright
            framePixel = [framePixel repmat(app.pulseOff, 1, round(rightPaddingActual / 2))];
            
            % 计算pixel 是否足够，不足补pulseOff,太多则砍掉
            needPixels = (2*app.imageSize+leftPaddingActual+rightPaddingActual)*app.imageSize/2;
            L = length(framePixel);
            if L < needPixels
                framePixel(L+1:needPixels) = app.pulseOff;
            else
                framePixel = framePixel(1:needPixels);
            end

            
            % 复原信号
            frameImage = reshape(framePixel,2*app.imageSize+leftPaddingActual+rightPaddingActual,app.imageSize/2)';
            oddLineSignal = frameImage(:,1:(app.imageSize+rightPaddingActual));
            evenLineSignal = frameImage(:,(app.imageSize+rightPaddingActual+1):end);
            oddRoiSignal = oddLineSignal(:,1:app.imageSize);
            evenRoiSignal = evenLineSignal(:,1:app.imageSize);
            
            frameImage = ones(app.imageSize,app.imageSize);
            frameImage(1:2:end,:) = oddRoiSignal;
            frameImage(2:2:end,:) = evenRoiSignal;

            % 因为scanner会对像素进行翻转
            if app.ActualScanFlipCheckBox.Value
                frameImage  = flip_matrix(app,frameImage);
            end
            
            frameImage = ~frameImage; % 鉴于激光是active low logic，所以取反
            
        end

        function result = flip_matrix(~,matrix)
            for i = 1:size(matrix, 1)
                if mod(i, 2) == 0 % 判断是否是偶数行
                    matrix(i, :) = fliplr(matrix(i, :)); % 利用 fliplr 函数将该行左右翻转
                end
            end
            result = matrix;
        end

    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            get_image_size(app);
            create_roi_mask(app);

            imagesc(app.UIAxes_2,app.roiMask); 
            colormap(app.UIAxes_2,gray()); % 1代表黑，0代表白
            app.UIAxes_2.XLim = [0,app.imageSize];
            app.UIAxes_2.YLim = [0,app.imageSize];
            set(app.UIAxes_2,'DataAspectRatio',[0.8980099502487562,0.8980099502487562,1])
            main(app);

            hold(app.UIAxes,'off');

        end

        % Value changing function: PulseperpixelSpinner
        function PulseperpixelSpinnerValueChanging(app, event)
            main(app);
        end

        % Value changing function: WaitpulseSpinner
        function WaitpulseSpinnerValueChanging(app, event)
            main(app);
        end

        % Value changing function: Turnaroundleft2pixelsSpinner
        function Turnaroundleft2pixelsSpinnerValueChanging(app, event)
            main(app);
        end

        % Value changing function: Turnaroundright2pixelsSpinner
        function Turnaroundright2pixelsSpinnerValueChanging(app, event)
            main(app);
        end

        % Value changed function: BidirectionalscanningCheckBox
        function BidirectionalscanningCheckBoxValueChanged(app, event)
            main(app);
        end

        % Value changing function: ActualWaitpulseSpinner
        function ActualWaitpulseSpinnerValueChanging(app, event)
            main(app);
        end

        % Value changing function: ActualScanBackLeftpixelSpinner
        function ActualScanBackLeftpixelSpinnerValueChanging(app, event)
            main(app);
        end

        % Value changing function: ActualScanBackRightpixelSpinner
        function ActualScanBackRightpixelSpinnerValueChanging(app, event)
            main(app);
        end

        % Value changed function: ImagesizeDropDown
        function ImagesizeDropDownValueChanged(app, event)
            main(app);
        end

        % Value changed function: PulseperpixelSpinner
        function PulseperpixelSpinnerValueChanged(app, event)
            main(app);
        end

        % Value changed function: WaitpulseSpinner
        function WaitpulseSpinnerValueChanged(app, event)
            main(app);
        end

        % Value changed function: Turnaroundleft2pixelsSpinner
        function Turnaroundleft2pixelsSpinnerValueChanged(app, event)
            % app.Turnaroundright2pixelsSpinner.Value = app.Turnaroundleft2pixelsSpinner.Value;
            main(app);
        end

        % Value changed function: Turnaroundright2pixelsSpinner
        function Turnaroundright2pixelsSpinnerValueChanged(app, event)
            main(app);
        end

        % Value changed function: ActualWaitpulseSpinner
        function ActualWaitpulseSpinnerValueChanged(app, event)
            main(app);
        end

        % Value changed function: ActualScanBackLeftpixelSpinner
        function ActualScanBackLeftpixelSpinnerValueChanged(app, event)
            main(app);
        end

        % Value changed function: ActualScanBackRightpixelSpinner
        function ActualScanBackRightpixelSpinnerValueChanged(app, event)
            main(app);
        end

        % Value changed function: ActualScanFlipCheckBox
        function ActualScanFlipCheckBoxValueChanged(app, event)
            main(app);
        end

        % Button pushed function: SaveImageButton
        function SaveImageButtonPushed(app, event)
            [filename, pathname] = uiputfile({'*.jpg';'*.png';'tif'}, 'Save as');
            
            if ischar(filename) && ischar(pathname)
                fullpath = fullfile(pathname, filename);
                imwrite(app.frameImage, fullpath);
            end
        end

        % Button pushed function: SvaeMatrixButton
        function SvaeMatrixButtonPushed(app, event)
            [filename, pathname] = uiputfile({'*.csv'}, 'Save as');
            
            if ischar(filename) && ischar(pathname)
                fullpath = fullfile(pathname, filename);
                writematrix(app.frameImage, fullpath);
            end
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.SimulationofVerticalStripeROIImagingUIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {690, 690};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {314, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create SimulationofVerticalStripeROIImagingUIFigure and hide until all components are created
            app.SimulationofVerticalStripeROIImagingUIFigure = uifigure('Visible', 'off');
            app.SimulationofVerticalStripeROIImagingUIFigure.AutoResizeChildren = 'off';
            app.SimulationofVerticalStripeROIImagingUIFigure.Position = [100 100 821 690];
            app.SimulationofVerticalStripeROIImagingUIFigure.Name = 'Simulation of Vertical Stripe ROI Imaging';
            app.SimulationofVerticalStripeROIImagingUIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.SimulationofVerticalStripeROIImagingUIFigure);
            app.GridLayout.ColumnWidth = {314, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create ActualParamterPanel
            app.ActualParamterPanel = uipanel(app.LeftPanel);
            app.ActualParamterPanel.Title = 'Actual Paramter';
            app.ActualParamterPanel.Position = [24 116 276 202];

            % Create WaitpulseSpinner_2Label
            app.WaitpulseSpinner_2Label = uilabel(app.ActualParamterPanel);
            app.WaitpulseSpinner_2Label.Position = [9 142 69 22];
            app.WaitpulseSpinner_2Label.Text = 'Wait (pulse)';

            % Create ActualWaitpulseSpinner
            app.ActualWaitpulseSpinner = uispinner(app.ActualParamterPanel);
            app.ActualWaitpulseSpinner.ValueChangingFcn = createCallbackFcn(app, @ActualWaitpulseSpinnerValueChanging, true);
            app.ActualWaitpulseSpinner.Limits = [0 Inf];
            app.ActualWaitpulseSpinner.ValueDisplayFormat = '%.0f';
            app.ActualWaitpulseSpinner.ValueChangedFcn = createCallbackFcn(app, @ActualWaitpulseSpinnerValueChanged, true);
            app.ActualWaitpulseSpinner.Position = [165 142 92 22];
            app.ActualWaitpulseSpinner.Value = 56;

            % Create ScanBackLeft2pixelLabel
            app.ScanBackLeft2pixelLabel = uilabel(app.ActualParamterPanel);
            app.ScanBackLeft2pixelLabel.Position = [8 101 139 22];
            app.ScanBackLeft2pixelLabel.Text = 'Turnaround left*2 (pixels)';

            % Create ActualScanBackLeftpixelSpinner
            app.ActualScanBackLeftpixelSpinner = uispinner(app.ActualParamterPanel);
            app.ActualScanBackLeftpixelSpinner.ValueChangingFcn = createCallbackFcn(app, @ActualScanBackLeftpixelSpinnerValueChanging, true);
            app.ActualScanBackLeftpixelSpinner.Limits = [0 Inf];
            app.ActualScanBackLeftpixelSpinner.ValueChangedFcn = createCallbackFcn(app, @ActualScanBackLeftpixelSpinnerValueChanged, true);
            app.ActualScanBackLeftpixelSpinner.Position = [165 101 93 22];
            app.ActualScanBackLeftpixelSpinner.Value = 55;

            % Create ScanBackRight2pixelLabel
            app.ScanBackRight2pixelLabel = uilabel(app.ActualParamterPanel);
            app.ScanBackRight2pixelLabel.Position = [9 61 147 22];
            app.ScanBackRight2pixelLabel.Text = 'Turnaround right*2 (pixels)';

            % Create ActualScanBackRightpixelSpinner
            app.ActualScanBackRightpixelSpinner = uispinner(app.ActualParamterPanel);
            app.ActualScanBackRightpixelSpinner.ValueChangingFcn = createCallbackFcn(app, @ActualScanBackRightpixelSpinnerValueChanging, true);
            app.ActualScanBackRightpixelSpinner.Limits = [0 Inf];
            app.ActualScanBackRightpixelSpinner.ValueDisplayFormat = '%.0f';
            app.ActualScanBackRightpixelSpinner.ValueChangedFcn = createCallbackFcn(app, @ActualScanBackRightpixelSpinnerValueChanged, true);
            app.ActualScanBackRightpixelSpinner.Position = [165 61 94 22];
            app.ActualScanBackRightpixelSpinner.Value = 55;

            % Create ActualScanFlipCheckBox
            app.ActualScanFlipCheckBox = uicheckbox(app.ActualParamterPanel);
            app.ActualScanFlipCheckBox.ValueChangedFcn = createCallbackFcn(app, @ActualScanFlipCheckBoxValueChanged, true);
            app.ActualScanFlipCheckBox.Text = 'Bidirectional scanning';
            app.ActualScanFlipCheckBox.Position = [12 21 139 22];
            app.ActualScanFlipCheckBox.Value = true;

            % Create TestParamterPanel
            app.TestParamterPanel = uipanel(app.LeftPanel);
            app.TestParamterPanel.Title = 'Test Paramter';
            app.TestParamterPanel.Position = [18 408 276 256];

            % Create WaitpulseSpinnerLabel
            app.WaitpulseSpinnerLabel = uilabel(app.TestParamterPanel);
            app.WaitpulseSpinnerLabel.Position = [9 129 69 22];
            app.WaitpulseSpinnerLabel.Text = 'Wait (pulse)';

            % Create WaitpulseSpinner
            app.WaitpulseSpinner = uispinner(app.TestParamterPanel);
            app.WaitpulseSpinner.ValueChangingFcn = createCallbackFcn(app, @WaitpulseSpinnerValueChanging, true);
            app.WaitpulseSpinner.Limits = [0 Inf];
            app.WaitpulseSpinner.ValueChangedFcn = createCallbackFcn(app, @WaitpulseSpinnerValueChanged, true);
            app.WaitpulseSpinner.Position = [164 129 92 22];
            app.WaitpulseSpinner.Value = 56;

            % Create ImagesizeDropDownLabel
            app.ImagesizeDropDownLabel = uilabel(app.TestParamterPanel);
            app.ImagesizeDropDownLabel.Position = [8 206 63 22];
            app.ImagesizeDropDownLabel.Text = 'Image size';

            % Create ImagesizeDropDown
            app.ImagesizeDropDown = uidropdown(app.TestParamterPanel);
            app.ImagesizeDropDown.Items = {'512*512', '256*256'};
            app.ImagesizeDropDown.ValueChangedFcn = createCallbackFcn(app, @ImagesizeDropDownValueChanged, true);
            app.ImagesizeDropDown.Position = [157 206 100 22];
            app.ImagesizeDropDown.Value = '512*512';

            % Create PulseperpixelSpinnerLabel
            app.PulseperpixelSpinnerLabel = uilabel(app.TestParamterPanel);
            app.PulseperpixelSpinnerLabel.Position = [9 167 87 22];
            app.PulseperpixelSpinnerLabel.Text = 'Pulse per pixel';

            % Create PulseperpixelSpinner
            app.PulseperpixelSpinner = uispinner(app.TestParamterPanel);
            app.PulseperpixelSpinner.ValueChangingFcn = createCallbackFcn(app, @PulseperpixelSpinnerValueChanging, true);
            app.PulseperpixelSpinner.Limits = [1 2];
            app.PulseperpixelSpinner.ValueDisplayFormat = '%.0f';
            app.PulseperpixelSpinner.ValueChangedFcn = createCallbackFcn(app, @PulseperpixelSpinnerValueChanged, true);
            app.PulseperpixelSpinner.Editable = 'off';
            app.PulseperpixelSpinner.Position = [164 167 93 22];
            app.PulseperpixelSpinner.Value = 1;

            % Create ScanBackLeftpixelLabel
            app.ScanBackLeftpixelLabel = uilabel(app.TestParamterPanel);
            app.ScanBackLeftpixelLabel.Position = [8 91 139 22];
            app.ScanBackLeftpixelLabel.Text = 'Turnaround left*2 (pixels)';

            % Create Turnaroundleft2pixelsSpinner
            app.Turnaroundleft2pixelsSpinner = uispinner(app.TestParamterPanel);
            app.Turnaroundleft2pixelsSpinner.ValueChangingFcn = createCallbackFcn(app, @Turnaroundleft2pixelsSpinnerValueChanging, true);
            app.Turnaroundleft2pixelsSpinner.Limits = [0 Inf];
            app.Turnaroundleft2pixelsSpinner.ValueChangedFcn = createCallbackFcn(app, @Turnaroundleft2pixelsSpinnerValueChanged, true);
            app.Turnaroundleft2pixelsSpinner.Position = [164 91 92 22];
            app.Turnaroundleft2pixelsSpinner.Value = 55;

            % Create ScanBackRightpixelLabel
            app.ScanBackRightpixelLabel = uilabel(app.TestParamterPanel);
            app.ScanBackRightpixelLabel.Position = [8 53 147 22];
            app.ScanBackRightpixelLabel.Text = 'Turnaround right*2 (pixels)';

            % Create Turnaroundright2pixelsSpinner
            app.Turnaroundright2pixelsSpinner = uispinner(app.TestParamterPanel);
            app.Turnaroundright2pixelsSpinner.ValueChangingFcn = createCallbackFcn(app, @Turnaroundright2pixelsSpinnerValueChanging, true);
            app.Turnaroundright2pixelsSpinner.Limits = [0 Inf];
            app.Turnaroundright2pixelsSpinner.ValueChangedFcn = createCallbackFcn(app, @Turnaroundright2pixelsSpinnerValueChanged, true);
            app.Turnaroundright2pixelsSpinner.Position = [164 53 92 22];
            app.Turnaroundright2pixelsSpinner.Value = 55;

            % Create BidirectionalscanningCheckBox
            app.BidirectionalscanningCheckBox = uicheckbox(app.TestParamterPanel);
            app.BidirectionalscanningCheckBox.ValueChangedFcn = createCallbackFcn(app, @BidirectionalscanningCheckBoxValueChanged, true);
            app.BidirectionalscanningCheckBox.Text = 'Bidirectional scanning';
            app.BidirectionalscanningCheckBox.Position = [11 15 139 22];
            app.BidirectionalscanningCheckBox.Value = true;

            % Create SaveImageButton
            app.SaveImageButton = uibutton(app.LeftPanel, 'push');
            app.SaveImageButton.ButtonPushedFcn = createCallbackFcn(app, @SaveImageButtonPushed, true);
            app.SaveImageButton.Position = [27 73 100 23];
            app.SaveImageButton.Text = 'Save Image';

            % Create SvaeMatrixButton
            app.SvaeMatrixButton = uibutton(app.LeftPanel, 'push');
            app.SvaeMatrixButton.ButtonPushedFcn = createCallbackFcn(app, @SvaeMatrixButtonPushed, true);
            app.SvaeMatrixButton.Position = [186 73 100 23];
            app.SvaeMatrixButton.Text = 'Svae Matrix';

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.RightPanel);
            title(app.UIAxes, 'Simulation')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.PlotBoxAspectRatio = [1.11357340720222 1.11357340720222 1];
            app.UIAxes.Position = [61 7 375 330];

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.RightPanel);
            title(app.UIAxes_2, 'Input ROI mask')
            zlabel(app.UIAxes_2, 'Z')
            app.UIAxes_2.PlotBoxAspectRatio = [1.11357340720222 1.11357340720222 1];
            app.UIAxes_2.Position = [60 366 376 322];

            % Show the figure after all components are created
            app.SimulationofVerticalStripeROIImagingUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = simulation_veritical_stripe_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.SimulationofVerticalStripeROIImagingUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.SimulationofVerticalStripeROIImagingUIFigure)
        end
    end
end