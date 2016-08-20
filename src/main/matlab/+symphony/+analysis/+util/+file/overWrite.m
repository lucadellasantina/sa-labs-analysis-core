function overWrite(folder)

if exist(folder, 'file')
    rmdir(folder, 's');
end
mkdir(folder);
end