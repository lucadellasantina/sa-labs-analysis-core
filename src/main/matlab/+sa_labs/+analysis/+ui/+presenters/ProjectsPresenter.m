classdef ProjectsPresenter < appbox.Presenter
    
    properties (Access = private)
        log
        session
    end
    
    methods
        
        function obj = ProjectsPresenter(session, view)
            if nargin < 2
                view = sa_labs.analysis.ui.views.ProjectsView();
            end
            obj = obj@appbox.Presenter(view);
            obj.log = log4m.getLogger();
            obj.session = session;
        end
        
        function showCreateProjectPrsenter(obj)
            presenter = sa_labs.analysis.ui.presenters.CreateProjectPresenter(obj.session);
            presenter.goWaitStop();
        end
    end
    
    methods (Access = protected)
        
        function willGo(obj, ~, ~)
            obj.populateDescriptionList();
            obj.updateStateOfControls();
        end
        
        function bind(obj)
            bind@appbox.Presenter(obj);
            
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'Initialize', @obj.onViewSelectedInitialize);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end
        
    end
    
    methods (Access = private)
        
        function populateDescriptionList(obj)
            desc = obj.session.presets.getAvailableProjectPresetNames();
            desc{end + 1} = 'Create New Project..';
            obj.view.setDescriptionList(desc, desc);
            obj.view.enableSelectDescription(true);
        end
        
        function onViewKeyPress(obj, ~, event)
            switch event.data.Key
                case 'return'
                    if obj.view.getEnableInitialize()
                        obj.onViewSelectedInitialize();
                    end
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end
        
        function onViewSelectedInitialize(obj, ~, ~)
            obj.view.update();
            
            description = obj.view.getSelectedDescription();
            
            try
                if strcmp(description, 'Create New Project..')
                    obj.showCreateProjectPrsenter();
                    project = obj.session.project;
                else
                    project = obj.session.presets.getProjectPresets(description);
                end
                obj.session.analysisDataService.initializeProject(project.name);
                
            catch x
                stack = dbstack;
                obj.log.error([class(obj) '.' stack.name], x.message);
                obj.view.showError(x.message);
                return;
            end
            
            obj.stop();
        end
        
        function onViewSelectedCancel(obj, ~, ~)
            obj.stop();
        end
        
        function updateStateOfControls(obj)
            descriptionList = obj.view.getDescriptionList();
            hasDescription = ~isempty(descriptionList{1});
            
            obj.view.enableInitialize(hasDescription);
        end
    end
end

