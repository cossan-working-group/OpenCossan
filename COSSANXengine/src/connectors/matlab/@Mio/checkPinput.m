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
    case 'Input'
        % checks that all the required inputs ara available
        Cnames=Pinput.Cnames;        
       
        assert(all(ismember(Xmio.Cinputnames,Pinput.Cnames)),...
                'openCOSSAN:mio:checkPinput',...
                ['Not all the necessary inputs are contained in the Input.\n'...
                'Missing inputs: %s'], ...
                sprintf(' "%s"; ',Xmio.Cinputnames{~ismember(Xmio.Cinputnames,Cnames)}))
        
        if Xmio.Liostructure, % I/O with structure
            % Return a structure
            Poutput  = Pinput.getStructure;
        elseif Xmio.Liomatrix % I/O with matrix
            % Return a Matrix with the required input in the required order
            Poutput  = Pinput.getValues('Cnames',Xmio.Cinputnames);
        else % I/O with multiple vectors
            % Return a cell array with the input vectors
            TtempStructure=Pinput.getStructure;
            
        end
        
    case 'Samples'
        % checks that all the required inputs ara available
        Cnames=[Pinput.CnamesRandomVariable...
            Pinput.CnamesStochasticProcess...
            Pinput.CnamesDesignVariables];
        assert(all(ismember(Xmio.Cinputnames,Cnames)),...
            'openCOSSAN:mio:checkPinput',...
            ['Not all the necessary inputs are contained in the structure.\n'...
            'Missing inputs: %s'], ...
            sprintf('%s\n',Xmio.Cinputnames{~ismember(Xmio.Cinputnames,Cnames)}))            
        
        if Xmio.Liostructure,   %generates input for matlab function in structure or matrix form
            Poutput  = Pinput.Tsamples;    %input as a structure
        elseif Xmio.Liomatrix % I/O with matrix
            
            MoutputUnsorted  = Pinput.MsamplesPhysicalSpace;  %input as matrix
            
            Poutput=zeros(size(MoutputUnsorted)); % preallocate memory
            
            % be sure the variables are in the right order
            for n=1:length(Xmio.Cinputnames)
                % Extract input from the field Cxobjects of Mio
                index=find(strcmp(Cnames,Xmio.Cinputnames{n}),1);
                if isempty(index)
                    error('openCOSSAN:connector:mio:run', ...
                        ['The input ' Xmio.Cinputnames{n} ' in not available'])
                else
                    Poutput(:,n)=MoutputUnsorted(:,index);
                end
            end
        else % I/O with multiple vectors
            % Return a cell array with the input vectors
            TtempStructure = Pinput.Tsamples;
            
        end
    case 'struct'
        %checks whether or not argument is a structure
        % check that all the necessary field names are available in the
        % structure
        Cnames = fieldnames(Pinput);
        assert(all(ismember(Xmio.Cinputnames,Cnames)),...
            'openCOSSAN:mio:checkPinput',...
            ['Not all the necessary inputs are contained in the structure.\n'...
            'Missing inputs: %s'], ...
            sprintf(' "%s";',Xmio.Cinputnames{~ismember(Xmio.Cinputnames,Cnames)}))
        
        if Xmio.Liostructure,   %checks whether or not argument is an Samples object
            Poutput  = Pinput;     % nothing to do
        elseif Xmio.Liomatrix
            Nsamples=length(Pinput);
            Poutput=zeros(Nsamples,length(Xmio.Cinputnames)); % preallocate memory
            for n=1:length(Xmio.Cinputnames)
                Poutput(:,n)=[Pinput.(Xmio.Cinputnames{n})]';
            end
        else
            TtempStructure = Pinput;
        end
        
    case 'double'
        % check that the sample matrix has enough columns
        assert(size(Pinput,2)==length(Xmio.Cinputnames),...
            'openCOSSAN:mio:checkPinput',...
            ['Wrong number of columns in provided samples matrix!\n'...
            'Nr. of columns:%d\nNr. of inputs:%d\n'],...
            size(Pinput,2),length(Xmio.Cinputnames));
        %checks whether or not argument is a structure
        if Xmio.Liostructure,   %checks whether or not argument is an Samples object
            Poutput = cell2struct(num2cell(Pinput),Xmio.Cinputnames,2);
        elseif Xmio.Liomatrix
            Poutput = Pinput;  % nothing to do
        else 
            Poutput = mat2cell(Pinput, size(Pinput,1), ones(size(Pinput,2),1));
        end
        
    otherwise
        error('openCOSSAN:mio:checkPinput',...
            'Pinput of type %s not supported',class(Pinput))
end

if exist('TtempStructure','var') % if the temporary structure is available
    % convert it to a cell array with the correct order of inputs
    Cstructurenames=fieldnames(TtempStructure);
    Poutput=cell(length(Xmio.Cinputnames),1); % memory preallocations
    Cell=squeeze(struct2cell(TtempStructure));
    for n=1:length(Xmio.Cinputnames)
        index=find(strcmp(Cstructurenames,Xmio.Cinputnames{n}),1);
        if ~isempty(index)
            Poutput{n}=transpose(cell2mat(Cell(index,:)));
        else
            % Extract input from the field Cxobjects of Mio
            index=find(strcmp(Xmio.CobjectsNames,Xmio.Cinputnames{n}),1);
            if isempty(index)
                error('openCOSSAN:connector:mio:run', ...
                    ['The input ' Xmio.Cinputnames{n} ' in not available'])
            else
                Poutput{n}=Xmio.Cxobjects{index};
            end
        end
    end
end

return
