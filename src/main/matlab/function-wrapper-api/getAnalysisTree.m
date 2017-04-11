function analysisTree = getAnalysisTree(experiment)

    import sa_labs.analysis.*;
    dao = getInstance('analysisDao');
    
    treeData = dao.findAnalysisResult(dao.findAnalysisResultNames(experiment));
    analysisTree = core.factory.createFeatureBuilder('project', matlab.lang.makeValidName(char(datetime)),...
        'data', treeData);
    analysisTree.getStructure().tostring()
end

