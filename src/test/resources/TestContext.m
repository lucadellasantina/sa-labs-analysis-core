ctx = struct();

ctx.analysisDao.class = 'symphony.analysis.dao.AnalysisDao';
ctx.analysisDao.repository = 'fileRepository';

ctx.preferenceDao.class = 'symphony.analysis.dao.PreferenceDao';
ctx.preferenceDao.repository = 'fileRepository';

ctx.fileRepository.class = 'symphony.analysis.app.FileRepository';
