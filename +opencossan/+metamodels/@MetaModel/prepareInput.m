function [Minput,TinputAll]=prepareInput(Xobj,Pinput)
%PREPAREINPUT This is used to prepare the input required to evaluate the meta-model.
% It returns a matrix with Input arranged according to the CinputNames
% field
%
% Author: Edoardo Patelli

switch class(Pinput)
    case 'opencossan.common.inputs.Input'
        TinputAll=Pinput.getTable;
    case 'opencossan.common.Samples'
        TinputAll = Pinput.Tsamples;
        %MDA: a check should be added to make sure TinputAll is a table
    case 'struct'
        TinputAll = Pinput;
        TinputAll=struct2table(TinputAll);
    otherwise
        error('openCOSSAN:Metamodel:prepareInput',...
            'The input of class %s is not allowed. ',class(Pinput))
end

% Remove not required fields
% Cfieldnames=fieldnames(TinputAll);
% Tinput = rmfield(TinputAll,Cfieldnames(~ismember(Cfieldnames,Xobj.Cinputnames)));
% Reorder the input
% Tinput = orderfields(Tinput, Xobj.Cinputnames);
% Minput = cell2mat(squeeze(struct2cell(Tinput)))';
% Minput = table2array(TinputAll);
Minput = table2array(TinputAll(:,Xobj.Cinputnames));

