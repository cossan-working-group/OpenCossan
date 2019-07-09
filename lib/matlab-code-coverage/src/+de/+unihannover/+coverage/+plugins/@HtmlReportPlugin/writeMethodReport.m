function writeMethodReport(this, fileID, package, class, method)
%WRITE Summary of this function goes here
%   Detailed explanation goes here
template_index = fileread(which(fullfile('assets', 'html', 'method', 'index.html')));

index = strrep(template_index,'{{package}}',package);
index = strrep(index,'{{class}}',class);
index = strrep(index,'{{method}}',method.name);

% Summary
summary = de.unihannover.coverage.plugins.HtmlReportPlugin.injectSummary(method);
index = strrep(index,'{{summary}}',summary);

%% Write coverage count
coverage = cell(method.lastLine-method.firstLine,1);
for j = method.firstLine:method.lastLine
    if method.lines.lines(j-method.firstLine+1).valid
        if method.lines.lines(j-method.firstLine+1).hits > 0
            coverage{j-method.firstLine + 1} = sprintf('<span class="covered">%dx</span>', method.lines.lines(j-method.firstLine+1).hits);
        else
            coverage{j-method.firstLine + 1} = sprintf('<span class="uncovered">%dx</span>', method.lines.lines(j-method.firstLine+1).hits);
        end
    else
        coverage{j-method.firstLine + 1} = '';
    end
end
index = strrep(index,'{{coverage}}',sprintf('%s\n',coverage{:}));

%% Write line numbers
index = strrep(index,'{{numbers}}',sprintf('%d.\n',method.firstLine:method.lastLine));

%% Write code
code = this.CodeInfoProvider.readCode(method.fileName);

indent = find(code{method.firstLine} ~= ' ',1,'first') - 1;
if indent == 0; indent = 1; end

for j = method.firstLine:method.lastLine
    % Remove indentation
    code{j} = code{j}(indent:end);
    % Escape special characters (potentially incomplete)
    code{j} = strrep(code{j},'&','&amp;');
    code{j} = strrep(code{j},'<','&lt;');
    code{j} = strrep(code{j},'>','&gt;');
    code{j} = strrep(code{j},'\','\\');
    code{j} = strrep(code{j},'%','%%');
end

index = strrep(index,'{{code}}',sprintf('%s\n',code{method.firstLine:method.lastLine}));

fprintf(fileID,index);

end
