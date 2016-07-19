function obj = getInstance(fname)
import symphony.analysis.parser.*

version = SymphonyParser.getVersion(fname);

if version == 2
    obj = DefaultSymphonyParser();
else
    obj = Symphony2Parser();
end

obj.fname = fname;
end

