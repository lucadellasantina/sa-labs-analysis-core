classdef Constants < handle
    
    properties(Constant)
        
        TEMPLATE_ANALYSIS_NAME = 'analysis'
        TEMPLATE_BUILD_TREE_BY = 'buildTreeBy'
        TEMPLATE_COPY_PARAMETERS = 'copyParameters'
        TEMPLATE_SPLIT_VALUE = 'splitValue'
        TEMPLATE_FEATURE_EXTRACTOR = 'featureExtractor'
        TEMPLATE_TYPE = 'type'
        TEMPLATE_FEATURE_BUILDER_CLASS = 'featureBuilder'
        TEMPLATE_FEATURE_DESC_FILE = 'feature-description-file'
        
        FEATURE_DESC_FILE_NAME = 'feature-description.csv'
        ANALYSIS_LOGGER = 'sa-labs-analysis-core-logger'

        EPOCH_KEY_SUFFIX = 'EPOCH'
        
        ANALYSIS_PROJECT_FOLDER = 'projects'
        ANALYSIS_CELL_DATA_FOLDER = 'cellData'
        ANALYSIS_FILTER_FOLDER = 'filters'
        ANALYSIS_TREE_FOLDER = 'analysisTrees'
    end
end

