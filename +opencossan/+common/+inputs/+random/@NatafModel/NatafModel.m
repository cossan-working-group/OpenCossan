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
            for i = 1:rvset.Nrv
                for j = i+1:rvset.Nrv
                    tmp = NaN;
                    rij = rvset.Correlation(i,j);
                    if ~rij; continue; end
                    if isa(rvset.Members(i), ...
                            'opencossan.common.inputs.random.NormalRandomVariable')
                        % N-LN
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.LognormalRandomVariable')
                            tmp = rvset.Members(j).CoV / sqrt(log(1 + rvset.Members(j)^2));
                        end
                        % N-WEI
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.WeibullRandomVariable')
                            tmp = rvset.Members(j).CoV / sqrt(log(1 + rvset.Members(j)^2));
                        end
                        % N-U
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.UniformRandomVariable')
                            tmp = 1.023;
                        end
                        % N-EXP
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.ExponentialRandomVariable')
                            tmp = 1.107;
                        end
                        % N-RAY
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.RayleighRandomVariable')
                            tmp = 1.014;
                        end
                        % N-SML
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.SmallIRandomVariable')
                            tmp = 1.031;
                        end
                        % N-LAR
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.LargeIRandomVariable')
                            tmp = 1.107;
                        end
                    elseif isa(rvset.Members(i), ...
                            'opencossan.common.inputs.random.LognormalRandomVariable')
                        % LN-LN
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.LognormalRandomVariable')
                            tmp = log(1 + rij * rvset.Members(i).CoV * rvset.Members(j).CoV) / ...
                                (rij * sqrt(log(1 + rvset.Members(i).CoV^2) * log(1 + rvset.Members(j).CoV^2)));
                        end
                        % LN-WEI
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.WeibullRandomVariable')
                            cov_i = rvset.Members(i).CoV;
                            cov_j = rvset.Members(j).CoV;
                            tmp = 1.026 + 0.082 * rij - 0.019 * cov_i + 0.222 * cov_j ...
                                + 0.018 * rij^2 + 0.288 * cov_i^2 + 0.379 * cov_j^2 ...
                                -0.441 * rij * cov_i + 0.126 * cov_i * cov_j^2 - 0.277 * rij * cov_j;
                        end
                    elseif isa(rvset.Members(i), ...
                            'opencossan.common.inputs.random.UniformRandomVariable')
                        % U-U
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.UniformRandomVariable')
                            tmp = 1.047 - 0.047 * rij^2;
                        end
                        % U-LN
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.LognormalRandomVariable')
                            tmp = 1.019 + 0.010 * rij ^2 +...
                                0.014 * rvset.Members(j).CoV + ...
                                0.249 * rvset.Members(j).CoV^2;
                        end
                        % U-WEI
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.WeibullRandomVariable')
                            tmp = 1.033 + 0.305 * rvset.Members(j).CoV ...
                                + 0.074*rij^2 + 0.405 * rvset.Members(j).CoV^2;
                        end
                    elseif isa(rvset.Members(i), ...
                            'opencossan.common.inputs.random.ExponentialRandomVariable')
                        % EXP-EXP
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.ExponentialRandomVariable')
                            tmp = 1.229 - 0.367 * rij + 0.153* rij^2;
                        end
                        % EXP-U
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.UniformRandomVariable')
                            tmp = 1.133 + 0.029 * rij^2;
                        end
                        % EXP-LN
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.LognormalRandomVariable')
                            tmp = 1.098 + 0.003 * rij + ...
                                0.019 * rvset.Members(j).CoV + ...
                                0.025 * rij^2 + ...
                                0.303 * rvset.Members(j).CoV ^2 - ...
                                0.437 * rvset.Members(j).CoV * rij;
                        end
                        % EXP-RAY
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.ExponentialRandomVariable')
                            tmp = 1.123 - 0.100 * rij + 0.021 * rij ^2;
                        end
                        % EXP-WEI
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.WeibullRandomVariable')
                            tmp = 1.109 - 0.152 * rij + 0.361 * rvset.Members(j).CoV ...
                                + 0.13 * rij^2 + 0.455 * rvset.Members(j).CoV^2 - 0.728 * rij * rvset.Members(j).CoV;
                        end
                    elseif isa(rvset.Members(i), ...
                            'opencossan.common.inputs.random.RayleighRandomVariable')
                        % RAY-RAY
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.RayleighRandomVariable')
                            tmp = 1.028 - 0.029 * rij;
                        end
                        % RAY-LN
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.LognormalRandomVariable')
                            tmp = 1.011 + 0.001 * rij + ...
                                0.014 * rvset.Members(j).CoV + ...
                                0.004 * rij^2 + ...
                                0.231 * rvset.Members(j).CoV^2 - ...
                                0.130 * rvset.Members(j).CoV * rij;
                        end
                        % RAY-U
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.UniformRandomVariable')
                            tmp = 1.038 + 0.008 * rij ^2;
                        end
                        % RAY-WEI
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.WeibullRandomVariable')
                            tmp = 1.036 - 0.038*rij +.266 * rvset.Members(j).CoV ...
                                + 0.028 * rij^2 + 0.383 * rvset.Members(j).CoV^2 -0.229 * rij * rvset.Members(j).CoV;
                        end
                    elseif isa(rvset.Members(i), ...
                            'opencossan.common.inputs.random.SmallIRandomVariable')
                        % SML-SML
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.SmallIRandomVariable')
                            tmp = 1.064 - 0.069 * rij + 0.005 * rij^2;
                        end
                        % SML-EXP
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.ExponentialRandomVariable')
                            tmp = 1.142 + 0.154 * rij + 0.031 * rij ^2;
                        end
                        % SML-U
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.UniformRandomVariable')
                            tmp = 1.055 + 0.015* rij ^2;
                        end
                        % SML-LN
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.LognormalRandomVariable')
                            tmp = 1.029 - 0.001 * rij + ...
                                0.014 * rvset.Members(j).CoV + ...
                                0.004 * rij^2 + ...
                                0.233 * rvset.Members(j).CoV^2 + ...
                                0.197 * rvset.Members(j).CoV * rij;
                        end
                        % SML-RAY
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.RayleighRandomVariable')
                            tmp = 1.046 + 0.045 * rij + 0.006 * rij ^2;
                        end
                        % SML-LAR
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.LargeIRandomVariable')
                            tmp = 1.064 + 0.069 * rij + 0.005 * rij^2;
                        end
                        % SML-WEI
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.WeibullRandomVariable')
                            tmp = 1.056 + 0.06 * rij + 0.263 * rvset.Members(j).CoV^2 ...
                                + 0.02 * rij^2 + 0.383 * rvset.Members(j).CoV^2 + 0.322 * rij * rvset.Members(j).CoV^2;
                        end
                    elseif isa(rvset.Members(i), ...
                            'opencossan.common.inputs.random.LargeIRandomVariable')
                        % LAR-LAR
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.LargeIRandomVariable')
                            tmp = 1.064 - 0.069 * rij + 0.005 * rij^2;
                        end
                        % LAR-RAY
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.RayleighRandomVariable')
                            tmp = 1.046 - 0.045 * rij + 0.006 * rij ^2;
                        end
                        % LAR-EXP
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.ExponentialRandomVariable')
                            tmp = 1.142 - 0.154 * rij + 0.031 * rij ^2;
                        end
                        % LAR-U
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.UniformRandomVariable')
                            tmp = 1.055 + 0.015 * rij ^2;
                        end
                        % LAR-LN
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.LognormalRandomVariable')
                            tmp = 1.029 + 0.001 * rij +...
                                0.014 * rvset.Members(j).CoV +...
                                0.004 * rij^2 +...
                                0.233 * rvset.Members(j).CoV^2 - ...
                                0.197 * rvset.Members(j).CoV * rij;
                        end
                        % LAR-LN
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.WeibullRandomVariable')
                            tmp = 1.056 - 0.06 * rij + ...
                                0.263 * rvset.Members(j).CoV + ...
                                0.02 * rij^2 + ...
                                0.383 * rvset.Members(j).CoV^2 - ...
                                0.322 * rij * rvset.Members(j).CoV;
                        end
                    elseif isa(rvset.Members(i), ...
                            'opencossan.common.inputs.random.WeibullRandomVariable')
                        % WEI-WEI
                        if isa(rvset.Members(j), ...
                                'opencossan.common.inputs.random.WeibullRandomVariable')
                            cov_i = rvset.Members(i).CoV;
                            cov_j = rvset.Members(j).CoV;
                            tmp = 1.086 + 0.054 * rij + 0.104 * (cov_i + cov_j) ...
                                -0.055 * rij^2 + 0.662 * (cov_i^2 + cov_j^2) ...
                                -0.57 * rij * (cov_i + cov_j) + 0.203 * (cov_i * cov_j) ...
                                -0.02 * rij^3 - 0.218 * (cov_i^3 + cov_j^3) ...
                                -0.371 * rij * (cov_i^2 + cov_j^2) + 0.257 * rij^2 * (cov_i + cov_j) ...
                                +0.141 * (cov_i + cov_j) * cov_i * cov_j;
                        end
                    else
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
            
            [eigvecs, eigvals] = eig(obj.Correlation);
            
            Vipos = find(diag(eigvals) > 0);
            
            assert(length(Vipos) == rvset.Nrv, ...
                'OpenCOSSAN:NatafModel', ...
                ['There are ' num2str(rvset.Nrv - length(Vipos)) ' negative eigenvalues!'])
            
            obj.MUY = eigvecs * sqrt(eigvals);
            obj.MYU = obj.MUY^(-1);
        end
    end
end
