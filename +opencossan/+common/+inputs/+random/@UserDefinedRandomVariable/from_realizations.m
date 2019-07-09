function obj = from_realizations(obj)
%USERDEFINED compute missing parameters (if is possible) of the userdefined
%                       distribution
% Input/Output is the structure of the random variable

    %{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2019 COSSAN WORKING GROUP

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

    %Use ksdensity to find pdf
    
    [empir,sampleSupport] = ecdf(obj.data);
 
    if obj.Smoothing       
        % Number of support points defined in object
        dif = ( sampleSupport(end) - sampleSupport(1) ) / obj.NsupportPoints;
        support = [sampleSupport(1):dif:sampleSupport(end)];    
        pdf = ksdensity(obj.data, support);
        cdf = ksdensity(obj.data,support, 'FUNCTION','cdf');
    else
        pdf= ksdensity(obj.data,support1);
        support = sampleSupport;
        cdf = empir;
    end
    
    obj.pdf = pdf;
    obj.cdf = cdf;
    obj.support = support;

end


