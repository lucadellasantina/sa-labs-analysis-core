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

analysisProtocol = core.AnalysisProtocol(analysisPreset);

project = offlineAnalysisManager.doAnalysis('optometer-calibration', analysisProtocol);