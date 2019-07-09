function MatrixOutput = compute(Xobj,MatrixInput)
%COMPUTE The covariance function to be evaluated. COMPUTE method accepts a matrix MatrixInput
% and returns a vector MatrixOutput.
%
% This method prepars a InputTable and then call the method evaluate and
% finally it converts the OutputTable to MatrixOutput.

% =====================================================================
% This file is part of *OpenCossan*: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License.
%
% *OpenCossan* is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
% =====================================================================


%% Check inputs
validateattributes(MatrixInput,{'numeric'},{'nonempty'})

% The number of rows in MX must be a multiple of 2
assert(mod(size(MatrixInput,1),2)==0,'OpenCossan:input:CovarianceFunction:evaluate',...
    ['The number of rows of the passed matrix MX must be a multiple of 2, ' ...
    'where this multiple is equal to the dimension of the input variables']);

%% Prepare input
Cnames=Xobj.InputNames;

if size(MatrixInput,1) == 2
    % if it is a mono-dimensional SP
    TableInput = array2table(MatrixInput','VariableNames',Cnames);
else
    % split the matrix with the combined input in two sub-matrices, then
    % convert them to cell array
    Ndimensions = size(MatrixInput,1)/2;
    TableInput= table(MatrixInput(1:Ndimensions,:)',MatrixInput(Ndimensions+1:Ndimensions*2,:)','VariableNames',Cnames);
end


%% Evaluate function
TableOutput = evaluate(Xobj,TableInput);

%% Extract values of the objective function
% The objective function should contain only 1 value in the field
% Coutputnames

MatrixOutput=table2array(TableOutput);

return
