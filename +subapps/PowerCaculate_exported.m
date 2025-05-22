classdef PowerCaculate_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        GridLayout3                   matlab.ui.container.GridLayout
        CaculateROIimagingpowerPanel  matlab.ui.container.Panel
        GridLayout2                   matlab.ui.container.GridLayout
        PowerCostEditField            matlab.ui.control.NumericEditField
        PowerCostEditFieldLabel       matlab.ui.control.Label
        ROIPowerEditField             matlab.ui.control.NumericEditField
        ROIPowermWEditField_2Label    matlab.ui.control.Label
        StructurePowerEditField       matlab.ui.control.NumericEditField
        MHzPowermWEditFieldLabel      matlab.ui.control.Label
        GetLaserPowerPanel            matlab.ui.container.Panel
        GridLayout                    matlab.ui.container.GridLayout
        hBeamsIDEditField             matlab.ui.control.NumericEditField
        hBeamsIDEditFieldLabel        matlab.ui.control.Label
        ImagingPowerEditField         matlab.ui.control.NumericEditField
        LaserPowermWLabel             matlab.ui.control.Label
        UpdateButton                  matlab.ui.control.Button
    end

    
    properties (Access = public)
        MainApp % 主程序
    end
    
    methods (Access = public)
        function variableInit(app)
            app.hBeamsIDEditField.Value = app.MainApp.PowerCaculatConfig.hBeamID;
        end
        function update_scanimage_power(app,~,~)
            try
                % get scanimage power fraction and caculate the laser power by lut
                app.get_scanimage_power();
                % caculate 0.1MHz and ROI actual power
                app.caculate_power();
            catch ME
                % 捕获并显示错误信息
                errordlg("get scanimage power error", 'Error');
                fprintf(2,'%s\n', ME.getReport('extended'));
            end
        end
        function caculate_power(app)
            % 计算理想激光功率，方便调整
            % get value
            imagingPower= app.ImagingPowerEditField.Value;
            powerCost = app.PowerCostEditField.Value;
            roiRatio = app.ROIRatioEditField.Value;
            scanArea = (app.scannerConfig.scanBackLeftPixelTwice/2+app.scannerConfig.imageSize+app.scannerConfig.scanBackRightPixelTwice/2)*app.scannerConfig.imageSize+app.scannerConfig.scanWait;
            acquisitionArea = app.scannerConfig.imageSize*app.scannerConfig.imageSize;
            fillfraction = acquisitionArea/scanArea;

            % caculate power
            %structurePower = imagingPower *0.1* powerCost*fillfraction;
            structurePower = imagingPower *0.1;
            roiPower = imagingPower*roiRatio*fillfraction*powerCost;

            % update value in gui
            app.StructurePowerEditField.Value = structurePower;
            app.ROIPowerEditField.Value = roiPower;
        end
        function get_scanimage_power(app)
            hBeamsID = app.hBeamsIDEditField.Value;
            lut = app.MainApp.hSI.hBeams.hBeams{hBeamsID}.powerFraction2PowerWattLut;
            fraction = app.MainApp.hSI.hBeams.powerFractions{hBeamsID};
            power_W = utils.interp1_extended(lut(:,1),lut(:,2),fraction,'linear','extrap'); % unit: W
            app.ImagingPowerEditField.Value = round(power_W(1)*10^3);
        end

    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp)
            app.MainApp = mainApp;
            app.UIFigure.Position(1) = app.MainApp.UIFigure.Position(1)+app.MainApp.UIFigure.Position(3)+5;
            app.UIFigure.Position(2) = app.MainApp.UIFigure.Position(2)+app.MainApp.UIFigure.Position(4)-app.UIFigure.Position(4);
            variableInit(app)
            UpdateButtonPushed(app);
        end

        % Button pushed function: UpdateButton
        function UpdateButtonPushed(app, event)
            if isa(app.MainApp.hSI,'scanimage.SI') && ~isempty(app.MainApp.hSI)
                update_scanimage_power(app);
            else
                uialert(app.MainApp.UIFigure,"Please Start Scanimage First",'Warning','Icon','warning','Modal',false);
            end

        end

        % Value changed function: ImagingPowerEditField
        function ImagingPowerEditFieldValueChanged(app, event)
            caculate_power(app);
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            app.MainApp.PowerCaculateAPP = [];
            delete(app)
            
        end

        % Value changed function: hBeamsIDEditField
        function hBeamsIDEditFieldValueChanged(app, event)
            app.MainApp.PowerCaculatConfig.hBeamID = app.hBeamsIDEditField.Value;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 262 320];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.UIFigure);
            app.GridLayout3.ColumnWidth = {'1x'};

            % Create GetLaserPowerPanel
            app.GetLaserPowerPanel = uipanel(app.GridLayout3);
            app.GetLaserPowerPanel.Title = 'Get Laser Power';
            app.GetLaserPowerPanel.Layout.Row = 1;
            app.GetLaserPowerPanel.Layout.Column = 1;

            % Create GridLayout
            app.GridLayout = uigridlayout(app.GetLaserPowerPanel);
            app.GridLayout.RowHeight = {'1x', '1x', '1x'};
            app.GridLayout.ColumnSpacing = 5.5;
            app.GridLayout.RowSpacing = 14;
            app.GridLayout.Padding = [5.5 14 5.5 14];

            % Create UpdateButton
            app.UpdateButton = uibutton(app.GridLayout, 'push');
            app.UpdateButton.ButtonPushedFcn = createCallbackFcn(app, @UpdateButtonPushed, true);
            app.UpdateButton.Layout.Row = 3;
            app.UpdateButton.Layout.Column = 2;
            app.UpdateButton.Text = 'Update';

            % Create LaserPowermWLabel
            app.LaserPowermWLabel = uilabel(app.GridLayout);
            app.LaserPowermWLabel.Layout.Row = 2;
            app.LaserPowermWLabel.Layout.Column = 1;
            app.LaserPowermWLabel.Text = 'Laser  Power(mW)';

            % Create ImagingPowerEditField
            app.ImagingPowerEditField = uieditfield(app.GridLayout, 'numeric');
            app.ImagingPowerEditField.ValueChangedFcn = createCallbackFcn(app, @ImagingPowerEditFieldValueChanged, true);
            app.ImagingPowerEditField.HorizontalAlignment = 'left';
            app.ImagingPowerEditField.Layout.Row = 2;
            app.ImagingPowerEditField.Layout.Column = 2;

            % Create hBeamsIDEditFieldLabel
            app.hBeamsIDEditFieldLabel = uilabel(app.GridLayout);
            app.hBeamsIDEditFieldLabel.Layout.Row = 1;
            app.hBeamsIDEditFieldLabel.Layout.Column = 1;
            app.hBeamsIDEditFieldLabel.Text = 'hBeams ID';

            % Create hBeamsIDEditField
            app.hBeamsIDEditField = uieditfield(app.GridLayout, 'numeric');
            app.hBeamsIDEditField.ValueChangedFcn = createCallbackFcn(app, @hBeamsIDEditFieldValueChanged, true);
            app.hBeamsIDEditField.HorizontalAlignment = 'left';
            app.hBeamsIDEditField.Layout.Row = 1;
            app.hBeamsIDEditField.Layout.Column = 2;
            app.hBeamsIDEditField.Value = 2;

            % Create CaculateROIimagingpowerPanel
            app.CaculateROIimagingpowerPanel = uipanel(app.GridLayout3);
            app.CaculateROIimagingpowerPanel.Title = 'Caculate ROI imaging power';
            app.CaculateROIimagingpowerPanel.Layout.Row = 2;
            app.CaculateROIimagingpowerPanel.Layout.Column = 1;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.CaculateROIimagingpowerPanel);
            app.GridLayout2.RowHeight = {'1x', '1x', '1x'};
            app.GridLayout2.ColumnSpacing = 5.75;
            app.GridLayout2.RowSpacing = 13.25;
            app.GridLayout2.Padding = [5.75 13.25 5.75 13.25];

            % Create MHzPowermWEditFieldLabel
            app.MHzPowermWEditFieldLabel = uilabel(app.GridLayout2);
            app.MHzPowermWEditFieldLabel.Layout.Row = 2;
            app.MHzPowermWEditFieldLabel.Layout.Column = 1;
            app.MHzPowermWEditFieldLabel.Text = '0.1MHz Power(mW)';

            % Create StructurePowerEditField
            app.StructurePowerEditField = uieditfield(app.GridLayout2, 'numeric');
            app.StructurePowerEditField.Editable = 'off';
            app.StructurePowerEditField.HorizontalAlignment = 'left';
            app.StructurePowerEditField.Layout.Row = 2;
            app.StructurePowerEditField.Layout.Column = 2;

            % Create ROIPowermWEditField_2Label
            app.ROIPowermWEditField_2Label = uilabel(app.GridLayout2);
            app.ROIPowermWEditField_2Label.Layout.Row = 3;
            app.ROIPowermWEditField_2Label.Layout.Column = 1;
            app.ROIPowermWEditField_2Label.Text = 'ROI Power(mW)';

            % Create ROIPowerEditField
            app.ROIPowerEditField = uieditfield(app.GridLayout2, 'numeric');
            app.ROIPowerEditField.Editable = 'off';
            app.ROIPowerEditField.HorizontalAlignment = 'left';
            app.ROIPowerEditField.Layout.Row = 3;
            app.ROIPowerEditField.Layout.Column = 2;

            % Create PowerCostEditFieldLabel
            app.PowerCostEditFieldLabel = uilabel(app.GridLayout2);
            app.PowerCostEditFieldLabel.Layout.Row = 1;
            app.PowerCostEditFieldLabel.Layout.Column = 1;
            app.PowerCostEditFieldLabel.Text = 'Power Cost';

            % Create PowerCostEditField
            app.PowerCostEditField = uieditfield(app.GridLayout2, 'numeric');
            app.PowerCostEditField.HorizontalAlignment = 'left';
            app.PowerCostEditField.Layout.Row = 1;
            app.PowerCostEditField.Layout.Column = 2;
            app.PowerCostEditField.Value = 1;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = PowerCaculate_exported(varargin)

            runningApp = getRunningApp(app);

            % Check for running singleton app
            if isempty(runningApp)

                % Create UIFigure and components
                createComponents(app)

                % Register the app with App Designer
                registerApp(app, app.UIFigure)

                % Execute the startup function
                runStartupFcn(app, @(app)startupFcn(app, varargin{:}))
            else

                % Focus the running singleton app
                figure(runningApp.UIFigure)

                app = runningApp;
            end

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