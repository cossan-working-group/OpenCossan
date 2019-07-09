classdef Identifier
    % class Identifier 
    % 
    % Objects of the class Identifier contains information for Injector to
    % find data to inject. The properties of the Identifier objects can be
    % populated by scanning an ASCII input file that contains COSSAN
    % identifier (see Injector for additional information)
    
    properties
        Sname                    % 1) Name of the associate COSSAN varialbles
        Nindex                   % 2) Index of the variable (only for vector and matrix)
        Sfieldformat             % 3) Format string '%' +  Maximum field width + conversion character (see fscanf for more information)
        Slookoutfor              % 4)  if present define the string to be searched inside the ASCII file in order to define the relative position
        Sregexpression           % 6) Regular expression
        Ncolnum                  % 7) Colum position in the ASCII file of the variables (length(Vcolnum)=Nresponse)
        Nrownum                  % 8) Row  position in the ASCII file of the variables (length(Vcolnum)=Nresponse)
        Nposition                % 9) Absolute position inside the input file
        Soriginal                % 10) Original text in the ASCII file
        Sincludefile             % 11) Name of the file where the samples of the Stochastic Process are written
    end
    
    properties (Dependent=true)
        Noriginal                % Original value of the identifier
    end
    
    methods
        function Xobj = Identifier(varargin)
            % IDENTIFIER 
            
             %% Check Inputs
            opencossan.OpenCossan.validateCossanInputs(varargin{:});
            
            for k = 1:2:length(varargin)
                switch(lower(varargin{k}))
                    case 'sname'
                        Xobj.Sname=varargin{k+1};
                    case 'nindex'
                        Xobj.Nindex=varargin{k+1};
                    case 'sfieldformat'
                        Xobj.Sfieldformat=varargin{k+1};
                    case 'slookoutfor'
                        Xobj.Slookoutfor=varargin{k+1};
                    case 'sregexpression'
                        Xobj.Sregexpression=varargin{k+1};
                    case 'ncolnum'
                        Xobj.Ncolnum=varargin{k+1};
                    case 'nrownum'
                        Xobj.Nrownum=varargin{k+1};
                    case 'nposition'
                        Xobj.Nposition=varargin{k+1};
                    case 'soriginal'
                        Xobj.Soriginal=varargin{k+1};
                    case 'sincludefile'
                        Xobj.Sincludefile=varargin{k+1};
                end
                
            end
            
        end %end constructor
            
        display(Xobj) % Display identifier object
        
        function Noriginal = get.Noriginal(Xobj)
            
            import opencossan.common.utilities.*
            % convert the string to a number. The function mystr2double is
            % used to convert also number in nastran format.
            Noriginal = mystr2double(Xobj.Soriginal);
        end
        
        replaceValues(Xobj,varargin)
    end
     
    methods (Static)
        Svalue=num2nastran8(value); % Convert to Nastran Format 8
        Svalue=num2nastran16(value); % Convert to Nastran Format 16
        writeTable(Sfolder,Sformat,Sname,Vdata,Vtime); % write table with samples from Dataseries
    end
    
end
