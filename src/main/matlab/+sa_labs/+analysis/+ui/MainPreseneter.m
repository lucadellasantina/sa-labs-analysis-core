classdef MainPreseneter < appbox.Presenter

	properties
		analysisService
	end

	methods

		function obj = MainPreseneter(analysisService, view)
			if nargin < 2
				view = sa_labs.analysis.ui.MainView();
			end
			obj = obj@appbox.Presenter(view);

			obj.analysisService = analysisService;
		end

		function showProjects(obj)
			presenter = sa_labs.analysis.ui.presenters.ProjectsPresenter(obj.analysisService);
			presenter.goWaitStop();
		end

		function populateProjectTree(obj)

		end

	end

end