function project = createTempProject(experiment)


    import sa_labs.analysis.*;

    offlineAnalysisManager = getInstance('offlineAnalaysisManager');

    project = entity.AnalysisProject();
    project.identifier = matlab.lang.makeValidName(char(datetime));
    project.analysisDate = datestr(now, 'dd.mm.yyyy');
    project.experimentDate = datetime;
    project.performedBy = 'For the time being, I prefer to anonymous';
    project.addCellData(experiment);

    project = offlineAnalysisManager.createProject(project);

end

