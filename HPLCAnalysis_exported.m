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
        menuGroups         matlab.ui.container.Menu
        MakeGroup          matlab.ui.container.Menu
        CurvesPanel        matlab.ui.container.Panel
        GroupsGrid

        ChromatogramPanel  matlab.ui.container.Panel
        RightButton        matlab.ui.control.Button
        LeftButton         matlab.ui.control.Button
        ChromatogramAxis   matlab.ui.control.UIAxes
        GroupsPanel        matlab.ui.container.Panel
        GroupListBox       matlab.ui.control.ListBox
        ImportPanel        matlab.ui.container.Panel
        ChromatogramOptions matlab.ui.container.Panel
        CurveOptions       matlab.ui.container.Panel
        PlotCurveButton    matlab.ui.control.Button
        ClearCurvePlotButton  matlab.ui.control.Button
        PeakDropdown
        FitLinearCurveButton matlab.ui.control.Button
        FitNonLinearCurveButton matlab.ui.control.Button
        ExportTableButton   matlab.ui.control.Button
        ExportIntegratedCurvesButton  matlab.ui.control.Button

        IntegratedPeaksTable
        IntegratedCurveAxis
        ImportListBox      matlab.ui.control.ListBox
        PlotRawButton      
        PlotCorrectedButton 
        ShowPeaksCheckBox  
        ShowIntegrationCheckBox 
        OffsetOverlayCheckBox
        ClearPlotButton
        Data% Struct aray holding data
    end

    properties (Access = private)
        ImportGrid; % Layout container for file list
        CustomColors; 
        RawFiles;
        CurrentPlotType = 'raw'; % Default plot type
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

            % Create menuGroups
            app.menuGroups = uimenu(app.UIFigure);
            app.menuGroups.Text = 'Groups';

            % Create MakeGroup
            app.MakeGroup = uimenu(app.menuGroups);
            app.MakeGroup.Text = 'Create Group';
            app.MakeGroup.MenuSelectedFcn = @(src, event) onCreateGroup(app);

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

            % Add a ImportGrid grid layout inside ImportPanel
            app.GroupsGrid = uigridlayout(app.GroupsPanel);
            app.GroupsGrid.RowHeight = {'1x'};
            app.GroupsGrid.ColumnWidth = {'1x'};

            % Inside createComponents(app), after creating GroupsPanel
            app.GroupListBox = uilistbox(app.GroupsGrid);
            app.GroupListBox.Multiselect = 'off';
            app.GroupListBox.Items = {};  % Empty initially
            app.GroupListBox.FontSize = 12;
            app.GroupListBox.Tag = 'GroupListBox';
            app.GroupListBox.ValueChangedFcn = @(src, even) onGroupListBoxChanged(app);

            % Create ChromatogramPanel
            app.ChromatogramPanel = uipanel(app.UIFigure);
            app.ChromatogramPanel.Title = 'Chromatogram';
            app.ChromatogramPanel.Position = [360 346 882 520];
        
            % Create ChromatogramAxis
            app.ChromatogramAxis = uiaxes(app.ChromatogramPanel);
            title(app.ChromatogramAxis, 'Chromatogram');
            xlabel(app.ChromatogramAxis, 'Time (min)', 'FontSize', 12);
            ylabel(app.ChromatogramAxis, 'A_{260} (mAU)', 'FontSize', 12);
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

            % Create layout in CurvesPanel
            CurvesLayout = uigridlayout(app.CurvesPanel, [1, 2]);
            CurvesLayout.ColumnWidth = {'1x', '1x'};  % Adjust as needed
            CurvesLayout.RowHeight = {'1x'};

            app.IntegratedPeaksTable = uitable(CurvesLayout);
            app.IntegratedPeaksTable.Layout.Row = 1;
            app.IntegratedPeaksTable.Layout.Column = 1;
            app.IntegratedPeaksTable.ColumnName = {'Name',...
                'Ret. Time', 'Area', 'X Variable'};
            app.IntegratedPeaksTable.ColumnWidth = {'fit'};
            app.IntegratedPeaksTable.Data = {};
            app.IntegratedPeaksTable.ColumnEditable = [true false false true];

            app.IntegratedCurveAxis = uiaxes(CurvesLayout);
            app.IntegratedCurveAxis.Layout.Row = 1;
            app.IntegratedCurveAxis.Layout.Column = 2;
            xlabel(app.IntegratedCurveAxis, 'X Variable');
            ylabel(app.IntegratedCurveAxis, 'Integrated Area');
            title(app.IntegratedCurveAxis, 'Integrated Curve');

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

            app.PlotCorrectedButton = uibutton(buttonRow, 'push');
            app.PlotCorrectedButton.Text = 'Plot Corrected';
            app.PlotCorrectedButton.Layout.Row = 1;
            app.PlotCorrectedButton.Layout.Column = 2;
            app.PlotCorrectedButton.ButtonPushedFcn = @(src, event) onPlotCorrected(app);

            app.ClearPlotButton = uibutton(buttonRow, 'push');
            app.ClearPlotButton.Text = 'Clear Plot';
            app.ClearPlotButton.Layout.Row = 2;
            app.ClearPlotButton.Layout.Column = 1;
            app.ClearPlotButton.ButtonPushedFcn = @(src, event) onClearPlot(app);

            checkboxRow = uigridlayout(chromPlotLayout, [3, 1]);
            checkboxRow.Layout.Row = 2;
            checkboxRow.RowHeight = {'fit', 'fit', 'fit'};
            
            app.ShowPeaksCheckBox = uicheckbox(checkboxRow);
            app.ShowPeaksCheckBox.Text = 'Show Peaks';
            app.ShowPeaksCheckBox.Layout.Row = 1;
            app.ShowPeaksCheckBox.ValueChangedFcn = @(src, event) onRefreshChromatogram(app);

            app.ShowIntegrationCheckBox = uicheckbox(checkboxRow);
            app.ShowIntegrationCheckBox.Text = 'Show Integration';
            app.ShowIntegrationCheckBox.Layout.Row = 2;
            app.ShowIntegrationCheckBox.ValueChangedFcn = @(src, event) onRefreshChromatogram(app);

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

            %Create curveOptionsLayout for CurveOptions Panel
            curveOptionsLayout = uigridlayout(app.CurveOptions, [4, 1]);
            curveOptionsLayout.RowHeight = {'fit', 'fit', 'fit', 'fit'};
            curveOptionsLayout.ColumnWidth = {'1x'};

            % Create disabled dropdown for selecting peaks
            app.PeakDropdown = uidropdown(curveOptionsLayout);
            app.PeakDropdown.Layout.Row = 1;
            app.PeakDropdown.Layout.Column = 1;
            app.PeakDropdown.Items = {}; % Will be populated dynamically later
            app.PeakDropdown.Placeholder = 'Peaks';
            app.PeakDropdown.Enable = 'off';
            app.PeakDropdown.ValueChangedFcn = @(src, event) onPeakDropdownChanged(app);

            % Create CurvePlotOptionsLayout for curveOptionsLayout panel
            CurvePlotOptionsLayout = uigridlayout(curveOptionsLayout, [1, 2]);
            CurvePlotOptionsLayout.Layout.Row = 2;
            CurvePlotOptionsLayout.Layout.Column = 1;
            CurvePlotOptionsLayout.RowHeight = {'fit'};
            CurvePlotOptionsLayout.ColumnWidth = {'1x', '1x'};

            app.PlotCurveButton = uibutton(CurvePlotOptionsLayout, 'push');
            app.PlotCurveButton.Layout.Row = 1;
            app.PlotCurveButton.Layout.Column = 1;
            app.PlotCurveButton.Text = 'Plot Curve';
            app.PlotCurveButton.ButtonPushedFcn = @(src, event) onPlotCurve(app);

            app.ClearCurvePlotButton = uibutton(CurvePlotOptionsLayout, 'push');
            app.ClearCurvePlotButton.Layout.Row = 1;
            app.ClearCurvePlotButton.Layout.Column = 2;
            app.ClearCurvePlotButton.Text = 'Clear Curve';

            % Create Fit Curve Buttons rows
            FitCurveButtonRow = uigridlayout(curveOptionsLayout,[1, 2]);
            FitCurveButtonRow.Layout.Row = 3;
            FitCurveButtonRow.Layout.Column = 1;
            FitCurveButtonRow.RowHeight = {'fit'};
            FitCurveButtonRow.ColumnWidth = {'1x','1x'};

            app.FitLinearCurveButton = uibutton(FitCurveButtonRow, 'push');
            app.FitLinearCurveButton.Layout.Row = 1;
            app.FitLinearCurveButton.Layout.Column = 1;
            app.FitLinearCurveButton.Text = 'Fit Linear';

            app.FitNonLinearCurveButton = uibutton(FitCurveButtonRow, 'push');
            app.FitNonLinearCurveButton.Layout.Row = 1;
            app.FitNonLinearCurveButton.Layout.Column = 2;
            app.FitNonLinearCurveButton.Text = 'Fit Nonlinear';

            % Create ExportButtonRow
            ExportButtonRow = uigridlayout(curveOptionsLayout, [1,2]);
            ExportButtonRow.Layout.Row = 4;
            ExportButtonRow.Layout.Column = 1;
            ExportButtonRow.RowHeight = {'fit'};
            ExportButtonRow.ColumnWidth = {'1x', '1x'};

            app.ExportTableButton = uibutton(ExportButtonRow, 'push');
            app.ExportTableButton.Layout.Row = 1;
            app.ExportTableButton.Layout.Column = 1;
            app.ExportTableButton.Text = 'Export Table';

            app.ExportIntegratedCurvesButton = uibutton(ExportButtonRow, 'push');
            app.ExportIntegratedCurvesButton.Layout.Row = 1;
            app.ExportIntegratedCurvesButton.Layout.Column = 2;
            app.ExportIntegratedCurvesButton.Text = 'Export Curves';

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
                y_corrected = y - baseline;

                % Adaptive threshold
                prom_threshold = 0.002 * max(y_corrected);
                min_threshold = 0.5;
            
                % Find peaks
                [pks, locs, w, prom] = findpeaks(y_corrected, x, ...
                    'MinPeakProminence', prom_threshold, ...
                    'MinPeakHeight', min_threshold);
            
                
                [~, ilocs, ~, ~] = findpeaks(y_corrected, ...
                    'MinPeakProminence', prom_threshold, ...
                    'MinPeakHeight', min_threshold);

                % Build peak substructure
                peakStruct = struct( ...
                    'pks', pks, ...
                    'locs', locs, ...
                    'locs_ind', ilocs, ...
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
                app.Data(i).integratedPeaks = integratePeaksForEntry(app, x, y_corrected, ilocs);
            end

            % Update list box with filenames
            app.ImportListBox.Items = files;
        end

        function integratedPeaks = integratePeaksForEntry(app, x, y_corrected, ilocs)
            % Returns a struct array of integrated peak info with valley-limited bounds
            
            thresholdFraction = 0.02;  % 2% of peak height
            n = numel(ilocs);
            integratedPeaks = struct('xmin', {}, 'xmax', {}, 'area', {}, 'index_range', {});
            
            for k = 1:n
                pkLoc = ilocs(k);
                yPeak = y_corrected(pkLoc);
                threshold = thresholdFraction * yPeak;
        
                % Determine left bound (valley)
                if k == 1
                    leftIdx = 1;
                else
                    searchRange = y_corrected(ilocs(k-1):pkLoc);
                    [~, minRel] = min(searchRange);
                    leftIdx = ilocs(k-1) + minRel - 1;
                end
        
                % Determine right bound (valley)
                if k == n
                    rightIdx = numel(y_corrected);
                else
                    searchRange = y_corrected(pkLoc:ilocs(k+1));
                    [~, minRel] = min(searchRange);
                    rightIdx = pkLoc + minRel - 1;
                end
        
                % Walk left while above threshold and within valley
                xmin = pkLoc;
                while xmin > 1 && y_corrected(xmin) > threshold && xmin > leftIdx
                    xmin = xmin - 1;
                end
        
                % Walk right while above threshold and within valley
                xmax = pkLoc;
                while xmax < numel(y_corrected) && y_corrected(xmax) > threshold && xmax < rightIdx
                    xmax = xmax + 1;
                end
        
                % Clamp indices
                xmin = max(xmin, 1);
                xmax = min(xmax, numel(y_corrected));
        
                % Compute net area (baseline corrected)
                area = trapz(x(xmin:xmax), y_corrected(xmin:xmax));
        
                integratedPeaks(k).xmin = x(xmin);
                integratedPeaks(k).xmax = x(xmax);
                integratedPeaks(k).area = area;
                integratedPeaks(k).index_range = [xmin xmax];
            end
        end

        function onCreateGroup(app)
            % Create new UI figure for group creation
            groupFig = uifigure('Name', 'Create Group', ...
                'Position', [500 500 300 180]);
        
            % Create grid layout (4 rows x 1 column)
            grid = uigridlayout(groupFig, [4, 1]);
            grid.RowHeight = {'fit', 'fit', 'fit', 'fit'};
            grid.ColumnWidth = {'1x'};
            grid.Padding = [10 10 10 10];
            grid.RowSpacing = 10;
        
            % Row 1: Label
            label = uilabel(grid);
            label.Text = 'Group Label:';
            label.FontWeight = 'bold';
        
            % Row 2: Edit Field
            groupEditField = uieditfield(grid, 'text');
            groupEditField.Placeholder = 'Enter group name';
        
            % Row 3: OK Button
            okButton = uibutton(grid, 'push');
            okButton.Text = 'OK';
            okButton.ButtonPushedFcn = @(src, event) onGroupOK(app, groupFig, groupEditField);
        
            % Row 4: Cancel Button
            cancelButton = uibutton(grid, 'push');
            cancelButton.Text = 'Cancel';
            cancelButton.ButtonPushedFcn = @(src, event) close(groupFig);
        end

        function onGroupOK(app, fig, groupEditField)
            groupName = strtrim(groupEditField.Value);
            if isempty(groupName)
                uialert(fig, 'Group name cannot be empty.', 'Input Error');
                return;
            end
        
            selectedFiles = app.ImportListBox.Value;
            if ischar(selectedFiles)
                selectedFiles = {selectedFiles};
            end
        
            allLocs = [];
            allSources = [];
            peakIndices = [];
        
            % Collect all peaks from selected files
            for i = 1:numel(selectedFiles)
                fileIdx = find(strcmp({app.Data.filename}, selectedFiles{i}));
                if isempty(fileIdx), continue; end
        
                locs = app.Data(fileIdx).peaks.locs;
                allLocs = [allLocs; locs(:)];
                allSources = [allSources; repmat(i, numel(locs), 1)];
                peakIndices = [peakIndices; repmat(fileIdx, numel(locs), 1)];
        
                % Assign group label to the data entry
                app.Data(fileIdx).group = groupName;
            end
        
            % Cluster peak locations using DBSCAN
            epsilon = 0.05; % tolerance for retention time drift
            minPts = 2;
            if numel(allLocs) >= minPts
                clusterLabels = dbscan(allLocs, epsilon, minPts);
            elseif isscalar(allLocs)
                clusterLabels = 1; % assign single cluster
            else
                clusterLabels = -1 * ones(size(allLocs)); % Not enough data
            end
        
            % Assign cluster IDs to original peaks
            for i = 1:numel(clusterLabels)
                if clusterLabels(i) == -1, continue; end
                idx = peakIndices(i);
                locVal = allLocs(i);
        
                % Find match for locVal
                matchIdx = find(abs(app.Data(idx).peaks.locs - locVal) < 1e-2, 1);
                if ~isempty(matchIdx)
                    if ~isfield(app.Data(idx).peaks, 'clusterID')
                        app.Data(idx).peaks.clusterID = nan(size(app.Data(idx).peaks.locs));
                    end
                    app.Data(idx).peaks.clusterID(matchIdx) = clusterLabels(i);
                end
            end
        
            % Add group to the GroupListBox safely
            existingGroups = app.GroupListBox.Items;
            if isempty(existingGroups)
                app.GroupListBox.Items = {groupName};
            elseif ~any(strcmp(existingGroups, groupName))
                app.GroupListBox.Items = [existingGroups {groupName}];
            end
        
            % Enable dropdown
            app.PeakDropdown.Enable = 'on';
        
            % Close group creation window
            delete(fig);
        end

        function onGroupListBoxChanged(app)
            selectedGroup = app.GroupListBox.Value;
        
            % No selection: clear and disable
            if isempty(selectedGroup)
                app.PeakDropdown.Items = {};
                app.PeakDropdown.Value = '';
                app.PeakDropdown.Enable = 'off';
                app.IntegratedPeaksTable.Data = {};
                return;
            end
        
            % Collect clusterIDs from selected group
            clusterIDs = [];
            for i = 1:numel(app.Data)
                if isfield(app.Data(i), "group") && strcmp(app.Data(i).group, selectedGroup)
                    if isfield(app.Data(i).peaks, "clusterID")
                        ids = app.Data(i).peaks.clusterID;
                        clusterIDs = [clusterIDs; ids(:)];
                    end
                end
            end
        
            % Filter valid cluster IDs
            clusterIDs = unique(clusterIDs(~isnan(clusterIDs) & clusterIDs >= 0));
        
            if isempty(clusterIDs)
                app.PeakDropdown.Items = {};
                app.PeakDropdown.Value = {};
                app.PeakDropdown.Enable = 'off';
                app.IntegratedPeaksTable.Data = {};
            else
                labels = arrayfun(@(id) sprintf("Peak %d", id), clusterIDs);
                app.PeakDropdown.Items = labels';
                app.PeakDropdown.Enable = 'on';
        
                % Trigger table update
                onPeakDropdownChanged(app);
            end
        end


        function onPeakDropdownChanged(app)
            selectedGroup = app.GroupListBox.Value;
            peakLabel = app.PeakDropdown.Value;
        
            if isempty(selectedGroup) || isempty(peakLabel)
                return;
            end
        
            % Extract numeric clusterID
            tokens = regexp(peakLabel, 'Peak\s+(\d+)', 'tokens');
            if isempty(tokens), return; end
            clusterID = str2double(tokens{1}{1});
        
            % Initialize table data
            tableData = {};
        
            for i = 1:numel(app.Data)
                if isfield(app.Data(i), "group") && strcmp(app.Data(i).group, selectedGroup)
                    if isfield(app.Data(i).peaks, "clusterID") && any(app.Data(i).peaks.clusterID == clusterID)
                        matchIdx = find(app.Data(i).peaks.clusterID == clusterID);
                        for m = 1:numel(matchIdx)
                            % Validate peak index
                            intPeaks = app.Data(i).integratedPeaks;
                            if matchIdx(m) <= numel(intPeaks)
                                % Extract retention time from peak location
                                retentionTime = app.Data(i).peaks.locs(matchIdx(m));
                                tableData{end+1, 1} = app.Data(i).filename;                     % Reaction Name
                                tableData{end,   2} = retentionTime;                           % Ret. Time
                                tableData{end,   3} = intPeaks(matchIdx(m)).area;             % Area
                                tableData{end,   4} = 0.0;                                     % X Variable

                            end
                        end
                    end
                end
            end
        
            % Set table
            app.IntegratedPeaksTable.Data = tableData;
        end

        function onPlotCurve(app)
            % Get the table data
            data = app.IntegratedPeaksTable.Data;
        
            % Validate table is not empty
            if isempty(data)
                uialert(app.UIFigure, 'No data to plot. Please select a peak group first.', 'Plot Error');
                return;
            end
        
            % Extract X and Y data
            x = cell2mat(data(:, 4));  % X Variable
            y = cell2mat(data(:, 3));  % Area
        
            % Validate that X and Y have valid numeric entries
            if any(isnan(x)) || any(isnan(y))
                uialert(app.UIFigure, 'X or Y values contain NaNs. Please edit the table to fix this.', 'Data Error');
                return;
            end
        
            % Plot
            cla(app.IntegratedCurveAxis);  % Clear previous curve
            plot(app.IntegratedCurveAxis, x, y, '-o', ...
                'LineWidth', 2, ...
                'MarkerSize', 6, ...
                'DisplayName', 'Integrated Curve');
            xlabel(app.IntegratedCurveAxis, 'X Variable');
            ylabel(app.IntegratedCurveAxis, 'Integrated Area');
            title(app.IntegratedCurveAxis, 'Integrated Curve');
            grid(app.IntegratedCurveAxis, 'on');
        end


        function plotChromatograms(app, dataType, showPeaks, showIntegration, applyOffset)

            % Clear and hold
            % disp("Before CLA:"); disp(get(app.ChromatogramAxis, 'Children'))
            cla(app.ChromatogramAxis);
            % disp("After CLA:"); disp(get(app.ChromatogramAxis, 'Children'))

            if isempty(app.Data)
                return
            end

            hold(app.ChromatogramAxis, 'on');
        
            % Get selected files
            selectedFiles = app.ImportListBox.Value;
            if ischar(selectedFiles)
                selectedFiles = {selectedFiles};
            end
        
            % Prepass to get axis maxes
            allX = []; allY = [];
            for i = 1:numel(selectedFiles)
                match = strcmp({app.Data.filename}, selectedFiles{i});
                if any(match)
                    d = app.Data(match).RawData;
                    allX = [allX; d(:,1)];
                    allY = [allY; d(:,2)];
                end
            end

            [xOffset, yOffset] = getOverlayOffsetMagnitude(app, allX, allY);
        
            lineHandles = gobjects(0);  % Preallocate empty handle array
            legendLabels = {};

            for i = 1:numel(selectedFiles)
                match = strcmp({app.Data.filename}, selectedFiles{i});
                if ~any(match), continue; end
        
                entry = app.Data(match);
                x = entry.RawData(:,1);
                y = entry.RawData(:,2);
                colorIdx = mod(i-1, size(app.CustomColors,1)) + 1;
                color = app.CustomColors(colorIdx,:);
        
                % Apply baseline correction
                switch dataType
                    case 'raw'
                        signal = y;
                    case 'corrected'
                        signal = y - entry.Baseline;
                    otherwise
                        warning("Unknown data type: %s", dataType);
                        continue;
                end
        
                % Apply offset
                if applyOffset
                    x = x + (i-1)*xOffset;
                    signal = signal + (i-1)*yOffset;
                end
        
                % Plot signal
                hLine = plot(app.ChromatogramAxis, x, signal, 'Color', color, 'LineWidth', 1.5);
                lineHandles(end+1) = hLine;
                legendLabels{end+1} = selectedFiles{i}; % Label matches the line

                % Plot peaks
                if showPeaks && isfield(entry, 'peaks') && ~isempty(entry.peaks)
                    px = entry.peaks.locs;
                    py = entry.peaks.pks;
                    if applyOffset
                        px = px + (i-1)*xOffset;
                        py = py + (i-1)*yOffset;
                    end
                    plot(app.ChromatogramAxis, px, py, 'v', ...
                        'Color', color, 'MarkerFaceColor', color, ...
                        'MarkerSize', 6, 'LineStyle', 'none');
                end
        
                % Plot integrated regions
                if showIntegration && isfield(entry, 'integratedPeaks')
                    for j = 1:numel(entry.integratedPeaks)
                        int = entry.integratedPeaks(j);
                        if int.index_range(1) < 1 || int.index_range(2) > numel(x) || ...
                           int.index_range(1) > int.index_range(2)
                            warning('Skipping integration region: invalid index range [%d %d] for signal length %d.', ...
                                int.index_range(1), int.index_range(2), numel(x));
                            continue;
                        end

                        xPatch = [x(int.index_range(1):int.index_range(2))];
                        yBase = signal(int.index_range(1):int.index_range(2)); 
                        % if applyOffset
                        %     xPatch = xPatch + (i-1)*xOffset;
                        %     yBase = yBase + (i-1)*yOffset;
                        % end
                        fill(app.ChromatogramAxis, xPatch, yBase, color, ...
                            'FaceAlpha', 0.25, 'EdgeColor', 'none', ...
                            'Parent',app.ChromatogramAxis);
                    end
                end
            end
        
            % Finalize axes
            xlabel(app.ChromatogramAxis, 'Time (min)', 'FontSize', 12);
            ylabel(app.ChromatogramAxis, 'A_{260} (mAU)', 'FontSize', 12);
            xlim(app.ChromatogramAxis, 'tight');
            ylim(app.ChromatogramAxis, 'padded');
            title(app.ChromatogramAxis, 'Chromatogram');
            legend(app.ChromatogramAxis, lineHandles, legendLabels, ...
                'Interpreter', 'none', 'Box', 'off', 'FontSize', 10);
            hold(app.ChromatogramAxis, 'off');
        end

        function onPlotRaw(app)
            app.PlotRawButton.BackgroundColor = '#baf1ff';
            drawnow;
            pause(0.3);
            app.PlotRawButton.BackgroundColor = [0.94 0.94 0.94];

            plotChromatograms(app, ...
                'raw', ...
                app.ShowPeaksCheckBox.Value, ...
                app.ShowIntegrationCheckBox.Value, ...
                app.OffsetOverlayCheckBox.Value);

            app.CurrentPlotType = 'raw';
        end
        
        function onPlotCorrected(app)
            app.PlotCorrectedButton.BackgroundColor = '#baf1ff';
            drawnow;
            pause(0.3);
            app.PlotCorrectedButton.BackgroundColor = [0.94 0.94 0.94];
        
            plotChromatograms(app, ...
                'corrected', ...
                app.ShowPeaksCheckBox.Value, ...
                app.ShowIntegrationCheckBox.Value, ...
                app.OffsetOverlayCheckBox.Value);

            app.CurrentPlotType = 'corrected';
        end

        function onRefreshChromatogram(app)
            plotChromatograms(app, ...
                app.CurrentPlotType, ...
                app.ShowPeaksCheckBox.Value, ...
                app.ShowIntegrationCheckBox.Value, ...
                app.OffsetOverlayCheckBox.Value);
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

        function onClearPlot(app)
            cla(app.ChromatogramAxis, 'reset');  % Clears all graphics and resets axes properties
            app.ShowPeaksCheckBox.Value = false;
            app.ShowIntegrationCheckBox.Value = false;
            app.OffsetOverlayCheckBox.Value = false;
            title(app.ChromatogramAxis, 'Chromatogram');
            xlabel(app.ChromatogramAxis, 'Time (min)', 'FontSize', 12);
            ylabel(app.ChromatogramAxis, 'A_{260} (mAU)', 'FontSize', 12);
            app.CurrentPlotType = 'raw';
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
                onRefreshChromatogram(app);
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