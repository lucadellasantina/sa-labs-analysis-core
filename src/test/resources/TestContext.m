ctx = struct();

ctx.analysisDao.class = 'sa_labs.analysis.dao.AnalysisFolderDao';
ctx.analysisDao.repository = 'fileRepository';

ctx.preferenceDao.class = 'sa_labs.analysis.dao.PreferenceDao';
ctx.preferenceDao.repository = 'fileRepository';

ctx.fileRepository.class = 'sa_labs.analysis.app.FileRepository';
