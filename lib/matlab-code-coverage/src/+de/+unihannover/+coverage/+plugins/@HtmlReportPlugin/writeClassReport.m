function writeClassReport(~, fileID, package, class)
%WRITE Summary of this function goes here
%   Detailed explanation goes here

template_index = fileread(which(fullfile('assets', 'html', 'class', 'index.html')));
template_method = fileread(which(fullfile('assets', 'html', 'class', 'method.html')));

index = strrep(template_index,'{{package}}',package);
index = strrep(index,'{{class}}',class.name);

% Summary
summary = de.unihannover.coverage.plugins.HtmlReportPlugin.injectSummary(class);
index = strrep(index,'{{summary}}',summary);

methods = '';

for i = 1:numel(class.functions)
    m = class.functions(i);
    
    method = strrep(template_method,'{{method}}',m.name);
    
    method = de.unihannover.coverage.plugins.HtmlReportPlugin.injectSummary(m, method);
    
    methods = strcat(methods, method);
    if i < numel(class.functions)
        methods = strcat(methods, sprintf(newline));
    end
end

index = strrep(index,'{{methods}}',methods);

fprintf(fileID, index);
end

