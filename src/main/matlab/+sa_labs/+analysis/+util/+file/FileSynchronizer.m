classdef FileSynchronizer < handle
    
    methods (Abstract)
        isConnected(obj)
        uploadFile(obj, fname, srcFolder, destFolder)
        downloadFile(obj, fname, srcFolder, destFolder)
    end
    
    methods (Abstract, Access = protected)
        isFileInSync(obj, fname, srcFolder, destFolder)
    end
end

