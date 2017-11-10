classdef NetworkDriveSynchronizer < sa_labs.util.FileSynchronizer
    
    properties
        serverRoot
        localRoot
    end
    
    methods
        
        function obj = NetworkDriveSynchronizer(localRoot, serverRoot)
            obj.localRoot = localRoot;
            obj.serverRoot = serverRoot;
        end
        
        function tf = isConnected(obj)
            tf = exist(obj.serverRoot, 'dir');
        end
        
        function uploadFile(obj, fname, localFolder, remoteFolder)
            
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

