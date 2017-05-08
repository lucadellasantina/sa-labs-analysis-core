function [project, offlineAnalysisManager] = createAnalysisProject(projectName, experiments)

import sa_labs.analysis.*;

offlineAnalysisManager = getInstance('offlineAnalaysisManager');

try
    project = offlineAnalysisManager.initializeProject(projectName);
    
    if ~ all(ismember(experiments, project.experimentList))
        project.addExperiments(experiments);
        offlineAnalysisManager.createProject(project);
    end
    
catch exception
    if ~ strcmp(exception.identifier, app.Exceptions.NO_PROJECT.msgId)
      rethrow(exception);
    end
    disp(exception.message);
    
    fileRepo = getInstance('fileRepository');
    project = entity.AnalysisProject();
    project.identifier = projectName;
    project.analysisDate = fileRepo.dateFormat(date);
    project.addExperiments(experiments);
    project.performedBy = getenv('username');
    offlineAnalysisManager.createProject(project);
end
end