function Poutput =checkPinput(Xmio,Pinput)
%checkPinput this method checks the correctness of the object Pinput
%
%   checkPinput is a method intended for checking the correcteness of the
%   arguments passed to the method run or runGrid of the class Mio.
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@Mio
%
% ==============================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% ==============================================================================
%
% Copyright~1993-2011, COSSAN Working Group, University of Innsbruck, Austria
% Author: Edoardo Patelli

%%  In case the argument Pinput is an Input object

switch class(Pinput)
    case 'opencossan.common.inputs.Input'
        % checks that all the required inputs ara available
        Cnames=Pinput.Names;        
       
        assert(all(ismember(Xmio.InputNames,Pinput.Names)),...
                'openCOSSAN:mio:checkPinput',...
                ['Not all the necessary inputs are contained in the Input.\n'...
                'Missing inputs: %s'], ...
                sprintf(' "%s"; ',Xmio.InputNames{~ismember(Xmio.InputNames,Cnames)}))
        
        switch Xmio.Format
            case 'structure' % I/O with structure
                % Return a structure
                Poutput  = Pinput.getStructure;
            case 'matrix'  % I/O with matrix
                % Return a Matrix with the required input in the required order
                Poutput  = Pinput.getValues('VariableNames',Xmio.InputNames);
            case 'vectors' % I/O with multiple vectors
                % Return a cell array with the input vectors
                TtempStructure=Pinput.getStructure;
            case 'table'
                Poutput = Pinput.getTable;
        end
        
    case 'opencossan.common.Samples'
        % checks that all the required inputs ara available
        Cnames=[Pinput.CnamesRandomVariable...
            Pinput.CnamesStochasticProcess...
            Pinput.CnamesDesignVariables];
        assert(all(ismember(Xmio.InputNames,Cnames)),...
            'openCOSSAN:mio:checkPinput',...
            ['Not all the necessary inputs are contained in the structure.\n'...
            'Missing inputs: %s'], ...
            sprintf('%s\n',Xmio.Cinputnames{~ismember(Xmio.InputNames,Cnames)}))            
        
        switch Xmio.Sformat
            case 'structure' %generates input for matlab function in structure or matrix form
                Poutput  = Pinput.Tsamples;    %input as a structure
            case 'matrix' % I/O with matrix
            
            MoutputUnsorted  = Pinput.MsamplesPhysicalSpace;  %input as matrix
            
            Poutput=zeros(size(MoutputUnsorted)); % preallocate memory
            
            % be sure the variables are in the right order
            for n=1:length(Xmio.InputNames)
                % Extract input from the field Cxobjects of Mio
                index=find(strcmp(Cnames,Xmio.InputNames{n}),1);
                if isempty(index)
                    error('openCOSSAN:connector:mio:run', ...
                        ['The input ' Xmio.InputNames{n} ' in not available'])
                else
                    Poutput(:,n)=MoutputUnsorted(:,index);
                end
            end
            case 'vectors' % I/O with multiple vectors
                % Return a cell array with the input vectors
                TtempStructure = Pinput.Tsamples;
            case 'table'
                Poutput = struct2table(Pinput.Tsamples);
            
        end
    case 'struct'
        %checks whether or not argument is a structure
        % check that all the necessary field names are available in the
        % structure
        Cnames = fieldnames(Pinput);
        assert(all(ismember(Xmio.InputNames,Cnames)),...
            'openCOSSAN:mio:checkPinput',...
            ['Not all the necessary inputs are contained in the structure.\n'...
            'Missing inputs: %s'], ...
            sprintf(' "%s";',Xmio.InputNames{~ismember(Xmio.InputNames,Cnames)}))
        
        switch Xmio.Format
            case 'structure' %checks whether or not argument is an Samples object
                Poutput  = Pinput;     % nothing to do
            case 'matrix' 
                Nsamples=length(Pinput);
                Poutput=zeros(Nsamples,length(Xmio.InputNames)); % preallocate memory
                for n=1:length(Xmio.InputNames)
                    Poutput(:,n)=[Pinput.(Xmio.InputNames{n})]';
                end
            case 'vectors'
                TtempStructure = Pinput;
            case 'table'
                Poutput = struct2table(Pinput);
        end
        
    case 'double'
        % check that the sample matrix has enough columns
        assert(size(Pinput,2)==length(Xmio.InputNames),...
            'openCOSSAN:mio:checkPinput',...
            ['Wrong number of columns in provided samples matrix!\n'...
            'Nr. of columns:%d\nNr. of inputs:%d\n'],...
            size(Pinput,2),length(Xmio.InputNames));
        %checks whether or not argument is a structure
        switch Xmio.Format
            case 'structure' %checks whether or not argument is an Samples object
                Poutput = cell2struct(num2cell(Pinput),Xmio.InputNames,2);
            case 'matrix'
                Poutput = Pinput;  % nothing to do
            case 'vectors' 
                Poutput = mat2cell(Pinput, size(Pinput,1), ones(size(Pinput,2),1));
            case 'table'
                Poutput = array2table(Pinput, 'VariableNames', Xmio.InputNames);
        end
        
    otherwise
        error('openCOSSAN:mio:checkPinput',...
            'Pinput of type %s not supported',class(Pinput))
end

if exist('TtempStructure','var') % if the temporary structure is available
    % convert it to a cell array with the correct order of inputs
    Cstructurenames=fieldnames(TtempStructure);
    Poutput=cell(length(Xmio.InputNames),1); % memory preallocations
    Cell=squeeze(struct2cell(TtempStructure));
    for n=1:length(Xmio.InputNames)
        index=find(strcmp(Cstructurenames,Xmio.InputNames{n}),1);
        if ~isempty(index)
            Poutput{n}=transpose(cell2mat(Cell(index,:)));
        else
            % Extract input from the field Cxobjects of Mio
            index=find(strcmp(Xmio.CobjectsNames,Xmio.InputNames{n}),1);
            if isempty(index)
                error('openCOSSAN:connector:mio:run', ...
                    ['The input ' Xmio.InputNames{n} ' in not available'])
            else
                Poutput{n}=Xmio.Cxobjects{index};
            end
        end
    end
end

return
