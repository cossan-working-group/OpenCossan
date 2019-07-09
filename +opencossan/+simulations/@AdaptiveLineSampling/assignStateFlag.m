function varargout=assignStateFlag(Xobj,Vd,Vg,iLine,Valpha,Vlhp)

if isa(Xobj,'opencossan.simulations.AdaptiveLineSampling') || isa(Xobj,'opencossan.simulations.LineSampling')
    if iLine == 0 % line through the origin or zero-line
        % Assign the state flags
        if sign(Vg(1))==1 && sign(Vd(end))==1
            stateFlag=1; % State boundary met regularly after some iterations
        elseif sign(Vg(1))==1 && sign(Vd(end))==-1
            stateFlag=1; % State boundary met after some iterations on the direction opposite to Valpha
        elseif sign(Vg(1))==-1 && sign(Vd(end))==1
            stateFlag=2; % State boundary met regularly after some iterations
        elseif sign(Vg(1))==-1 && sign(Vd(end))==-1
            stateFlag=2; % State boundary met on the negative half-space on the direction opposite to Valpha
        end
    else
        if abs(sum(sign(Vg)))<=length(Vg)
            [~,sd]=sort(abs(Vd));
            % coordinates of the closest point
            Point_i = Vlhp+Valpha*Vd(sd(1));
            % coordinates of the farthest point
            Point_k = Vlhp+Valpha*Vd(sd(end));
            % if the lineOrientation is negative the line is oriented opposite
            % to the important direction
            lineOrientation = ((Point_k - Point_i)/norm(Point_k - Point_i))'*Valpha(:);
            % if the hyperplane point lies on the failure region unlike the
            % zero-line the following sign is negative
            signOfGradient = -sign(Vg(sd(end))-Vg(sd(1)));
            if lineOrientation==1 || signOfGradient==1
                stateFlag=1; % line is oriented as the important direction and origin is in safe domain: state boundary met regularly and pf < 0.5
            elseif lineOrientation==1 || signOfGradient==-1
                stateFlag=2; % line is oriented as the important direction and origin is in fail domain: state boundary met regularly and pf > 0.5
            elseif lineOrientation==-1 || signOfGradient==1
                stateFlag=2; % line is oriented opposite to the important direction and origin is in safe domain: state boundary met the other way roundy and pf < 0.5
            elseif lineOrientation==-1 || signOfGradient==-1
                stateFlag=1; % line is oriented opposite to the important direction and origin is in fail domain: state boundary met the other way roundy and pf > 0.5
            end
        else
            % it must not get in here because of the way it is called by lineSearch
        end
    end
end
varargout{1}=stateFlag;