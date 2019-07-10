%% Tutorial for FUNCTION object
%   This tutorial shows the basics on how to define an object of the class
%   Function and how to evaluate it
%
%
%
% See Also:  http://cossan.co.uk/wiki/index.php/@Function
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author:~Pierre~Beaurepaire$ 

%% First Example
    % Create an input object
    Xin     = Input;
    
    %% Create Parameter object
    Xpar1   = Parameter('value',2);
    % Add parameter to the input
    Xin     = Xin.add('Xmember',Xpar1,'Sname','Xpar1');

    %%  Create Random Variable  and Random Variable Set objects
    Xrv1    = RandomVariable('Sdistribution','normal','mean',0,'std',1);
    Xrvs1   = RandomVariableSet('Cmembers',{'Xrv1'});
    Xin     = Xin.add('Xmember',Xrvs1,'Sname','Xrvs1');

    %% Create Function object
    % This function returns the sum of the random variable 1 plus the values of
    % the paramter
    Xfun1   = Function('Sdescription','function #1', ...
    'Sexpression','<&Xrv1&>+<&Xpar1&>');
    Xin     = Xin.add('Xmember',Xfun1,'Sname','Xfun1');
    
%% Evaluate the Function
% the Input object must be sampled before function evaluation
Xin     = sample(Xin,'Nsamples',3);

%% Evaluate Function 
values  =  evaluate(Xfun1,Xin);
disp(values)

    %% Validate Solutions
    VvaluesRV=Xin.getValues('Sname','Xrv1');
    Vreference=VvaluesRV+2;
    assert(max(Vreference-values)<1e-10,'COSSAN:Tutorial','wrong results')

%%  getMembers
%retrieve the names of all objects that are associated with the Function
%object and their type

[Cmembers Ctypes] = getMembers(Xfun1);
disp(Cmembers)
disp(Ctypes)

%% Second example 
% This second example involves functions that make use of parameters that
% contain array of values 
% 
    %% Create Input
    Xin     = Input;
    
    % Create Parameter objects
    Xpar1   = Parameter('value',2);
    Xpar2   = Parameter('Vvalues',[1 2 3 4]);
    
    % Create Function objects
    Xfunction1 = Function('Sdescription','Target function #1', ...
    'Sexpression','2 * <&Xpar1&>');
    
    % The function can access to a specific value of the parameter object or it
    % can use the entire values of the parameter. Hence, the function returs
    % (when evaluated) a vector that contains the same number of samples present
    % in the input.
    
    Xfunction2 = Function('Sdescription','Target function #2', ...
    'Sexpression','2 * <&Xpar2&>');
    
    % Add objects to input
    Xin     = Xin.add('Xmember',Xpar1,'Sname','Xpar1');
    Xin     = Xin.add('Xmember',Xpar2,'Sname','Xpar2');
    Xin     = Xin.add('Xmember',Xfunction1,'Sname','Xfunction1');
    Xin     = Xin.add('Xmember',Xfunction2,'Sname','Xfunction2');
    
    values1  =  Xfunction1.evaluate(Xin);   
    values2  =  Xfunction2.evaluate(Xin);  

%% Third example: Dependent function
% Create Function object that depends on other function.
Xfunction3   = Function('Sdescription','function #3', ...
    'Sexpression','.2 .* <&Xfunction1&>');

% Evaluate the function
values3  =  Xfunction3.evaluate(Xin);   
disp(values3)

%% Forth example: Multidimensional Function object
% The function can also access a specific value of a multidimensional function.
Xfunction4   = Function('Sdescription','function #2', ...
    'Sexpression','.5 .* <&Xfunction2&>(3)');

% Evaluate the function
values4  =  Xfunction4.evaluate(Xin);   
disp(values4)

%% Fifth exmple
    %   Create Input
    Xin     = Input;
    
    %   Create Parameter object
    Xpar1   = Parameter('Vvalues',[2;3]);
    Xpar2   = Parameter('Mvalues',[1 2 ; 3 4]);
    Xin     = Xin.add('Xmember',Xpar1,'Sname','Xpar1');
    Xin     = Xin.add('Xmember',Xpar2,'Sname','Xpar2');
    
    %Create Function object
    Xfun1   = Function('Sdescription','function #1', ...
    'Sexpression','2 .* <&Xpar1&>(2)');
    
    % Input object needn't to be sampled before function evaluation because it
    % does not contains random variables
    values1  =  evaluate(Xfun1,Xin);
    % show the results
    disp(values1)


    %%  Function operation elements of multidimensional Parameters
    Xfun3   = Function('Sdescription','function #3', ...
    'Sexpression','<&Xpar2&>(2) .*<&Xpar1&>(1)');
    values3  =  evaluate(Xfun3,Xin);
    
    % show the results
    disp(values3)


