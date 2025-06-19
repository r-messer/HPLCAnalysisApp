classdef HPLCAnalysis_exported < matlab.apps.AppBase
    
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
        CurvesPanel        matlab.ui.container.Panel
        IntegratedCurveAxis   matlab.ui.control.UIAxes
        ChromatogramPanel  matlab.ui.container.Panel
        RightButton        matlab.ui.control.Button
        LeftButton         matlab.ui.control.Button
        ChromatogramAxis   matlab.ui.control.UIAxes
        GroupsPanel        matlab.ui.container.Panel
        ImportPanel        matlab.ui.container.Panel
        ChromatogramOptions matlab.ui.container.Panel
        CurveOptions       matlab.ui.container.Panel
        ImportListBox
        PlotRawButton      
        PlotBaselineButton 
        ShowPeaksCheckBox  
        ShowIntegrationCheckBox 
        OffsetOverlayCheckBox
        ClearPlotButton
        Data;% Struct aray holding data
    end

    properties (Access = private)
        ImportGrid; % Layout container for file list
        CustomColors; 
        RawFiles;
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1440 864];
            app.UIFigure.Name = 'MATLAB App';

            % Create menuFile
            app.menuFile = uimenu(app.UIFigure);
            app.menuFile.Text = 'File';

            % Create LoadDataMenu
            app.LoadDataMenu = uimenu(app.menuFile);
            app.LoadDataMenu.Text = 'Load Data';
            app.LoadDataMenu.MenuSelectedFcn = @(src, event) LoadDataMenuSelected(app, event);

            % Create LoadWorkspaceMenu
            app.LoadWorkspaceMenu = uimenu(app.menuFile);
            app.LoadWorkspaceMenu.Text = 'Load Workspace';

            % Create SaveWorkspaceMenu
            app.SaveWorkspaceMenu = uimenu(app.menuFile);
            app.SaveWorkspaceMenu.Text = 'Save Workspace';

            % Create CloseMenu
            app.CloseMenu = uimenu(app.menuFile);
            app.CloseMenu.Text = 'Close';

            % Create menuProcess
            app.menuProcess = uimenu(app.UIFigure);
            app.menuProcess.Text = 'Process';

            % Create PreprocessAllMenu
            app.PreprocessAllMenu = uimenu(app.menuProcess);
            app.PreprocessAllMenu.Text = 'Preprocess All';

            % Create ImportPanel
            app.ImportPanel = uipanel(app.UIFigure);
            app.ImportPanel.Title = 'Import';
            app.ImportPanel.Position = [1 346 360 520]; % Original values were [1 346 360 518], height extended for asthetics

            % Add a ImportGrid grid layout inside ImportPanel
            app.ImportGrid = uigridlayout(app.ImportPanel);
            app.ImportGrid.RowHeight = {'1x'};
            app.ImportGrid.ColumnWidth = {'1x'};

            % Create UIListBox inside ImportGrid
            app.ImportListBox = uilistbox(app.ImportGrid);
            app.ImportListBox.Multiselect = 'on';  % or 'on' if you want multi-selection
            app.ImportListBox.Items = {};          % empty initially
            app.ImportListBox.Layout.Row = 1;
            app.ImportListBox.Layout.Column = 1;

            % Create GroupsPanel
            app.GroupsPanel = uipanel(app.UIFigure);
            app.GroupsPanel.Title = 'Groups';
            app.GroupsPanel.Position = [1 1 360 346];

            % Create ChromatogramPanel
            app.ChromatogramPanel = uipanel(app.UIFigure);
            app.ChromatogramPanel.Title = 'Chromatogram';
            app.ChromatogramPanel.Position = [360 346 882 520];
        
            % Create ChromatogramAxis
            app.ChromatogramAxis = uiaxes(app.ChromatogramPanel);
            title(app.ChromatogramAxis, 'Title')
            xlabel(app.ChromatogramAxis, 'X')
            ylabel(app.ChromatogramAxis, 'Y')
            app.ChromatogramAxis.Position = [20 40 820 440];

            % Create LeftButton
            app.LeftButton = uibutton(app.ChromatogramPanel, 'push');
            app.LeftButton.FontWeight = 'bold';
            app.LeftButton.Interpreter = 'html';
            app.LeftButton.Position = [8 16 20 25];
            app.LeftButton.Text = '&#60;';

            % Create RightButton
            app.RightButton = uibutton(app.ChromatogramPanel, 'push');
            app.RightButton.FontWeight = 'bold';
            app.RightButton.Interpreter = 'html';
            app.RightButton.Position = [34 16 20 25];
            app.RightButton.Text = '&#62;';

            % Create Curves Panel
            app.CurvesPanel = uipanel(app.UIFigure);
            app.CurvesPanel.Title = 'Integrated Curves';
            app.CurvesPanel.Position = [360 1 882 346];

            % Create IntegrateCurveAxis
            app.IntegratedCurveAxis = uiaxes(app.CurvesPanel);
            title(app.IntegratedCurveAxis, 'Title')
            xlabel(app.IntegratedCurveAxis, 'X')
            ylabel(app.IntegratedCurveAxis, 'Y')
            app.IntegratedCurveAxis.Position = [20 20 440 300];

            % Create ChromatogramOptions Panel
            app.ChromatogramOptions = uipanel(app.UIFigure);
            app.ChromatogramOptions.Title = "Chromatogram Options";
            app.ChromatogramOptions.Position = [1242 346 198 520];

            % Add layout to ChromatogramOptions panel
            chromPlotLayout = uigridlayout(app.ChromatogramOptions, [2, 1]);
            chromPlotLayout.RowHeight = {'fit', 'fit'};
            chromPlotLayout.ColumnWidth = {'1x'};
            
            buttonRow = uigridlayout(chromPlotLayout, [2, 2]);
            buttonRow.Layout.Row = 1;
            buttonRow.RowHeight = {'fit', 'fit'};
            buttonRow.ColumnWidth = {'fit', 'fit'};
            
            app.PlotRawButton = uibutton(buttonRow, 'push');
            app.PlotRawButton.Text = 'Plot Raw';
            app.PlotRawButton.Layout.Row = 1;
            app.PlotRawButton.Layout.Column = 1;
            app.PlotRawButton.ButtonPushedFcn = @(src, event) onPlotRaw(app);

            app.PlotBaselineButton = uibutton(buttonRow, 'push');
            app.PlotBaselineButton.Text = 'Plot Corrected';
            app.PlotBaselineButton.Layout.Row = 1;
            app.PlotBaselineButton.Layout.Column = 2;

            app.ClearPlotButton = uibutton(buttonRow, 'push');
            app.ClearPlotButton.Text = 'Clear Plot';
            app.ClearPlotButton.Layout.Row = 2;
            app.ClearPlotButton.Layout.Column = 1;

            checkboxRow = uigridlayout(chromPlotLayout, [3, 1]);
            checkboxRow.Layout.Row = 2;
            checkboxRow.RowHeight = {'fit', 'fit', 'fit'};
            
            app.ShowPeaksCheckBox = uicheckbox(checkboxRow);
            app.ShowPeaksCheckBox.Text = 'Show Peaks';
            app.ShowPeaksCheckBox.Layout.Row = 1;
            app.ShowPeaksCheckBox.ValueChangedFcn = @(src, event) onPlotRaw(app);

            app.ShowIntegrationCheckBox = uicheckbox(checkboxRow);
            app.ShowIntegrationCheckBox.Text = 'Show Integration';
            app.ShowIntegrationCheckBox.Layout.Row = 2;

            app.OffsetOverlayCheckBox = uicheckbox(checkboxRow);
            app.OffsetOverlayCheckBox.Text = 'Offset Overlays';
            app.OffsetOverlayCheckBox.Layout.Row = 3;
            app.OffsetOverlayCheckBox.Enable = 'off';
            app.OffsetOverlayCheckBox.Value = 0;
            app.ImportListBox.ValueChangedFcn = @(src, event) onImportListBoxChanged(app);
            app.OffsetOverlayCheckBox.ValueChangedFcn = @(src, event) onOffsetOverlayToggled(app);

            % Create CurveOptions Panel
            app.CurveOptions = uipanel(app.UIFigure);
            app.CurveOptions.Title = "Curve Options";
            app.CurveOptions.Position = [1242 1 198 346];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    
        function LoadDataMenuSelected(app, ~)
            % Prompt user to select files
            [files, loc] = uigetfile({'*.csv';'*.txt';'*.tsv'},...
                'Select files for analysis', 'MultiSelect', 'on');
            % Ensure files is always a cell array
            if ischar(files)
                files = {files};
            end
            
            if isempty(files)
                return; % User canceled
            end
   
            % Store full paths
            app.RawFiles = fullfile(loc, files);
        
            % Initialize Data struct array
            app.Data = struct('filename', {}, 'filepath', {}, 'RawData', {}, ...
                'Baseline', {}, 'BaselineCorrected', {}, 'peaks', {}, 'integratedPeaks', {});

            % backcor params
            order = 2;
            thresh = 0.002;

            for i = 1:length(app.RawFiles)
                fullpath = app.RawFiles{i};
                [~, name, ext] = fileparts(fullpath);
                dataImport = readmatrix(fullpath);
                x = dataImport(:,1);
                y = dataImport(:,2);
            
                % Calculate baseline using backcor (Mazet et al., 2004)
                baseline = backcor(x,y, order, thresh, 'atq');

                % Adaptive threshold
                prom_threshold = 0.002 * max(y);
                min_threshold = -1;
            
                % Find peaks
                [pks, locs, w, prom] = findpeaks(y, x, ...
                    'MinPeakProminence', prom_threshold, ...
                    'MinPeakHeight', min_threshold);
            
                


                % Build peak substructure
                peakStruct = struct( ...
                    'pks', pks, ...
                    'locs', locs, ...
                    'widths', w, ...
                    'prominences', prom, ...
                    'threshold', prom_threshold ...
                );
            
                % Populate data struct
                app.Data(i).filename = [name, ext];
                app.Data(i).filepath = fullpath;
                app.Data(i).RawData = dataImport;
                app.Data(i).group = '';
                app.Data(i).Baseline = baseline;
                app.Data(i).peaks = peakStruct;
            end

            % Index based integration of peaks
            for i = 1:numel(app.Data)
                x = app.Data(i).RawData(:,1);
                y = app.Data(i).RawData(:,2);
                b = app.Data(i).Baseline;
            
                % Peak data (recalculate to get index-based locs)
                [~, locs_idx, w, ~] = findpeaks(y, ...
                    'MinPeakProminence', app.Data(i).peaks.threshold);
            
                % Initialize table or struct to store integration results
                integratedPeaks = struct('xmin', {}, 'xmax', {}, ...
                                         'area', {});
            
                for j = 1:length(locs_idx)
                    sigma_idx = round(w(j)/2, 'TieBreaker', 'even');
                    idx_min = max(locs_idx(j) - sigma_idx, 1);
                    idx_max = min(locs_idx(j) + sigma_idx, numel(x));
                
                    % Extract ranges
                    x_range = x(idx_min:idx_max);
                    y_range = y(idx_min:idx_max);
                    b_range = b(idx_min:idx_max);
                
                    % Subtract baseline and integrate
                    corrected = y_range - b_range;
                    net_area = trapz(x_range, corrected);
                
                    % Store result
                    integratedPeaks(j).xmin = x(idx_min);
                    integratedPeaks(j).xmax = x(idx_max);
                    integratedPeaks(j).area = net_area;
                end

            
                app.Data(i).integratedPeaks = integratedPeaks;
            end

            
            % Update list box with filenames
            app.ImportListBox.Items = files;
        end

        function onPlotRaw(app)

            app.PlotRawButton.BackgroundColor = '#baf1ff';

            % Get selected filenames from listbox
            selectedFiles = app.ImportListBox.Value;
            if isempty(selectedFiles)
                return; % Nothing selected
            end

            if ischar(selectedFiles)
                selectedFiles = {selectedFiles};  % Normalize single selection
            end
        
            if ischar(selectedFiles)
                selectedFiles = {selectedFiles};
            end
            
            hold(app.ChromatogramAxis, 'on');
            cla(app.ChromatogramAxis);
            
            allX = [];
            allY = [];

            % Prepass to get axis extents
            for i = 1:numel(selectedFiles)
                match = strcmp({app.Data.filename}, selectedFiles{i});
                if any(match)
                    d = app.Data(match).RawData;
                    allX = [allX; d(:,1)];
                    allY = [allY; d(:,2)];
                end
            end
            
            [xOffset, yOffset] = getOverlayOffsetMagnitude(app, allX, allY);
            isOffset = app.OffsetOverlayCheckBox.Value;
            
            legends = {};
            
            for i = 1:numel(selectedFiles)
                match = strcmp({app.Data.filename}, selectedFiles{i});
                if ~any(match), continue; end
            
                d = app.Data(match).RawData;
                peakStruct = app.Data(match).peaks;
            
                if isOffset
                    [x, y] = applyOverlayOffset(app, d, i, xOffset, yOffset);
                    % Apply same offset to peak locations
                    peakStruct.locs = peakStruct.locs + (i-1) * xOffset;
                    peakStruct.pks = peakStruct.pks + (i-1) * yOffset;
                else
                    x = d(:,1);
                    y = d(:,2);
                end
            
                colorIdx = mod(i-1, size(app.CustomColors,1)) + 1;
                thisColor = app.CustomColors(colorIdx,:);
            
                % Plot trace
                plot(app.ChromatogramAxis, x, y, ...
                    'Color', thisColor, 'LineWidth', 1.5);
            
                % Plot peaks if enabled
                if app.ShowPeaksCheckBox.Value
                    plotPeaks(app, x, y, peakStruct, thisColor);
                end
            
                legends{end+1} = selectedFiles{i};
            end

            
            xlabel(app.ChromatogramAxis, 'Time (min)', 'FontSize', 12);
            ylabel(app.ChromatogramAxis, 'A_{260} (mAU)', 'FontSize', 12);
            xlim(app.ChromatogramAxis, 'tight');
            ylim(app.ChromatogramAxis, 'padded');
            title(app.ChromatogramAxis, 'Raw Chromatograms');
            legend(app.ChromatogramAxis, legends, 'Interpreter', 'none', ...
                'Box','off', 'FontSize', 10);
            hold(app.ChromatogramAxis, 'off');
        end

        function onImportListBoxChanged(app)
            selected = app.ImportListBox.Value;
        
            % Normalize to cell array
            if ischar(selected)
                selected = {selected};
            end
        
            if numel(selected) > 1
                % Enable checkbox
                app.OffsetOverlayCheckBox.Enable = 'on';
            else
                % Disable + reset checkbox
                app.OffsetOverlayCheckBox.Value = false;
                app.OffsetOverlayCheckBox.Enable = 'off';
            end
        end

        function [xOffset, yOffset] = getOverlayOffsetMagnitude(app, allX, allY)
            xmax = max(allX);
            ymax = max(allY);
            xOffset = 0.025 * xmax;
            yOffset = 0.015 * ymax;
        end

        function [x, y] = applyOverlayOffset(app, data, i, xOffset, yOffset)
            x = data(:,1) + (i-1) * xOffset;
            y = data(:,2) + (i-1) * yOffset;
        end

        function onOffsetOverlayToggled(app)
            if strcmp(app.OffsetOverlayCheckBox.Enable, 'on')
                onPlotRaw(app);
            end
        end

        function plotPeaks(app, x, y, peakStruct, color)
            % Find Y-values at peak x locations
            peakX = peakStruct.locs;
            peakY = peakStruct.pks;
            maxY = max(y);
            yOffset = maxY*0.01;
            % Plot as downward triangles
            plot(app.ChromatogramAxis, peakX, peakY+yOffset, 'v', ...
                'MarkerSize', 6, 'MarkerFaceColor', color, ...
                'MarkerEdgeColor', color, 'LineStyle', 'none')
        end

    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = HPLCAnalysis_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)
            app.CustomColors = [
                hex2rgb('#f200c2');
                hex2rgb('#6a4c93');
                hex2rgb('#1982c4');
                hex2rgb('#52a675');
                hex2rgb('#8ac926');
                hex2rgb('#d1ab00');
                hex2rgb('#ff924c');
                hex2rgb('#ff595e')
            ];
      
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