function [output] = performanceFunctionSimpleStructuralFrame(MX)
% This fuction defines the performance function of the simple structural
% frame
% It requires 7 inputs and returs 1 output.
%
%% 1. Parameters

x1 = MX(:,1);
x2 = MX(:,2);
x3 = MX(:,3);
x4 = MX(:,4);
x5 = MX(:,5);
x6 = MX(:,6);
x7 = MX(:,7);

ga=x1+2*x3+2*x4+x5-5*x6-5*x7;
gb=x1+2*x2+x4+x5-5*x6;
gc=x2+2*x3+x4-5*x6;

output = max([ga gb gc],[],2);

