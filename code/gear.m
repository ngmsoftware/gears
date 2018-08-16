function [X_involute, Y_involute, teeth_size] = gear(R1, n_teeth, adendum, slack, dedendum,  dt)

[X, Y, teeth_size] = involute(R1,n_teeth, adendum, slack, dedendum, dt);


do = 2*pi/n_teeth;

X_involute = [];
Y_involute = [];

o = 0;
for i=1:n_teeth
    R = [cos(o) -sin(o); sin(o) cos(o)];
    
    P_ = R*[X; Y];
    X_ = P_(1,:) + R1*cos(o);
    Y_ = P_(2,:) + R1*sin(o);
    
    X_involute = [X_involute X_(1:end-1)];
    Y_involute = [Y_involute Y_(1:end-1)];
    
    
    R = [cos(o+do) -sin(o+do); sin(o+do) cos(o+do)];
    
    P_ = R*[X; -Y];
    X_ = P_(1,:) + R1*cos(o+do);
    Y_ = P_(2,:) + R1*sin(o+do);
    
    o = o + do;
    
    X_involute = [X_involute X_(end-1:-1:1)];
    Y_involute = [Y_involute Y_(end-1:-1:1)];

end


% o = 0:dt:2*pi;
% X_involute = [X_involute 0.8*(1-dedendum)*R1*cos(o)];
% Y_involute = [Y_involute 0.8*(1-dedendum)*R1*sin(o)];
% 
% X_involute = [X_involute 0.2*(1-dedendum)*R1*cos(o)];
% Y_involute = [Y_involute 0.2*(1-dedendum)*R1*sin(o)];

end