load workerInput.mat

try
    TableOutput = Xworker.evaluate(TableInput);
    save workerOutput.mat TableOutput
catch ME
    for i=length(ME.stack):-1:1
    display(ME.stack(i).file)
        display(ME.stack(i).line)
    end
    save workerOutput.mat ME
end
exit