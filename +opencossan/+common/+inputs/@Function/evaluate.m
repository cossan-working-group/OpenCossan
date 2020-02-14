function out = evaluate(obj, input)
    %EVALUATE method evaluates the function defined in the Function object
    %
    % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/Evaluate@Function
    %
    
    % $Copyright~1993-2014,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$ $Author:
    % Edoardo-Patelli~and~Pierre-Beaurepaire$
    
    % ===================================================================== This file is part of
    % openCOSSAN.  The open general purpose matlab toolbox for numerical analysis, risk and
    % uncertainty quantification.
    %
    % openCOSSAN is free software: you can redistribute it and/or modify it under the terms of the
    % GNU General Public License as published by the Free Software Foundation, either version 3 of
    % the License.
    %
    % openCOSSAN is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    % without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
    % the GNU General Public License for more details.
    %
    %  You should have received a copy of the GNU General Public License along with openCOSSAN.  If
    %  not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    
    % Create executable expression by replacing the tokens with the values from the input table
    expression = obj.Expression;
    
    
    
    for token = obj.Tokens
        expression = replace(expression, sprintf("<&%s&>", token{1}), sprintf("input.%s", token{1}));
    end
    
    % Evaluate the function if possible
    try
        out = eval(expression);
    catch ME
        error('openCOSSAN:Function:evaluate',...
            strjoin("Function could not be evaluated successfully. Syntax may be invalid.\n", ...
            ME.message));
    end
    
end
