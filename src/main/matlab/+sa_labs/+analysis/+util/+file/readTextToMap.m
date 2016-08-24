function map = readTextToMap(file)
map = containers.Map();
cell = importdata(file,'\n');

for i = 1 : numel(cell)
    text = regexp(cell{i},'\s','Split');
    map(text{1}) = text(2:end);
end
end