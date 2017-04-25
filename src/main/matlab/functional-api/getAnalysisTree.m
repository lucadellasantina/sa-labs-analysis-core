function analysisTree = getAnalysisTree(identifier, varargin)

    ip = inputParser();
    ip.addParameter('isExperiment', false, @islogical);
    ip.parse(varargin{:});
    isExperiment = ip.Results.isExperiment;

    import sa_labs.analysis.*;

    if ~ isExperiment
        project  = getAnalysisManager().initializeProject(identifier);
        analysisTree = core.factory.createFeatureBuilder('project', identifier,...
            'data', project.getAllresult());
    else
        dao = getInstance('analysisDao');
        treeData = dao.findAnalysisResult(dao.findAnalysisResultNames(experiment));
        analysisTree = core.factory.createFeatureBuilder('project', matlab.lang.makeValidName(char(datetime)),...
            'data', treeData);
    end

end

