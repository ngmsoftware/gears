function [Xo, Yo, reach] = involute(R1, n_teeth, adendum, slack, dedendum, dt)

% R1 : base radius
% n_teeth : number of teaath
% adendum : adendum (percent)
% slack : spacing between teeth (percent)
% dedendum : inner radius distance (percent) can be negative

max_angle = pi/n_teeth;

X = [0];
Y = [0];
Xo = [0];
Yo = [0];

angle = 0;
reach = 0;

i = 1;
t = 0;
while angle<max_angle
    i = i+1;
    
    t = t+dt;

    if (angle<adendum*max_angle)
        dx_involute = R1*dt*t*cos(t);
        dy_involute = R1*dt*t*sin(t);
    else
        dx_involute = -(reach(i-1))*dt*sin(angle(i-1));
        dy_involute = (reach(i-1))*dt*cos(angle(i-1));
    end
    
    X = [X X(i-1) + dx_involute];
    Y = [Y Y(i-1) + dy_involute];
    
    reach(i) = sqrt(Y(end)^2 + (X(end)+R1)^2);    
    angle(i) = atan2(Y(end),X(end)+R1);
end

idx = angle<slack;
r = R1*(1 - dedendum);
X(idx) = -R1+r*cos(angle(idx));
Y(idx) = r*sin(angle(idx));

Xo = X;
Yo = Y;



reach = reach(end)-R1;

end