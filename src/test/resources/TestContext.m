ctx = struct();

ctx.analysisDao.class = 'sa_labs.analysis.dao.AnalysisFolderDao';
ctx.preferenceDao.class = 'sa_labs.analysis.dao.PreferenceDao';
ctx.offlineAnalaysisManager.class = 'sa_labs.analysis.app.OfflineAnalaysisManager';

ctx.fileRepositorySettings = sa_labs.analysis.TestRepositorySettings();
