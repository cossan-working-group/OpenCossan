function node = buildMethodNode(~,doc,method)
%GETMETHODS Summary of this function goes here
%   Detailed explanation goes here
node = doc.createElement('method');
node.setAttribute('name',method.name);
node.setAttribute('signature',method.signature);
node.setAttribute('line-rate',string(method.lineRate));
node.setAttribute('branch-rate',string(method.branchRate));
node.setAttribute('complexity',string(method.complexity));

lines = doc.createElement('lines');
for i = 1:numel(method.lines.lines)
    line = doc.createElement('line');
    line.setAttribute('number',string(method.lines.lines(i).number));
    line.setAttribute('hits',string(method.lines.lines(i).hits));
    line.setAttribute('branch',string(method.lines.lines(i).branch));
    
    if (method.lines.lines(i).branch)
        line.setAttribute('condition-coverage',"0% (0/0)");
    end
    
    lines.appendChild(line);
end
node.appendChild(lines);
end

