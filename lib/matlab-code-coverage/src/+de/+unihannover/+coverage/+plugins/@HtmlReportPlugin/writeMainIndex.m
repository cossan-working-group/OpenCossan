function writeMainIndex(~, fileID, coverage)
%WRITE Summary of this function goes here
%   Detailed explanation goes here
template_index = fileread(which(fullfile('assets', 'html', 'main', 'index.html')));
template_source = fileread(which(fullfile('assets', 'html', 'main', 'source.html')));
template_package = fileread(which(fullfile('assets', 'html', 'main', 'package.html')));

sources = '';
% Sources
for i = 1:size(coverage.sources, 1)
    if ispc
        sources = strcat(sources,strrep(template_source,'{{source}}',... 
            strrep(coverage.sources{i,1},filesep,'\\')));
    else
        sources = strcat(sources,strrep(template_source,'{{source}}',coverage.sources{i,1}));
    end
    if i < size(coverage.sources, 1)
        sources = strcat(sources,newline);
    end
end

index = strrep(template_index,'{{sources}}',sources);

% Summary
summary = de.unihannover.coverage.plugins.HtmlReportPlugin.injectSummary(coverage);
index = strrep(index,'{{summary}}',summary);

packages = '';

for i = 1:numel(coverage.packages)
    p = coverage.packages(i);
      
    package = strrep(template_package,'{{package}}',p.name);
    package = strrep(package,'{{classes}}',sprintf('%d', numel(p.classes)));
    package = de.unihannover.coverage.plugins.HtmlReportPlugin.injectSummary(p, package);
    
    packages = strcat(packages, package);
    if i < numel(coverage.packages)
        packages = strcat(packages, sprintf(newline));
    end
end

index = strrep(index,'{{packages}}',packages);

fprintf(fileID, index);
end

