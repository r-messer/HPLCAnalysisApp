classdef HPLCProcessingApp < matlab.apps.AppBase

    % UI components
    properties (Access = public)
        UIFigure             matlab.ui.Figure
        UIAxes               matlab.ui.control.UIAxes
        AnalysisPanel        matlab.ui.container.Panel
    end

    properties (Access = private)
        CurrentImage         matlab.graphics.primitive.Image
        ImageData            % Original image data
    end

    methods (Access = private)

        function loadImage(app, ~, ~)
            [file, path] = uigetfile({'*.jpg;*.png;*.tif;*.bmp','Image Files'});
            if isequal(file,0)
                return;
            end
            img = imread(fullfile(path, file));
            app.ImageData = img;
            imshow(img, 'Parent', app.UIAxes);
        end

        function saveImage(app, ~, ~)
            if isempty(app.ImageData)
                uialert(app.UIFigure, 'No image to save.', 'Warning');
                return;
            end
            [file, path] = uiputfile({'*.png';'*.jpg';'*.tif'}, 'Save Image');
            if isequal(file,0)
                return;
            end
            exportgraphics(app.UIAxes, fullfile(path, file));
        end

        function closeImage(app, ~, ~)
            cla(app.UIAxes);
            app.ImageData = [];
        end
    end

    methods (Access = private)

        function createComponents(app)

            % Main figure
            app.UIFigure = uifigure('Position', [100 100 800 600], 'Name', 'Image Processing App');

            % File Menu
            fileMenu = uimenu(app.UIFigure, 'Text', 'File');

            uimenu(fileMenu, 'Text', 'Load Image', 'MenuSelectedFcn', @app.loadImage);
            uimenu(fileMenu, 'Text', 'Save Image', 'MenuSelectedFcn', @app.saveImage);
            uimenu(fileMenu, 'Text', 'Close Image', 'MenuSelectedFcn', @app.closeImage);

            % Analysis toolbar (placeholder panel)
            app.AnalysisPanel = uipanel(app.UIFigure, ...
                'Title', 'Analysis Tools', ...
                'Position', [640 440 150 140]);

            % Image display axes
            app.UIAxes = uiaxes(app.UIFigure, ...
                'Position', [50 50 700 380], ...
                'XTick', [], 'YTick', [], ...
                'Box', 'on');
        end
    end

    methods (Access = public)

        function app = HPLCProcessingApp()
            createComponents(app);
        end
    end
end
