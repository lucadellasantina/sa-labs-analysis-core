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