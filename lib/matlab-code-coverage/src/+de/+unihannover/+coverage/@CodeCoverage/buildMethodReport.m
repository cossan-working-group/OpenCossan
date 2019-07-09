function [method] = buildMethodReport(this, name, signature, shortClassName,...
    fileName, methodsCallInfo, runnableLineIndex, code, profData)
%BUILDMETHODREPORT Summary of this function goes here
%   Detailed explanation goes here

%initialize output
method = de.unihannover.coverage.stats.MethodStats.empty;

methodCallInfo = [
    methodsCallInfo(strcmp({methodsCallInfo.type}, 'class method') & strcmp({methodsCallInfo.name}, name));
    methodsCallInfo(strcmp({methodsCallInfo.type}, 'nested-function') & strcmp({methodsCallInfo.fullname}, [shortClassName '>' shortClassName '.' name]));
    methodsCallInfo(strcmp({methodsCallInfo.type}, 'subfunction') & strcmp({methodsCallInfo.fullname}, [shortClassName '>' name]))];

%method not defined in main class file
if isempty(methodCallInfo)
    if ~any(fileName == '@'); return; end
    methodFileName = [fileName(1:find(fileName == filesep, 1, 'last')) name '.m'];
    if ~this.CodeInfoProvider.exists(methodFileName); return; end
    if (isequal(fileName, methodFileName)); return; end

    methodCallInfo = this.CodeInfoProvider.getCallInfo(methodFileName);
    runnableLineIndex = this.CodeInfoProvider.getRunnableLines(methodFileName);

    % Skip empty files that are mistaken for containing functions
    if any([methodCallInfo.firstline] == 0) || ...
       any([methodCallInfo.lastline] == 0); return; end

    code = this.CodeInfoProvider.readCode(methodFileName);
    
    method = de.unihannover.coverage.stats.MethodStats.empty(numel(methodCallInfo),0);
    for i = 1:numel(methodCallInfo)
        methodProfData = profData.FunctionTable(strcmp({profData.FunctionTable.FunctionName}, [shortClassName '.' methodCallInfo(i).fullname]));
        if i ~= 1
           signature = []; 
        end
        method(i) = this.buildSubFunctionReport(methodFileName, code, runnableLineIndex, methodCallInfo(i), signature, methodProfData);
    end
    return;
end

%method defined in main class file
method = de.unihannover.coverage.stats.MethodStats(name,fileName,signature,...
    methodCallInfo.firstline, methodCallInfo.lastline);
%lines
methodProfData = profData.FunctionTable(strcmp({profData.FunctionTable.CompleteName}, [fileName '>' shortClassName '.' name]));
method.addLineStats(this.buildLinesReport(code, runnableLineIndex, method.firstLine, method.lastLine, methodProfData));

%method stats
if ~isempty(methodProfData)
    method.calls = methodProfData.NumCalls;
    method.time = methodProfData.TotalTime;
end
end

