classdef InputTest < matlab.unittest.TestCase
    % INPUTTEST Unit tests for the class opencossan.common.inputs.Input
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
    
    properties
        Xcovfun
    end
    
    methods (TestClassSetup)
        function defineCovarianceFunction(testCase)
            testCase.Xcovfun  = opencossan.common.inputs.stochasticprocess.CovarianceFunction( ...
                'Description','covariance function', ...
                'Format','structure',...
                'InputNames',{'t1','t2'},... % Define the inputs
                'Script', strcat('sigma = 1; b = 0.5;', ...
                'for i=1:length(Tinput), Toutput(i).fcov  =', ...
                'sigma^2*exp(-1/b*abs(Tinput(i).t2-Tinput(i).t1));', ...
                'end'),'OutputNames',{'fcov'}); % Define the outputs
        end
    end
    
    methods (Test)
        
        %% Constructor
        function constructorEmpty(testCase)
            Xin = opencossan.common.inputs.Input();
            testCase.assertClass(Xin, 'opencossan.common.inputs.Input');
            testCase.assertEqual(Xin.Nsamples, 0);
        end
        
        function constructorShouldSetDescription(testCase)
            Xin = opencossan.common.inputs.Input('Description', 'My description');
            testCase.assertEqual(Xin.Description, "My description");
        end
        
        function constructorShouldSetFunctionsCheck(testCase)
            Xin = opencossan.common.inputs.Input('DoFunctionsCheck', false);
            testCase.assertEqual(Xin.DoFunctionsCheck, false);
        end
        
        function constructorShouldSetMembers(testCase)
            x1      = opencossan.common.inputs.random.NormalRandomVariable('mean',2.763,'std',0.4);
            x2      = opencossan.common.inputs.random.NormalRandomVariable('mean',1.25,'std',0.4);
            Xrvs1 = opencossan.common.inputs.random.RandomVariableSet('Names',["x1","x2"],'Members',[x1,x2]);
            
            x3      = opencossan.common.inputs.random.NormalRandomVariable('mean',22.273,'std',0.9);
            x4      = opencossan.common.inputs.random.NormalRandomVariable('mean',2.65,'std',0.7);
            Xrvs2   = opencossan.common.inputs.random.RandomVariableSet('Names', ["x1","x2"], 'Members', [x3, x4]);
            
            Xin     = opencossan.common.inputs.Input('MembersNames', {'XrvsN1' 'XrvsN2'}, 'Members', {Xrvs1 Xrvs2});
            testCase.assumeEqual(Xin.RandomVariableSetNames, {'XrvsN1' 'XrvsN2'})
        end
        
        function constructorShouldFailWithoutBothMembers(testCase)
            x1      = opencossan.common.inputs.random.NormalRandomVariable('mean',2.763,'std',0.4);
            x2      = opencossan.common.inputs.random.NormalRandomVariable('mean',1.25,'std',0.4);
            Xrvs1   = opencossan.common.inputs.random.RandomVariableSet('Names',["x1","x2"],'Members',[x1,x2]);
            
            x3      = opencossan.common.inputs.random.NormalRandomVariable('mean',22.273,'std',0.9);
            x4      = opencossan.common.inputs.random.NormalRandomVariable('mean',2.65,'std',0.7);
            Xrvs2   = opencossan.common.inputs.random.RandomVariableSet('Names',["x1","x2"],'Members',[x3, x4]);
            
            testCase.assumeError(@()opencossan.common.inputs.Input('MembersNames', {}, 'Members', {Xrvs1 Xrvs2}), 'openCOSSAN:Input:WrongInputLength');
            testCase.assumeError(@()opencossan.common.inputs.Input('MembersNames', {'Xrvs1' 'Xrvs2'}, 'Members', {}), 'openCOSSAN:Input:WrongInputLength')
        end
        
        %% test Xfunction
        
        function testXparameter(testCase)
            Xmat1 = opencossan.common.inputs.Parameter('description', 'material 1 E', 'value', 7E+7);
            Xin   = opencossan.common.inputs.Input('Parameter', Xmat1);
            testCase.assumeEqual(Xin.ParameterNames, {'Xmat1'});
        end
        
        %% test XrandomVariableSet
        
        function testXrandomVariableSet(testCase)
            x1    = opencossan.common.inputs.random.NormalRandomVariable('mean',2.763,'std',0.4);
            x2    = opencossan.common.inputs.random.NormalRandomVariable('mean',1.25,'std',0.4);
            Xrvs1 = opencossan.common.inputs.random.RandomVariableSet('Names',["x1","x2"],'Members',[x1,x2]);
            
            Xin   = opencossan.common.inputs.Input('RandomVariableSet', Xrvs1);
            
            testCase.assumeEqual(Xin.RandomVariableSetNames, {'Xrvs1'})
        end
        
        %% test Xdesignvariable
        
        function testDesignVariableIO(testCase)
            Xdv1 = opencossan.optimization.DesignVariable('SDescription', 'dummy', 'value', 5);
            Xin  = opencossan.common.inputs.Input('DesignVariable', Xdv1);
            testCase.assumeEqual(Xin.DesignVariableNames, {'Xdv1'})
        end
        
        %% Test method add
        function addShouldAddParameter(testCase)
            Xmat = opencossan.common.inputs.Parameter('description', 'Material 1', 'Value', 7E+5);
            Xin  = opencossan.common.inputs.Input('Description', 'Description');
            Xin  = Xin.add('Member', Xmat, 'Name', 'Xmat');
            testCase.assertLength(Xin.Parameters, 1)
            testCase.assertEqual(Xin.ParameterNames, {'Xmat'});
        end
        
        function addShouldAddDesignVariable(testCase)
            Xdv = opencossan.optimization.DesignVariable('value', 5);
            Xin = opencossan.common.inputs.Input('Description', 'Description');
            Xin = Xin.add('Member', Xdv, 'Name', 'Xdv');
            testCase.assertLength(Xin.DesignVariables, 1)
            testCase.assertEqual(Xin.DesignVariableNames, {'Xdv'});
        end
        
        function addShouldAddRandomVariableSet(testCase)
            Xrv  = opencossan.common.inputs.random.ExponentialRandomVariable('lambda', 1);
            Xrvs = opencossan.common.inputs.random.RandomVariableSet('names', "Xrv", 'Members', Xrv);
            Xin  = opencossan.common.inputs.Input('Description', 'Description');
            Xin  = Xin.add('Member', Xrvs, 'Name', 'Xrvs');
            testCase.assertLength(Xin.RandomVariableSets, 1);
            testCase.assertEqual(Xin.RandomVariableSetNames, {'Xrvs'});
            testCase.assertEqual(Xin.NrandomVariables, 1);
            testCase.assertEqual(Xin.RandomVariableNames, "Xrv");
        end
        
        function addShouldAddBoundedSet(testCase)
            testCase.assumeFail();
            % TODO: BoundedSet to be moved to imprecise probabilities
            % toolbox
            error('BoundedSet to be moved');
            Xbs = intervals.BoundedSet('Cmembers', {'Interval 1'}, 'Cxint', {[0, 1]});
            Xin = opencossan.common.inputs.Input('Sdescription', 'Description');
            Xin = Xin.add('Member', Xbs, 'Name', 'Xbs');
            testCase.assertLength(Xin.Xbset, 1);
            testCase.assertEqual(Xin.CnamesBoundedSet, {'Xbs'});
            testCase.assertEqual(Xin.NintervalVariables, 1);
            testCase.assertEqual(Xin.CnamesIntervalVariable, {'Interval 1'});
        end
        
        function addShouldAddStochasticProcess(testCase)
            Xsp = opencossan.common.inputs.stochasticprocess.KarhunenLoeve(...
                'Description','Process 1','Distribution',...
                'normal','Mean',0,'CovarianceFunction',testCase.Xcovfun,...
                'Coordinates',1:0.1:5,'IsHomogeneous',true);
            Xsp = computeTerms(Xsp, 'NumberTerms', 5,'AssembleCovariance',true);
            Xin = opencossan.common.inputs.Input('Description', 'Description');
            Xin = Xin.add('Member', Xsp, 'Name', 'Xsp');
            testCase.assertLength(Xin.StochasticProcesses, 1);
            testCase.assertEqual(Xin.StochasticProcessNames, {'Xsp'});
        end
        
        function addShouldAddFunction(testCase)
            Xfun = opencossan.common.inputs.Function('Expression', '5');
            Xin  = opencossan.common.inputs.Input('Description', 'Description');
            Xin  = Xin.add('Member', Xfun, 'Name', 'Xfun');
            testCase.assertLength(Xin.Functions, 1);
            testCase.assertEqual(Xin.FunctionNames, {'Xfun'});
        end
        
        function addShouldAddSamples(testCase)
            Xrv1     = opencossan.common.inputs.random.ExponentialRandomVariable('lambda', 1);
            Xrvs1    = opencossan.common.inputs.random.RandomVariableSet('Names', "Xrv1", 'Members', Xrv1);
            Xsamples = Xrvs1.sample(1e3);
            Xin      = opencossan.common.inputs.Input;
            Xin      = add(Xin, 'Member', Xsamples, 'Name', 'Xsamples');
            testCase.assertEqual(Xin.Samples.Nsamples, 1000);
        end
        
        function addShouldAddGaussianMixtureRandomVariableSet(testCase)
            N     = 20;
            A1    = [2, -1.8, 0; -1.8, 2, 0; 0, 0, 1];
            A2    = [2, -1.9, 1.9; -1.9, 2 -1.9; 1.9 -1.9, 2];
            A3    = [2, 1.9, 0; 1.9, 2, 0; 0, 0, 1];
            p     = [0.03, 0.95, 0.02];
            MU    = [4, 4 -4; -3 -5, 4; 4 -4, 0];
            SIGMA = cat(3, A1, A2, A3);
            obj   = gmdistribution(MU, SIGMA, p);
            r     = random(obj, N);
            
            Xgmrvs = opencossan.common.inputs.GaussianMixtureRandomVariableSet('MdataSet', r, 'Cmembers', {'X1' 'X2' 'X3'});
            Xin    = opencossan.common.inputs.Input();
            Xin    = Xin.add('Member', Xgmrvs, 'Name', 'Xgmrvs');
            testCase.assertLength(Xin.RandomVariableSets, 1);
            testCase.assertEqual(Xin.GaussianMixtureRandomVariableSetNames, {'Xgmrvs'});
        end
        
        function addShouldNotAddStochasticProcessWithoutKLTerms(testCase)
            Xsp = opencossan.common.inputs.stochasticprocess.KarhunenLoeve(...
                'Description','Process 1','Distribution',...
                'normal','Mean',0,'CovarianceFunction',testCase.Xcovfun,...
                'Coordinates',1:0.1:5,'IsHomogeneous',true);
            Xin = opencossan.common.inputs.Input('Description', 'Description');
            testCase.assertError(@() Xin.add('Member', Xsp, 'Name', 'Xsp'), ...
                'openCOSSAN:Input:add:NoKLtermStochasticProcess');
        end
        
        function addShouldFailWithDuplicateObjects(testCase)
            Xmat1 = opencossan.common.inputs.Parameter('description', 'Material 1', 'value', 7E+5);
            Xin   = opencossan.common.inputs.Input('Description', 'Input Description');
            Xin   = Xin.add('Member', Xmat1, 'Name', 'Xmat1');
            testCase.assertError(@()Xin.add('Member', Xmat1, 'Name', 'Xmat1'), ...
                'openCOSSAN:Input:add:duplicate');
        end
        
        function addShouldNotAcceptRandomVariable(testCase)
            Xrv = opencossan.common.inputs.random.NormalRandomVariable('mean',2.763,'std',0.4);
            Xin = opencossan.common.inputs.Input('Description', 'Input Description');
            testCase.assertError(@() Xin.add('Member', Xrv, 'Name', 'Xrv'), ...
                'openCOSSAN:inputs:Inputs:add');
        end
        
        function addShouldFailForUnexpectedObjects(testCase)
            Xin1 = opencossan.common.inputs.Input;
            Xin2 = opencossan.common.inputs.Input;
            testCase.assertError(@() Xin1.add('Member', Xin2, 'Name', 'Xin2'), ...
                'openCOSSAN:inputs:Inputs:add');
        end
        
        function addShouldAddAll(testCase)
            Xin   = opencossan.common.inputs.Input;
            Xmat1 = opencossan.common.inputs.Parameter('description', 'material 1 E', 'value', 7E+7);
            Xin   = Xin.add('Member', Xmat1, 'Name', 'Xmat1');
            
            x1    = opencossan.common.inputs.random.UniformRandomVariable('bounds',[0 10]);
            x2    = opencossan.common.inputs.random.UniformRandomVariable.fromMeanAndStd('mean',5,'std',1);
            Xrvs1 = opencossan.common.inputs.random.RandomVariableSet('Names',["x1","x2"],'Members',[x1,x2]);
            Xin   = Xin.add('Member', Xrvs1, 'Name', 'Xrvs1');
            
            Xfun1       = opencossan.common.inputs.Function('Description','function #1', ...
                'Expression','<&x1&>+<&x2&>');
            Xin  = Xin.add('Member', Xfun1, 'Name', 'Xfun1');
            
            Xdv1 = opencossan.optimization.DesignVariable('SDescription', 'dummy', 'value', 5);
            Xin  = Xin.add('Member', Xdv1, 'Name', 'Xdv1');
            
            SP1  = opencossan.common.inputs.stochasticprocess.KarhunenLoeve(...
                'Description','Process 1','Distribution',...
                'normal','Mean',0,'CovarianceFunction',testCase.Xcovfun,...
                'Coordinates',1:0.1:5,'IsHomogeneous',true);
            SP1  = computeTerms(SP1, 'NumberTerms', 5,'AssembleCovariance',true);
            
            Xin  = Xin.add('Member', SP1, 'Name', 'SP1');
            
            testCase.assertEqual(Xin.Names, ["x1","x2","Xfun1","Xmat1","SP1","Xdv1"]);
            testCase.assertEqual(Xin.StochasticProcessNames, {'SP1'});
            testCase.assertEqual(Xin.DesignVariableNames, {'Xdv1'});
            testCase.assertEqual(Xin.FunctionNames, {'Xfun1'});
        end
        
        function addShouldIncreaseNinputs(testCase)
            Xpar = opencossan.common.inputs.Parameter('description', 'material 1', 'value', 5E+3);
            Xdv  = opencossan.optimization.DesignVariable('value', 5);
            Xin  = opencossan.common.inputs.Input('Description', 'Input Description');
            Xin  = Xin.add('Member', Xpar, 'Name', 'Xpar');
            Xin  = Xin.add('Member', Xdv, 'Name', 'Xdv');
            testCase.assertEqual(Xin.Ninputs, 2);
        end
        
        %% remove
        function removeShouldRemoveObject(testCase)
            Xmat1 = opencossan.common.inputs.Parameter('description', 'material 1', 'value', 5E+3);
            Xin   = opencossan.common.inputs.Input('Description', 'Input Description');
            Xin   = Xin.add('Member', Xmat1, 'Name', 'Xmat1');
            Xin   = Xin.remove(Xmat1);
            testCase.assertEqual(Xin.Parameters, struct());
        end
        
        function removeShouldFailForInvalidObject(testCase)
            Xmat1 = opencossan.common.inputs.Parameter('description', 'material 1', 'value', 5E+3);
            Xin   = opencossan.common.inputs.Input('Description', 'Input Description');
            Xin   = Xin.add('Member', Xmat1, 'Name', 'Xmat1');
            testCase.assertError(@()Xin.remove('stuff'), 'openCOSSAN:Input:remove')
        end
        
        function removeShouldWhenRemovingUnknownObject(testCase)
            Xmat1 = opencossan.common.inputs.Parameter('description', 'material 1', 'value', 5E+3);
            Xmat2 = opencossan.common.inputs.Parameter('description', 'material 2', 'value', 5E+3);
            Xin   = opencossan.common.inputs.Input('Description', 'Input Description');
            Xin   = Xin.add('Member', Xmat1, 'Name', 'Xmat1');
            testCase.assertWarning(@()Xin.remove(Xmat2), ...
                'openCOSSAN:Input:remove')
        end
        %% sample
        function sampleShouldCreateDesiredNumber(testCase)
            Xrv1  = opencossan.common.inputs.random.ExponentialRandomVariable('lambda', 1);
            Xrvs1 = opencossan.common.inputs.random.RandomVariableSet('Names',"Xrv1",'Members',Xrv1);
            Xin   = opencossan.common.inputs.Input;
            Xin   = add(Xin, 'Member', Xrvs1, 'Name', 'Xrvs1');
            Xin   = Xin.sample('Nsamples', 1e3);
            
            testCase.assertEqual(Xin.Nsamples, 1000);
        end
        
        function samplesShouldReplaceSamples(testCase)
            Xrv1  = opencossan.common.inputs.random.ExponentialRandomVariable('lambda', 1);
            Xrvs1 = opencossan.common.inputs.random.RandomVariableSet('Names',"Xrv1",'Members',Xrv1);
            Xin   = opencossan.common.inputs.Input;
            Xin   = add(Xin, 'Member', Xrvs1, 'Name', 'Xrvs1');
            Xin   = Xin.sample('Nsamples', 1e4);
            Xin   = Xin.sample('Nsamples', 1e3);
            
            testCase.assertEqual(Xin.Nsamples, 1000);
        end
        
        function sampleShouldAddSamples(testCase)
            Xrv1  = opencossan.common.inputs.random.ExponentialRandomVariable('lambda', 1);
            Xrvs1 = opencossan.common.inputs.random.RandomVariableSet('Names',"Xrv1",'Members',Xrv1);
            Xin   = opencossan.common.inputs.Input;
            Xin   = add(Xin, 'Member', Xrvs1, 'Name', 'Xrvs1');
            Xin   = Xin.sample('Nsamples', 1e3);
            Xin   = Xin.sample('Nsamples', 1e3, 'AddSamples', true);
            
            testCase.assertEqual(Xin.Nsamples, 2000);
        end
        
        %% get
        function getShouldReturnDefaultValues(testCase)
            Xin   = opencossan.common.inputs.Input;
            x1    = opencossan.common.inputs.random.UniformRandomVariable('bounds',[0 10]);
            x2    = opencossan.common.inputs.random.UniformRandomVariable.fromMeanAndStd('mean',5,'std',1);
            Xrvs1 = opencossan.common.inputs.random.RandomVariableSet('Names',["x1","x2"],'Members',[x1,x2]);
            Xin   = Xin.add('Member', Xrvs1, 'Name', 'Xrvs1');
            testCase.verifyEqual(Xin.get('DefaultValues'), struct('x1', 5, 'x2', 5))
        end
        
        function getShouldFailForUnknownArgument(testCase)
            Xin   = opencossan.common.inputs.Input;
            x1    = opencossan.common.inputs.random.UniformRandomVariable('bounds',[0 10]);
            x2    = opencossan.common.inputs.random.UniformRandomVariable.fromMeanAndStd('mean',5,'std',1);
            Xrvs1 = opencossan.common.inputs.random.RandomVariableSet('Names', ["x1", "x2"], 'Members', [x1, x2]);
            Xin   = Xin.add('Member', Xrvs1, 'Name', 'Xrvs1');
            testCase.verifyError(@()Xin.get('randomvariableset'), 'openCOSSAN:Input:get')
        end
        %% set
        function setShouldChangeProperties(testCase)
            testCase.assumeFail(); % TODO we need this?!
            Xin   = opencossan.common.inputs.Input;
            x1    = opencossan.common.inputs.random.UniformRandomVariable('bounds',[0 10]);
            x2    = opencossan.common.inputs.random.UniformRandomVariable.fromMeanAndStd('mean',5,'std',1);
            Xrvs1 = opencossan.common.inputs.random.RandomVariableSet('Names', ["x1", "x2"], 'Members', [x1, x2]);
            Xin   = Xin.add('Member', Xrvs1, 'Name', 'Xrvs1');
            
            Xin   = Xin.set('SobjectName', 'x2', 'SpropertyName', 'std', 'value', 2);
            Xin   = Xin.set('SobjectName', 'x2', 'SpropertyName', 'mean', 'value', 3);
            Xin   = Xin.set('SobjectName', 'x1', 'SpropertyName', 'parameter1', 'value', 5);
            
            testCase.assumeEqual(Xin.get('RandomVariable', 'x1').lowerBound, 5)
            testCase.assumeEqual(Xin.get('RandomVariable', 'x2').std, 2)
            testCase.assumeEqual(Xin.get('RandomVariable', 'x2').mean, 3)
        end
        
        function setShouldChangeDistribution(testCase)
            testCase.assumeFail(); % TODO we need this?!
            Xin   = opencossan.common.inputs.Input;
            x1    = opencossan.common.inputs.random.UniformRandomVariable('bounds',[0 10]);
            x2    = opencossan.common.inputs.random.UniformRandomVariable.fromMeanAndStd('mean',5,'std',1);
            Xrvs1 = opencossan.common.inputs.random.RandomVariableSet('Names', ["x1", "x2"], 'Members', [x1, x2]);
            Xin   = Xin.add('Member', Xrvs1, 'Name', 'Xrvs1');
            
            Xin   = Xin.set('SobjectName', 'x2', 'SpropertyName', 'Sdistribution', 'Svalue', 'normal');
            testCase.assumeEqual(Xin.RandomVariableSets.Xrvs1.getDistribution("x2"), "Normal")
        end
        
        %% merge
        function mergeTwoParameters(testCase)
            Xmat1 = opencossan.common.inputs.Parameter('description', 'material 1 E', 'value', 7E+7);
            Xmat2 = opencossan.common.inputs.Parameter('description', 'material 2 E', 'value', 2E+7);
            Xin1  = opencossan.common.inputs.Input;
            Xin2  = opencossan.common.inputs.Input;
            Xin1  = Xin1.add('Member', Xmat1, 'Name', 'Xmat1');
            Xin2  = Xin2.add('Member', Xmat2, 'Name', 'Xmat2');
            
            Xin2  = Xin2.merge(Xin1);
            
            testCase.assumeEqual(Xin2.ParameterNames, {'Xmat2', 'Xmat1'})
        end
        
        function mergeInputsWithTheSameRvsetsShouldWarn(testCase)
            Xin1  = opencossan.common.inputs.Input;
            x1    = opencossan.common.inputs.random.UniformRandomVariable('bounds',[0 10]);
            x2    = opencossan.common.inputs.random.UniformRandomVariable.fromMeanAndStd('mean',5,'std',1);
            Xrvs1 = opencossan.common.inputs.random.RandomVariableSet('Names', ["x1", "x2"], 'Members', [x1, x2]);
            Xin1  = Xin1.add('Member', Xrvs1, 'Name', 'Xrvs1');
            
            Xin2  = opencossan.common.inputs.Input;
            Xin2  = Xin2.add('Member', Xrvs1, 'Name', 'Xrvs1');
            
            testCase.assertWarning(@() Xin2.merge(Xin1), 'openCOSSAN:Inputs:merge');
        end
        
        function mergeWithStochasticProcess(testCase)
            Xpar = opencossan.common.inputs.Parameter('description', 'material 1 E', 'value', 7E+7);
            Xin1 = opencossan.common.inputs.Input('Members', {Xpar}, 'MembersNames', {'Xpar'});
            Xsp  = opencossan.common.inputs.stochasticprocess.KarhunenLoeve(...
                'Description','Process 1','Distribution',...
                'normal','Mean',0,'CovarianceFunction',testCase.Xcovfun,...
                'Coordinates',1:0.1:5,'IsHomogeneous',true);
            Xsp  = computeTerms(Xsp, 'NumberTerms', 5,'AssembleCovariance',true);
            Xin2 = opencossan.common.inputs.Input('Members', {Xsp}, 'MembersNames', {'Xsp'});
            Xin1 = Xin2.merge(Xin1);
            testCase.assertEqual(Xin1.Ninputs, 2);
            testCase.assertLength(Xin1.StochasticProcesses, 1);
            testCase.assertLength(Xin1.Parameters, 1);
        end
        
        %% getMoments
        function getMomentsShouldReturnMeanValues(testCase)
            Xin     = opencossan.common.inputs.Input;
            x1      = opencossan.common.inputs.random.NormalRandomVariable('mean',2.763,'std',0.4);
            x2      = opencossan.common.inputs.random.NormalRandomVariable('mean',1.25,'std',0.4);
            Xrvs1   = opencossan.common.inputs.random.RandomVariableSet('Names', ["x1", "x2"], 'Members', [x1, x2]);
            Xin     = Xin.add('Member', Xrvs1, 'Name', 'Xrvs1');
            moments = Xin.getMoments;
            testCase.verifyEqual(moments, [2.763, 1.25])
        end
        
        %% getStructure
        function getStructureShouldFailForEmptyInput(testCase)
            Xin = opencossan.common.inputs.Input;
            testCase.assertError(@() Xin.getStructure(), 'openCOSSAN:Input:getStructure:noInput');
        end
        
        function getStructureFailWithoutSamples(testCase)
            Xin   = opencossan.common.inputs.Input;
            x1    = opencossan.common.inputs.random.NormalRandomVariable('mean',2.763,'std',0.4);
            Xrvs1 = opencossan.common.inputs.random.RandomVariableSet('Names', "x1", 'Members', x1);
            Xin   = Xin.add('Member', Xrvs1, 'Name', 'Xrvs1');
            testCase.assertError(@() Xin.getStructure(), 'openCOSSAN:Input:getStructure:noSamples');
        end
        
        function getStructureShouldReturnRealizations(testCase)
            Xin     = opencossan.common.inputs.Input;
            Xpar    = opencossan.common.inputs.Parameter('value', 5);
            Xrv1    = opencossan.common.inputs.random.NormalRandomVariable('mean',2.763,'std',0.4);
            Xrvs    = opencossan.common.inputs.random.RandomVariableSet('Names', "Xrv1", 'Members', Xrv1);
            Xin     = Xin.add('Member', Xrvs, 'Name', 'Xrvs');
            Xin     = Xin.add('Member', Xpar, 'Name', 'Xpar');
            Xin     = Xin.sample('Nsamples', 10);
            Xstruct = Xin.getStructure();
            
            testCase.assertLength(Xstruct, 10);
            par(1:10) = Xstruct(1:10).Xpar;
            testCase.assertEqual(par, 5 * ones(1, 10));
        end
        
        function getDefaultStructureWithAllInputs(testCase)
            testCase.assumeFail(); % TODO Fix Dataseries?
            Xin   = opencossan.common.inputs.Input;
            Xmat1 = opencossan.common.inputs.Parameter('description', 'material 1 E', 'value', 7E+7);
            Xin   = Xin.add('Member', Xmat1, 'Name', 'Xmat1');
            
            x1    = opencossan.common.inputs.random.UniformRandomVariable('bounds',[0 10]);
            x2    = opencossan.common.inputs.random.UniformRandomVariable.fromMeanAndStd('mean',5,'std',1);
            Xrvs1 = opencossan.common.inputs.random.RandomVariableSet('Names', ["x1", "x2"], 'Members', [x1, x2]);
            Xin   = Xin.add('Member', Xrvs1, 'Name', 'Xrvs1');
            
            Xfun1 = opencossan.common.inputs.Function('Description','function #1', ...
                'Expression','<&x1&>+<&x2&>');
            Xin   = Xin.add('Member', Xfun1, 'Name', 'Xfun1');
            
            Xdv1  = opencossan.optimization.DesignVariable('SDescription', 'dummy', 'value', 5);
            Xin   = Xin.add('Member', Xdv1, 'Name', 'Xdv1');
            
            SP1   = opencossan.common.inputs.stochasticprocess.KarhunenLoeve(...
                'Description','Process 1','Distribution',...
                'normal','Mean',0,'CovarianceFunction',testCase.Xcovfun,...
                'Coordinates',1:0.1:5,'IsHomogeneous',true);
            SP1   = computeTerms(SP1, 'NumberTerms', 5,'AssembleCovariance',true);
            
            Xin   = Xin.add('Member', SP1, 'Name', 'SP1');
            
            out   = Xin.getDefaultValuesStructure;
            testCase.assertEqual(out.SP1.Vdata,zeros(1,41))
            Xin   = Xin.add('Member', SP1, 'Name', 'SP2');
            out   = Xin.getDefaultValuesStructure;
            testCase.assertEqual(out.SP2.Vdata,zeros(1,41))
        end
        
        %% getSampleMatrix
        function getSampleMatrixShouldReturnSamples(testCase)
            Xin  = opencossan.common.inputs.Input;
            Xpar = opencossan.common.inputs.Parameter('value', 5);
            Xdv  = opencossan.optimization.DesignVariable('value', 5);
            Xrv1 = opencossan.common.inputs.random.NormalRandomVariable('mean',2.763,'std',0.4);
            Xrvs = opencossan.common.inputs.random.RandomVariableSet('Names', "Xrv1", 'Members', Xrv1);
            Xin  = Xin.add('Member', Xrvs, 'Name', 'Xrvs');
            Xin  = Xin.add('Member', Xpar, 'Name', 'Xpar');
            Xin  = Xin.add('Member', Xdv, 'Name', 'Xdv');
            Xin  = Xin.sample('Nsamples', 10);
            
            MX  = Xin.getSampleMatrix();
            testCase.assertEqual(size(MX), [10, 2]);
        end
        
        function getSampleMatrixShouldWarnWithStochaticProcess(testCase)
            Xsp = opencossan.common.inputs.stochasticprocess.KarhunenLoeve(...
                'Description','Process 1','Distribution',...
                'normal','Mean',0,'CovarianceFunction',testCase.Xcovfun,...
                'Coordinates',1:0.1:5,'IsHomogeneous',true);
            Xsp = computeTerms(Xsp, 'NumberTerms', 5,'AssembleCovariance',true);
            Xin = opencossan.common.inputs.Input('Description', 'Description');
            Xin = Xin.add('Member', Xsp, 'Name', 'Xsp');
            Xin = Xin.sample('Nsamples', 10);
            testCase.assertWarning(@() Xin.getSampleMatrix(), 'openCOSSAN:Input:getSampleMatrix');
        end
        
        %% getValues
        function getValuesShouldReturnRealizations(testCase)
            Xrv1  = opencossan.common.inputs.random.NormalRandomVariable('mean',2.763,'std',0.4);
            Xrv2  = opencossan.common.inputs.random.NormalRandomVariable('mean',1.25,'std',0.4);
            Xrvs  = opencossan.common.inputs.random.RandomVariableSet('Names', ["Xrv1", "Xrv2"], 'Members', [Xrv1, Xrv2]);
            Xin   = opencossan.common.inputs.Input('Members', {Xrvs}, 'MembersNames', {'Xrvs'});
            Xin   = Xin.sample('Nsamples', 10);
            Mdata = getValues(Xin, 'VariableNames', {'Xrv1', 'Xrv2'});
            testCase.assertEqual(size(Mdata), [10, 2]);
        end
    end
end
