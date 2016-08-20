function obj = getInstance(fname)
import symphony.analysis.parser.*

version = SymphonyParser.getVersion(fname);

if version == 2
    obj = Symphony2Parser();
else
    obj = DefaultSymphonyParser();
end
obj.fname = fname;
end

