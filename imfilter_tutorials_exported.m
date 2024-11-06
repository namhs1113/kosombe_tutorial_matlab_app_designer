classdef imfilter_tutorials_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        KOSOMBEIMFILTERTUTORIALSUIFigure  matlab.ui.Figure
        OutputSizeButtonGroup      matlab.ui.container.ButtonGroup
        FullButton                 matlab.ui.control.RadioButton
        SameButton                 matlab.ui.control.RadioButton
        PaddingOptionsButtonGroup  matlab.ui.container.ButtonGroup
        CircularButton             matlab.ui.control.RadioButton
        ReplicateButton            matlab.ui.control.RadioButton
        SymmetricButton            matlab.ui.control.RadioButton
        ParametersPanel            matlab.ui.container.Panel
        ThetaSlider                matlab.ui.control.Slider
        TransposeCheckBox          matlab.ui.control.CheckBox        
        ThetaEditField             matlab.ui.control.NumericEditField
        ThetaEditFieldLabel        matlab.ui.control.Label
        LengthEditField            matlab.ui.control.NumericEditField
        LengthEditFieldLabel       matlab.ui.control.Label
        AlphaEditField             matlab.ui.control.NumericEditField
        AlphaEditFieldLabel        matlab.ui.control.Label
        SigmaEditField             matlab.ui.control.NumericEditField
        SigmaEditFieldLabel        matlab.ui.control.Label
        RadiusEditField            matlab.ui.control.NumericEditField
        RadiusEditFieldLabel       matlab.ui.control.Label
        SizeEditField              matlab.ui.control.NumericEditField
        SizeEditFieldLabel         matlab.ui.control.Label
        KernelTypeDropDown         matlab.ui.control.DropDown
        KernelTypeDropDownLabel    matlab.ui.control.Label
        LoadImageButton            matlab.ui.control.Button
        IMFILTERTUTORIALSLabel     matlab.ui.control.Label
        UIAxesKernel               matlab.ui.control.UIAxes
        UIAxesFiltered             matlab.ui.control.UIAxes
        UIAxesOriginal             matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        orig_img  % original image
        filt_img  % filtered image
        kernel  % kernel
        
        % filtering parameters
        kernel_type = 'average';
        size = 3;
        radius = 1;
        sigma = 1;
        alpha = 1;
        len = 3;
        theta = 0;
        tp = 0;

        pad_opt = 'symmetric';
        output_size = 'same';
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: LoadImageButton
        function LoadImageButtonPushed(app, event)
            % get specified image filepath
            [file,path] = uigetfile({'*.jpg;*.bmp;*.png;*.tif','Image Files (*.jpg;*.bmp;*.png;*.tif)';},'Select an Image');

            if ~isempty(file)
                % read image
                app.orig_img = imread(fullfile(path,file));

                % enable components
                app.KernelTypeDropDown.Enable = 'on';
                app.KernelTypeDropDownLabel.Enable = 'on';
                app.ParametersPanel.Enable = 'on';
                app.PaddingOptionsButtonGroup.Enable = 'on';
                app.OutputSizeButtonGroup.Enable = 'on';

                % set kernel
                KernelTypeDropDownValueChanged(app);

                % filtering
                app.filt_img = imfilter(app.orig_img,app.kernel,app.pad_opt,app.output_size);

                % visualization
                imagesc(app.orig_img,'Parent',app.UIAxesOriginal);
                imagesc(app.filt_img,'Parent',app.UIAxesFiltered);
                imagesc(app.kernel,'Parent',app.UIAxesKernel);
            end
        end

        % Value changed function: KernelTypeDropDown
        function KernelTypeDropDownValueChanged(app, event)
            % get current kernel type
            app.kernel_type = app.KernelTypeDropDown.Value;

            % disable parameter components
            fields = fieldnames(app);
            for i = 1 : numel(fields)                
                if isprop(app.(fields{i}).Parent,'Title')
                    if strcmp(app.(fields{i}).Parent.Title,'Parameters')
                        app.(fields{i}).Enable = 'off';
                    end
                end
            end

            % instead of enumerating
            % app.SizeEditField.Enable = 'off'; app.SizeEditFieldLabel.Enable = 'off';
            % app.RadiusEditField.Enable = 'off'; app.RadiusEditFieldLabel.Enable = 'off';
            % app.SigmaEditField.Enable = 'off'; app.SigmaEditFieldLabel.Enable = 'off';
            % app.AlphaEditField.Enable = 'off'; app.AlphaEditFieldLabel.Enable = 'off';
            % app.LengthEditField.Enable = 'off'; app.LengthEditFieldLabel.Enable = 'off';
            % app.ThetaEditField.Enable = 'off'; app.ThetaEditFieldLabel.Enable = 'off';
            % app.ThetaSlider.Enable = 'off'; 
            % app.TransposeCheckBox.Enable = 'off'; 

            % define kernel
            switch (app.kernel_type)
                case 'Average'
                    app.SizeEditField.Enable = 'on'; app.SizeEditFieldLabel.Enable = 'on';

                    app.size = app.SizeEditField.Value;
                    app.kernel = fspecial(app.kernel_type,app.size);                    
                case 'Disk'
                    app.RadiusEditField.Enable = 'on'; app.RadiusEditFieldLabel.Enable = 'on';

                    app.radius = app.RadiusEditField.Value;
                    app.kernel = fspecial(app.kernel_type,app.radius);                    
                case 'Gaussian' 
                    app.SizeEditField.Enable = 'on'; app.SizeEditFieldLabel.Enable = 'on';
                    app.SigmaEditField.Enable = 'on'; app.SigmaEditFieldLabel.Enable = 'on';

                    app.size = app.SizeEditField.Value;
                    app.sigma = app.SigmaEditField.Value;
                    app.kernel = fspecial(app.kernel_type,app.size,app.sigma);
                case 'Laplacian'
                    app.AlphaEditField.Enable = 'on'; app.AlphaEditFieldLabel.Enable = 'on';

                    app.alpha = app.AlphaEditField.Value;
                    app.kernel = fspecial(app.kernel_type,app.alpha);
                case 'LoG'
                    app.SizeEditField.Enable = 'on'; app.SizeEditFieldLabel.Enable = 'on';
                    app.SigmaEditField.Enable = 'on'; app.SigmaEditFieldLabel.Enable = 'on';

                    app.size = app.SizeEditField.Value;
                    app.sigma = app.SigmaEditField.Value;
                    app.kernel = fspecial(app.kernel_type,app.size,app.sigma);
                case 'Motion'
                    app.LengthEditField.Enable = 'on'; app.LengthEditFieldLabel.Enable = 'on';
                    app.ThetaEditField.Enable = 'on'; app.ThetaEditFieldLabel.Enable = 'on';
                    app.ThetaSlider.Enable = 'on'; 

                    app.len = app.LengthEditField.Value;
                    app.theta = app.ThetaEditField.Value;
                    app.kernel = fspecial(app.kernel_type,app.len,app.theta);
                case {'Prewitt', 'Sobel'}
                    app.TransposeCheckBox.Enable = 'on'; 

                    app.tp = app.TransposeCheckBox.Value;
                    app.kernel = fspecial(app.kernel_type);
                    if app.tp, app.kernel = app.kernel'; end
            end

            % get current padding option
            app.pad_opt = app.PaddingOptionsButtonGroup.SelectedObject.Text;

            % get current output sizing option
            app.output_size = app.OutputSizeButtonGroup.SelectedObject.Text;

            % filtering
            app.filt_img = imfilter(app.orig_img,app.kernel,app.pad_opt,app.output_size);

            % visualization
            imagesc(app.orig_img,'Parent',app.UIAxesOriginal);
            imagesc(app.filt_img,'Parent',app.UIAxesFiltered);
            imagesc(app.kernel,'Parent',app.UIAxesKernel);

        end

        % Value changed function: SizeEditField
        function SizeEditFieldValueChanged(app, event)
            % get current size parameter
            app.size = app.SizeEditField.Value;

            % define kernel 
            switch (app.kernel_type)
                case 'Average'                
                    app.kernel = fspecial(app.kernel_type,app.size);
                case {'Gaussian', 'LoG'}
                    app.kernel = fspecial(app.kernel_type,app.size,app.sigma);
            end

            % filtering
            app.filt_img = imfilter(app.orig_img,app.kernel,app.pad_opt,app.output_size);

            % visualization
            imagesc(app.filt_img,'Parent',app.UIAxesFiltered);
            imagesc(app.kernel,'Parent',app.UIAxesKernel);
        end

        % Value changed function: RadiusEditField
        function RadiusEditFieldValueChanged(app, event)
            % get current radius parameter
            app.radius = app.RadiusEditField.Value;
            
            % define kernel 
            switch (app.kernel_type)
                case 'Disk'
                    app.kernel = fspecial(app.kernel_type,app.radius);                    
            end

            % filtering
            app.filt_img = imfilter(app.orig_img,app.kernel,app.pad_opt,app.output_size);

            % visualization
            imagesc(app.filt_img,'Parent',app.UIAxesFiltered);
            imagesc(app.kernel,'Parent',app.UIAxesKernel);
        end

        % Value changed function: SigmaEditField
        function SigmaEditFieldValueChanged(app, event)
            % get current sigma parameter
            app.sigma = app.SigmaEditField.Value;

            % define kernel 
            switch (app.kernel_type)
                case {'Gaussian', 'LoG'}
                    app.kernel = fspecial(app.kernel_type,app.size,app.sigma);
            end

            % filtering
            app.filt_img = imfilter(app.orig_img,app.kernel,app.pad_opt,app.output_size);

            % visualization
            imagesc(app.filt_img,'Parent',app.UIAxesFiltered);
            imagesc(app.kernel,'Parent',app.UIAxesKernel);
        end

        % Value changed function: AlphaEditField
        function AlphaEditFieldValueChanged(app, event)
            % get current alpha parameter
            app.alpha = app.AlphaEditField.Value;

            % define kernel 
            switch (app.kernel_type)
                case 'Laplacian'                
                    app.kernel = fspecial(app.kernel_type,app.alpha);
            end

            % filtering
            app.filt_img = imfilter(app.orig_img,app.kernel,app.pad_opt,app.output_size);

            % visualization
            imagesc(app.filt_img,'Parent',app.UIAxesFiltered);
            imagesc(app.kernel,'Parent',app.UIAxesKernel);
        end

        % Value changed function: LengthEditField
        function LengthEditFieldValueChanged(app, event)
            % get current length parameter
            app.len = app.LengthEditField.Value;

            % define kernel 
            switch (app.kernel_type)
                case 'Motion'                
                    app.kernel = fspecial(app.kernel_type,app.len,app.theta);
            end

            % filtering
            app.filt_img = imfilter(app.orig_img,app.kernel,app.pad_opt,app.output_size);

            % visualization
            imagesc(app.filt_img,'Parent',app.UIAxesFiltered);
            imagesc(app.kernel,'Parent',app.UIAxesKernel);
        end

        % Value changed function: ThetaEditField
        function ThetaEditFieldValueChanged(app, event)
            % get current theta parameter
            app.theta = app.ThetaEditField.Value;
            
            % define kernel 
            switch (app.kernel_type)
                case 'Motion'                
                    app.kernel = fspecial(app.kernel_type,app.len,app.theta);
            end

            % reflect the value to slider
            app.ThetaSlider.Value = app.theta;

            % filtering
            app.filt_img = imfilter(app.orig_img,app.kernel,app.pad_opt,app.output_size);

            % visualization
            imagesc(app.filt_img,'Parent',app.UIAxesFiltered);
            imagesc(app.kernel,'Parent',app.UIAxesKernel);
        end

        % Value changing function: ThetaSlider, ThetaSlider, ThetaSlider, 
        % ...and 2 other components
        function ThetaSliderValueChanging(app, event)
            % get current theta parameter
            app.theta = event.Value;

            % define kernel 
            switch (app.kernel_type)
                case 'Motion'                
                    app.kernel = fspecial(app.kernel_type,app.len,app.theta);
            end

            % reflect the value to edit field
            app.ThetaEditField.Value = app.theta;

            % filtering
            app.filt_img = imfilter(app.orig_img,app.kernel,app.pad_opt,app.output_size);

            % visualization
            imagesc(app.filt_img,'Parent',app.UIAxesFiltered);
            imagesc(app.kernel,'Parent',app.UIAxesKernel);            
        end

        % Value changed function: TransposeCheckBox
        function TransposeCheckBoxValueChanged(app, event)
            % get current tp parameter
            app.tp = app.TransposeCheckBox.Value;

            % define kernel
            switch (app.kernel_type)
                case {'Prewitt', 'Sobel'}                                        
                    app.kernel = fspecial(app.kernel_type);
                    if app.tp, app.kernel = app.kernel'; end
            end

            % filtering
            app.filt_img = imfilter(app.orig_img,app.kernel,app.pad_opt,app.output_size);

            % visualization
            imagesc(app.filt_img,'Parent',app.UIAxesFiltered);
            imagesc(app.kernel,'Parent',app.UIAxesKernel);             
        end

        % Selection changed function: PaddingOptionsButtonGroup
        function PaddingOptionsButtonGroupSelectionChanged(app, event)
            % get current padding option
            app.pad_opt = event.NewValue.Text;

             % filtering
            app.filt_img = imfilter(app.orig_img,app.kernel,app.pad_opt,app.output_size);

            % visualization
            imagesc(app.filt_img,'Parent',app.UIAxesFiltered);
            imagesc(app.kernel,'Parent',app.UIAxesKernel);                 
        end

        % Selection changed function: OutputSizeButtonGroup
        function OutputSizeButtonGroupSelectionChanged(app, event)
            % get current padding option
            app.output_size = event.NewValue.Text;

             % filtering
            app.filt_img = imfilter(app.orig_img,app.kernel,app.pad_opt,app.output_size);

            % visualization
            imagesc(app.filt_img,'Parent',app.UIAxesFiltered);
            imagesc(app.kernel,'Parent',app.UIAxesKernel);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create KOSOMBEIMFILTERTUTORIALSUIFigure and hide until all components are created
            app.KOSOMBEIMFILTERTUTORIALSUIFigure = uifigure('Visible', 'off');
            app.KOSOMBEIMFILTERTUTORIALSUIFigure.Position = [100 100 994 451];
            app.KOSOMBEIMFILTERTUTORIALSUIFigure.Name = 'KOSOMBE IMFILTER TUTORIALS';

            % Create UIAxesOriginal
            app.UIAxesOriginal = uiaxes(app.KOSOMBEIMFILTERTUTORIALSUIFigure);
            title(app.UIAxesOriginal, 'Original')
            app.UIAxesOriginal.XLimitMethod = 'tight';
            app.UIAxesOriginal.YLimitMethod = 'tight';
            app.UIAxesOriginal.ZLimitMethod = 'tight';
            app.UIAxesOriginal.XTick = [];
            app.UIAxesOriginal.XTickLabel = '';
            app.UIAxesOriginal.YTick = [];
            app.UIAxesOriginal.YTickLabel = '';
            app.UIAxesOriginal.ZTick = [];
            app.UIAxesOriginal.ZTickLabel = '';
            app.UIAxesOriginal.Box = 'on';
            app.UIAxesOriginal.Position = [17 84 300 300];

            % Create UIAxesFiltered
            app.UIAxesFiltered = uiaxes(app.KOSOMBEIMFILTERTUTORIALSUIFigure);
            title(app.UIAxesFiltered, 'Filtered')
            app.UIAxesFiltered.XLimitMethod = 'tight';
            app.UIAxesFiltered.YLimitMethod = 'tight';
            app.UIAxesFiltered.ZLimitMethod = 'tight';
            app.UIAxesFiltered.XTick = [];
            app.UIAxesFiltered.XTickLabel = '';
            app.UIAxesFiltered.YTick = [];
            app.UIAxesFiltered.ZTick = [];
            app.UIAxesFiltered.Box = 'on';
            app.UIAxesFiltered.Position = [316 84 300 300];

            % Create UIAxesKernel
            app.UIAxesKernel = uiaxes(app.KOSOMBEIMFILTERTUTORIALSUIFigure);
            title(app.UIAxesKernel, 'Kernel Shape')
            app.UIAxesKernel.XLimitMethod = 'tight';
            app.UIAxesKernel.YLimitMethod = 'tight';
            app.UIAxesKernel.ZLimitMethod = 'tight';
            app.UIAxesKernel.XTick = [];
            app.UIAxesKernel.XTickLabel = '';
            app.UIAxesKernel.YTick = [];
            app.UIAxesKernel.ZTick = [];
            app.UIAxesKernel.Box = 'on';
            app.UIAxesKernel.Position = [826 36 120 120];

            % Create IMFILTERTUTORIALSLabel
            app.IMFILTERTUTORIALSLabel = uilabel(app.KOSOMBEIMFILTERTUTORIALSUIFigure);
            app.IMFILTERTUTORIALSLabel.FontSize = 18;
            app.IMFILTERTUTORIALSLabel.FontWeight = 'bold';
            app.IMFILTERTUTORIALSLabel.Position = [27 402 213 36];
            app.IMFILTERTUTORIALSLabel.Text = 'IMFILTER TUTORIALS';

            % Create LoadImageButton
            app.LoadImageButton = uibutton(app.KOSOMBEIMFILTERTUTORIALSUIFigure, 'push');
            app.LoadImageButton.ButtonPushedFcn = createCallbackFcn(app, @LoadImageButtonPushed, true);
            app.LoadImageButton.Position = [637 401 100 23];
            app.LoadImageButton.Text = 'Load Image';

            % Create KernelTypeDropDownLabel
            app.KernelTypeDropDownLabel = uilabel(app.KOSOMBEIMFILTERTUTORIALSUIFigure);
            app.KernelTypeDropDownLabel.HorizontalAlignment = 'right';
            app.KernelTypeDropDownLabel.Enable = 'off';
            app.KernelTypeDropDownLabel.Position = [637 372 68 22];
            app.KernelTypeDropDownLabel.Text = 'Kernel Type';

            % Create KernelTypeDropDown
            app.KernelTypeDropDown = uidropdown(app.KOSOMBEIMFILTERTUTORIALSUIFigure);
            app.KernelTypeDropDown.Items = {'Average', 'Disk', 'Gaussian', 'Laplacian', 'LoG', 'Motion', 'Prewitt', 'Sobel'};
            app.KernelTypeDropDown.ValueChangedFcn = createCallbackFcn(app, @KernelTypeDropDownValueChanged, true);
            app.KernelTypeDropDown.Enable = 'off';
            app.KernelTypeDropDown.Position = [720 372 100 22];
            app.KernelTypeDropDown.Value = 'Average';

            % Create ParametersPanel
            app.ParametersPanel = uipanel(app.KOSOMBEIMFILTERTUTORIALSUIFigure);
            app.ParametersPanel.Enable = 'off';
            app.ParametersPanel.Title = 'Parameters';
            app.ParametersPanel.Position = [638 36 163 323];

            % Create SizeEditFieldLabel
            app.SizeEditFieldLabel = uilabel(app.ParametersPanel);
            app.SizeEditFieldLabel.HorizontalAlignment = 'right';
            app.SizeEditFieldLabel.Position = [43 264 28 22];
            app.SizeEditFieldLabel.Text = 'Size';

            % Create SizeEditField
            app.SizeEditField = uieditfield(app.ParametersPanel, 'numeric');
            app.SizeEditField.Limits = [0 Inf];
            app.SizeEditField.ValueChangedFcn = createCallbackFcn(app, @SizeEditFieldValueChanged, true);
            app.SizeEditField.HorizontalAlignment = 'center';
            app.SizeEditField.Position = [85 264 42 22];
            app.SizeEditField.Value = 3;

            % Create RadiusEditFieldLabel
            app.RadiusEditFieldLabel = uilabel(app.ParametersPanel);
            app.RadiusEditFieldLabel.HorizontalAlignment = 'right';
            app.RadiusEditFieldLabel.Position = [29 230 42 22];
            app.RadiusEditFieldLabel.Text = 'Radius';

            % Create RadiusEditField
            app.RadiusEditField = uieditfield(app.ParametersPanel, 'numeric');
            app.RadiusEditField.Limits = [0 Inf];
            app.RadiusEditField.ValueChangedFcn = createCallbackFcn(app, @RadiusEditFieldValueChanged, true);
            app.RadiusEditField.HorizontalAlignment = 'center';
            app.RadiusEditField.Position = [85 230 42 22];
            app.RadiusEditField.Value = 1;

            % Create SigmaEditFieldLabel
            app.SigmaEditFieldLabel = uilabel(app.ParametersPanel);
            app.SigmaEditFieldLabel.HorizontalAlignment = 'right';
            app.SigmaEditFieldLabel.Position = [32 196 39 22];
            app.SigmaEditFieldLabel.Text = 'Sigma';

            % Create SigmaEditField
            app.SigmaEditField = uieditfield(app.ParametersPanel, 'numeric');
            app.SigmaEditField.Limits = [0 Inf];
            app.SigmaEditField.ValueChangedFcn = createCallbackFcn(app, @SigmaEditFieldValueChanged, true);
            app.SigmaEditField.HorizontalAlignment = 'center';
            app.SigmaEditField.Position = [85 196 42 22];
            app.SigmaEditField.Value = 1;

            % Create AlphaEditFieldLabel
            app.AlphaEditFieldLabel = uilabel(app.ParametersPanel);
            app.AlphaEditFieldLabel.HorizontalAlignment = 'right';
            app.AlphaEditFieldLabel.Position = [35 163 36 22];
            app.AlphaEditFieldLabel.Text = 'Alpha';

            % Create AlphaEditField
            app.AlphaEditField = uieditfield(app.ParametersPanel, 'numeric');
            app.AlphaEditField.Limits = [0 1];
            app.AlphaEditField.ValueChangedFcn = createCallbackFcn(app, @AlphaEditFieldValueChanged, true);
            app.AlphaEditField.HorizontalAlignment = 'center';
            app.AlphaEditField.Position = [85 163 42 22];
            app.AlphaEditField.Value = 1;

            % Create LengthEditFieldLabel
            app.LengthEditFieldLabel = uilabel(app.ParametersPanel);
            app.LengthEditFieldLabel.HorizontalAlignment = 'right';
            app.LengthEditFieldLabel.Position = [29 130 42 22];
            app.LengthEditFieldLabel.Text = 'Length';

            % Create LengthEditField
            app.LengthEditField = uieditfield(app.ParametersPanel, 'numeric');
            app.LengthEditField.Limits = [0 Inf];
            app.LengthEditField.ValueChangedFcn = createCallbackFcn(app, @LengthEditFieldValueChanged, true);
            app.LengthEditField.HorizontalAlignment = 'center';
            app.LengthEditField.Position = [85 130 42 22];
            app.LengthEditField.Value = 3;

            % Create ThetaEditFieldLabel
            app.ThetaEditFieldLabel = uilabel(app.ParametersPanel);
            app.ThetaEditFieldLabel.HorizontalAlignment = 'right';
            app.ThetaEditFieldLabel.Position = [36 97 35 22];
            app.ThetaEditFieldLabel.Text = 'Theta';

            % Create ThetaEditField
            app.ThetaEditField = uieditfield(app.ParametersPanel, 'numeric');
            app.ThetaEditField.Limits = [0 360];
            app.ThetaEditField.ValueChangedFcn = createCallbackFcn(app, @ThetaEditFieldValueChanged, true);
            app.ThetaEditField.HorizontalAlignment = 'center';
            app.ThetaEditField.Position = [85 97 42 22];

            % Create ThetaSlider
            app.ThetaSlider = uislider(app.ParametersPanel);
            app.ThetaSlider.Limits = [0 360];
            app.ThetaSlider.ValueChangingFcn = createCallbackFcn(app, @ThetaSliderValueChanging, true);
            app.ThetaSlider.Position = [33 83 99 3];

            % Create ThetaSlider
            app.ThetaSlider = uislider(app.ParametersPanel);
            app.ThetaSlider.Limits = [0 360];
            app.ThetaSlider.ValueChangingFcn = createCallbackFcn(app, @ThetaSliderValueChanging, true);
            app.ThetaSlider.Position = [33 83 99 3];

            % Create TransposeCheckBox
            app.TransposeCheckBox = uicheckbox(app.ParametersPanel);
            app.TransposeCheckBox.ValueChangedFcn = createCallbackFcn(app, @TransposeCheckBoxValueChanged, true);
            app.TransposeCheckBox.Text = 'Transpose';
            app.TransposeCheckBox.Position = [27 19 78 22];

            % Create ThetaSlider
            app.ThetaSlider = uislider(app.ParametersPanel);
            app.ThetaSlider.Limits = [0 360];
            app.ThetaSlider.ValueChangingFcn = createCallbackFcn(app, @ThetaSliderValueChanging, true);
            app.ThetaSlider.Position = [33 83 99 3];

            % Create ThetaSlider
            app.ThetaSlider = uislider(app.ParametersPanel);
            app.ThetaSlider.Limits = [0 360];
            app.ThetaSlider.ValueChangingFcn = createCallbackFcn(app, @ThetaSliderValueChanging, true);
            app.ThetaSlider.Position = [33 83 99 3];

            % Create ThetaSlider
            app.ThetaSlider = uislider(app.ParametersPanel);
            app.ThetaSlider.Limits = [0 360];
            app.ThetaSlider.ValueChangingFcn = createCallbackFcn(app, @ThetaSliderValueChanging, true);
            app.ThetaSlider.Position = [33 83 99 3];

            % Create PaddingOptionsButtonGroup
            app.PaddingOptionsButtonGroup = uibuttongroup(app.KOSOMBEIMFILTERTUTORIALSUIFigure);
            app.PaddingOptionsButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @PaddingOptionsButtonGroupSelectionChanged, true);
            app.PaddingOptionsButtonGroup.Enable = 'off';
            app.PaddingOptionsButtonGroup.Title = 'Padding Options';
            app.PaddingOptionsButtonGroup.Position = [825 253 123 106];

            % Create SymmetricButton
            app.SymmetricButton = uiradiobutton(app.PaddingOptionsButtonGroup);
            app.SymmetricButton.Text = 'Symmetric';
            app.SymmetricButton.Position = [11 56 80 22];
            app.SymmetricButton.Value = true;

            % Create ReplicateButton
            app.ReplicateButton = uiradiobutton(app.PaddingOptionsButtonGroup);
            app.ReplicateButton.Text = 'Replicate';
            app.ReplicateButton.Position = [11 34 72 22];

            % Create CircularButton
            app.CircularButton = uiradiobutton(app.PaddingOptionsButtonGroup);
            app.CircularButton.Text = 'Circular';
            app.CircularButton.Position = [11 12 64 22];

            % Create OutputSizeButtonGroup
            app.OutputSizeButtonGroup = uibuttongroup(app.KOSOMBEIMFILTERTUTORIALSUIFigure);
            app.OutputSizeButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @OutputSizeButtonGroupSelectionChanged, true);
            app.OutputSizeButtonGroup.Enable = 'off';
            app.OutputSizeButtonGroup.Title = 'Output Size';
            app.OutputSizeButtonGroup.Position = [825 169 123 77];

            % Create SameButton
            app.SameButton = uiradiobutton(app.OutputSizeButtonGroup);
            app.SameButton.Text = 'Same';
            app.SameButton.Position = [11 30 53 22];
            app.SameButton.Value = true;

            % Create FullButton
            app.FullButton = uiradiobutton(app.OutputSizeButtonGroup);
            app.FullButton.Text = 'Full';
            app.FullButton.Position = [11 8 41 22];

            % Show the figure after all components are created
            app.KOSOMBEIMFILTERTUTORIALSUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = imfilter_tutorials_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.KOSOMBEIMFILTERTUTORIALSUIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.KOSOMBEIMFILTERTUTORIALSUIFigure)
        end
    end
end