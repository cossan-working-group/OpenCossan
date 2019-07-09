function node = buildClassNode(this,doc,class,basePath)
%GETCLASSES Summary of this function goes here
%   Detailed explanation goes here

node = doc.createElement('class');
node.setAttribute('name',class.name);
node.setAttribute('filename',...
    de.unihannover.util.PathUtils.relativeToBasePath(basePath,...
    class.fileName));
node.setAttribute('line-rate',string(class.lineRate));
node.setAttribute('branch-rate',string(class.branchRate));
node.setAttribute('complexity',string(class.complexity));

functions = doc.createElement('methods');
for i = 1:numel(class.functions)
    functions.appendChild(buildMethodNode(this,doc,class.functions(i)));
end
node.appendChild(functions);

lines = doc.createElement('lines');
for i = 1:numel(class.lines)
    for j = 1:numel(class.lines(i).lines)
        line = doc.createElement('line');
        line.setAttribute('number',string(class.lines(i).lines(j).number));
        line.setAttribute('hits',string(class.lines(i).lines(j).hits));
        line.setAttribute('branch',string(class.lines(i).lines(j).branch));
        line.setAttribute('time',string(class.lines(i).lines(j).time));

        if (class.lines(i).lines(j).branch)
            line.setAttribute('condition-coverage',"0% (0/0)");
        end
        lines.appendChild(line);
    end
end
node.appendChild(lines);

end

