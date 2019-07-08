function [Xobj,distanceHyperplane,stateFlag]=searchNearestRoot(Xobj,varargin)

d=varargin{1};
v=varargin{2};


if all(sign(v)==1)
    distanceHyperplane=NaN;
    stateFlag=3;
elseif all(sign(v)==-1)
    distanceHyperplane=NaN;
    stateFlag=4;
else
    
    vneg=v(d<0);
    vpos=v(d>=0);
    
    if all(sign(vpos)==1) || all(sign(vpos)==-1)
        zero_pos=Inf;
    else
        index_1=find(sign(vpos)==-1, 1 );
        if index_1==1
            index_2=find(sign(vpos)==1, 1 );
            x_plus_pos=index_2;
            x_minus_pos=index_2-1;
        else
            x_plus_pos=index_1-1;
            x_minus_pos=index_1;
        end
        x_plus_pos=x_plus_pos+length(vneg);
        x_minus_pos=x_minus_pos+length(vneg);

        if x_plus_pos>x_minus_pos
            dy=v(x_plus_pos)-v(x_minus_pos);
            dx=d(x_plus_pos)-d(x_minus_pos);
            y=abs(v(x_minus_pos));
            x=dx/dy*y;
            zero_pos=d(x_minus_pos)+x;
        else
            dy=v(x_plus_pos)-v(x_minus_pos);
            dx=d(x_minus_pos)-d(x_plus_pos);
            y=abs(v(x_plus_pos));
            x=dx/dy*y;
            zero_pos=d(x_plus_pos)+x;
        end
    end
    
    
    
    if all(sign(vneg)==1) || all(sign(vneg)==-1)
        zero_neg=-Inf;
    else
        if sign(vneg(end))==-1 && sign(vpos(1))==1
            x_minus_neg=length(vneg);
            x_plus_neg=length(vneg)+1;
        elseif sign(vneg(end))==1 && sign(vpos(1))==-1
            x_plus_neg=length(vneg);
            x_minus_neg=length(vneg)+1;
        else
            index_3=find(sign(vneg)==-1, 1, 'last' );
            if index_3==length(vneg)
                index_4=find(sign(vneg)==1,1,'last');
                x_plus_neg=index_4;
                x_minus_neg=index_4+1;
            else
                x_plus_neg=index_3+1;
                x_minus_neg=index_3;
            end
        end
        
        if x_plus_neg>x_minus_neg
            dy=v(x_plus_neg)-v(x_minus_neg);
            dx=d(x_plus_neg)-d(x_minus_neg);
            y=abs(v(x_minus_neg));
            x=dx/dy*y;
            zero_neg=d(x_minus_neg)+x;
        else
            dy=v(x_plus_neg)-v(x_minus_neg);
            dx=d(x_minus_neg)-d(x_plus_neg);
            y=abs(v(x_plus_neg));
            x=dx/dy*y;
            zero_neg=d(x_plus_neg)+x;
        end
    end
    
    midval=(zero_neg+zero_pos)/2;
    if midval>0
        distanceHyperplane=zero_neg;
    else
        distanceHyperplane=zero_pos;
    end
    stateFlag=1;
end