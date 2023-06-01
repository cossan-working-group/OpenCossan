function varargout=useGivenData(Xobj)
% computeGivendataIndices is the function that computes the Local
% sensitivity methods for a given sample of data and does not require any
% model for the computation
%
% The file returns the sensitivity indices  based on truncated Haar wavelet
%
% Initially written by Elmar Plischke
%
% $Copyright~1993-2017,~COSSAN~Working~Group,~UK$
% $Author: Edoardo-Patelli$

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
%  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/

%% Main script
MsimInput=Xobj.XsimulationData.getValues('Cnames',Xobj.Cinputnames);
MsimOutput=Xobj.XsimulationData.getValues('Cnames',Xobj.Coutputnames);

% Normalise the data
MsimInput=(MsimInput-mean(MsimInput))./std(MsimInput);
MsimOutput=MsimOutput-mean(MsimOutput)./std(MsimOutput);

[NsamplesIn,kfactorsIn]=size(MsimInput) ;
[~,kfactorsOut]=size(MsimOutput);

% Checking if the length of the data is a power of 2
S=floor(log2(NsamplesIn));
NsamplesHaar=2^S;

if isempty(Xobj.Nfrequency)
    Xobj.Nfrequency=min(S-4,7);
end

if NsamplesHaar~=NsamplesIn
    OpenCossan.cossanDisp(['* The length of the given data is not in the order of 2^N',length(Xobj.Xsimulator)],2);
    OpenCossan.cossanDisp('* Ignoring excess data elements',3);
    MsimInput(((NsamplesHaar+1):NsamplesIn),:)=[];
    if kfactorsIn==1
        MsimOutput((NsamplesHaar+1):Nsamples)=[];
    else
        MsimOutput(((NsamplesHaar+1):NsamplesIn),:)=[];
    end
end

% Sort the output
[~,Index]=sort(MsimInput);
if kfactorsOut==1
    XsimOutHaar=MsimOutput(Index);
else
    XsimOutHaar=zeros(Nsamples,kfactorsIn*kfactorsOut);
    for i=1:kfactorsOut
        Zposition=MsimOutput(:,i);
        XsimOutHaar(:,(i-1)*kfactorsIn+(1:kfactorsIn))=Zposition(:,Index);
    end
end

%% Haar wavelet tranformation
Moutcoeff=wavetraf(XsimOutHaar);
% Tranformation is orthogonal, so by Parseval's Theorem
Var=sum(Moutcoeff(2:end,:).^2);

if Xobj.Nfrequency>0
    Vi=sum(Moutcoeff(1+(1:(2^Xobj.Nfrequency)),:).^2);
else
    % different selection scheme: use only the largest contributor
    if Xobj.Nfrequency==0
        Mthreshold=0.2;
    else
        Mthreshold=-Xobj.Nfrequency/100;
    end
    Vi=zeros(size(V));
    for i=1:(kfactorsIn*kfactorsOut)
        Mcoeff=Moutcoeff(2:end,i).^2;
        Vi(i)=sum(Mcoeff(coeff>Mthreshold*V(i)));
    end
end
MfirstOrder=Vi./Var;

for n=1:kfactorsOut    
    varargout{1}(n)=SensitivityMeasures('Cinputnames',Xobj.Cinputnames, ...
        'Soutputname',Xobj.Coutputnames{n},...
        'Sevaluatedobjectname',Xobj.Sevaluatedobjectname, ...
        'VsobolFirstOrder',MfirstOrder', ...
        'Sestimationmethod',['Sensitivity.sobolIndices (' Xobj.Smethod ')' ]);
end

% if exist('Hplot','var')
%     Zeta=abs(Moutcoeff);
%     Zeta=64*(Zeta/max(max(Zeta)));
%     subplot(1,1,1)
%     Dy=zeros(1,NsamplesIn);
%     Dy(1:(1+2^Nfrequency))=1;
%     image(0:(kfactorsIn),1:NsamplesIn,[Dy'*64,Zeta,Dy'*64]);
%     colorbar;
%     title(Hplot);
%     xlabel('Permuted output');
%     ylabel('Haar coefficients');
%     h=text(kfactorsIn+.75,NsamplesIn/2+10,'Selected Coefficients','Rotation',90);
%     bw=(63:-1:0)'*[1,1,1]/64;
%     colormap(hot)
% end
% 
% if kfactorsOut>1
%     Si=reshape(Si',k,kk)';
% end

end

function Yout=wavetraf(Xin)
% Haar wavelet transformation Function
[N,K]=size(Xin);
if N==1
    Yout=Xin;
else
    if K==1
        sums=Xin(1:2:end)+Xin(2:2:end);
        diffs=Xin(1:2:end)-Xin(2:2:end);
    else
        sums=Xin(1:2:end,:)+Xin(2:2:end,:);
        diffs=Xin(1:2:end,:)-Xin(2:2:end,:);
    end
    Yout=[wavetraf(sums);diffs]./sqrt(2);
end
end

