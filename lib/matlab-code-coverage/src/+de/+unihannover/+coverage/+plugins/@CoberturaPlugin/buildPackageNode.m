function node = buildPackageNode(this,doc,package,basePath)
%GETPACKAGES Summary of this function goes here
%   Detailed explanation goes here

node = doc.createElement('package');

node.setAttribute('name',package.name);
node.setAttribute('line-rate',string(package.lineRate));
node.setAttribute('branch-rate',string(package.branchRate));
node.setAttribute('complexity',string(package.complexity));

classes = doc.createElement('classes');
for i = 1:numel(package.classes)
    classes.appendChild(buildClassNode(this,doc,package.classes(i),basePath));
end
node.appendChild(classes);

end

