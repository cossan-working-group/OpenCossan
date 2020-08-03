function [ext_point, comp_ext_point] = extremePoints(CN,varargin)%(LowerBound,UpperBound)

% extremePoints generates the extreme points from a Credal set defined
% by the bounds of the states of a node in the following format:
% LowerBound = [0.1 0.5 0.1]; UpperBound = [0.2 0.7 0.4]; , where:
% LowerBound := lower bounds of each state in the node (must be negative for linprog)
% UpperBound := upper bounds of each state in the node (must be positive for linprog)
%
% E.g., node_bounds = [.2 .7 .4 -.1 -.5 -.1];
% The linear programming algorithm is used in the following way:
% The objective function consists on the states xi of the node:
%   f(x1,x2,x3) = c1x1 + c2x2 + c3x3
% Also, the sum of the states must be 1, normalization:
%   P(X=x1)+P(X=x2)+P(X=x3)=1
% Constraints are then:
%   .1<=x1<=.2
%   .5<=x2<=.7
%   .1<=x3<=.4
%   x1+x2+x3 = 1
% Converting to the cannonical form, Ax <= b:
%   x1 <= .2
%   x2 <= .7
%   x3 <= .4
%   -x1 <= -.1
%   -x2 <= -.5
%   -x3 <= -.1
%   x1+x2+x3 <=1                    %Constraint of sum to 1, normalization
%   -x1-x2-x3 <=-1                  %Constraint of sum to 1, normalization
%     
% Calculating linear inequality constraints A and b
% A is a sparse matrix A = [[x1 0 0];[0 x2 0];[0 0 x3];[1 1 1];[-1 -1 -1]]; 
% A= [[1 0 0];[0 1 0];[0 0 1];[1 1 1];[-1 -1 -1]];
% A = [diag(ones(1,n_states))   %diagonal -ones matrix for the upper bounds
%      diag(-ones(1,n_states))  %diagonal -ones matrix for the lower bounds
%      ones(1,n_states)         %normalized upper bounds one per state
%      -ones(1,n_states)];      %normalized lower bounds one per state
% b is a sparse vector related to A
% b = [[UpperBound -LowerBound],1,-1];
%
% In the conditional case, namely P(X|Y) there is a combination of extreme
% points per local credal set, i.e., one per state of Y. (Intro to IP, p 216)
% E.g. X=(x1,x2), Y=(y1,y2) there are 4 extreme points for P(X|Y)
% 0.1 <= P(X=x1|Y=y1) <= 0.3
% 0.2 <= P(X=x1|Y=y2) <= 0.4
% ep1 = [P(x1|y1)=0.1, P(x2|y1)=0.9]; ep2 = [P(x1|y1)=0.3, P(x2|y1)=0.7];
% ep3 = [P(x1|y2)=0.2, P(x2|y2)=0.8]; ep4 = [P(x1|y2)=0.4, P(x2|y2)=0.6];

%   Author: Hector Diego Estrada-Lugo
%   Institute for Risk and Uncertainty, University of Liverpool, UK
%   email address: openengine@cossan.co.uk
%   Website: http://www.cossan.co.uk
%
%   =====================================================================
%   This file is part of openCOSSAN.  The open general purpose matlab
%   toolbox for numerical analysis, risk and uncertainty quantification.
%   
%   openCOSSAN is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License.
%
%   openCOSSAN is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
% =====================================================================


%% Initialise variables
p = inputParser;
p.FunctionName = 'opencossan.bayesiannetworks.CredalNetwork.extremePoints';

% Initialize input
p.addParameter('inode',@isnumeric);
p.addParameter('LowerBound',@isnumeric);
p.addParameter('UpperBound',@isnumeric);
p.parse(varargin{:});

% Assign input 
inode           = p.Results.inode;
LowerBound      = p.Results.LowerBound;
UpperBound      = p.Results.UpperBound;

% Checking bounds values
boundChecker      = LowerBound < UpperBound;

if numel(LowerBound) ~= sum(boundChecker)
    error('openCOSSAN:CredalNetwork',...
                'Values in Lower Bound must be smaller than values in Upper Bound in node: "%s"',...
                CN.NodesNames(CN.TopologicalOrder(inode)));
end


%%  Preparing inputs
bounds = [UpperBound -LowerBound];
n_states = length(LowerBound);
inds = 1:n_states;          %Create the index positions for bounds comparison

%% Preparing Linear Inequality Constraints
A = [diag(ones(1,n_states))   
     diag(-ones(1,n_states))  
     ones(1,n_states)         
     -ones(1,n_states)];
b = [bounds,1,-1];

%% Output 1. Extreme point
options = optimoptions('linprog','Display','none'); % Suppress linprog 'Optimal solution found' message
ext_point = linprog(-ones(1,n_states),A,b,[],[],[],[],options)';

% Checking if linprog was successful
if isempty(ext_point)
    error('openCOSSAN:CredalNetwork',...
                'Probability values in node "%s" do not sum to 1, extreme points could not be found',...
                CN.NodesNames(CN.TopologicalOrder(inode)));
end

%% Ouput 2. Complement extreme point
compare_low = abs(ext_point-LowerBound)>eps;   %In case they are not numerically equal
                                           %the comparison is rounded.
indsLow = inds(compare_low);               %Take the indices where the values are the same (Logic value=1)
indsUp = inds(~compare_low);               %Logic value 0
comp_ext_point(indsLow) = LowerBound(indsLow); %Assigning values to the positions indicated in indsLow
comp_ext_point(indsUp) = UpperBound(indsUp);


