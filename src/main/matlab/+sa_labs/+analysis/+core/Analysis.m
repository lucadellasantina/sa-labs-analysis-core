classdef Analysis < handle
    
    properties (SetAccess = protected)
        identifier
        functionContext
        featureBuilder
        state
    end
    
    properties
        analysisProtocol
        log
    end
    
    properties(Abstract)
        mode
    end
    
    methods
        
        function obj = Analysis(protocol, recordingLabel)
            import sa_labs.analysis.*;
            obj.log = logging.getLogger(app.Constants.ANALYSIS_LOGGER);
            
            obj.state = app.AnalysisState.NOT_STARTED;
            obj.identifier = strcat(protocol.type, '-', recordingLabel);
            obj.analysisProtocol = protocol;
            obj.featureBuilder = core.factory.createFeatureBuilder('class', protocol.featurebuilderClazz,...
                'name', 'analysis',...
                'value', obj.identifier);
            
            obj.log.debug(['protocol [ ' obj.identifier ' ] is initialized with builder [ ' class(obj.featureBuilder) ' ]' ]);
        end
        
        function service(obj)
            
            if isempty(obj.analysisProtocol)
                error('analysisProtocol is empty'); %TODO replace with exception
            end
            obj.state = sa_labs.analysis.app.AnalysisState.STARTED;
            obj.log.info('started building analysis ...');
            obj.build();
            obj.log.info('started extracting features ...');
            obj.extractFeatures();
            obj.state = sa_labs.analysis.app.AnalysisState.COMPLETED;
            obj.log.info('completed analysis ...');
        end
        
        function r = getResult(obj)
            r = obj.featureBuilder.dataStore;
        end
        
        function setEpochSource(obj, source) %#ok
            % will be overriden in the subclass
        end
    end
    
    methods (Access = protected)
        
        function extractFeatures(obj)
            [map, order] = obj.getFeaureGroupsByProtocol();
            keys = map.keys();
            parameters = keys(order);
            
            for i = numel(parameters) : -1 : 1
                parameter = parameters{i};
                functions = obj.analysisProtocol.getExtractorFunctions(parameter);
                featureGroups = map(parameter);
                
                if ~ isempty(featureGroups)
                    obj.log.debug(['feature extraction for [ ' parameter ' featureGroups id ' num2str([featureGroups.id]) ']']);
                    
                    % obj.copyEpochParameters(featureGroups);
                    obj.delegateFeatureExtraction(functions, featureGroups);
                    
                    obj.log.debug('collecting features ...');
                    keySet = featureGroups.getFeatureKey();
                    obj.featureBuilder.collect([featureGroups.id], keySet, keySet);
                end
            end
        end
    end
    
    methods (Access = protected, Abstract)
        build(obj)
        getFeaureGroupsByProtocol(obj)
        copyEpochParameters(obj, featureGroups)
    end
    
    methods (Access = private)
        
        function delegateFeatureExtraction(obj, functions, featureGroups)
            
            for i = 1 : numel(functions)
                func = str2func(functions{i});
                try 
                    for group = featureGroups
                        func(obj, group);
                    end
                catch exception
                    disp(getReport(exception, 'extended', 'hyperlinks', 'on'));
                    obj.log.error(exception.message);
                end
            end
        end
        
    end
end
