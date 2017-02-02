import sa_labs.analysis.*;

configPath = which('ExampleAnalysisContext');
obj.beanFactory = mdepin.getBeanFactory(configPath);
offlineAnalysisManager = obj.beanFactory.getBean('offlineAnalaysisManager');

project = entity.AnalysisProject();
project.identifier = 'optometer-calibration';
project.analysisDate = datestr(now, 'dd.mm.yyyy');
project.experimentDate = datestr(datetime(2017, 01, 30), 'mmddyy');
project.performedBy = 'daisuke';

offlineAnalysisManager.createProject(project)

data = project.getCellData(project.cellDataNames{1});

