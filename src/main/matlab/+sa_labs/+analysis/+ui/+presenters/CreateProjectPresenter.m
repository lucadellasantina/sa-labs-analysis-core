classdef CreateProjectPresenter < appbox.Presenter
    
    properties (Access = private)
        log
        session
        settings
    end
    
    methods
        
        function obj = CreateProjectPresenter(session, view)
            if nargin < 2
                view = sa_labs.analysis.ui.views.CreateProjectView();
            end
            obj = obj@appbox.Presenter(view);
            
            obj.settings = sa_labs.analysis.ui.settings.CreateProjectSettings();
            obj.log = log4m.getLogger();
            obj.session = session;
        end
    end
    
    methods (Access = protected)
        
        function willGo(obj, ~, ~)
            obj.populateProjectProperties();
            try
                obj.loadSettings();
            catch x
                obj.log.debug(['Failed to load presenter settings: ' x.message], x);
            end
        end
        
        function bind(obj)
            bind@appbox.Presenter(obj);
            
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'Ok', @obj.onViewSelectedOk);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
            obj.addListener(v, 'SetProjectProperty', @obj.onViewSetProjectProperty);
        end
    end
    
    methods (Access = private)
        
        function populateProjectProperties(obj)
            obj.session.project = obj.session.analysisDataService.createEmptyProject();
            
            try
                fields = sa_labs.analysis.ui.util.desc2field(obj.session.project.getPropertyDescriptors());
            catch x
                fields = uiextras.jide.PropertyGridField.empty(0, 1);
                stack = dbstack;
                obj.log.error([class(obj) '.' stack.name], x.message);
                obj.view.showError(x.message);
            end
            obj.view.setProjectProperties(fields);
        end
        
        function updateProjectProperties(obj)
            try
                fields = sa_labs.analysis.ui.util.desc2field(obj.session.project.getPropertyDescriptors());
            catch x
                fields = uiextras.jide.PropertyGridField.empty(0, 1);
                stack = dbstack;
                obj.log.error([class(obj) '.' stack.name], x.message);
                obj.view.showError(x.message);
            end
            obj.view.updateProjectProperties(fields);
        end
        
        function onViewSetProjectProperty(obj, ~, event)
            p = event.Property;
            try
                obj.session.project.setProperty(p.Name, p.Value);
            catch x
                stack = dbstack;
                obj.log.error([class(obj) '.' stack.name], x.message);
                obj.view.showError(x.message);
                return;
            end
        end
        
        function onViewKeyPress(obj, ~, event)
            switch event.data.Key
                case 'return'
                    if obj.view.getEnableOk()
                        obj.onViewSelectedOk();
                    end
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end
        
        function onViewSelectedOk(obj, ~, ~)
            obj.view.update();
            project = obj.session.project;
            try
                obj.view.enableOk(false);
                obj.view.startSpinner();
                obj.view.update();
                
                obj.session.analysisDataService.createProject(project);
                obj.session.presets.addProjectPresets(project.createPreset(project.name));
                obj.session.presets.save();
            catch x
                
                stack = dbstack;
                obj.log.error([class(obj) '.' stack.name], x.message);
                obj.view.showError(x.message);
                obj.view.stopSpinner();
                obj.view.enableOk(true);
                return;
            end
            
            try
                obj.saveSettings();
            catch x
                obj.log.debug(['Failed to save presenter settings: ' x.message], x);
            end
            obj.stop();
        end
        
        function onViewSelectedCancel(obj, ~, ~)
            obj.stop();
        end
        
        function loadSettings(obj)
            if ~isempty(obj.settings.viewPosition)
                obj.view.position = obj.settings.viewPosition;
            end
        end
        
        function saveSettings(obj)
            obj.settings.viewPosition = obj.view.position;
            obj.settings.save();
        end
    end
    
end

