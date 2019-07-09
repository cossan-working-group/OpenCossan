function checkFunction(Xin)
%CHECKFUNCTION This method is used to validate the Function objects
%
% Revised by EP
% ==================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% ==================================================================

CfunctionNames = Xin.FunctionNames;
CinputNames= Xin.Names;
myFunctions = Xin.Functions;
CblackList=cell(length(CfunctionNames),1);


for ifun = 1:length(CfunctionNames) % go accross all functions
    
    %% check if all the elements required by the functions are present in the
    % Input object
    myTokens=myFunctions.(CfunctionNames{ifun}).Tokens;
    for itoken=1:length(myTokens)
        %check for the presence of the elements
        if ~sum(ismember(CinputNames, myTokens{itoken}))
            error('openCOSSAN:Input:checkFunction',...
                'Function named %s requires an input named %s', ...
                CfunctionNames{ifun},myTokens{itoken}{1} );
        end
        
        %go accross the tokens
        Nfun=find(ismember(CfunctionNames, myTokens{itoken}));
        if ~isempty(Nfun)
            if ~isempty(CblackList{ifun}) && sum(ismember(CblackList{ifun}, myTokens{itoken}))
                error('openCOSSAN:Input:checkFunction',...
                    'Invalid calls between functions');
            end
            CblackList{Nfun}{end+1} = CfunctionNames{ifun}; %computes 'black list'
        end
        
        
    end
end
