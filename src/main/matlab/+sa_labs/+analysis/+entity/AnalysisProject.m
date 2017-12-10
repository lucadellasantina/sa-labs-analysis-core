classdef AnalysisProject < handle & matlab.mixin.CustomDisplay
    
    properties
        identifier              % project identifier
        description             % Brief description about the project
        experimentList          % List of experiment hdf5 files which are part of project
        cellDataIdList          % List of cell-cluster id (or) cell data id parsed from experiment hdf5 file
        analysisDate            % Latest analysis date 
        analysisResultIdList    % List of analysis results of format ( analysis protocol name - cell data name i.e. 'Example-Analysis-20170325Dc1')
        performedBy             % Who performed the analysis
        file                    % Location of project file
    end
    
    properties(Access = private)
        cellDataMap
        resultMap
    end
    
    methods

        function obj = AnalysisProject(structure)
            
            % Loads the project structure (originally from json) 
            % and set it to the class properties
            
            obj.clear();
            obj.experimentList = {};
            
            if nargin < 1
                return
            end
            attributes = fields(structure);
            for i = 1 : numel(attributes)
                attr = attributes{i};
                obj.(attr) = structure.(attr);
            end
        end

        function addExperiments(obj, dateOrPattern)
            dateOrPattern = cellstr(dateOrPattern);
            cellfun(@(d) obj.addToList('experimentList', d), dateOrPattern);
        end
        
        function list = get.experimentList(obj)
            list = cellstr(obj.experimentList);
        end

        function addCellData(obj, cellName, cellData)
            obj.addToList('cellDataIdList', cellName);
            obj.cellDataMap(cellName) = cellData;
        end

        function list = get.cellDataIdList(obj)
            list = cellstr(obj.cellDataIdList);
        end
        
        function c = getCellData(obj, cellName)
            c = obj.cellDataMap(cellName);
        end

        function arrays = getCellDataArray(obj)
            list = obj.cellDataMap.values;
            [~, idx] = ismember(obj.cellDataIdList, obj.cellDataMap.keys);
            list = list(idx);
            arrays = [list{:}];
        end

        function addResult(obj, resultId, analysisResult)
            obj.addToList('analysisResultIdList', resultId);
            obj.resultMap(resultId) = analysisResult;
        end

        function list = get.analysisResultIdList(obj)
            list = cellstr(obj.analysisResultIdList);
        end
        
        function r = getResult(obj, resultId)
            r = obj.resultMap(resultId);
        end

        function arrays = getAnalysisResultArray(obj)
            list = obj.resultMap.values;
            [~, idx] = ismember(obj.analysisResultIdList, obj.resultMap.keys);
            list = list(idx);
            arrays = [list{:}];
        end
        
        function clearCellData(obj)
            obj.cellDataIdList = {};
            obj.cellDataMap = containers.Map();
        end

        function clearAnalaysisResult(obj)
            obj.analysisResultIdList = {};
            obj.resultMap = containers.Map();
        end

        function clear(obj)
            obj.clearCellData();
            obj.clearAnalaysisResult();
        end

        function types = getUniqueAnalysisTypes(obj)
            types = {};
            
            for resultId = each(obj.analysisResultIdList)
                parsedId = strsplit(resultId, '-');
                types{end + 1} = parsedId{1};
            end
            types = unique(types);
        end

        function names = getCellNames(obj, analysisType)
            names = {};
            
            for resultId = each(obj.analysisResultIdList)
                if any(strfind(resultId, analysisType))
                    parsedId = strsplit(resultId, '-');
                    names{end + 1} = parsedId{2};
                end
            end
        end

        function name = getAnalysisResultName(obj, analysisType, cellName)
            name = strcat(analysisType, '-', cellName);
        end

    end

    methods (Access = private)
        
        function addToList(obj, prop, value)
            value = cellstr(value);

            if ~ isempty(obj.(prop)) && ismember(value, obj.(prop))
                return; 
            end
            obj.(prop)(end + 1) = value;    
        end
    end
end