classdef ParseRequiredNameValuePairsTest < matlab.unittest.TestCase
    
    methods (Test)
        function shouldReturnParsedAndUnmatchedArguments(testCase)
            names = ["arg1" "arg2"];
            varargin = {'arg1' 1 'arg2' 2 'opt1' 3 'opt2', 4};
            
            [results, unmatched] = opencossan.common.utilities.parseRequiredNameValuePairs(names, varargin{:});
            
            testCase.verifyEqual(results.arg1, 1);
            testCase.verifyEqual(results.arg2, 2);
            
            testCase.verifyEqual(unmatched, {'opt1' 3 'opt2' 4});
        end
        
        function shouldThrowExceptionForMissingArguments(testCase)
            names = ["arg1" "arg2"];
            varargin = {'arg1' 1 'opt1' 3 'opt2', 4};
            
            testCase.verifyError(...
                @() opencossan.common.utilities.parseRequiredNameValuePairs(names, varargin{:}),...
                'OpenCossan:MissingRequiredInput');
        end
        
    end
end