classdef MarkovChain
    % MarkovChain This class allows to generate samples adopting the
    %             Metropolis-Hastings algorithm.
    %
    % See also: https://cossan.co.uk/wiki/index.php/@MarkovChain
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
    
    properties (SetAccess = protected)
        XoffSprings       % RandomVariableSet for the offsprings
        Xbase             % RandomVariableSet original distribution
        Xsamples          % Array of Samples 
    end
    
    
    properties (Dependent = true, SetAccess = protected)
        lengthChains    % Effective length of the Chains
        Minitial        % Initial points in SNS of the Markov Chains
        Mlast           % Last points in SNS of the Markoc Chains
        Nsets           % Number of RandomVariableSets
    end
    
    properties % Public access
        Sdescription      % Description of the object
        burnin=0          % Omitted initial samples from the chain
        thin=1            % omitted samples in the chain
    end
    
    
    methods
        
        
        display(Xobj)                     % This method shows the summary of
        % the MarkovChain object
        
        Xobj=buildChain(Xobj,varargin)    % Generate samples of the Markov Chains
        
        Xout=getChain(Xobj,varargin)      % Retrive the samples of  specific chains
        
        Xobj=add(Xobj,varargin)           % Add samples to the MarkovChains
        
        Xobj=remove(Xobj,varargin)        % Remove samples from specific chains
        
        %% Constructor MarkovChain
        %
        function  Xobj=MarkovChain(varargin)
            % See also: https://cossan.co.uk/wiki/index.php/@OpenCossan
            %
            % Author: Edoardo Patelli
            % Institute for Risk and Uncertainty, University of Liverpool, UK
            % email address: openengine@cossan.co.uk
            % Website: http://www.cossan.co.uk   
            
            if isempty(varargin)
                return %Return and empty MarkovChain object
            end
            
            OpenCossan.validateCossanInputs(varargin{:})
            % Process the inputs
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'xsamples'} % Set the initial points
                        if isa(varargin{k+1},'Samples')
                            Xobj.Xsamples = varargin{k+1};
                        else
                            error('openCOSSAN:MarkovChain:MarkovChain',...
                                 ' The %s is not a Samples object', inputname(k+1))
                            
                        end
                    case {'xbase','xtargetdistribution'}
                        if isa(varargin{k+1},'RandomVariableSet')
                            Xobj.Xbase = varargin{k+1};
                        else
                            error('openCOSSAN:MarkovChain:MarkovChain',...
                                [' The ' inputname(k+1) ' is not a RandomVariableSet object'])
                        end
                    case {'xoffsprings','xproposeddistribution'}
                        if isa(varargin{k+1},'RandomVariableSet')
                            Xobj.XoffSprings = varargin{k+1};
                        else
                            error('openCOSSAN:MarkovChain:MarkovChain',...
                                [' The ' inputname(k+1) ' is not a RandomVariableSet object'])
                        end
                    case 'xinput'
                        if isa(varargin{k+1},'Input')
                            Crvsname=varargin{k+1}.CnamesRandomVariableSet;
                            assert(length(Crvsname)==1, ...
                                'openCOSSAN:MarkovChain:MarkovChain',...
                                ['The input object contains ' ...
                                num2str(length(Crvsname)) ...
                                ' RandomVariableSet. Only Input with 1 RandomVariableSet are supported'])
                            Xobj.Xbase = varargin{k+1}.Xrvset.(Crvsname{1});
                            if isempty(Xobj.Xsamples)
                                Xobj.Xsamples = varargin{k+1}.Xsamples;
                            end
                        end
                    case {'npoints'}
                        Npoints=varargin{k+1};
                    case {'burnin','nburnin'}
                        Xobj.burnin=varargin{k+1};
                    case {'thin','nthin'}
                        Xobj.thin=varargin{k+1};
                    otherwise
                        error('openCOSSAN:MarkovChain:MarkovChain',...
                            'PropertyName %s not allowed',varargin{k})
                end
            end
            
            if isempty(Xobj.Xbase)
                error('openCOSSAN:MarkovChain:MarkovChain',...
                    'A RandomVariableSet object is required to initialize the MarkovChain')
            end
            
            if exist('Npoints','var')
                Xobj=Xobj.buildChain(Npoints);
            else
                Xobj=Xobj.buildChain;
            end
        end
        
        % Dependent properties
        function outdata = get.Minitial(Xobj)
            outdata = Xobj.Xsamples(1).MsamplesStandardNormalSpace;
        end
        
        % Dependent properties
        function outdata = get.Mlast(Xobj)
            outdata = Xobj.Xsamples(end).MsamplesStandardNormalSpace;
        end
        
        % Dependent properties
        function outdata = get.lengthChains(Xobj)
            outdata = floor((length(Xobj.Xsamples)-Xobj.burnin)/Xobj.thin);
        end
        
        % Dependent properties
        function Nsets = get.Nsets(Xobj)
            Nsets = length(Xobj.Xbase);
        end
    end % methods
    
    methods (Access=private)
        
        [varargout]  = offspring(Xobj)
    end % end of the private methods
    
end
