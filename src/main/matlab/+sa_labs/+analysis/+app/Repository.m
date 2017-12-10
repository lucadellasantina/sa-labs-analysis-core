classdef Repository < handle
    
    properties
        analysisFolder
        rawDataFolder
        preferenceFolder
        dateFormat
        remoteAnalysisFolder
        remoteRawDataFolder
        logFile
    end
    
    properties (Dependent)
        cellDataFolder
        filterFolder
        analysisTreeFolder
    end
    
    methods
        
        function obj = Repository()
            obj.createFolder(obj.analysisFolder);
            obj.createFolder(obj.rawDataFolder);
            obj.createFolder(obj.preferenceFolder);
            obj.createFolder([obj.analysisFolder filesep '.logs']);
        end
        
        function folder = get.cellDataFolder(obj)
            folder = [obj.analysisFolder filesep sa_labs.analysis.app.Constants.ANALYSIS_CELL_DATA_FOLDER filesep];
            obj.createFolder(folder);
        end
        
        function folder = get.filterFolder(obj)
            folder = [obj.analysisFolder filesep sa_labs.analysis.app.Constants.ANALYSIS_FILTER_FOLDER filesep];
            obj.createFolder(folder);
        end
        
        function folder = get.analysisTreeFolder(obj)
            folder = [obj.analysisFolder filesep sa_labs.analysis.app.Constants.ANALYSIS_TREE_FOLDER filesep];
            obj.createFolder(folder);
        end
        
        function folder = getProjectFolder(obj, identifier)
            folder = [obj.repository.analysisFolder filesep sa_labs.analysis.app.Constants.ANALYSIS_PROJECT_FOLDER filesep];
            if nargin == 2
                folder = [folder identifier filesep];
            end
            obj.createFolder(folder)
        end
    end
    
    methods (Access = private)
        
        function createFolder(~, folder)
            
            if ~ exist(folder, 'dir')
                mkdir(folder)
            end
        end
    end
end

