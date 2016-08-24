classdef MainPreseneter < appbox.Presenter
    
    properties
        session
    end
    
    methods
        
        function obj = MainPreseneter(session, view)
            if nargin < 2
                view = sa_labs.analysis.ui.MainView();
            end
            obj = obj@appbox.Presenter(view);
            obj.session = session;
        end
        
        function showProjects(obj)
            presenter = sa_labs.analysis.ui.presenters.ProjectsPresenter(obj.session);
            presenter.goWaitStop();
        end
        
        function populateProjectTree(obj)
            
        end
        
    end
    
end