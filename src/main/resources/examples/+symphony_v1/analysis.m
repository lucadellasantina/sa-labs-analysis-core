%% Application initialization
clear;
pause(1);

import sa_labs.analysis.*;

configPath = which('ExampleAnalysisContext');
obj.beanFactory = mdepin.getBeanFactory(configPath);
offlineAnalysisManager = obj.beanFactory.getBean('offlineAnalaysisManager');

%% step 1) create project

project = entity.AnalysisProject();
project.identifier = 'optometer-calibration';
project.analysisDate = datestr(now, 'dd.mm.yyyy');
project.experimentDate = datestr(datetime(2017, 01, 30), 'mmddyy');
project.performedBy = 'daisuke';

offlineAnalysisManager.createProject(project)

data = project.getCellData(project.cellDataNames{1});
% offlineAnalysisManager.preProcess(data, {@(d) addRstarMean(data.epochs,  data.savedFileName)})
data.recordingLabel = 'optometer';

data %#ok display data

%% step 2) do analysis

analysisPreset = struct();
analysisPreset.type = 'optometer-analysis';
analysisPreset.buildTreeBy = {'stimTime', 'pulseAmplitude'};
analysisPreset.featureManager = 'sa_labs.analysis.core.FeatureTreeManager';
analysisPreset.pulseAmplitude.featureExtractor = {'@(e, f) symphony_v1.extractorFunctions.addEpochAsFeature(e, f, ''device'', ''Optometer'')'};
analysisPreset.stimTime.featureExtractor = {'@(e, f)symphony_v1.extractorFunctions.computeIntegralOfPulse(e, f)'};

analysisProtocol = core.AnalysisProtocol(analysisPreset);

tic;
project = offlineAnalysisManager.doAnalysis('optometer-calibration', analysisProtocol);
result = project.getResult('optometer-analysis');
toc;

treeManager = core.FeatureTreeManager(analysisProtocol, core.AnalysisMode.OFFLINE_ANALYSIS, result);
treeManager.getStructure().tostring()

treeManager.getFeatureGroups(2).parameters

%% step 3) plot the results

figure(1)
for i = [3, 4, 5, 6]
    group = treeManager.getFeatureGroups(i);
    tic;
    average = group.getFeatureData('EPOCH_AVERAGE');
    toc;
    t = symphony_v1.extractorFunctions.util.getStimulusDuration(group);
    plot(t, average);
    hold on;
end
hold off;

figure(2)
power = treeManager.getFeatureGroups(2).getFeatureData('TIME_INTEGRAL');
pulseAmplitude = treeManager.getFeatureGroups(2).getParameter('pulseAmplitude');
plot(pulseAmplitude, power, 'o--')
