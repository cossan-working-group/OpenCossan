function writePackageReport(~, fileID, package)
%WRITE Summary of this function goes here
%   Detailed explanation goes here

template_index = fileread(which(fullfile('assets', 'html', 'package', 'index.html')));
template_class = fileread(which(fullfile('assets', 'html', 'package', 'class.html')));

index = strrep(template_index,'{{package}}',package.name);

% Summary
summary = de.unihannover.coverage.plugins.HtmlReportPlugin.injectSummary(package);
index = strrep(index,'{{summary}}',summary);

classes = '';

for i = 1:numel(package.classes)
    c = package.classes(i);
    
    class = strrep(template_class,'{{class}}',c.name);
    class = de.unihannover.coverage.plugins.HtmlReportPlugin.injectSummary(c, class);
    
    classes = strcat(classes, class);
    if i < numel(package.classes)
        classes = strcat(classes, sprintf(newline));
    end
end

index = strrep(index,'{{classes}}',classes);

fprintf(fileID, index);
end

