function [method] = buildSubFunctionReport(this, fileName, code, runnableLineIndex, callInfo, signature, profData)
%BUILDSUBFUNCTIONREPORT Summary of this function goes here
%   Detailed explanation goes here

method = de.unihannover.coverage.stats.MethodStats(callInfo.fullname, fileName,...
    signature, callInfo.firstline, callInfo.lastline);

%lines
method.addLineStats(this.buildLinesReport(code, runnableLineIndex, method.firstLine, ...
    method.lastLine, profData));

%method stats
if ~isempty(profData)
    method.calls = profData.NumCalls;
    method.time = profData.TotalTime;
end

end

