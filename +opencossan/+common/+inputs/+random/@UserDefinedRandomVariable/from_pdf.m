function obj = from_pdf(obj)
%PDF compute missing parameters (if is possible) of the userdefined
    
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


    cdf = zeros(length(obj.support),1);
    %Integrate to produce cdf
    for i=2:length(cdf)
        cdf(i)=trapz(obj.support(1:i),obj.pdf(1:i)); 
    end
    obj.cdf = cdf;

    %approximate the mean and std
    samples = obj.sample(obj.NsampleFit);
    
    obj.data = samples;
end