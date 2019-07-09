function in = inSources(this, fileName)
%INSOURCES Check if the file is located inside one of the defined source
%folders
%
%   IN = inSources(THIS,FILENAME)

in = false;
for i = 1:size(this.sources, 1)
    source = this.sources{i, 1};
    if startsWith(fileName,source)
        % Found inside sources -> return true
        in = true;
        return;
    end
end
end