function [project, offlineAnalysisManager] = createAnalysisProject(experiment, name)
    
    if nargin < 2
        name = matlab.lang.makeValidName(char(datetime));
    end
    experimentDate = datenum(experiment, 'mmddyy');
    
    import sa_labs.analysis.*;
    
    offlineAnalysisManager = getInstance('offlineAnalaysisManager');
    project = entity.AnalysisProject();
    project.identifier = name;
    project.analysisDate = datestr(now, 'dd.mm.yyyy');
    project.experimentDate = datestr(experimentDate, 'mmddyy');
    project.performedBy = getenv('username');
    project.addCellData(experiment);

    project = offlineAnalysisManager.createProject(project);

end

