classdef NetworkDriveSynchronizer < sa_labs.analysis.sync.FileSynchronizer
    
    properties
        serverRoot
        localRoot
    end
    
    methods
        
        function tf = isConnected(obj)
            tf = exist(obj.serverRoot, 'dir');
        end
        
        function uploadFile(obj, fname, localFolder, remoteFolder)
            
            if nargin < 3
                remoteFolder = localFolder;
            end
            
            if ~ obj.isConnected()
                return;
            end
            
            if obj.isFileInSync(fname, localFolder, remoteFolder)
                return;
            end
            
            dest = fullfile(obj.serverRoot, remoteFolder);
            src = fullfile(obj.localRoot, localFolder, fname);
            copyfile(src, dest, 'f');
        end
        
        function downloadFile(obj, fname, localFolder, remoteFolder)
            
            if nargin < 3
                remoteFolder = localFolder;
            end
            
            if ~ obj.isConnected()
                return;
            end
            
            if obj.isFileInSync(fname, localFolder, remoteFolder)
                return;
            end
            
            dest = fullfile(obj.localRoot, localFolder);
            src = fullfile(obj.serverRoot, remoteFolder, fname);
            copyfile(src, dest, 'f');
        end
        
        function fileList = listFiles(obj, folder, pattern)
            fileList = [];
            
            if ~ obj.isConnected()
                return;
            end
            dest = fullfile(obj.localRoot, folder, ['*' pattern '*']);
            info = dir(dest);
            fileList = arrayfun(@(d) {d.name(1 : end-4)}, info);
        end
    end
    
    methods (Access = protected)
        
        function tf = isFileInSync(obj, fname, localFolder, remoteFolder)
            tf = false;
            
            src = fullfile(obj.localRoot, localFolder, fname);
            localFileInfo = dir(src);
            
            if isempty(localFileInfo)
                return;
            end
                
            localModDate = localFileInfo.datenum;
            dest = fullfile(obj.serverRoot, remoteFolder, fname);
            remoteFileInfo = dir(dest);
            
            if isempty(remoteFileInfo)
                return;
            end

            serverModDate = remoteFileInfo.datenum;
            tf = localModDate == serverModDate;
        end
    end
end

