function [class] = buildClassReport(this, metaClass, profData)
%BUILDCLASSREPORT Build coverage report for a class including methods,
%getters, setters, and nested(sub) functions

fileName = this.CodeInfoProvider.getClassFile(metaClass.Name);

if endsWith(fileName,'.p') || ~inSources(this, fileName)
    class = de.unihannover.coverage.stats.ClassStats.empty;
    return;
end

class = de.unihannover.coverage.stats.ClassStats(metaClass.Name, fileName);

shortClassName = metaClass.Name(find(metaClass.Name == '.', 1, 'last')+1:end);
methodsCallInfo = this.CodeInfoProvider.getCallInfo(fileName);
runnableLineIndex = this.CodeInfoProvider.getRunnableLines(fileName);

code = this.CodeInfoProvider.readCode(fileName);

%methods
for i = find(cellfun(@(x) isequal(x.DefiningClass.Name, metaClass.Name), metaClass.Methods))'
    metaMethod = metaClass.Methods{i};
    
    signature = sprintf('[%s] = %s(%s)', ...
        de.unihannover.util.StringUtils.strjoin(', ', metaMethod.OutputNames{:}),...
        metaMethod.Name, ...
        de.unihannover.util.StringUtils.strjoin(', ', metaMethod.InputNames{:}));
    
    method = this.buildMethodReport(...
        metaMethod.Name, signature, ...
        shortClassName, fileName, methodsCallInfo, runnableLineIndex, code, profData);
    
    for j = 1:numel(method)
        class.addFunction(method(j));
    end
end

%getters & setters
for i = find(cellfun(@(x) isequal(x.DefiningClass.Name, metaClass.Name), metaClass.Properties))'
    class.addFunction(this.buildMethodReport(...
        ['get.' metaClass.Properties{i}.Name], ['value = get.' metaClass.Properties{i}.Name '(this)'], ...
        shortClassName, fileName, methodsCallInfo, runnableLineIndex, code, profData));
    
    class.addFunction(this.buildMethodReport(...
        ['set.' metaClass.Properties{i}.Name], ['set.' metaClass.Properties{i}.Name '(this, value)'], ...
        shortClassName, fileName, methodsCallInfo, runnableLineIndex, code, profData));
end

%nested functions and subfunctions
for i = 1:numel(methodsCallInfo)
    methodCallInfo = methodsCallInfo(i);
    if ~ismember(methodCallInfo.type, {'nested-function', 'subfunction'},'legacy')
        continue;
    end
    
    class.addFunction(this.buildMethodReport(...
        methodCallInfo.fullname(find(methodCallInfo.fullname == '.',1,'first')+1:end), [], ...
        shortClassName, fileName, methodsCallInfo, runnableLineIndex, code, profData));
end

end

