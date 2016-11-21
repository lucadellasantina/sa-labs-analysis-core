%% Mock object for presenters
import sa_labs.analysis.*;
config = Mock(mdepin.StructConfig());
mockService = Mock(app.AnalysisDataService(config));

presets = app.Presets.getDefault();
session = app.Session(presets, mockService);
project = entity.Project();
project.createExperimentFilesType({'060716c1', '060716c2', '060716c3'});

%% Test project presenter
mockService.when.initializeProject(AnyArgs()).thenReturn([]);
mockService.when.createEmptyProject(AnyArgs()).thenReturn(project);
mockService.when.createProject(AnyArgs()).thenReturn([]);

presenter = ui.presenters.ProjectsPresenter(session);
presenter.goWaitStop();
