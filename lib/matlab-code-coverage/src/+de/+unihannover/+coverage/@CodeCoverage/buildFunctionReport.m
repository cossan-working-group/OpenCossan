function [class] = buildFunctionReport(this, packageName, metaFunction, profData)
%BUILDFUNCTIONREPORT Summary of this function goes here
%   Detailed explanation goes here
fileName = this.CodeInfoProvider.getFunctionFile(packageName, metaFunction.Name);

if ~inSources(this, fileName)
    class = de.unihannover.coverage.stats.ClassStats.empty;
    return;
end

class = de.unihannover.coverage.stats.ClassStats(['_' metaFunction.Name],fileName);

methodsCallInfo = this.CodeInfoProvider.getCallInfo(fileName);
runnableLineIndex = this.CodeInfoProvider.getRunnableLines(fileName);
code = this.CodeInfoProvider.readCode(fileName);

for i = 1:numel(methodsCallInfo)
    methodCallInfo = methodsCallInfo(i);
    methodProfData = profData.FunctionTable(strcmp({profData.FunctionTable.CompleteName}, [fileName '>' methodCallInfo.name]));
    method = this.buildSubFunctionReport(fileName, code, runnableLineIndex, methodCallInfo, [], methodProfData);
    
    class.addFunction(method);
end

end

