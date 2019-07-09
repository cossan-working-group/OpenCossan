
Nl1=3; 
Nl2=3;

%survival signature
Phi=ones(Nl1,Nl2);

% time step 
t=0:0.1:2;

A=0:Nl1-1;
B=0:Nl2-1;
At=zeros(Nl1,length(t));
Bt=zeros(Nl2,length(t));

for j=1:Nl1
    At(j,:)=A(j)*t;% this is only one example
end

for j=1:Nl2
    Bt(j,:)=B(j)*t;
end


% probability of ...
P=zeros(1,length(t));

for jl1=1:Nl1
    for jl2=1:Nl2
        P=P+Phi(jl1,jl2)*At(jl1,:).*Bt(jl2,:);
    end
end


figure
plot(t,P);
xlabel('time')
ylabel('Probability of ')


% 
% 
% % what is s
% s=zeros(Nl1,Nl2);
% 
% for i=1:length(A)
% 
%     s(i,:)=A(i)+B;
%     
% %     for j=1:length(B)
% % 
% %         s(i,j)=A(i)+B(j)
% % 
% %     end
% 
% end
% R=reshape(s,[],9);
% 

