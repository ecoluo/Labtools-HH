% fit minimize orthangonal distance
aa=dlmread('Data1.TXT');
% a1=dlmread('aa.txt');
% a2=dlmread('bb.txt');
% a1=1:10;
% a2=[12,21,30,36,47,65,66,76,87,100];
% aa(:,1) = a1;
% aa(:,2) = a2;
xx=aa(:,2);
yy=aa(:,1);

A=[]; B=[]; Aeq=[]; Beq=[]; NONLCON=[];
OPTIONS = optimset('fmincon');
OPTIONS = optimset('LargeScale', 'off', 'LevenbergMarquardt', 'on', 'MaxIter', 5000, 'Display', 'off');

estimate = polyfit(xx,yy,1);

yy1 = @(x)sum( abs(yy-(xx.*x(1)+x(2)))/sqrt(1+x(1)^2) ); % d=abs(y-(intercept+slope*x))/sqrt(1+slope^2);
es1 = [estimate(1),estimate(2)];

LB1 = [-100,-100];
UB1 = [100,100];

%v1 = lsqnonlin(@(x)sum( (abs(y-(x.*x(1)+x(2)))/sqrt(1+x(1)^2)).^1 ),es1); % fminsearch   
v1 = fmincon(yy1,es1,A,B,Aeq,Beq,LB1,UB1, NONLCON, OPTIONS); % fminsearch    
     
slope = v1(1);
intercept = v1(2);

b=slope;
a=intercept;

plot(xx,yy,'bo');
hold on;
plot(xx,xx*slope+intercept,'b-');
plot(xx,xx*estimate(1)+estimate(2),'r-');
b
a
estimate

return
