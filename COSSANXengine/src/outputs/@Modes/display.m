function display(Xmodes)
%DISPLAY   Displays the information related to the modes object
%
%   MANDATORY ARGUMENT:
%   
%   - Xmodes:    modes object
%
%
%   OPTIONAL ARGUMENTS: -
%
%
%   EXAMPLE:
%
%   display(Xmodes)
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008 IfM
% =====================================================
%
% History:
% BG, 13-aug-2008
% BG, 01-sep-2008: Consolidation phase
% =====================================================

%% ARGUMENT CHECK

if ~isa(Xmodes, 'Modes') %FIXE: this clause will never be touched, please remove it
    error('openCOSSAN:modes:display','The argument MUST BE a modes object');
end

%% DISPLAY OBJECT INFORMATION

OpenCossan.cossanDisp(' ');
OpenCossan.cossanDisp(['     MODES oject; Name: ' inputname(1)])
OpenCossan.cossanDisp(['     (' Xmodes(1).Sdescription ')'])
if strcmp(Xmodes(1).Sdescription,'null')
    return
end
OpenCossan.cossanDisp(' ');
OpenCossan.cossanDisp('     ======================');
OpenCossan.cossanDisp(['     number of eigenvalues : ' num2str(length(Xmodes(1).Vlambda))]);
OpenCossan.cossanDisp(['     size of matrix of eigenvectors = ' num2str(size(Xmodes(1).MPhi))]);
OpenCossan.cossanDisp(' ');
