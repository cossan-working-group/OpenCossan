function Xobj=validateObject(Xobj)
%VALIDATEOBJCECT This is a protected function of Evaluator used to validate
%the inputs.
% See also: https://cossan.co.uk/wiki/index.php/@Evaluator
%
% Author: Edoardo Patelli
% Institute for Risk and Uncertainty, University of Liverpool, UK
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk

% =====================================================================
% This file is part of openCOSSAN.  The open general purpose matlab
% toolbox for numerical analysis, risk and uncertainty quantification.
%
% openCOSSAN is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License.
%
% openCOSSAN is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
% =====================================================================

% Validate objects
if Xobj.LverticalSplit
    Nworkers=1;
else
    Nworkers=length(Xobj.CXsolvers);
end

if ~isempty(Xobj.CSnames)
    assert(length(Xobj.CSnames)==Nworkers,...
        'openCOSSAN:Evaluator',...
        ['Length of CSnames (' num2str(length(Xobj.CSnames)) ...
        ') must be equal to the length of CXsolvers (' ...
        num2str(Nworkers) ')' ])
else
    Xobj.CSnames=repmat({'N/A'},Nworkers,1);
end

if ~isempty(Xobj.Vconcurrent)
    assert(length(Xobj.Vconcurrent)==Nworkers,...
        'openCOSSAN:Evaluator',...
        ['Length of Vconcurrent (' num2str(length(Xobj.Vconcurrent)) ...
        ') must be equal to the length of CXsolvers (' ...
        num2str(Nworkers) ')' ])
else
    Xobj.Vconcurrent=inf(size(Xobj.CXsolvers));
end

if ~isempty(Xobj.CSqueues)
    assert(length(Xobj.CSqueues)==Nworkers,...
        'openCOSSAN:Evaluator',...
        ['Length of CSqueues (' num2str(length(Xobj.CSqueues)) ...
        ') must be equal to the length of CXsolvers (' ...
        num2str(Nworkers) ')' ])
else
    for n=1:Nworkers
        Xobj.CSqueues{n}='';
        Xobj.CShostnames{n}='';
    end
end

if ~isempty(Xobj.CShostnames)
    assert(length(Xobj.CShostnames)==Nworkers,...
        'openCOSSAN:Evaluator',...
        ['Length of CShostnames (' num2str(length(Xobj.CShostnames)) ...
        ') must be equal to the length of CXsolvers (' ...
        num2str(Nworkers) ')' ])
else
    for n=1:Nworkers
        Xobj.CShostnames{n}='';
    end
end

if ~isempty(Xobj.CSparallelEnvironments)
    assert(length(Xobj.CSparallelEnvironments)==Nworkers,...
        'openCOSSAN:Evaluator',...
        ['Length of CSparallelEnvironments (' num2str(length(Xobj.CSparallelEnvironments)) ...
        ') must be equal to the length of CXsolvers (' ...
        num2str(Nworkers) ')' ])
else
    for n=1:Nworkers
        Xobj.CSparallelEnvironments{n}='';
    end
end

if ~isempty(Xobj.Vslots)
    assert(length(Xobj.Vslots)==Nworkers,...
        'openCOSSAN:Evaluator',...
        ['Length of Vslots (' num2str(length(Xobj.Vslots)) ...
        ') must be equal to the length of CXsolvers (' ...
        num2str(Nworkers) ')' ])
else
    Xobj.Vslots=ones(size(Xobj.CXsolvers));
end


% Check for unique SwrapperName in the Mio
for n=1:Nworkers
    if isa(Xobj.CXsolvers{n},'Mio')
        Ncount=1;
        for i=1:n-1
            if isa(Xobj.CXsolvers{i},'Mio')
                if(strcmp(Xobj.CXsolvers{i}.SwrapperName,Xobj.CXsolvers{n}.SwrapperName))
                    Ncount = Ncount+1;
                    if Ncount==2
                        Xobj.CXsolvers{n}.SwrapperName = [Xobj.CXsolvers{n}.SwrapperName num2str(Ncount)];
                    elseif Ncount<=10
                        Xobj.CXsolvers{n}.SwrapperName = [Xobj.CXsolvers{n}.SwrapperName(1:end-1) num2str(Ncount)];
                    else
                        Xobj.CXsolvers{n}.SwrapperName = [Xobj.CXsolvers{n}.SwrapperName(1:end-2) num2str(Ncount)];
                    end
                end
            end
        end
    end
end



%% Check for duplicated Outputs
if ~isempty(Xobj.Coutputnames)
    Couts=unique(Xobj.Coutputnames);
    assert(length(Couts)==length(Xobj.Coutputnames),...
        'openCOSSAN:Evaluator:validateObject',...
        strcat('Duplicated outputs present in the Evaluator \n',sprintf('%s ',Xobj.Coutputnames{:})))
end
