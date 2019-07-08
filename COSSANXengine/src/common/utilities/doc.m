function  doc( varargin )
%HELP Summary of this function goes here
%   Detailed explanation goes here

if isempty(varargin)
    % if no input is given, call the built-in Matlab doc with no arguments
    % (open the built-in matlab doc browser)
    Spwd=pwd;
    cd ([matlabroot,'/toolbox/matlab/helptools/']);
    doc;
    cd (Spwd)
else
    switch (varargin{1})
        %% Help for rv object
        case {'mio'}
            web('http://cossan.cfd.liv.ac.uk/wiki/index.php/%40mio','-browser');
        case {'mio.add','mio/add'}
            web('http://cossan.cfd.liv.ac.uk/wiki/index.php/%40mio','-browser');
        case {'mio.compile','mio/compile'}
            web('http://cossan.cfd.liv.ac.uk/wiki/index.php/Compile%40mio','-browser');
        case {'mio.clear','mio/clear'}
            web('http://cossan.cfd.liv.ac.uk/wiki/index.php/Clear%40mio','-browser');
        case {'mio.get','mio/get'}
            web('http://cossan.cfd.liv.ac.uk/wiki/index.php/Get%40mio','-browser');
        case {'mio.set','mio/set'}
            web('http://cossan.cfd.liv.ac.uk/wiki/index.php/Set%40mio','-browser');
        case {'mio.run','mio/run'}
            web('http://cossan.cfd.liv.ac.uk/wiki/index.php/Run%40mio','-browser');
        case {'mio.run_grid','mio/run_grid'}
            web('http://cossan.cfd.liv.ac.uk/wiki/index.php/Run_grid%40mio','-browser');
        case {'mio.run_grid','mio/run_grid'}
            web('http://cossan.cfd.liv.ac.uk/wiki/index.php/Run_grid%40mio','-browser');
            %% Help for rv object

            %% Help for rvset object

        otherwise
            Spwd=pwd;
            cd ([matlabroot,'/toolbox/matlab/helptools/']);
            doc(varargin{:});
            cd (Spwd)
    end


end

