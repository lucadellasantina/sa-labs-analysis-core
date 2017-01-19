classdef AnalaysisManagerPresenter < appbox.Presenter
  	

  	properties
        viewSelectedCloseFcn
    end

    properties (Access = private)
        log
        settings
        documentationService
        acquisitionService
        configurationService
        detailedEntitySet
        uuidToNode
    end

    methods

        function obj = AnalaysisManagerPresenter(documentationService, acquisitionService, configurationService, view)
            if nargin < 4
                view = symphonyui.ui.views.DataManagerView();
            end
            obj = obj@appbox.Presenter(view);

            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.settings = symphonyui.ui.settings.DataManagerSettings();
            obj.documentationService = documentationService;
            obj.acquisitionService = acquisitionService;
            obj.configurationService = configurationService;
            obj.detailedEntitySet = symphonyui.core.persistent.collections.EntitySet();
            obj.uuidToNode = containers.Map();
        end

    end

    methods (Access = protected)

        function willGo(obj)
            obj.populateEntityTree();
            try
                obj.loadSettings();
            catch x
                obj.log.debug(['Failed to load presenter settings: ' x.message], x);
            end
            obj.updateStateOfControls();
        end

        function willStop(obj)
            obj.viewSelectedCloseFcn = [];
            try
                obj.saveSettings();
            catch x
                obj.log.debug(['Failed to save presenter settings: ' x.message], x);
            end
        end

        function bind(obj)
            bind@appbox.Presenter(obj);

            v = obj.view;
            obj.addListener(v, 'SelectedNodes', @obj.onViewSelectedNodes).Recursive = true;
            obj.addListener(v, 'SelectedFeatureGroupSignal', @obj.onViewSelectedConfigureDevices);
            obj.addListener(v, 'SelectedFeatureSignal', @obj.onViewSelectedAddSource);
            obj.addListener(v, 'AddFeature', @obj.onViewSetSourceLabel);
          
            obj.addListener(v, 'SendEntityToWorkspace', @obj.onViewSelectedSendEntityToWorkspace);
            obj.addListener(v, 'DeleteEntity', @obj.onViewSelectedDeleteEntity);

        end

        function onViewSelectedClose(obj, ~, ~)
            if ~isempty(obj.viewSelectedCloseFcn)
                obj.viewSelectedCloseFcn();
            end
        end

    end
end