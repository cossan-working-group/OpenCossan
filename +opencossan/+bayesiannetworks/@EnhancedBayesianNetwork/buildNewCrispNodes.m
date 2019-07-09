function CNewNodesObj = buildNewCrispNodes(~,CnewNodesName, CPTtotal, CSdiscrete, SizeDiscrete)
% BUILDNEWNODES method of the class EnhancedBayesianNetwork
%   Given the names of the new nodes, the CPTtotal computed by
%   probabilisticSRM or hybridSRM and name,index and size of discrete nodes
%   the method allows to build the related new nodes objects
%   (see probabilisticSRM and hybridSRM)
%
% Author: Silvia Tolo
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
import opencossan.bayesiannetworks.DiscreteNode

Nnew        = length(CnewNodesName);
Ncpt        = length(CSdiscrete);
CPT         = cell(1,Nnew);
CSparents   = cell(1,Nnew);
[~,CPTch]   = intersect(CSdiscrete,CnewNodesName,'stable');
LMarkovEnvelope= Nnew>1;


if Ncpt==1 %if there is only one new node left in the markov envelope
    pseudoCPT   = cell2mat(CPTtotal);
    normCoeff=sum(pseudoCPT);
    % normalize CPT values of new node
    newCPT=num2cell(pseudoCPT./normCoeff);
    % Define new node obj
    CNewNodesObj=DiscreteNode('Name',CSdiscrete{1},'CPD',newCPT);
    clear newCPT
elseif Ncpt>1 &&  LMarkovEnvelope
    pseudoCPT   = cell2mat(CPTtotal);
    for icpt=0:(Nnew-1)
        %calculate the coeff to normalize the values of the CPT
        normCoeff=sum(pseudoCPT,(Ncpt-icpt));   % the normCoeff is the joint probability related to the parents of the node under computation
        newSize=SizeDiscrete(1:Ncpt-icpt);      % size of the CPT for the node to define
        CSparents{1,Nnew-icpt}=CSdiscrete(1,1:(CPTch(Nnew-icpt)-1)); %new parents
        isize=1;
        %"section" refers to one state of the node under study (ex.column CPT)
        indsection=0;
        lengthsection=(prod(newSize)/SizeDiscrete(Ncpt-icpt)); % number of probability values for each state of the node
        newCPT=zeros(prod(SizeDiscrete(1:Ncpt-icpt)),1);
        while isize<=SizeDiscrete(Ncpt-icpt) % calculate the probabilities for each state of the node
            
            if ~(length(newSize(1:Ncpt-icpt-1))<=1)
                partialCPT=reshape(pseudoCPT(indsection+1:indsection+lengthsection),newSize(1:Ncpt-icpt-1)); % values of prob for the state isize of the node
            else
                partialCPT=pseudoCPT(indsection+1:indsection+lengthsection)';
            end
            if SizeDiscrete(Ncpt-icpt)>1
                %                 newCPT{isize,1}=num2cell(partialCPT./normCoeff); %conditional probabilities for the state isize
                newCPT(indsection+1:indsection+lengthsection)=(partialCPT./normCoeff);
                indsection=(isize*lengthsection);
            else
                %                 newCPT{isize,1}=num2cell(partialCPT);
                newCPT(indsection+1:indsection+lengthsection)=(partialCPT./normCoeff);
            end
            isize=isize+1;
        end
        if ~isempty(CSparents{1,Nnew-icpt})
            CPT{1,Nnew-icpt}=num2cell(reshape(newCPT,newSize));
        else
            CPT{1,Nnew-icpt}=num2cell(reshape(newCPT,[1,newSize]));
        end
        % Define new node obj
        CNewNodesObj(Nnew-icpt)=DiscreteNode('Name',CSdiscrete{CPTch(Nnew-icpt)},...
            'Parents',CSparents{1,Nnew-icpt},'CPD',CPT{1,Nnew-icpt});
        
    end
elseif Ncpt>1 && ~LMarkovEnvelope
    CSparents=CSdiscrete(1,1:(CPTch(Nnew)-1));
    pseudoCPT   = cell2mat(CPTtotal);
    Mnorm       = reshape(repmat(sum(reshape(pseudoCPT,[prod(SizeDiscrete(1:end-1)),SizeDiscrete(end)]),2),1,SizeDiscrete(1,end)),SizeDiscrete);
    % Define new node obj
    CNewNodesObj=DiscreteNode('Name',CSdiscrete{CPTch},...
        'Parents',CSparents,'CPD',num2cell(reshape(pseudoCPT,SizeDiscrete)./Mnorm));
    
end

