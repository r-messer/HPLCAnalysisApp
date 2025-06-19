classdef HPLCAnalysis_Layout2 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure           matlab.ui.Figure
        menuFile           matlab.ui.container.Menu
        LoadDataMenu       matlab.ui.container.Menu
        LoadWorkspaceMenu  matlab.ui.container.Menu
        SaveWorkspaceMenu  matlab.ui.container.Menu
        CloseMenu          matlab.ui.container.Menu
        menuProcess        matlab.ui.container.Menu
        PreprocessAllMenu  matlab.ui.container.Menu
        LeftPanel          matlab.ui.container.Panel
        IntegratedCurveAxis   matlab.ui.control.UIAxes
        RightPanel         matlab.ui.container.Panel
        RightButton        matlab.ui.control.Button
        LeftButton         matlab.ui.control.Button
        ChromatogramAxis   matlab.ui.control.UIAxes
        GroupsPanel        matlab.ui.container.Panel
        ImportPanel        matlab.ui.container.Panel
        ChromatogramPanel  matlab.ui.container.Panel
        ChromatogramOptions matlab.ui.container.Panel
        CurveOptions       matlab.ui.container.Panel
        ContainerPanel     matlab.ui.container.Panel
        CurvesPanel        matlab.ui.container.Panel
        OptionsPanel       matlab.ui.container.Panel
        Data % Struct aray holding data
        ImportListBox; 
        MainGrid           matlab.ui.container.GridLayout
        CenterPanel        matlab.ui.container.Panel

    end

    properties (Access = private)
        ImportGrid; % Layout container for file list
        RawFiles; % Cell array of full file paths to loaded .csv/.txt files

        
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        
        function createComponents(app)
        
            % Create UIFigure
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1440 864];
            app.UIFigure.Name = 'HPLC Analysis App';
        
            %---------------------- MAIN LAYOUT ----------------------%
            app.MainGrid = uigridlayout(app.UIFigure, [1, 3]);
            app.MainGrid.ColumnWidth = {360, '1x', 200};
            app.MainGrid.RowHeight = {'1x'};
        
            %---------------------- LEFT PANEL ----------------------%
            app.LeftPanel = uipanel(app.MainGrid);
            app.LeftPanel.Title = 'Controls';
            app.LeftPanel.Layout.Column = 1;
            leftGrid = uigridlayout(app.LeftPanel, [2, 1]);
            leftGrid.RowHeight = {'1x', '1x'};
        
            % Import Panel
            app.ImportPanel = uipanel(leftGrid);
            app.ImportPanel.Title = 'Import';
            app.ImportPanel.Layout.Row = 1;
        
            % Inside ImportPanel: Grid + ListBox
            app.ImportGrid = uigridlayout(app.ImportPanel, [1, 1]);
            app.ImportGrid.Scrollable = 'on';
            app.ImportGrid.RowHeight = {'1x'};
            app.ImportGrid.ColumnWidth = {'1x'};
        
            app.ImportListBox = uilistbox(app.ImportGrid);
            app.ImportListBox.Multiselect = 'off';
        
            % Groups Panel
            app.GroupsPanel = uipanel(leftGrid);
            app.GroupsPanel.Title = 'Groups';
            app.GroupsPanel.Layout.Row = 2;
        
            %---------------------- CENTER PANEL ----------------------%
            app.CenterPanel = uipanel(app.MainGrid);
            app.CenterPanel.Title = '';
            app.CenterPanel.Layout.Column = 2;
            centerGrid = uigridlayout(app.CenterPanel, [2, 1]);
            centerGrid.RowHeight = {'2x', '1x'};
        
            % Chromatogram Panel
            app.ChromatogramPanel = uipanel(centerGrid);
            app.ChromatogramPanel.Title = 'Chromatogram';
            app.ChromatogramPanel.Layout.Row = 1;
        
            app.ChromatogramAxis = uiaxes(app.ChromatogramPanel);
            app.ChromatogramAxis.Position = [20 40 800 440];
            title(app.ChromatogramAxis, 'Chromatogram');
            xlabel(app.ChromatogramAxis, 'Time (min)');
            ylabel(app.ChromatogramAxis, 'Absorbance (mAU)');
        
            % Curves Panel
            app.CurvesPanel = uipanel(centerGrid);
            app.CurvesPanel.Title = 'Integrated Curves';
            app.CurvesPanel.Layout.Row = 2;
        
            app.IntegratedCurveAxis = uiaxes(app.CurvesPanel);
            app.IntegratedCurveAxis.Position = [20 20 800 300];
            title(app.IntegratedCurveAxis, 'Kinetic Curve');
            xlabel(app.IntegratedCurveAxis, 'Time (min)');
            ylabel(app.IntegratedCurveAxis, 'Signal');
        
            %---------------------- RIGHT PANEL ----------------------%
            app.OptionsPanel = uipanel(app.MainGrid);
            app.OptionsPanel.Title = '';
            app.OptionsPanel.Layout.Column = 3;
            rightGrid = uigridlayout(app.OptionsPanel, [2, 1]);
            rightGrid.RowHeight = {'1x', '1x'};
        
            % Chromatogram Options
            app.ChromatogramOptions = uipanel(rightGrid);
            app.ChromatogramOptions.Title = 'Chromatogram Options';
            app.ChromatogramOptions.Layout.Row = 1;
        
            % Curve Options
            app.CurveOptions = uipanel(rightGrid);
            app.CurveOptions.Title = 'Curve Options';
            app.CurveOptions.Layout.Row = 2;
        
            %---------------------- Show UI ----------------------%
            app.UIFigure.Visible = 'on';
        end

    
        

    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = HPLCAnalysis_Layout2

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

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