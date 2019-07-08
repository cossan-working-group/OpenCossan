function [Xout, varargout]=deterministicAnalysis(Xc)
%
%
%
% See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/DeterministicAnalysis@Connector

% By passing an empty array as second argument, the connector is instructed
% to run the solver using the original input files
[Xout, varargout{1},  varargout{2}, varargout{3}]=run(Xc,[]);
