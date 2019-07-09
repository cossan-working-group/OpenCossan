function Toutput = preprocessing( Tinput )
%PREPROCESSING this function defines quantities which are compatible with
%the parametric FE model


%% 1. memory allocation
Cpreallocate=num2cell(zeros(length(Tinput),1));
Toutput=struct('ActualRadius1',Cpreallocate,'XcoorCentre1',Cpreallocate,'YcoorCentre1',Cpreallocate,...
    'ActualRadius2',Cpreallocate,'XcoorCentre2',Cpreallocate,'YcoorCentre2',Cpreallocate,...
    'ActualRadius3',Cpreallocate,'XcoorCentre3',Cpreallocate,'YcoorCentre3',Cpreallocate,...
    'DistanceHoleEdge1',Cpreallocate,'DistanceHoleEdge2',Cpreallocate,'DistanceHoleEdge3',Cpreallocate,...
    'DistanceHoleHole12',Cpreallocate,'DistanceHoleHole23',Cpreallocate,'DistanceHoleHole13',Cpreallocate);





%% 2. quantities defining the geometry
% in the following, the vertex of the edges of the central hollow section
% are provided, and also the centre line of the structure is computed

% coordinates of the points at the bottom of the hollow section
Mpt_bot = [   68.9000   42.9600
    134.8300  210.8500
    147.7600  232.8900
    170.2000  249.0800
    205.0300  267.8600
    229.8700  278.0900
    248.4400  285.3700
    290.9500  295.2100
    308.8800  298.0200
    333.9000  299.6600];

% coordinates of the points at the top of the hollow section
Mpt_top = [  333.9000  320.6500
    297.5000  322.4000
    274.4900  320.8500
    235.4800  314.1400
    198.2600  302.4400
    149.0900  281.4200
    118.0000  267.8000
    85.5300  249.2200
    68.4200  196.5100
    38.1400   51.6700];

% coordinates of all the points of the hollow section
% Mpt_in is the array of all the vertexes used in order to create the geometry
Mpt_in = [Mpt_bot; Mpt_top];

% renumbering
Mpt_top = Mpt_top(end:-1:1,:);


% the points at the centre line of the structure are determined
Vdist_bot=zeros(length(Mpt_bot),1);
Vdist_top=zeros(length(Mpt_top),1);
Vdist_bot_cumul=zeros(length(Mpt_bot),1);
Vdist_top_cumul=zeros(length(Mpt_top),1);
for i=2:length(Vdist_bot)
    Vdist_bot(i) = sqrt((Mpt_bot(i,1)-Mpt_bot(i-1,1)).^2 + (Mpt_bot(i,2)-Mpt_bot(i-1,2)).^2);
end
for i=2:length(Vdist_top)
    
    Vdist_top(i) = sqrt((Mpt_top(i,1)-Mpt_top(i-1,1)).^2 + (Mpt_top(i,2)-Mpt_top(i-1,2)).^2);
    
end
for i=2:length(Vdist_bot_cumul)
    
    Vdist_bot_cumul(i) = Vdist_bot_cumul(i-1)+  Vdist_bot(i) ;
    
end
for i=2:length(Vdist_top_cumul)
    
    Vdist_top_cumul(i) = Vdist_top_cumul(i-1)+  Vdist_top(i) ;
    
end

Vgridtop=0:Vdist_top_cumul(end)/100:Vdist_top_cumul(end);

Vgridbot=0:Vdist_bot_cumul(end)/100:Vdist_bot_cumul(end);

Vout_bot=findcoor(Vgridbot,Mpt_bot,Vdist_bot, Vdist_bot_cumul);
Vout_top=findcoor(Vgridtop,Mpt_top,Vdist_top, Vdist_top_cumul);

% coordinates of the points on the centre line of the structure
Mmid = 0.5*(Vout_bot+Vout_top);



%% 3. main loop of the mio

% factor used in order to have the same order of magnitude of the bounds of
% the design variables
mult_factor = 10;

for iMainLoop=1:length(Tinput)
    
    %3.1 centre of the holes
    % retrieve the abscissa of the centre of the holes
    l1=Tinput(iMainLoop).Abscissa1;
    l2=Tinput(iMainLoop).Abscissa2;
    l3=Tinput(iMainLoop).Abscissa3;
    
    
    VcoorCentre1 = findcoor(l1, Mmid,[],[]);
    VcoorCentre2 = findcoor(l2, Mmid,[],[]);
    VcoorCentre3 = findcoor(l3, Mmid,[],[]);
    
    
    
    Toutput(iMainLoop).XcoorCentre1 = VcoorCentre1(1);
    Toutput(iMainLoop).YcoorCentre1 = VcoorCentre1(2);
    Toutput(iMainLoop).XcoorCentre2 = VcoorCentre2(1);
    Toutput(iMainLoop).YcoorCentre2 = VcoorCentre2(2);
    Toutput(iMainLoop).XcoorCentre3 = VcoorCentre3(1);
    Toutput(iMainLoop).YcoorCentre3 = VcoorCentre3(2);
    
    
    
    %3.2 actual radius of the holes
    distanceNearestEdge1 = distancePointAllLines( l1 );
    distanceNearestEdge2 = distancePointAllLines( l2 );
    distanceNearestEdge3 = distancePointAllLines( l3 );
    
    
    
    if Tinput(iMainLoop).NormalizedRadius1/mult_factor >distanceNearestEdge1-.5
        Toutput(iMainLoop).ActualRadius1 = (distanceNearestEdge1-.5);
    else
        Toutput(iMainLoop).ActualRadius1 = Tinput(iMainLoop).NormalizedRadius1/mult_factor;
    end
    
    if Tinput(iMainLoop).NormalizedRadius2/mult_factor >distanceNearestEdge2-.5
        Toutput(iMainLoop).ActualRadius2 = (distanceNearestEdge2-.5);
    else
        Toutput(iMainLoop).ActualRadius2 = Tinput(iMainLoop).NormalizedRadius2/mult_factor;
    end
    
    if Tinput(iMainLoop).NormalizedRadius3/mult_factor >distanceNearestEdge3-.5
        Toutput(iMainLoop).ActualRadius3 = (distanceNearestEdge3-.5);
    else
        Toutput(iMainLoop).ActualRadius3 = Tinput(iMainLoop).NormalizedRadius3/mult_factor;
    end
    
    
    %3.3 distance between the holes and the nearest edge
    Toutput(iMainLoop).DistanceHoleEdge1 = distanceNearestEdge1-.5;
    Toutput(iMainLoop).DistanceHoleEdge2 = distanceNearestEdge2-.5;
    Toutput(iMainLoop).DistanceHoleEdge3 = distanceNearestEdge3-.5;
    
    
    
    % 3.4 distance between the holes
    Toutput(iMainLoop).DistanceHoleHole12 = sqrt((VcoorCentre2(1)-VcoorCentre1(1))^2 + (VcoorCentre2(2)-VcoorCentre1(2))^2) -  Tinput(iMainLoop).NormalizedRadius2/mult_factor - Tinput(iMainLoop).NormalizedRadius1/mult_factor+5;
    Toutput(iMainLoop).DistanceHoleHole13 = sqrt((VcoorCentre3(1)-VcoorCentre1(1))^2 + (VcoorCentre3(2)-VcoorCentre1(2))^2) -  Tinput(iMainLoop).NormalizedRadius3/mult_factor - Tinput(iMainLoop).NormalizedRadius1/mult_factor+5;
    Toutput(iMainLoop).DistanceHoleHole23 = sqrt((VcoorCentre3(1)-VcoorCentre2(1))^2 + (VcoorCentre3(2)-VcoorCentre2(2))^2) -  Tinput(iMainLoop).NormalizedRadius3/mult_factor - Tinput(iMainLoop).NormalizedRadius2/mult_factor+5;

    
end % end of themain loop of the mio



%% 4. Additionnal functions

    function Vout= findcoor(l, Mcoor,Vdist,Vdistcum)
        % Determines the coordinates of a point defined by its curviliear
        % abscissa 
        % * l is the distance on the curv. absiscissa 
        % * Mcoor is a matrix containing the coordinates of all the points
        % defining a curve (it is of dimension 2)
        % * Vist and Vdistcum are optional arguments, they indicate the
        % distance and cumulated distance between points of Mcoor
        % Vout is a vector containing the coordinates of the point of
        % interest
        Vout = zeros(length(l),2);
        for j=1:length(l)
            
            if isempty(Mcoor)
                error('Mcoor must not be empty')
            end
            
            % compute missing info if necessary
            if isempty(Vdist)
                Vdist=zeros(length(Mcoor),1);
                Vdistcum=zeros(length(Mcoor),1);
                for i1=2:length(Vdist)
                    
                    Vdist(i1) = sqrt((Mcoor(i1,1)-Mcoor(i1-1,1)).^2 + (Mcoor(i1,2)-Mcoor(i1-1,2)).^2);
                end
                for i1=2:length(Vdistcum)
                    Vdistcum(i1) = Vdistcum(i1-1)+  Vdist(i1) ;
                end
            end
            
            if isempty(Vdistcum)
                Vdistcum=zeros(length(Mcoor),1);
                for i1=2:length(Vdistcum)
                    Vdistcum(i1) = Vdistcum(i1-1)+  Vdist(i1) ;
                end
            end
            
            % find the last point with smaller curvilinear abscissa
            my_index = find(Vdistcum<+l(j),1,'last');
            
            % interpolation on the next segment
            if ~isempty(my_index)
                remain_dist = l(j)-Vdistcum(my_index);
                Vout(j,:) = Mcoor(my_index,:)+remain_dist/Vdist(my_index+1)*( Mcoor(my_index+1,:)- Mcoor(my_index,:));
            else
                Vout(j,:) = Mcoor(1,:);
            end
        end
        
        
    end

    function [ Vdist, VLisOnSegment  ] = distancePointLine( Vpoint,Mline )
        % distancePointLine determines the distance between a point (defined by
        % its coordinates) and a set of lines (each line is defined by the coordinates of two points laying on the line)
        % A vector of boolean is also returned in order to indicate whether for each line
        % the projection of the point of interest is on the segment of the inpout points
        % Vpoint: coordinates of the point of interest, defined as [x_P y_P]
        % coordinates of two points defining the line of interest, defined as [x_A1 y_A1 x_B1 y_B1 ; x_A2 y_A2 x_B2 y_B2]
        % Vdist contains the distance between the point and the line
        
        
        Vdist = zeros(size(Mline,1),1);
        VLisOnSegment =  ones(size(Mline,1),1)*(1==2);
        
        x_P = Vpoint(1);
        y_P = Vpoint(2);

        for iLine = 1:size(Mline,1)
            
            
            %coordinates of the two points defining the line of interest
            x_A = Mline(iLine,1);
            y_A = Mline(iLine,2);
            x_B = Mline(iLine,3);
            y_B = Mline(iLine,4);
            
            %% computing the distance between P and (AB)
            % case 1: the straight line does not pass through the origin
            if x_A*y_B ~= x_B*y_A
                
                X = [x_A y_A; x_B y_B];
                
                Vpara = X^-1 * [-1 -1]';
                a=Vpara(1); b=Vpara(2);c=1;
                % case 2: the straight line passes through the origin
            else
                a=-y_A;
                b=x_A;
                c=0;
                
            end
            % a b c the params defining the straight line of interest
            
            % distance between the point and the line
            distance = abs(a*x_P + b*y_P + c )/sqrt(a^2 + b^2);
            
            
            %% determining whether the projection of P in the seg [AB]
            
            Vect_ab = [x_B - x_A ; y_B - y_A];
            Vect_ap = [x_P - x_A ; y_P - y_A];
            
            indicator = sum(Vect_ab.*Vect_ap)/(sum(Vect_ab.^2));
            
            
            % 'export results'
            VLisOnSegment(iLine) = (indicator>= 0) &  (indicator<= 1);
            Vdist(iLine)=distance;
            
            
        end
    end

    function [distance, Vpoint ] = distancePointAllLines( l )
        % distancePointAllLines determines the distance between one point
        % in the web of the structure and all the the edges of the flanges
        
        Vpoint = findcoor(l,Mmid,[],[]);
        
        Vline = zeros(size(Mpt_in,1),4);
        
        for i3=1:size(Mpt_in,1)-1
            Vline(i3,:) = [Mpt_in(i3,:) Mpt_in(i3+1,:)];
        end
        Vline(end,:) = [Mpt_in(end,:) Mpt_in(1,:)];
        
        
        [ Vdist, Vvalid  ] = distancePointLine( Vpoint,Vline );
        
        
        VdistOk = Vdist(Vvalid==1);
        
        distance = min(VdistOk);
        
    end


end % end of the mio
