function pdf = pdf(obj, samples)
    %EVALPDF Evaluates the multidimensional probability density of a set of
    %points in the physiscal space.
    %
    % See also: https://cossan.co.uk/wiki/index.php/evalpdf@RandomVariableSet
    %
    % Author: Edoardo Patelli
    % Institute for Risk and Uncertainty, University of Liverpool, UK
    % email address: openengine@cossan.co.uk
    % Website: http://www.cossan.co.uk
    
    %{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2018 COSSAN WORKING GROUP

    OpenCossan is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License or,
    (at your option) any later version.

    OpenCossan is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
    %}

    validateattributes(samples, {'table'}, {});
    
    pdf = table();
    
    for i = 1:obj.Nrv
        pdf.(obj.Names(i)) = obj.Members(i).evalpdf(samples.(obj.Names(i)));
    end
    
    % in case rv's are not independent, calculate correction coefficient for pdf this correction
    % factor accounts for the correlations between random variables; for details on the theory,
    % please see P. Liu & A. Der Kiureghian. Multivariate distribution models with prescribed
    % marginals and covariances. Probabilistic Engineering Mechanics 1(2),105-112
    
    if (~obj.isIndependent())
        MY = obj.map2stdnorm(samples);
        
        correction = mvnpdf(MY{:, obj.Names}, [], obj.NatafModel.Correlation) ./ prod(normpdf(MY{:, obj.Names}), 2);
    else
        correction = 1; % no correction is required, as the rv's are independent
    end
    
    pdf   = prod(pdf{:, obj.Names}, 2) .* correction;
end
