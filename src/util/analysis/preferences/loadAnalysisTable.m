function table = loadAnalysisTable()

% getAnalysisTable - Open DataSetsAnalyses.txt file that defines
% the mapping between data set names and analysis classes

global PREFERENCE_FILES_FOLDER

fid = fopen([PREFERENCE_FILES_FOLDER '\DataSetAnalyses.txt'], 'r');
table = textscan(fid, '%s\t%s');
fclose(fid);
end

