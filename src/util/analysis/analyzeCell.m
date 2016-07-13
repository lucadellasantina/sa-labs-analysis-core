function tree = analyzeCell(name)

% analyzeCell - Gets the analysis class name from DataSetAnalyses.txt 
% for the given datset present in @parameter name and performs doAnalysis() 
% 
% parameter 
%   name - cell name to be analyzed
%
% Description
%   1. loads analysis table from DataSetAnalyses.txt
%   2. loads preference map from cellData if exists
%   3. construct AnalysisTree with default nodedata 
%           - name [Full cell analysis tree @parameter name], 
%           - device [Amplifier device name]
%   4. Iterate through available data sets in celldata and check for
%   matched analysis class 
%           - DataSet name example [<AnaylsisClass>_Idenfifier]
%   5. perform do analysis for given anaylsis class and graft to parent 
%   analysis tree 
%
%
%   call hierarchy 
%   ---------------
%       + LabData.analyzeCells()
%           + LabDataGUI.analyzeAndBrowseCell()
%           + LabdataGUI.analyzeAndBrowseCell()

analysisTable = loadAnalysisTable();
[parameters, cellData] = loadCellData(name);
preferenceMap = loadPreferenceMap(cellData.prefsMapName);  

tree = AnalysisTree();
nodeData.name = ['Full cell analysis tree: ' name];
nodeData.device = parameters.deviceName;
tree = tree.set(1, nodeData);

nAnalyses = length(analysisTable{1});
dataSetKeys = cellData.savedDataSets.keys;

for i = 1 : length(dataSetKeys)
    curDataSet = dataSetKeys{i};

    for j = 1 : nAnalyses
        if isempty(strfind(curDataSet, analysisTable{1}{j}))
            continue;
        end
        
        analysisClazz = analysisTable{2}{j};
        [hasPreferences, keyName] = hasMatchingKey(preferenceMap, curDataSet);
        
        if hasPreferences
            paramSets = preferenceMap(keyName);

            for p = 1 : length(paramSets)
                curParamSet = paramSets{p};
                params = loadAnaylsisParameters(analysisClazz, curParamSet);
                params.deviceName = parameters.deviceName;
                params.parameterSetName = curParamSet;
                params.class = analysisClazz;
                params.cellName = name;
                tree = delegateDoAnalysis();
            end
        else
            params = parameters;
            params.class = analysisClazz;
            params.cellName = name;
            tree = delegateDoAnalysis();
        end
    end
end

    function t = delegateDoAnalysis()
        constructor = str2func(analysisClazz);
        T = constructor(cellData, curDataSet, params);
        T = T.doAnalysis(cellData);
        
        if ~ isempty(T)
            t = tree.graft(1, T);
        end
    end

end

function table = loadAnalysisTable()

% getAnalysisTable - Open DataSetsAnalyses.txt file that defines
% the mapping between data set names and analysis classes

global PREFERENCE_FILES_FOLDER

fid = fopen([PREFERENCE_FILES_FOLDER '\DataSetAnalyses.txt'], 'r');
table = textscan(fid, '%s\t%s');
fclose(fid);
end

function p = loadAnaylsisParameters(clazz, parameterSet)
global ANALYSIS_FOLDER

result = load([ANALYSIS_FOLDER 'analysisParams' filesep clazz filesep parameterSet]);
p = result.params;
end

function [p, cellData] = loadCellData(cellName)

% Deal with cell names that include '-Ch1' or '-Ch2'
global ANALYSIS_FOLDER

p = struct();
p.deviceName = AnalysisConstant.AMP_CH_ONE;
loc = strfind(cellName, '-Ch1');

if ~ isempty(loc)
    cellName = cellName(1 : loc-1);
end

loc = strfind(cellName, '-Ch2');
if ~ isempty(loc)
    cellName = cellName(1 : loc -1);
    p.deviceName = AnalysisConstant.AMP_CH_TWO;
end

result = load([ANALYSIS_FOLDER 'cellData' filesep cellName]);
cellData = result.cellData;
end

function map = loadPreferenceMap(filename)

global ANALYSIS_FOLDER
map = containers.Map();

folder = [ANALYSIS_FOLDER 'analysisParams' filesep 'ParameterPrefs' filesep];
fid = fopen([folder filename], 'r');

if fid == -1
    return
end

lineIn = fgetl(fid);
while ischar(lineIn)
    
    [dataSetName, remPart] = strtok(lineIn);
    remPart = strtrim(remPart);
    index = 1;
    paramSets = [];
    
    while ~isempty(remPart)
       [paramSet, remPart] = strtok(remPart);
       
       if ~isempty(paramSet)           
           paramSets{index} = paramSet;
           index = index + 1;
       end
    end
    
    map(dataSetName) = paramSets;
    lineIn = fgetl(fid);
end
end

