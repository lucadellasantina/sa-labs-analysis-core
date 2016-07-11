function parseRawDataFiles(expDate)

global RAW_DATA_FOLDER;
global ANALYSIS_FOLDER;

rawDirPath = RAW_DATA_FOLDER;
cellDataDirPath = [ANALYSIS_FOLDER 'cellData' filesep];
rawDir = dir(rawDirPath);
cellDir = dir(cellDataDirPath);

allCellDataNames = {};
z = 1;

for i = 1 : length(cellDir)
    if strfind(cellDir(i).name, '.mat')
        allCellDataNames{z} = cellDir(i).name;
        z = z + 1;
    end
end

for i = 1 : length(rawDir)
    
    if any(strfind(rawDir(i).name, expDate)) &&  ~any(strfind(rawDir(i).name, 'metadata'))
        
        curCellName = rawDir(i).name;
        curCellName = strtok(curCellName, '.');
        
        overwrite = true;
        if strmatch(curCellName, allCellDataNames)
            answer = questdlg(['Overwrite current cellData file ' curCellName '?'] , 'Overwrite warning:', 'No','Yes','Yes');
            overwrite =  strcmp(answer, 'Yes');
        end
        
        if overwrite
            tic;
            disp(['parsing ' curCellName]);
            fname = [rawDirPath curCellName '.h5'];
            
            if h5readatt(fname, '/', 'version') == 2
                cellData = symphony2Mapper(fname);
            else
                cellData = CellData(fname);
            end
            save([cellDataDirPath curCellName], 'cellData');
            disp(['Elapsed time: ' num2str(toc) ' seconds']);
        end
    end
end
end
