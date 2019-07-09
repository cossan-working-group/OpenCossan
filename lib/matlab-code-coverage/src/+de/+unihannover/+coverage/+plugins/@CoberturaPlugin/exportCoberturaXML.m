function [] = exportCoberturaXML(this, coverage)
% EXPORTCOBERTURAXML Exports the Cobertura style coverage report
% 
% For more information on the format, see <a href="web('https://github.com/cobertura/cobertura/blob/master/cobertura/src/test/resources/dtds/coverage-04.dtd')">here</a>.

doc = com.mathworks.xml.XMLUtils.createDocument('coverage');
root = doc.getDocumentElement;

root.setAttribute('line-rate',string(coverage.lineRate));
root.setAttribute('branch-rate',string(coverage.branchRate));
root.setAttribute('lines-covered',string(coverage.linesCovered));
root.setAttribute('lines-valid',string(coverage.linesValid));
root.setAttribute('branches-covered',string(coverage.branchesCovered));
root.setAttribute('branches-valid',string(coverage.branchesValid));
root.setAttribute('complexity',string(coverage.complexity));
root.setAttribute('version','0.1');
root.setAttribute('timestamp',coverage.timeStamp);

%% Append sources
sources = doc.createElement('sources');
for i = 1:size(coverage.sources, 1)
    source = doc.createElement('source');
    source.appendChild(doc.createTextNode(...
        string(coverage.sources{i,1})));
    sources.appendChild(source);
end
root.appendChild(sources);

%% Append packages
packages = doc.createElement('packages');
for i = 1:numel(coverage.packages)
    packages.appendChild(buildPackageNode(this,doc,coverage.packages(i),coverage.basePath));
end
root.appendChild(packages);

xmlwrite(this.fileName,doc);
end

