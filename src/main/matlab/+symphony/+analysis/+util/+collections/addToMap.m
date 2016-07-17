function map  = addToMap(map, key, value)

if iskey(map, key)
    map(value) = [map(key), value];
else
    map(key) = value;
end
end

