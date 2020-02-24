function [outputArg1,outputArg2,outputArg4,outputArg5] = computeFailureProbability(inputArg1,inputArg2)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
specs = inputArg1;
problem = inputArg2;
specs.Problem = problem;
run(fullfile(problem,[problem,'.m']))
outputArg1 = XpF.pfhat;
outputArg2 = -norminv(XpF.pfhat);
outputArg4 = XpF;
outputArg5 = Xoutput;
end

