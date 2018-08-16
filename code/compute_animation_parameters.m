function compute_animation_parameters()

dt = 0.1;

adendum1 = 0.8;
dedendum1 = 0;
slack1 = 0.1;
adendum2 = 0.8;
dedendum2 = 0;
slack2 = 0.1;
n1 = 3+fix(30*rand());
n2 = 3+fix(30*rand());
factor_d = 0;


% picasso gear
adendum2 = 0.8;
dedendum2 = 0;
slack2 = 0.15;
dedendum1 = -0.2;
slack1 = 0.15;
n2 = 3;
n1 = 13;
factor_d = 2.25;

% normal gear
% adendum1 = 0.8;
% dedendum1 = -0.1;
% slack1 = 0.1;
% adendum2 = 0.8;
% dedendum2 = -0.06;
% slack2 = 0.03;
% n1 = 8;
% n2 = 24;
% factor_d = 1.0;


R1 = 10;
R2 = R1*n2/n1;

if (mod(n2,2)==0)
    phase1 = pi/n1;
    phase2 = 0;
else
    phase1 = 0;
    phase2 = 0;
end    

[X1, Y1, teeth_size1] = gear(R1, n1, adendum1, slack1, dedendum1, dt);

[X2, Y2, teeth_size2] = gear(R2, n2, adendum2, slack2, dedendum2, dt);

d = find_suitable_distance(X1, Y1, X2, Y2, n1, n2, R1, R2, teeth_size2, phase1, dt/10)+1.5;

%d = R1 + R2 + (teeth_size1 + teeth_size2)/2;


H2 = subplot(1,1,1);
animate_gears(R1, R2, [0; 0], [d; 0], phase1, phase2, [X1; Y1], [X2; Y2], 0.04, H2)



end



function d = find_suitable_distance(X1_, Y1_, X2_, Y2_, n1, n2, R1, R2, teeth_size2, o1, dt)

X1 = [X1_(fix(1:end/n1)) X1_(fix((2*n1-1)*end/n1:end))];
Y1 = [Y1_(fix(1:end/n1)) Y1_(fix((2*n1-1)*end/n1:end))];
R = [cos(o1) sin(o1); -sin(o1) cos(o1)];
P_ = R*[X1; Y1];
X1 = P_(1,:);
Y1 = P_(2,:);


X2 = X2_(fix(end/2-end/n2/2:end/2+end/n2/2));
Y2 = Y2_(fix(end/2-end/n2/2:end/2+end/n2/2));

d = R1+R2+teeth_size2*1.1;
 
keep_walking = 1;
while keep_walking

     cla();
     plot(X1,Y1);
     hold on
     plot(X2+d,Y2);
     drawnow();
    
    min_d = min_dist(X1,X2+d,Y1,Y2);
     
    if min_d>dt
        keep_walking = 0;
    end
    
    d = d+4*dt;
end

end



function d = min_dist(X1, X2, Y1, Y2)

for i=1:length(X1)
    for j=1:length(X2)
        D(i,j) = sqrt((X1(i)-X2(j))^2 + (Y1(i)-Y2(j))^2);
    end
end

d = min(min(D));

end