function main()
    global ANALYSIS_FOLDER
    ANALYSIS_FOLDER = 'D:\project\data\analysis\';
    global RAW_DATA_FOLDER
    RAW_DATA_FOLDER = 'D:\project\data\rawData\';
    global ANALYSIS_CODE_FOLDER
    ANALYSIS_CODE_FOLDER = 'D:\project\repo\becs\symphony-analysis1.x\src';
    global PREFERENCE_FILES_FOLDER
    PREFERENCE_FILES_FOLDER = 'D:\project\repo\becs\symphony-analysis1.x\resources';
    cd(ANALYSIS_FOLDER);
    addpath(genpath(ANALYSIS_CODE_FOLDER));
    addpath(genpath([fileparts(ANALYSIS_CODE_FOLDER) '\lib']));
end