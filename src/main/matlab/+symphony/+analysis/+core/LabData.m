classdef LabData < handle
    
    properties
        cellTypes           % Keys are cell type names (e.g. On Alpha), values are cell names (e.g. 042214Ac1)
        allDataSets         % Keys are cell names, values are cell arrays of data set names
        analysisFolder      % Path to analysis folder fetched from global variable
    end
    
    methods
        
        function obj = LabData()
            
            global ANALYSIS_FOLDER
            obj.analysisFolder = ANALYSIS_FOLDER;
            obj.clearContents();
        end
        
        function clearContents(obj)
            obj.cellTypes = containers.Map(); 
            obj.allDataSets = containers.Map();
        end
        
        function tf = hasCell(obj, cellName)
            names = obj.allCellNames();
            tf = sum(strcmp(names, cellName)) > 0;
        end
        
        function typeName = getCellType(obj, cellName)
            types = obj.allCellTypes();
            typeName = [];
            
            for i = 1 : length(types)
                if any(strmatch(cellName, obj.cellTypes(types{i}), 'exact')) %#ok
                    typeName = types{i};
                end
            end
        end
        
        function cellNames = getCellsOfType(obj, typeName)
            % returns string array of cell names
            cellNames = [];
            
            if obj.cellTypes.isKey(typeName)
                cellNames = obj.cellTypes(typeName);
            end
        end
        
        function cellTypes = allCellTypes(obj)
            cellTypes = obj.cellTypes.keys;
        end
        
        function cellNames = allCellNames(obj)
            cellNames = obj.cellTypes.values;
        end
        
        function addCell(obj, cellName, typeName)
            
            if strcmp(obj.cellTypes.values, cellName)
                errordlg(['Cell ' cellName ' is already in the database. Use moveCell instead']);
                return
            end
            
            if obj.cellTypes.isKey(typeName)
                obj.cellTypes(typeName) = [obj.cellTypes(typeName); cellName];
            else
                obj.cellTypes(typeName) = {cellName};
            end
            obj.updateDataSets(cellName);
        end
        
        function renameType(obj, old, new)
            
            if ~any(strmatch(old, obj.cellTypes.keys, 'exact')) %#ok
                errordlg(['Type ' old ' not found']);
                return
            end
            
            curCellList = obj.cellTypes(old);
            obj.cellTypes(new) = curCellList;
            obj.cellTypes.remove(old);
        end
        
        function renameCell(obj, old, new)
            
            if ~any(strmatch(old, obj.cellTypes.values, 'exact')) %#ok
                errordlg(['Cell ' old ' not found']);
                return
            end
            
            typeName = obj.getCellType(old);
            curList = obj.cellTypes(typeName);
            curList = strrep(curList, old, new);
            obj.cellTypes(typeName) = curList;
            
            dataSets = obj.allDataSets(old);
            obj.allDataSets.remove(old);
            obj.allDataSets(new) = dataSets;
        end
        
        function moveCell(obj, cellName, typeName)
            
            if ~any(strmatch(cellName, obj.cellTypes.values, 'exact')) %#ok
                errordlg(['Cell ' cellName ' not found']);
                return
            end
            
            %remove from old list
            oldTypeName = obj.getCellType(cellName);
            curList = obj.cellTypes(oldTypeName);
            curList = curList(~strcmp(cellName, curList));
            obj.cellTypes(oldTypeName) = curList;
            
            %remove if empty
            if isempty(curList)
                obj.cellTypes.remove(oldTypeName);
            end
            
            %add to new list
            if obj.cellTypes.isKey(typeName)
                obj.cellTypes(typeName) = [obj.cellTypes(typeName); cellName];
            else
                obj.cellTypes(typeName) = {cellName};
            end
        end
        
        function clearEmptyTypes(obj)
            types = obj.cellTypes.keys;
            
            for i = 1 : length(types)
                if isempty(obj.cellTypes(types{i}))
                    obj.cellTypes.remove(types{i});
                end
            end
        end
        
        function deleteCell(obj, cellName)
           
            if ~ any(strcmp(cellName, obj.cellTypes.values))
                errordlg(['Cell ' cellName ' not found']);
                return
            end
            
            typeName = obj.getCellType(cellName);
            curList = obj.cellTypes(typeName);
            curList = curList(~strcmp(cellName, curList));
            obj.cellTypes(typeName) = curList;
            
            obj.allDataSets.remove(cellName);
            if isempty(obj.getCellsOfType(typeName))
                obj.cellTypes.remove(typeName);
            end
        end
        
        function mergeCellTypes(obj, type1, type2)
            % Merge type 1 into type 2
            cell1 = obj.getCellsOfType(type1);
            
            for i = 1 : length(cell1)
                obj.addCell(cell1{i}, type2);
            end
            obj.cellTypes.remove(type1);
        end
        
        function cellNames = cellsWithDataSet(obj, dataSetName)
            cells = oobj.cellTypes.values;
            cellNames = {};
            
            for i= 1 : length(cells)
                curCell = cells{i};
                
                if strmatch(dataSetName, obj.allDataSets(curCell)) %#ok
                    cellNames = [cellNames; curCell]; %#ok
                end
            end
        end
        
        function [cellTypes, N] = cellTypesWithDataSet(obj, dataSetName)
            % N is the number of each
            cellNames = obj.cellsWithDataSet(dataSetName);
            cellCountMap = containers.Map();
            
            for i = 1 : length(cellNames)
                curType = obj.getCellType(cellNames{i});
                
                if ~ cellCountMap.isKey(curType)
                    cellCountMap(curType) = 1;
                else
                    cellCountMap(curType) = cellCountMap(curType) + 1;
                end
            end
            
            cellTypes = cellCountMap.keys;
            N = cell2mat(cellCountMap.values);
            
            for i = 1 : length(cellTypes)
                disp([cellTypes{i} ': ' num2str(N(i))]);
            end
        end
       
        function displayAllDataSets(obj, cellName)
            dataSets = obj.allDataSets(cellName);
            
            for i = 1 : length(dataSets)
                disp(dataSets{i});
            end
        end
        
        function displayCellTypes(obj)
            keys = obj.cellTypes.keys;
            
            for i = 1 : length(keys)
                disp([keys{i} ': ' num2str(length(obj.cellTypes(keys{i})))]);
            end
        end
        
        function parts = getCurrentCellNameParts(~, curCellName)
            % Deal with cells split across two files
            [parts{1}, remStr] = strtok(curCellName, ',');
            
            if isempty(remStr)
                parts = {};
            end
            
            index = 2;
            while ~ isempty(remStr)
                [cellNamePart, remStr] = strtok(remStr, ',');
                
                if ~ isempty(cellNamePart)
                    parts{index} = strtrim(cellNamePart);
                end
                index = index + 1;
            end
        end
                
        function updateDataSets(obj, cellNames)
            
            if nargin < 2
                cellNames = obj.cellTypes.values;
            end
            
            if ischar(cellNames)
                cellNames = {cellNames};
            end
            
            for i = 1 : length(cellNames)
                
                cellName = cellNames{i};
                defaultName = cellName;
                cellName = strrep(cellName, '-Ch1', '');
                cellName = strrep(cellName, '-Ch2', '');
                
                remove(obj.allDataSets, defaultName);
                parts = obj.getCurrentCellNameParts(cellName);
                cellfun(@(part) addToAllDataSet(defaultName, part), parts)
                
                if isempty(parts)
                    addToAllDataSet(defaultName, cellName)
                end
            end
            
            function addToAllDataSet(key, name)
                
                result = load([obj.analysisFolder 'cellData' filesep name]);
                values =  result.cellData.savedDataSets.keys;
                
                if ~ isKey(obj.allDataSets, key)
                    obj.allDataSets(key) = values;
                else
                    obj.allDataSets(key) =  [obj.allDataSets(key), values];
                end
            end
        end
        
        function analyzeCells(obj, cellNames)

            if ischar(cellNames)
                cellNames = {cellNames};
            end
            
            for i = 1 : length(cellNames)
                cellName = cellNames{i};

                disp(['Analyzing cell ' cellName ': '...
                    num2str(i) ' of ' num2str(length(cellNames))]);
                
                parts = obj.getCurrentCellNameParts(cellName);
                cellfun(@(part) analyze(part), parts)

                if isempty(parts)
                    analyze(cellName);
                end
            end
            
            function analyze(name)
                 % call to util/analysis/analazeCell.m
                 analysisTree = analyzeCell(name); %#ok
                 save([obj.analysisFolder 'analysisTrees' filesep name], 'analysisTree');
            end
        end
        
        function resultTree = collectCells(obj, cellNames)

            if ischar(cellNames)
                cellNames = {cellNames};
            end
            
            resultTree = AnalysisTree();
            nodeData = struct('name', 'Collected cells tree: multiple cells');
            resultTree = resultTree.set(1, nodeData);
            
            for i = 1 : length(cellNames)
                cellName = cellNames{i};
                disp(['Collecting cell ' cellName ': '...
                    num2str(i) ' of ' num2str(length(cellNames))]);
                
                parts = obj.getCurrentCellNameParts(cellName);
                
                if isempty(parts)
                    resultTree = graft(cellName, resultTree);
                    continue
                end
                
                splitCellTree = AnalysisTree();
                nodeData = struct('name', ['Split cell: ' cellName]);
                splitCellTree = splitCellTree.set(1, nodeData);
                
                for j = 1 : length(parts)
                    splitCellTree = graft(parts{j}, splitCellTree);
                end
                resultTree = graft([], resultTree, splitCellTree);
            end
           
            function d = graft(name, destination, source)
                d = destination;
                
                if nargin < 3
                    result = load([obj.analysisFolder 'analysisTrees' filesep name]);
                    source = result.analysisTree;
                end
                
                if length(source.Node) > 1
                    d = destination.graft(1, source);
                end
            end
        end
        
        function resultTree = collectAnalysis(obj, analysisName, cellTypes, cellFilter, epochFilter)
            %if overwriteFlag is true, this will recompute the analysis for
            %each cell
            %it should always compute the analysis if the cell has the
            %matching dataset (not the current behavior of collectAnalysis)
            if nargin < 5
                epochFilter = [];
            end
            if nargin < 4
                cellFilter = [];
            end
            if nargin < 3
                cellTypes = obj.cellTypes.keys;
            end
            if ischar(cellTypes)
                cellTypes = {cellTypes};
            end
            
            resultTree = AnalysisTree();
            nodeData = struct('name', ['Collected analysis tree: ' analysisName]);
            resultTree = resultTree.set(1, nodeData);
            
            for i = 1 : length(cellTypes)
                cellType = cellTypes{i};
                disp(['Analyzing type ' cellType ': '...
                    num2str(i) ' of ' num2str(length(cellTypes))]);

                cellTypeTree = AnalysisTree();
                nodeData.name = [cellType];
                cellTypeTree = cellTypeTree.set(1, nodeData);
                cellNames = obj.getCellsOfType(cellType);
                
                for j = 1 : length(cellNames)
                    
                    cellName = cellNames{j};
                    disp(['Analyzing cell ' cellName ': '...
                        num2str(j) ' of ' num2str(length(cellNames))]);
                    
                    parts = obj.getCurrentCellNameParts(cellName);
                    cellfun(@(part) analyze(part), parts)

                    if isempty(parts)
                        analyze(cellName);
                    end
                end
                
                if length(cellTypeTree.Node) > 1
                    resultTree = resultTree.graft(1, cellTypeTree);
                end
            end
            
            function analyze(name)
                
                tree = doSingleAnalysis(name, analysisName, cellFilter, epochFilter);
                if ~isempty(tree)
                    cellTypeTree = cellTypeTree.graft(1, tree);
                end
            end
        end
        
    end   
end