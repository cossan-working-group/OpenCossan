function Tsim=LS_linepf(Tsim,Toptions)	

% Private function of the Linesampling method.
% It is used to calculated the Failure Probability of Individual Line 
% and update the pf

%%   Interpolation of Performance Function in grid 'Tsim.Vcfine'
	% approximate the function in the surrounding of the limit state
	% function

Tsim.Vg_fine   = interp1(Tsim.Vset,Tsim.Vg,Tsim.Vcfine,'spline');
	

Tsim.Vlimits=[];% reset variables

		Tsim.Vgradient=sign(Tsim.Vg_fine(1));
		for iz=2:length(Tsim.Vg_fine)
			if (Tsim.Vgradient(end)<0 && Tsim.Vg_fine(iz)>0) || (Tsim.Vgradient(end)>0 && Tsim.Vg_fine(iz)<0)
				% new intersection idenfied (from failure domain to safe
				% domain with gradient >0 and from save to failure with
				% gradient <0
				%Tsim.Clast=sign(Tsim.Vg_fine(iz));
				Tsim.Vlimits=[Tsim.Vlimits Tsim.Vcfine(iz)];
				if length(Tsim.Vlimits)==1
					Tsim.Vgradient=sign(Tsim.Vg_fine(iz));
				else
					Tsim.Vgradient=[Tsim.Vgradient sign(Tsim.Vg_fine(iz))];
				end
			end
		end
		if (Tsim.Vg_fine(end)<0)
			Tsim.reliabilityIndex=min(Tsim.Vcfine(Tsim.Vg_fine<0));
		else
			Tsim.reliabilityIndex=max(Tsim.Vcfine(Tsim.Vg_fine<0));
		end


			if (Tsim.reliabilityIndex>max(Tsim.Vset))
				OpenCossan.cossanDisp(['Warning: limit state function > max(Vset) | ' num2str(Tsim.reliabilityIndex) ' ' num2str(max(Tsim.Vset))]);
			end
			if (Tsim.reliabilityIndex<min(Tsim.Vset))
				OpenCossan.cossanDisp(['Warning: limit state function < min(Vset) | ' num2str(Tsim.reliabilityIndex) ' ' num2str(min(Tsim.Vset))]);
			end

			if isempty(Tsim.reliabilityIndex) && Toptions.Lverbose
				OpenCossan.cossanDisp('The interpolator has not found the intersection with the limit state function');
			end

			
	% Compute the pf for each line
	if (Toptions.Lenhanced)
		if ~isempty(Tsim.Vlimits)
			if Toptions.Lverbose
				OpenCossan.cossanDisp([num2str(length(Tsim.Vlimits)) ' intersection found' ]);
			end
			Tsim.Vpf_elem(Tsim.iline)=sum(normcdf(Tsim.Vlimits).*sign(Tsim.Vgradient));

			if sign(Tsim.Vgradient(find(min(Tsim.Vlimits))))==-1 %#ok<FNDSB>
				Tsim.Vpf_elem(Tsim.iline)=Tsim.Vpf_elem(Tsim.iline)+1;
			end

			if Tsim.Vpf_elem(Tsim.iline)<0  % only for debugging
				warning('openCOSSAN:probmodel:linesampling','pf error');  % only for debugging
                %TODO: explain the error
                OpenCossan.cossanDisp(Tsim.Vpf_elem(Tsim.iline));
                OpenCossan.cossanDisp(Tsim.Vpf_elem(Tsim.iline));
			end
		else
			if all(Tsim.Vg>0)
				Tsim.Vpf_elem(Tsim.iline)=0;
			elseif all(Tsim.Vg<0)
				Tsim.Vpf_elem(Tsim.iline)=1;
			else
				OpenCossan.cossanDisp('LS:ERROR: intersection with the lsf!');
			end
		end
	else     % only for debugging(Tsim.Ndist)
		if isempty(Tsim.reliabilityIndex)
			if Toptions.Lverbose
				OpenCossan.cossanDisp(['no limit state function found (line= ' num2str(Tsim.iline) ')']);
			end
			Tsim.Vpf_elem(Tsim.iline)=0;
		else
			if Tsim.Vgradient(end)>0
				Tsim.Vpf_elem(Tsim.iline)=normcdf(Tsim.reliabilityIndex);
			else
				Tsim.Vpf_elem(Tsim.iline)=normcdf(-Tsim.reliabilityIndex);
			end
		end
	end
	
		%3.5.     Failure Probability and coefficient of variation (Output results)
	Tsim.pfhat = mean(Tsim.Vpf_elem(1:Tsim.iline));
	Tsim.CoV  =  sqrt(sum((Tsim.Vpf_elem(1:Tsim.iline)-Tsim.pfhat).^2) ...
		/(Tsim.iline*(Tsim.iline-1)))/Tsim.pfhat;

	%Confidence Level based on Chebyshev's inequality
	epsilon = 1 / (1-Toptions.confLevel) * sqrt(Tsim.pfhat*(1-Tsim.pfhat) ) / sqrt(Tsim.Nsamples);
	Tsim.TConfInt.confLevel = Toptions.confLevel;
	Tsim.TConfInt.Vinterval = [max([Tsim.pfhat-epsilon 0]) Tsim.pfhat+epsilon];
