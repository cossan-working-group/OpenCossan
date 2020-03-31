classdef NatafModel
    %NATAFMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
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
    
    properties
        Correlation;
        Covariance;
        MUY;
        MYU;
    end
    
    properties (Constant)
        CopulaBatches = 20;
        CopulaSamples = 15000;
    end
    
    methods
        function obj = NatafModel(rvset)
            factors = ones(rvset.Nrv);
            for i = 1:rvset.Nrv-1
                for j = i+1:rvset.Nrv
                    rij = rvset.Correlation(i,j);
                    if ~rij; continue; end
                    switch class(rvset.Members(i))
                        case 'opencossan.common.inputs.random.NormalRandomVariable'
                            tmp = obj.normalCorrectionFactors(rvset.Members(j));
                        case 'opencossan.common.inputs.random.LognormalRandomVariable'
                            tmp = obj.lognormalCorrectionFactors(rvset.Members(i), rvset.Members(j), rij);
                        case 'opencossan.common.inputs.random.UniformRandomVariable'
                            tmp = obj.uniformCorrectionFactors(rvset.Members(j), rij);
                        case 'opencossan.common.inputs.random.ExponentialRandomVariable'
                            tmp = obj.exponentialCorrectionFactors(rvset.Members(i), rvset.Members(j), rij);
                        case 'opencossan.common.inputs.random.RayleighRandomVariable'
                            tmp = obj.rayleighCorrectionFactors(rvset.Members(j), rij);
                        case 'opencossan.common.inputs.random.SmallIRandomVariable'
                            tmp = obj.smallICorrectionFactors(rvset.Members(j), rij);
                        case 'opencossan.common.inputs.random.LargeIRandomVariable'
                            tmp = obj.largeICorrectionFactors(rvset.Members(j), rij);
                        case 'opencossan.common.inputs.random.WeibullRandomVariable'
                            tmp = obj.weibullCorrectionFactors(rvset.Members(i), rvset.Members(j), rij);
                        otherwise
                            %% Distributions without analytical formulas
                            s = 0;
                            
                            for k = 1:obj.CopulaBatches
                                u = copularnd('gaussian', rij, obj.CopulaSamples);
                                
                                gauss = norminv(u,0,1);
                                
                                x(:,1) = rvset.Members(i).cdf2physical(u(:,1));
                                x(:,2) = rvset.Members(j).cdf2physical(u(:,2));
                                
                                rho_g = corr(gauss);
                                v = rij/rho_g(1,2);
                                
                                rho_l = corr(x);
                                rho_l(1,2) = rho_l(1,2)*v;
                                
                                rij = rij * rvset.Correlation(i,j)/rho_l(1,2);
                                if abs(rij) < abs(rvset.Correlation(i,j))
                                    rij = rvset.Correlation(i,j);
                                elseif rij < -0.999
                                    rij = -0.999;
                                elseif rij > 0.999
                                    rij = 0.999;
                                end
                                s = s + rij;
                            end
                            
                            tmp = s/(obj.CopulaBatches*rvset.Correlation(i,j));
                    end
                    if ~isnan(tmp)
                        factors(i,j) = tmp;
                        factors(j,i) = tmp;
                    end
                end
            end
            
            obj.Correlation = rvset.Correlation .* factors;
            obj.Covariance = rvset.getStd() * rvset.getStd()' .* obj.Correlation;
            
            
            obj.MUY = chol(obj.Correlation, 'lower');
            obj.MYU = inv(obj.MUY);
        end
    end
end
