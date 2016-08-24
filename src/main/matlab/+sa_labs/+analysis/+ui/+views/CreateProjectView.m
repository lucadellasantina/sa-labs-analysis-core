classdef CreateProjectView < appbox.View
    
    events
        Ok
        Cancel
        SetProjectProperty
    end
    
    properties
        projectPropertyGrid
        spinner
        okButton
        cancelButton
    end
    
    methods
        
        function createUi(obj)
            import appbox.*;
            
            set(obj.figureHandle, ...
                'Name', 'Select Project', ...
                'Position', screenCenter(230, 79));
            
            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 11);
            
            projectInputLayout = uix.VBox( ...
                'Parent', mainLayout, ...
                'Padding', 1, ...
                'Spacing', 5);
            
            obj.projectPropertyGrid = uiextras.jide.PropertyGrid(projectInputLayout, ...
                'Callback', @(h,d)notify(obj, 'SetProjectProperty', d), ...
                'ShowDescription', true);
            
            set(projectInputLayout, 'Heights', -1);
            
            controlsLayout = uix.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            spinnerLayout = uix.VBox( ...
                'Parent', controlsLayout);
            uix.Empty('Parent', spinnerLayout);
            obj.spinner = com.mathworks.widgets.BusyAffordance();
            javacomponent(obj.spinner.getComponent(), [], spinnerLayout);
            set(spinnerLayout, 'Heights', [4 -1]);
            uix.Empty('Parent', controlsLayout);
            obj.okButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'OK', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Ok'));
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Cancel'));
            set(controlsLayout, 'Widths', [16 -1 75 75]);
            
            set(mainLayout, 'Heights', [-1 23]);
            
            % Set OK button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.okButton);
            end
        end
        
        function enableOk(obj, tf)
            set(obj.okButton, 'Enable', appbox.onOff(tf));
        end
        
        function tf = getEnableOk(obj)
            tf = appbox.onOff(get(obj.okButton, 'Enable'));
        end
        
        function enableCancel(obj, tf)
            set(obj.cancelButton, 'Enable', appbox.onOff(tf));
        end
        
        function enableProjectProperties(obj, tf)
            set(obj.projectPropertyGrid, 'Enable', tf);
        end
        
        function f = getProjectProperties(obj)
            f = get(obj.projectPropertyGrid, 'Properties');
        end
        
        function setProjectProperties(obj, fields)
            set(obj.projectPropertyGrid, 'Properties', fields);
        end
        
        function updateProjectProperties(obj, fields)
            obj.projectPropertyGrid.UpdateProperties(fields);
        end
        
        function startSpinner(obj)
            obj.spinner.start();
        end
        
        function stopSpinner(obj)
            obj.spinner.stop();
        end
        
    end
    
end

