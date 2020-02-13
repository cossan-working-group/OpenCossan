%% Bayesian Optimization Tutorial
% 
% This tutorial shows how to optimise a cantilever beam design following the
% Bayesian Optimization approach, building a metamodel using Gaussian
% processes and updating it with expected improvement. 
% 
% A prerequisite for this tutorial is the ooDACE Toolbox
% (http://sumo.intec.ugent.be/ooDACE). To install it in OpenCossan move it
% to /OpenSourceSoftware/dace/.
% 
%
% See Also: https://cossan.co.uk/wiki/index.php/Bayesian_optimisation

% $Author: Enrique Miralles-Dolz$ 
% There is a clash of classes (hehe) with the OpenCossan Optimizer and the
% ooDACE Optimizer. dace must be in /OpenSourceSoftware/src/ but also
% it has to be included from a different folder as a external path, so the
% Optimizer classes don't conflict with each other.
% 

OpenCossan.resetRandomNumberGenerator(51120) % we get the same random numbers everytime

Xin = Input('Sdescription', 'input parameters of model');
Xb = RandomVariable('Sdescription', 'width', 'Sdistribution', 'uniform', 'par1', 0.05, 'par2', 0.3);
Xh = RandomVariable('Sdescription', 'height', 'Sdistribution', 'uniform', 'par1', 0.2, 'par2', 0.5);
Xrvset = RandomVariableSet('Cmembers', {'Xb','Xh'});
Xin = Xin.add('Xmember', Xrvset, 'Sname', 'Xrvset');
XP = Parameter('Sdescription', 'load', 'value', 1.0e6);
Xin = Xin.add('Xmember', XP, 'Sname', 'XP');

XL = Parameter('Sdescription', 'length', 'value', 5);
Xin = Xin.add('Xmember', XL, 'Sname', 'XL');
XE = Parameter('Sdescription', 'Youngs modulus', 'value', 10e9);
Xin = Xin.add('Xmember', XE, 'Sname', 'XE');
Xrho = Parameter('Sdescription', 'density', 'value', 600);
Xin = Xin.add('Xmember', Xrho, 'Sname', 'Xrho');
XI = Function('Sdescription', 'moment of inertia', 'Sexpression', '<&Xb&>.*<&Xh&>.^3/12');
Xin = Xin.add('Xmember', XI, 'Sname', 'XI');

Xtest = Xin;

Xmio = Mio('Sdescription', 'displacement', 'SScript', 'for i=1:length(Tinput),Toutput(i).disp=(Tinput(i).Xrho*9.81*Tinput(i).Xb*Tinput(i).Xh*Tinput(i).XL^4)/(8*Tinput(i).XE*Tinput(i).XI)+(Tinput(i).XP*Tinput(i).XL^3)/(3*Tinput(i).XE*Tinput(i).XI);end','Cinputnames', {'Xb', 'Xh', 'XP', 'XL', 'XE', 'Xrho', 'XI'}, 'Coutputnames', {'disp'}, 'Liostructure', true, 'Lfunction', false);

Xev = Evaluator('Sdescription', 'displacement evaluator', 'XMio', Xmio);
Xmod = Model('XEvaluator', Xev, 'Xinput', Xin);

Xkriging = KrigingModel('Sdescription', 'metamodel', 'SregressionType', 'regpoly0',...
'Coutputnames', {'disp'}, 'Cinputnames', {'Xb' 'Xh'}, 'Xfullmodel', Xmod,...
'VcorrelationParameter', [0.1 0.1]);

Xlhs = LatinHypercubeSampling('Nsamples', 8);
Xkriging1 = Xkriging.calibrate('XSimulator', Xlhs);
%%
Xmc=MonteCarlo('Nsamples',10000);
Xkriging1 = Xkriging1.validate('XSimulator',Xmc);
display(Xkriging1);

input_points = Xkriging1.XcalibrationInput.Xsamples.MsamplesPhysicalSpace;
output_points = Xkriging1.XcalibrationOutput.getValues('Sname', 'disp');
%for i=1:8
%    output_points(i) = Xkriging.XcalibrationOutput.Tvalues(i).disp;
%end

% MXX1 = repmat(linspace(0.05,0.3,201)',1,201);
% MXX2 = repmat(linspace(0.2,0.5,201),201,1);
% Vx1=MXX1(:); Vx2 = MXX2(:);
% Minput = [Vx1,Vx2];
% Xs = Samples('Xrvset',Xrvset,'MsamplesPhysicalSpace',Minput);
% Xin = Xin.add('Xmember', Xs, 'Sname', 'Xs');
% Xoutkr = Xkriging.apply(Xin);
%Xoutkr = Xoutkr.getValues('Sname', 'disp');

% input_points = [input_points ; 2,2] % to add new points
%% Example of metamodel updating
Xs = Samples('Xrvset', Xrvset, 'MsamplesPhysicalSpace', input_points);
Xin = Xin.add('Xmember', Xs, 'Sname', 'Xs');
Xkriging1 = Xkriging.calibrate('XcalibrationInput', Xin);

Xmc=MonteCarlo('Nsamples',10000);
Xkriging1 = Xkriging1.validate('XSimulator',Xmc);
display(Xkriging1);

% to calculate predictions and std-dev of our metamodel
new_point = [0.1, 0.35];
[y, s2] = Xkriging1.TdaceModel.predict(new_point) % large std-dev

% to update metamodel with new point here
Xs = Samples('Xrvset', Xrvset, 'MsamplesPhysicalSpace', new_point);
Xin = Xin.add('Xmember', Xs, 'Sname', 'Xs');
Xoutreal = Xmio.run(Xin);
j = Xoutreal.Tvalues(9);
display(j(1))
Xkriging1 = Xkriging.calibrate('XcalibrationInput', Xin);

Xmc=MonteCarlo('Nsamples',10000);
Xkriging1 = Xkriging1.validate('XSimulator',Xmc);
display(Xkriging1);

%Xstest = Samples('Xrvset', Xrvset, 'MsamplesPhysicalSpace', new_point);
%Xouttest = Xkriging1.apply(Xstest);
[y, s2] = Xkriging1.TdaceModel.predict(new_point) % 0 std-dev after training


%% Example of expected improvement application with a single point
output_points = Xkriging1.XcalibrationOutput.getValues('Sname', 'disp');
yPlug = min(output_points);
points = [0.22, 0.45; 0.27, 0.49]; % this should be MonteCarlo
[gpMean, gpStd] = Xkriging1.TdaceModel.predict(points);
gpVar = sqrt(gpStd);

inds = gpVar > 10^-16;

EI = (yPlug-gpMean).*(0.5+0.5*erf((yPlug-gpMean)./(sqrt(2)*gpStd)))+1/sqrt(2*pi)*gpVar.*exp(-(yPlug-gpMean).^2./(2*gpVar.^2));

EI(~inds) = 0;
sEI.EI = EI;
sEI.Inds = inds;

[maxEI, location] = max(EI);
display(points(location,:)) % add this point and recalibrate kriging
new_point = points(location,:);
Xs = Samples('Xrvset', Xrvset, 'MsamplesPhysicalSpace', new_point);
Xin = Xin.add('Xmember', Xs, 'Sname', 'Xs');
Xkriging1 = Xkriging.calibrate('XcalibrationInput', Xin);

%% Optimisation
rng(1) % fix matlab random seed for Monte-Carlo
N = 200; % we will evaluate only 200 points from our objective function
n=1;
while n <= N
    output_points = Xkriging1.XcalibrationOutput.getValues('Sname', 'disp');
    yPlug = min(output_points);

    b_points = 0.05 + (0.3-0.05)*rand(10000,1); % we will generate 1000 points from our metamodel using Monte-Carlo
    h_points = 0.2 + (0.5-0.2)*rand(10000,1);

    points = [b_points, h_points];

    [gpMean, gpStd] = Xkriging1.TdaceModel.predict(points);
    gpVar = sqrt(gpStd);

    inds = gpVar > 10^-16;

    EI = (yPlug-gpMean).*(0.5+0.5*erf((yPlug-gpMean)./(sqrt(2)*gpStd)))+1/sqrt(2*pi)*gpVar.*exp(-(yPlug-gpMean).^2./(2*gpVar.^2));

    EI(~inds) = 0;
    sEI.EI = EI;
    sEI.Inds = inds;

    [maxEI, location] = max(EI);
    display(points(location,:)) % add this point and recalibrate kriging
    new_point = points(location,:);
    Xs = Samples('Xrvset', Xrvset, 'MsamplesPhysicalSpace', new_point);
    Xin = Xin.add('Xmember', Xs, 'Sname', 'Xs');
    Xkriging1 = Xkriging.calibrate('XcalibrationInput', Xin);
    
    n = n + 1;
end

%% Visualization
MXX1 = repmat(linspace(0.05,0.3,201)',1,201);
MXX2 = repmat(linspace(0.2,0.5,201),201,1);
Vx1=MXX1(:); Vx2 = MXX2(:);
Minput = [Vx1,Vx2];
Xs = Samples('Xrvset',Xrvset,'MsamplesPhysicalSpace',Minput);
Xtest = Xtest.add('Xmember', Xs, 'Sname', 'Xs');
Xoutreal = Xmio.run(Xtest);
Xoutkr = Xkriging1.apply(Xtest);
f1 = figure(1);
contourf(MXX1,MXX2,reshape(Xoutreal.getValues('Sname','disp'),201,201));
xlabel('width');
ylabel('height');
zlabel('disp');
f2 =  figure(2);
contourf(MXX1,MXX2,reshape(Xoutkr.getValues('Sname','disp'),201,201));
hold on
improvement_points = Xin.Xsamples.MsamplesPhysicalSpace
scatter(improvement_points(:,1), improvement_points(:,2), 'fill', 'red');
xlabel('width');
ylabel('height');
zlabel('disp');

[minout, locout] = min(output_points)
display(points(locout,:))
[minval, locationval] = min(gpMean)
display(points(locationval,:))
[minerr, locationerr] = min(gpStd)
display(points(locationerr,:))
