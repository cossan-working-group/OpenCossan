classdef InputTest < matlab.unittest.TestCase
    % INPUTTEST Unit tests for the class common.inputs.Input
    % see http://cossan.co.uk/wiki/index.php/@Input
    %
    % @author Jasper Behrensdorf<behrensdorf@irz.uni-hannover.de>
    % @date   01.08.2016
    %
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
    % You should have received a copy of the GNU General Public License
    % along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    methods (Test)
        
        %% Constructor
        function constructorEmpty(testCase)
            Xin = common.inputs.Input();
            testCase.assertClass(Xin, 'common.inputs.Input');
            testCase.assertEqual(Xin.Nsamples, 0);
        end
        
        function constructorShouldSetDescription(testCase)
            Xin = common.inputs.Input('LcheckFunctions', false);
            testCase.assertEqual(Xin.LcheckFunctions, false);
        end
        
        function constructorShouldSetLCheckFunctions(testCase)
            Xin = common.inputs.Input('Sdescription', 'Description');
            testCase.assertEqual(Xin.Sdescription, 'Description');
        end
        
        function constructorShouldSetMembers(testCase)
            x1 = common.inputs.RandomVariable('Sdistribution', 'normal', 'mean', 2.763, 'std', 0.4);
            x2 = common.inputs.RandomVariable('Sdistribution', 'normal', 'mean', 1.25, 'std', 0.4);
            Xrvs1 = common.inputs.RandomVariableSet('Cmembers', {'x1', 'x2'}, 'Xrv', [x1, x2]);
            
            x3 = common.inputs.RandomVariable('Sdistribution', 'normal', 'mean', 22.273, 'std', 0.9);
            x4 = common.inputs.RandomVariable('Sdistribution', 'normal', 'mean', 2.65, 'std', 0.7);
            Xrvs2 = common.inputs.RandomVariableSet('Cmembers', {'x1', 'x2'}, 'Xrv', [x3, x4]);
            
            Xin = common.inputs.Input('CSmembers', {'XrvsN1' 'XrvsN2'}, 'CXmembers', {Xrvs1 Xrvs2});
            testCase.assumeEqual(Xin.CnamesRandomVariableSet, {'XrvsN1' 'XrvsN2'})
        end
        
        function constructorShouldFailWithoutBothMembers(testCase)
            x1 = common.inputs.RandomVariable('Sdistribution', 'normal', 'mean', 2.763, 'std', 0.4);
            x2 = common.inputs.RandomVariable('Sdistribution', 'normal', 'mean', 1.25, 'std', 0.4);
            Xrvs1 = common.inputs.RandomVariableSet('Cmembers', {'x1', 'x2'}, 'Xrv', [x1, x2]);
            
            x3 = common.inputs.RandomVariable('Sdistribution', 'normal', 'mean', 22.273, 'std', 0.9);
            x4 = common.inputs.RandomVariable('Sdistribution', 'normal', 'mean', 2.65, 'std', 0.7);
            Xrvs2 = common.inputs.RandomVariableSet('Cmembers', {'x1', 'x2'}, 'Xrv', [x3, x4]);
            
            testCase.assumeError(@()common.inputs.Input('CSmembers', {}, 'CXmembers', {Xrvs1 Xrvs2}), 'openCOSSAN:Input:WrongInputLength');
            testCase.assumeError(@()common.inputs.Input('CSmembers', {'Xrvs1' 'Xrvs2'}, 'CXmembers', {}), 'openCOSSAN:Input:WrongInputLength')
        end
        
        %% test Xfunction
        
        function testXparameter(testCase)
            Xmat1 = common.inputs.Parameter('description', 'material 1 E', 'value', 7E+7);
            Xin = common.inputs.Input('Xparameter', Xmat1);
            testCase.assumeEqual(Xin.CnamesParameter, {'Xmat1'});
        end
        
        %% test XrandomVariableSet
        
        function testXrandomVariableSet(testCase)
            x1 = common.inputs.RandomVariable('Sdistribution', 'normal', 'mean', 2.763, 'std', 0.4);
            x2 = common.inputs.RandomVariable('Sdistribution', 'normal', 'mean', 1.25, 'std', 0.4);
            Xrvs1 = common.inputs.RandomVariableSet('Cmembers', {'x1', 'x2'}, 'Xrv', [x1, x2]);
            
            Xin = common.inputs.Input('Xrandomvariableset', Xrvs1);
            
            testCase.assumeEqual(Xin.CnamesRandomVariableSet, {'Xrvs1'})
        end
        
        %% test Xdesignvariable
        
        function testDesignVariableIO(testCase)
            Xdv1 = optimization.DesignVariable('Sdescription', 'dummy', 'value', 5);
            Xin = common.inputs.Input('Xdesignvariable', Xdv1);
            testCase.assumeEqual(Xin.CnamesDesignVariable, {'Xdv1'})
        end
        
        %% add
        function addShouldAddParameter(testCase)
            Xmat = common.inputs.Parameter('description', 'Material 1', 'Value', 7E+5);
            Xin = common.inputs.Input('Sdescription', 'Description');
            Xin = Xin.add('Xmember', Xmat, 'Sname', 'Xmat');
            testCase.assertLength(Xin.Xparameters, 1)
            testCase.assertEqual(Xin.CnamesParameter, {'Xmat'});
        end
        
        function addShouldAddDesignVariable(testCase)
            Xdv = optimization.DesignVariable('value', 5);
            Xin = common.inputs.Input('Sdescription', 'Description');
            Xin = Xin.add('Xmember', Xdv, 'Sname', 'Xdv');
            testCase.assertLength(Xin.XdesignVariable, 1)
            testCase.assertEqual(Xin.CnamesDesignVariable, {'Xdv'});
        end
        
        function addShouldAddRandomVariableSet(testCase)
            Xrv = common.inputs.RandomVariable('Sdistribution', 'exponential', 'par1', 1);
            Xrvs = common.inputs.RandomVariableSet('Cmembers', {'Xrv'}, 'CXrv', {Xrv});
            Xin = common.inputs.Input('Sdescription', 'Description');
            Xin = Xin.add('Xmember', Xrvs, 'Sname', 'Xrvs');
            testCase.assertLength(Xin.Xrvset, 1);
            testCase.assertEqual(Xin.CnamesRandomVariableSet, {'Xrvs'});
            testCase.assertEqual(Xin.NrandomVariables, 1);
            testCase.assertEqual(Xin.CnamesRandomVariable, {'Xrv'});
        end
        
        function addShouldAddBoundedSet(testCase)
            Xbs = intervals.BoundedSet('Cmembers', {'Interval 1'}, 'Cxint', {[0, 1]});
            Xin = common.inputs.Input('Sdescription', 'Description');
            Xin = Xin.add('Xmember', Xbs, 'Sname', 'Xbs');
            testCase.assertLength(Xin.Xbset, 1);
            testCase.assertEqual(Xin.CnamesBoundedSet, {'Xbs'});
            testCase.assertEqual(Xin.NintervalVariables, 1);
            testCase.assertEqual(Xin.CnamesIntervalVariable, {'Interval 1'});
        end
        
        function addShouldAddStochasticProcess(testCase)
            Xcov  = common.inputs.CovarianceFunction('Sformat','structure', ...
                'Cinputnames',{'t1','t2'}, ...
                'Sscript', 'sigma = 1; b = 0.5; for i=1:length(Tinput), Toutput(i).fcov  = sigma^2*exp(-1/b*abs(Tinput(i).t2-Tinput(i).t1)); end', ...
                'Coutputnames',{'fcov'});
            Xsp = common.inputs.StochasticProcess('Mcoord', linspace(0, 50, 7), ...
                'Vmean', 20, 'XcovarianceFunction', Xcov, 'Lhomogeneous', false);
            Xsp = KL_terms(Xsp, 'NKL_terms', 5);
            Xin = common.inputs.Input('Sdescription', 'Description');
            Xin = Xin.add('Xmember', Xsp, 'Sname', 'Xsp');
            testCase.assertLength(Xin.Xsp, 1);
            testCase.assertEqual(Xin.CnamesStochasticProcess, {'Xsp'});
        end
        
        function addShouldAddFunction(testCase)
            Xfun = common.inputs.Function('Sexpression', '5');
            Xin = common.inputs.Input('Sdescription', 'Description');
            Xin = Xin.add('Xmember', Xfun, 'Sname', 'Xfun');
            testCase.assertLength(Xin.Xfunctions, 1);
            testCase.assertEqual(Xin.CnamesFunction, {'Xfun'});
        end
        
        function addShouldAddSamples(testCase)
            Xrv1 = common.inputs.RandomVariable('Sdistribution', 'exponential', 'par1', 1);
            Xrvs1 = common.inputs.RandomVariableSet('Cmembers', {'Xrv1'}, 'CXrv', {Xrv1});
            Xsamples = Xrvs1.sample('Nsamples', 1e3);
            Xin = common.inputs.Input;
            Xin = add(Xin, 'Xmember', Xsamples, 'Sname', 'Xsamples');
            testCase.assertEqual(Xin.Xsamples.Nsamples, 1000);
        end
        function addShouldAddGaussianMixtureRandomVariableSet(testCase)
            N = 20;
            A1 = [2, -1.8, 0; -1.8, 2, 0; 0, 0, 1];
            A2 = [2, -1.9, 1.9; -1.9, 2 -1.9; 1.9 -1.9, 2];
            A3 = [2, 1.9, 0; 1.9, 2, 0; 0, 0, 1];
            p = [0.03, 0.95, 0.02];
            MU = [4, 4 -4; -3 -5, 4; 4 -4, 0];
            SIGMA = cat(3, A1, A2, A3);
            obj = gmdistribution(MU, SIGMA, p);
            r = random(obj, N);
            
            Xgmrvs = common.inputs.GaussianMixtureRandomVariableSet('MdataSet', r, 'Cmembers', {'X1' 'X2' 'X3'});
            Xin = common.inputs.Input();
            Xin = Xin.add('Xmember', Xgmrvs, 'Sname', 'Xgmrvs');
            testCase.assertLength(Xin.Xrvset, 1);
            testCase.assertEqual(Xin.CnamesGaussianMixtureRandomVariableSet, {'Xgmrvs'});
        end
        
        function addShouldNotAddStochasticProcessWithoutKLTerms(testCase)
            Xcov  = common.inputs.CovarianceFunction('Sformat','structure', ...
                'Cinputnames',{'t1','t2'}, ...
                'Sscript', 'sigma = 1; b = 0.5; for i=1:length(Tinput), Toutput(i).fcov  = sigma^2*exp(-1/b*abs(Tinput(i).t2-Tinput(i).t1)); end', ...
                'Coutputnames',{'fcov'});
            Xsp = common.inputs.StochasticProcess('Mcoord', linspace(0, 50, 7), ...
                'Vmean', 20, 'XcovarianceFunction', Xcov, 'Lhomogeneous', false);
            Xin = common.inputs.Input('Sdescription', 'Description');
            testCase.assertError(@() Xin.add('Xmember', Xsp, 'Sname', 'Xsp'), ...
                'openCOSSAN:Input:add:NoKLtermStochasticProcess');
        end
        
        function addShouldFailWithDuplicateObjects(testCase)
            Xmat1 = common.inputs.Parameter('description', 'Material 1', 'value', 7E+5);
            Xin = common.inputs.Input('Sdescription', 'Input Description');
            Xin = Xin.add('Xmember', Xmat1, 'Sname', 'Xmat1');
            testCase.assertError(@()Xin.add('Xmember', Xmat1, 'Sname', 'Xmat1'), ...
                'openCOSSAN:Input:add:duplicate');
        end
        
        function addShouldNotAcceptRandomVariable(testCase)
            Xrv = common.inputs.RandomVariable('Sdistribution', 'normal', 'mean', 2.763, 'std', 0.4);
            Xin = common.inputs.Input('Sdescription', 'Input Description');
            testCase.assertError(@() Xin.add('Xmember', Xrv, 'Sname', 'Xrv'), ...
                'openCOSSAN:inputs:Inputs:add');
        end
        
        function addShouldFailForUnexpectedObjects(testCase)
            Xin1 = common.inputs.Input;
            Xin2 = common.inputs.Input;
            testCase.assertError(@() Xin1.add('Xmember', Xin2, 'Sname', 'Xin2'), ...
                'openCOSSAN:inputs:Inputs:add');
        end
        
        function addShouldAddAll(testCase)
            Xin = common.inputs.Input;
            Xmat1 = common.inputs.Parameter('description', 'material 1 E', 'value', 7E+7);
            Xin = Xin.add('Xmember', Xmat1, 'Sname', 'Xmat1');
            
            x1 = common.inputs.RandomVariable('Sdistribution', 'uniform', 'lowerbound', 0, 'upperbound', 10);
            x2 = common.inputs.RandomVariable('Sdistribution', 'uniform', 'mean', 5, 'std', 1);
            Xrvs1 = common.inputs.RandomVariableSet('Cmembers', {'x1', 'x2'}, 'Xrv', [x1, x2]);
            Xin = Xin.add('Xmember', Xrvs1, 'Sname', 'Xrvs1');
            
            Xfun1       = common.inputs.Function('Sdescription','function #1', ...
                'Sexpression','<&x1&>+<&x2&>');
            Xin = Xin.add('Xmember', Xfun1, 'Sname', 'Xfun1');
            
            Xdv1 = optimization.DesignVariable('Sdescription', 'dummy', 'value', 5);
            Xin = Xin.add('Xmember', Xdv1, 'Sname', 'Xdv1');
            
            SP1 = common.inputs.StochasticProcess('Sdescription', 'Description', 'Mcoord', linspace(0, 50, 51), 'Vmean', 20, 'Mcovariance', eye(51));
            SP1 = KL_terms(SP1, 'NKL_terms', 2);
            
            Xin = Xin.add('Xmember', SP1, 'Sname', 'SP1');
            testCase.assertEqual(Xin.Cnames, { 'x1' 'x2' 'Xfun1' 'Xmat1' 'SP1' 'Xdv1'});
            testCase.assertEqual(Xin.CnamesStochasticProcess, {'SP1'});
            testCase.assertEqual(Xin.CnamesDesignVariable, {'Xdv1'});
            testCase.assertEqual(Xin.CnamesFunction, {'Xfun1'});
        end
        
        function addShouldIncreaseNinputs(testCase)
            Xpar = common.inputs.Parameter('description', 'material 1', 'value', 5E+3);
            Xdv = optimization.DesignVariable('value', 5);
            Xin = common.inputs.Input('Sdescription', 'Input Description');
            Xin = Xin.add('Xmember', Xpar, 'Sname', 'Xpar');
            Xin = Xin.add('Xmember', Xdv, 'Sname', 'Xdv');
            testCase.assertEqual(Xin.Ninputs, 2);
        end
        
        %% remove
        function removeShouldRemoveObject(testCase)
            Xmat1 = common.inputs.Parameter('description', 'material 1', 'value', 5E+3);
            Xin = common.inputs.Input('Sdescription', 'Input Description');
            Xin = Xin.add('Xmember', Xmat1, 'Sname', 'Xmat1');
            Xin = Xin.remove(Xmat1);
            testCase.assertEqual(Xin.Xparameters, struct());
        end
        
        function removeShouldFailForInvalidObject(testCase)
            Xmat1 = common.inputs.Parameter('description', 'material 1', 'value', 5E+3);
            Xin = common.inputs.Input('Sdescription', 'Input Description');
            Xin = Xin.add('Xmember', Xmat1, 'Sname', 'Xmat1');
            testCase.assertError(@()Xin.remove('stuff'), 'openCOSSAN:Input:remove')
        end
        
        function removeShouldWhenRemovingUnknownObject(testCase)
            Xmat1 = common.inputs.Parameter('description', 'material 1', 'value', 5E+3);
            Xmat2 = common.inputs.Parameter('description', 'material 2', 'value', 5E+3);
            Xin = common.inputs.Input('Sdescription', 'Input Description');
            Xin = Xin.add('Xmember', Xmat1, 'Sname', 'Xmat1');
            testCase.assertWarning(@()Xin.remove(Xmat2), ...
                'openCOSSAN:Input:remove')
        end
        %% sample
        function sampleShouldCreateDesiredNumber(testCase)
            Xrv1 = common.inputs.RandomVariable('Sdistribution', 'exponential', 'par1', 1);
            Xrvs1 = common.inputs.RandomVariableSet('Cmembers', {'Xrv1'}, 'CXrv', {Xrv1});
            Xin = common.inputs.Input;
            Xin = add(Xin, 'Xmember', Xrvs1, 'Sname', 'Xrvs1');
            Xin = Xin.sample('Nsamples', 1e3);
            
            testCase.assertEqual(Xin.Nsamples, 1000);
        end
        
        function samplesShouldReplaceSamples(testCase)
            Xrv1 = common.inputs.RandomVariable('Sdistribution', 'exponential', 'par1', 1);
            Xrvs1 = common.inputs.RandomVariableSet('Cmembers', {'Xrv1'}, 'CXrv', {Xrv1});
            Xin = common.inputs.Input;
            Xin = add(Xin, 'Xmember', Xrvs1, 'Sname', 'Xrvs1');
            Xin = Xin.sample('Nsamples', 1e3);
            Xin = Xin.sample('Nsamples', 1e3);
            
            testCase.assertEqual(Xin.Nsamples, 1000);
        end
        
        function sampleShouldAddSamples(testCase)
            Xrv1 = common.inputs.RandomVariable('Sdistribution', 'exponential', 'par1', 1);
            Xrvs1 = common.inputs.RandomVariableSet('Cmembers', {'Xrv1'}, 'CXrv', {Xrv1});
            Xin = common.inputs.Input;
            Xin = add(Xin, 'Xmember', Xrvs1, 'Sname', 'Xrvs1');
            Xin = Xin.sample('Nsamples', 1e3);
            Xin = Xin.sample('Nsamples', 1e3, 'Ladd', true);
            
            testCase.assertEqual(Xin.Nsamples, 2000);
        end
        
        %% get
        function getShouldReturnDefaultValues(testCase)
            Xin = common.inputs.Input;
            x1 = common.inputs.RandomVariable('Sdistribution', 'uniform', 'lowerbound', 0, 'upperbound', 10);
            x2 = common.inputs.RandomVariable('Sdistribution', 'uniform', 'mean', 5, 'std', 1);
            Xrvs1 = common.inputs.RandomVariableSet('Cmembers', {'x1', 'x2'}, 'Xrv', [x1, x2]);
            Xin = Xin.add('Xmember', Xrvs1, 'Sname', 'Xrvs1');
            testCase.verifyEqual(Xin.get('defaultvalues'), struct('x1', 5, 'x2', 5))
        end
        
        function getShouldFailForUnknownArgument(testCase)
            Xin = common.inputs.Input;
            x1 = common.inputs.RandomVariable('Sdistribution', 'uniform', 'lowerbound', 0, 'upperbound', 10);
            x2 = common.inputs.RandomVariable('Sdistribution', 'uniform', 'mean', 5, 'std', 1);
            Xrvs1 = common.inputs.RandomVariableSet('Cmembers', {'x1', 'x2'}, 'Xrv', [x1, x2]);
            Xin = Xin.add('Xmember', Xrvs1, 'Sname', 'Xrvs1');
            testCase.verifyError(@()Xin.get('randomvariableset'), 'openCOSSAN:Input:get')
        end
        %% set
        function setShouldChangeProperties(testCase)
            Xin = common.inputs.Input;
            x1 = common.inputs.RandomVariable('Sdistribution', 'uniform', 'lowerbound', 0, 'upperbound', 10);
            x2 = common.inputs.RandomVariable('Sdistribution', 'uniform', 'mean', 5, 'std', 1);
            Xrvs1 = common.inputs.RandomVariableSet('Cmembers', {'x1', 'x2'}, 'Xrv', [x1, x2]);
            Xin = Xin.add('Xmember', Xrvs1, 'Sname', 'Xrvs1');
            
            Xin = Xin.set('SobjectName', 'x2', 'SpropertyName', 'std', 'value', 2);
            Xin = Xin.set('SobjectName', 'x2', 'SpropertyName', 'mean', 'value', 3);
            Xin = Xin.set('SobjectName', 'x1', 'SpropertyName', 'parameter1', 'value', 5);
            
            testCase.assumeEqual(Xin.get('Xrv', 'x1').lowerBound, 5)
            testCase.assumeEqual(Xin.get('Xrv', 'x2').std, 2)
            testCase.assumeEqual(Xin.get('Xrv', 'x2').mean, 3)
        end
        
        function setShouldChangeDistribution(testCase)
            Xin = common.inputs.Input;
            x1 = common.inputs.RandomVariable('Sdistribution', 'uniform', 'lowerbound', 0, 'upperbound', 10);
            x2 = common.inputs.RandomVariable('Sdistribution', 'uniform', 'mean', 5, 'std', 1);
            Xrvs1 = common.inputs.RandomVariableSet('Cmembers', {'x1', 'x2'}, 'Xrv', [x1, x2]);
            Xin = Xin.add('Xmember', Xrvs1, 'Sname', 'Xrvs1');
            
            Xin = Xin.set('SobjectName', 'x2', 'SpropertyName', 'Sdistribution', 'Svalue', 'normal');
            testCase.assumeEqual(Xin.Xrvset.Xrvs1.Xrv{2}.Sdistribution, 'NORMAL')
        end
        
        %% merge
        function mergeTwoParameters(testCase)
            Xmat1 = common.inputs.Parameter('description', 'material 1 E', 'value', 7E+7);
            Xmat2 = common.inputs.Parameter('description', 'material 2 E', 'value', 2E+7);
            Xin1 = common.inputs.Input;
            Xin2 = common.inputs.Input;
            Xin1 = Xin1.add('Xmember', Xmat1, 'Sname', 'Xmat1');
            Xin2 = Xin2.add('Xmember', Xmat2, 'Sname', 'Xmat2');
            
            Xin2 = Xin2.merge(Xin1);
            
            testCase.assumeEqual(Xin2.CnamesParameter, {'Xmat2', 'Xmat1'})
        end
        
        function mergeInputsWithTheSameRvsetsShouldWarn(testCase)
            Xin1 = common.inputs.Input;
            x1 = common.inputs.RandomVariable('Sdistribution', 'uniform', 'lowerbound', 0, 'upperbound', 10);
            x2 = common.inputs.RandomVariable('Sdistribution', 'uniform', 'mean', 5, 'std', 1);
            Xrvs1 = common.inputs.RandomVariableSet('Cmembers', {'x1', 'x2'}, 'Xrv', [x1, x2]);
            Xin1 = Xin1.add('Xmember', Xrvs1, 'Sname', 'Xrvs1');
            
            Xin2 = common.inputs.Input;
            Xin2 = Xin2.add('Xmember', Xrvs1, 'Sname', 'Xrvs1');
            
            testCase.assertWarning(@() Xin2.merge(Xin1), 'openCOSSAN:Inputs:merge');
        end
        
        function mergeWithStochasticProcess(testCase)
            Xpar = common.inputs.Parameter('description', 'material 1 E', 'value', 7E+7);
            Xin1 = common.inputs.Input('CXmembers', {Xpar}, 'Csmembers', {'Xpar'});
            Xcov  = common.inputs.CovarianceFunction('Sformat','structure', ...
                'Cinputnames',{'t1','t2'}, ...
                'Sscript', 'sigma = 1; b = 0.5; for i=1:length(Tinput), Toutput(i).fcov  = sigma^2*exp(-1/b*abs(Tinput(i).t2-Tinput(i).t1)); end', ...
                'Coutputnames',{'fcov'});
            Xsp = common.inputs.StochasticProcess('Mcoord', linspace(0, 50, 7), ...
                'Vmean', 20, 'XcovarianceFunction', Xcov, 'Lhomogeneous', false);
            Xsp = KL_terms(Xsp, 'NKL_terms', 5);
            Xin2 = common.inputs.Input('CXmembers', {Xsp}, 'Csmembers', {'Xsp'});
            Xin1 = Xin2.merge(Xin1);
            testCase.assertEqual(Xin1.Ninputs, 2);
            testCase.assertLength(Xin1.Xsp, 1);
            testCase.assertLength(Xin1.Xparameters, 1);
        end
        
        %% getMoments
        function getMomentsShouldReturnMeanValues(testCase)
            Xin = common.inputs.Input;
            x1 = common.inputs.RandomVariable('Sdistribution', 'normal', 'mean', 2.763, 'std', 0.4);
            x2 = common.inputs.RandomVariable('Sdistribution', 'normal', 'mean', 1.25, 'std', 0.4);
            Xrvs1 = common.inputs.RandomVariableSet('Cmembers', {'x1', 'x2'}, 'Xrv', [x1, x2]);
            Xin = Xin.add('Xmember', Xrvs1, 'Sname', 'Xrvs1');
            moments = Xin.getMoments;
            testCase.verifyEqual(moments, [2.763, 1.25])
        end
        
        %% getStructure
        function getStructureShouldFailForEmptyInput(testCase)
            Xin = common.inputs.Input;
            testCase.assertError(@() Xin.getStructure(), 'openCOSSAN:Input:getStructure:noInput');
        end
        
        function getStructureFailWithoutSamples(testCase)
            Xin = common.inputs.Input;
            x1 = common.inputs.RandomVariable('Sdistribution', 'normal', 'mean', 2.763, 'std', 0.4);
            Xrvs1 = common.inputs.RandomVariableSet('Cmembers', {'x1'}, 'Xrv', x1);
            Xin = Xin.add('Xmember', Xrvs1, 'Sname', 'Xrvs1');
            testCase.assertError(@() Xin.getStructure(), 'openCOSSAN:Input:getStructure:noSamples');
        end
        
        function getStructureShouldReturnRealizations(testCase)
            Xin = common.inputs.Input;
            Xpar = common.inputs.Parameter('value', 5);
            Xrv1 = common.inputs.RandomVariable('Sdistribution', 'normal', 'mean', 2.763, 'std', 0.4);
            Xrvs = common.inputs.RandomVariableSet('Cmembers', {'Xrv1'}, 'Xrv', Xrv1);
            Xin = Xin.add('Xmember', Xrvs, 'Sname', 'Xrvs');
            Xin = Xin.add('Xmember', Xpar, 'Sname', 'Xpar');
            Xin = Xin.sample('Nsamples', 10);
            Xstruct = Xin.getStructure();
            
            testCase.assertLength(Xstruct, 10);
            par(1:10) = Xstruct(1:10).Xpar;
            testCase.assertEqual(par, 5 * ones(1, 10));
        end
        
        %% getSampleMatrix
        function getSampleMatrixShouldReturnSamples(testCase)
            Xin = common.inputs.Input;
            Xpar = common.inputs.Parameter('value', 5);
            Xdv = optimization.DesignVariable('value', 5);
            Xrv1 = common.inputs.RandomVariable('Sdistribution', 'normal', 'mean', 2.763, 'std', 0.4);
            Xrvs = common.inputs.RandomVariableSet('Cmembers', {'Xrv1'}, 'Xrv', Xrv1);
            Xin = Xin.add('Xmember', Xrvs, 'Sname', 'Xrvs');
            Xin = Xin.add('Xmember', Xpar, 'Sname', 'Xpar');
            Xin = Xin.add('Xmember', Xdv, 'Sname', 'Xdv');
            Xin = Xin.sample('Nsamples', 10);
            
            MX = Xin.getSampleMatrix();
            testCase.assertEqual(size(MX), [10, 2]);
        end
        
        function getSampleMatrixShouldWarnWithStochaticProcess(testCase)
            Xcov  = common.inputs.CovarianceFunction('Sformat','structure', ...
                'Cinputnames',{'t1','t2'}, ...
                'Sscript', 'sigma = 1; b = 0.5; for i=1:length(Tinput), Toutput(i).fcov  = sigma^2*exp(-1/b*abs(Tinput(i).t2-Tinput(i).t1)); end', ...
                'Coutputnames',{'fcov'});
            Xsp = common.inputs.StochasticProcess('Mcoord', linspace(0, 50, 7), ...
                'Vmean', 20, 'XcovarianceFunction', Xcov, 'Lhomogeneous', false);
            Xsp = KL_terms(Xsp, 'NKL_terms', 5);
            Xin = common.inputs.Input('Sdescription', 'Description');
            Xin = Xin.add('Xmember', Xsp, 'Sname', 'Xsp');
            Xin = Xin.sample('Nsamples', 10);
            testCase.assertWarning(@() Xin.getSampleMatrix(), 'openCOSSAN:Input:getSampleMatrix');
        end
        
        %% getValues
        function getValuesShouldReturnRealizations(testCase)
            Xrv1 = common.inputs.RandomVariable('Sdistribution', 'normal', 'mean', 2.763, 'std', 0.4);
            Xrv2 = common.inputs.RandomVariable('Sdistribution', 'normal', 'mean', 1.25, 'std', 0.4);
            Xrvs = common.inputs.RandomVariableSet('Cmembers', {'Xrv1', 'Xrv2'}, 'Xrv', [Xrv1, Xrv2]);
            Xin = common.inputs.Input('CXmembers', {Xrvs}, 'CSmembers', {'Xrvs'});
            Xin = Xin.sample('Nsamples', 10);
            Mdata = getValues(Xin, 'CSnames', {'Xrv1', 'Xrv2'});
            testCase.assertEqual(size(Mdata), [10, 2]);
        end
        
    end
    
end


