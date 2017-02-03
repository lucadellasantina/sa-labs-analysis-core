%% Application initialization
clear;
pause(1);

import sa_labs.analysis.*;

configPath = which('ExampleAnalysisContext');
obj.beanFactory = mdepin.getBeanFactory(configPath);
offlineAnalysisManager = obj.beanFactory.getBean('offlineAnalaysisManager');

%% phase 1) project creation block

project = entity.AnalysisProject();
project.identifier = 'optometer-calibration';
project.analysisDate = datestr(now, 'dd.mm.yyyy');
project.experimentDate = datestr(datetime(2017, 01, 30), 'mmddyy');
project.performedBy = 'daisuke';

offlineAnalysisManager.createProject(project)

data = project.getCellData(project.cellDataNames{1});
offlineAnalysisManager.preProcess(data, {@(d) addRstarMean(data.epochs,  data.savedFileName)})
data.recordingLabel = 'optometer';

data %#ok display data

%% phase 2) start analysis

analysisPreset = struct();
analysisPreset.type = 'optometer-analysis';
analysisPreset.buildTreeBy = {'stimTime', 'pulseAmplitude'};
analysisPreset.extractorClass = 'sa_labs.analysis.core.FeatureExtractor';
analysisPreset.pulseAmplitude.featureExtractor = {'@(e, f) symphony_v1.addEpochAsFeature(e, f, ''device'', ''Optometer'')'};

analysisProtocol = core.AnalysisProtocol(analysisPreset);
project = offlineAnalysisManager.doAnalysis('optometer-calibration', analysisProtocol);

treeManager = core.FeatureTreeManager(project.getAllresult{1});
treeManager.getStructure().tostring() 

treeManager.getFeatureGroups(1).parameters

%% phase 3) plot the results

figure(1)
for i = [3, 4, 5, 6]
    epochsOfpulseAmplitude80 = treeManager.getFeatureGroups(i).featureMap('EPOCH');
    plot(mean([epochsOfpulseAmplitude80.data], 2));
    hold on;
end
hold off;
