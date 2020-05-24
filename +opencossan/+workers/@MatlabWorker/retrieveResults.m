function [PoutputALL, Vresults] = retrieveResults(Xobj,Vresults,Vstart,Vend,PoutputALL,Xjob)
%retrieveResults is a private method to retrieve results after evaluation of Mio
%   object on a grid using a JobManager object
%
%
% Copyright~1993-2013, COSSAN Working Group
%
% Author: Edoardo Patelli, Matteo Broggi, Marco De Angelis
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

%% 1.   Determine which results have not been read so far
Vpos   = find(Vresults==0);

if Xobj.Liostructure
    PoutputALL = cell2struct(cell(length(Vpos),length(Xobj.Coutputnames)),Xobj.Coutputnames,2);
elseif Xobj.Liomatrix
    PoutputALL = nan(length(Vpos),length(Xobj.Coutputnames));
end
    

%% 2.   Iterate over results which have not ben read
for i=1:length(Vpos),
    %2.1.   Define some variables
    ij      = Vpos(i);     %determine job that has not been read
    Toutput = []; %% Clear variables
    Moutput = []; %% Clear variables
    %2.2.   Try to load results from corresponding folder
    try
        load(fullfile(OpenCossan.getCossanWorkingPath,[Xjob.Sfoldername '_sim_' num2str(ij)],'mioOUTPUT.mat'));
        if ~isempty(Toutput)
            % if the Toutput is not a column vector, transpose it
            if size(Toutput,2)>size(Toutput,1)
                Toutput = Toutput';
            end
        elseif ~isempty(Moutput)
            OpenCossan.cossanDisp(['Output of sim # ' num2str(ij) ' loaded'],1);
        else
            exception = MException('OpenCossan:Mio', ...
                'Output of sim # %i is not available', ij);
            throw(exception)
        end
        
        %continue in case file was read
        
        %Delete files of simulation
        if ~Xobj.Lkeepsimfiles,  %in case files of simulation must be deleted
            %try to delete
            try
                SfullFilename=fullfile(OpenCossan.getCossanWorkingPath,[Xjob.SjobScriptName num2str(ij) '.sh']);
                delete(SfullFilename);
            catch ME
                OpenCossan.cossanDisp(['The job script ' SfullFilename ' can not be removed'],1);
                OpenCossan.cossanDisp(ME.message,1);
            end
            % Clean the directory
            Scleanfolder = fullfile(OpenCossan.getCossanWorkingPath,[Xjob.Sfoldername '_sim_' num2str(ij)]);    %folder to be deleted
            %try to delete directory
            try
                [Lstatus,Smessage]=rmdir(Scleanfolder,'s');
                
                if ~Lstatus
                    warning('OpenCossan:Mio', ...
                    'Folder %s can not be deleted\n%s', Scleanfolder,Smessage);
                end
            catch ME
                OpenCossan.cossanDisp(['Error cleaning the results of ' Scleanfolder],1)
                OpenCossan.cossanDisp(ME.message,1)
            end
        end
        %2.4.   Change status of job to read
        Vresults(ij)   = 1;
        %2.5.   Append results that were read to structure Tsim
        if ~isempty(Toutput)
            PoutputALL(Vstart(ij):Vend(ij),1)  = Toutput;     %append as structure
        else
            PoutputALL(Vstart(ij):Vend(ij),:)  = Moutput;     %append as matrix
        end
        
    catch exception
        OpenCossan.cossanDisp(exception.message,1);
    end
    
end


