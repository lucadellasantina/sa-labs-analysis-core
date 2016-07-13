function resultTree = doSingleAnalysis(cellName, analysisClazz, cellFilter, epochFilter)

if nargin < 4
    epochFilter = [];
end
if nargin < 3
    cellFilter = [];
end

resultTree = []; 
analysisTable = loadAnalysisTable();
nAnalyses = length(analysisTable{1});
analysisInd = 0;

for i = 1 : nAnalyses
    if strcmp(analysisTable{2}{i}, analysisClazz);
        analysisInd = i;
        break
    end
end

if analysisInd == 0
    disp(['Error: analysis ' analysisClazz ' not found in DataSetAnalyses.txt']);
    return
end

[parameters, cellData] = loadCellData(cellName);

if ~ isempty(cellFilter) &&  cellData.filterCell(cellFilter.makeQueryString())
    return
end

resultTree = AnalysisTree();
nodeData = struct();
nodeData.name = ['Single analysis tree: ' cellName ' : ' analysisClazz];
nodeData.device = parameters.deviceName;
resultTree = resultTree.set(1, nodeData);
dataSetKeys = cellData.savedDataSets.keys;

for i = 1 : length(dataSetKeys);

    proccedAnalysis = false;
    dataSetKey = dataSetKeys{i};
    
    if ~ isempty(epochFilter) && strfind(dataSetKey, analysisTable{1}{analysisInd})
        
        dataSet = cellData.savedDataSets(dataSetKey);
        filterOut = cellData.filterEpochs(epochFilter.makeQueryString(), dataSet);
        
        if length(filterOut) == length(dataSet) % All epochs match filter
            proccedAnalysis = true;
        end
    end
    
    if proccedAnalysis
        params = parameters;
        params.class = analysisClazz;
        params.cellName = cellName;      
        
        constructor = str2func(analysisClazz);
        T = constructor(cellData, dataSetKey, params);
        T = T.doAnalysis(cellData);
        if ~ isempty(T)
            resultTree = resultTree.graft(1, T);
        end
    end
end

% If nothing found for this cell
% return empty so this does not get grafted onto anything
if length(resultTree.Node) == 1 
    resultTree = [];
end
end