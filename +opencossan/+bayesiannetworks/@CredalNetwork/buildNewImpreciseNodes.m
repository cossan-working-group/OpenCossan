function CNewNodesObj = buildNewImpreciseNodes(~,CnewNodesName, CPTtotal, CSdiscrete, SizeDiscrete)
% BUILDNEWIMPRECISENODES method of the class CredalNetwork
%   Given the names of the new nodes, the CPTtotal computed by
%   hybridSRM and name,index and size of discrete nodes
%   the method allows to build the related new nodes objects containing
%   interval probability values
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
import opencossan.bayesiannetworks.Node

Nnew        = length(CnewNodesName);
Ncpt        = length(CSdiscrete);
CPT         = cell(1,Nnew);
CNewNodesObj= cell(1,Nnew);
CSparents   = cell(1,Nnew);
[~,CPTch]   = intersect(CSdiscrete,CnewNodesName,'stable');
% [~,~,indInNet]= intersect(CnewNodesName,Xebn.CSnames,'stable');
LMarkovEnvelope= Nnew>1;


if Ncpt==1 %if there is only one new node left in the markov envelope
    pseudoCPT1   = cell2mat(CPTtotal{1});
    pseudoCPT2   = cell2mat(CPTtotal{2});
    Mcoeff=repmat(pseudoCPT1, [length(pseudoCPT2),1]);
    Mcoeff(1:size(Mcoeff,1)+1:end)=pseudoCPT2;
    %         normCoeff2=sum(pseudoCPT2);
    newCPT={num2cell(pseudoCPT1./flip(sum(Mcoeff,2))') num2cell(pseudoCPT2./sum(Mcoeff,2)')};
    % Define new node obj
    CNewNodesObj{1}=DiscreteNode('Name',CSdiscrete{1},'CPD',newCPT);
    clear newCPT
    
elseif Ncpt>1 &&  ~LMarkovEnvelope
    CSparents=CSdiscrete(1,1:(CPTch(Nnew)-1));
%     newSize=SizeDiscrete(end);
    pseudoCPT1   = cell2mat(CPTtotal{1});
    pseudoCPT2   = cell2mat(CPTtotal{2});
    
    % Define new node obj
    CNewNodesObj{1}=DiscreteNode('Nname',CSdiscrete{CPTch},'Parents',CSparents,...
        'CPD',{num2cell(reshape(pseudoCPT1,SizeDiscrete)), num2cell(reshape(pseudoCPT2,SizeDiscrete))});
    
elseif Ncpt>1 && LMarkovEnvelope
    pseudoCPT1   = cell2mat(CPTtotal{1});
    pseudoCPT2   = cell2mat(CPTtotal{2});
    for icpt=0:(Nnew-1)
        normCoeff1=sum(pseudoCPT1,(Ncpt-icpt));
        newSize=SizeDiscrete(1:Ncpt-icpt);
        normCoeff2=sum(pseudoCPT2,(Ncpt-icpt));
        CSparents{1,Nnew-icpt}=CSdiscrete(1,1:(CPTch(Nnew-icpt)-1));
        isize=1;
        indsection=0;
        lengthsection=(prod(newSize)/SizeDiscrete(Ncpt-icpt));
        newCPT1=zeros(prod(SizeDiscrete(1:Ncpt-icpt)),1);
        newCPT2=zeros(prod(SizeDiscrete(1:Ncpt-icpt)),1);
        while isize<=SizeDiscrete(Ncpt-icpt)
            if ~(length(newSize(1:Ncpt-icpt-1))<=1)
                partialCPT1=reshape(pseudoCPT1(indsection+1:indsection+lengthsection),newSize(1:Ncpt-icpt-1));
                partialCPT2=reshape(pseudoCPT2(indsection+1:indsection+lengthsection),newSize(1:Ncpt-icpt-1));
                
            else
                partialCPT1=pseudoCPT1(indsection+1:indsection+lengthsection)';
                partialCPT2=pseudoCPT2(indsection+1:indsection+lengthsection)';
            end
            if SizeDiscrete(Ncpt-icpt)>1
                newCPT1(indsection+1:indsection+lengthsection)=(partialCPT1./normCoeff1);
                newCPT2(indsection+1:indsection+lengthsection)=(partialCPT2./normCoeff2);
                indsection=(isize*lengthsection);
            else
                newCPT1(indsection+1:indsection+lengthsection)=(partialCPT1./normCoeff1);
                newCPT2(indsection+1:indsection+lengthsection)=(partialCPT2./normCoeff1);
            end
            isize=isize+1;
        end
        
        
        if ~isempty(CSparents{1,Nnew-icpt})
            CPT{1,Nnew-icpt}={num2cell(reshape(newCPT1,newSize)) num2cell(reshape(newCPT2,newSize))};
        else
            CPT{1,Nnew-icpt}={num2cell(reshape(newCPT1,[1,newSize])) num2cell(reshape(newCPT2,[1,newSize]))};
        end
        % Define new node obj
        CNewNodesObj{Nnew-icpt}=DiscreteNode('Name',CSdiscrete{CPTch(Nnew-icpt)},...
            'Parents',CSparents{1,Nnew-icpt},'CPD',CPT{1,Nnew-icpt});
    end
%     pseudoCPT1=normCoeff1;
%     pseudoCPT2=normCoeff2;
end


