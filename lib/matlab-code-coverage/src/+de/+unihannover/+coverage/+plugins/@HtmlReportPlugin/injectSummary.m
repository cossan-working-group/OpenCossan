function html = injectSummary(stats, html)
% GETSUMMARY Creates the summary header for packages/classes
import de.unihannover.coverage.plugins.HtmlReportPlugin;

if ~exist('html','var') || isempty(html)
    html = fileread(which(['assets' filesep 'html' filesep 'summary.html']));
end

branchLevel = de.unihannover.coverage.plugins.HtmlReportPlugin.getCoverageLevel(stats.branchRate);
lineLevel = de.unihannover.coverage.plugins.HtmlReportPlugin.getCoverageLevel(stats.lineRate);

%% Inject branch stats
html = strrep(html,'{{branch-rate}}',sprintf('%2.2f',stats.branchRate*100));
html = strrep(html,'{{branches-covered}}',sprintf('%d',stats.branchesCovered));
html = strrep(html,'{{branches-valid}}',sprintf('%d', stats.branchesValid));
html = strrep(html,'{{branch-level}}',branchLevel);

%% Inject line stats
html = strrep(html,'{{line-rate}}',sprintf('%2.2f',stats.lineRate*100));
html = strrep(html,'{{lines-covered}}',sprintf('%d',stats.linesCovered));
html = strrep(html,'{{lines-valid}}',sprintf('%d',stats.linesValid));
html = strrep(html,'{{line-level}}',lineLevel);

%% Inject complexity
html = strrep(html,'{{complexity}}',sprintf('%d',stats.complexity));

%% Inject bar (only present in summary.html)
html = strrep(html,'{{level}}',lineLevel);

end

