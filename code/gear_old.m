function [X, Y, n_teeth, extra, teeth_size] = gear(R1)

% non geometric params
dt = 0.001;



working_path = 2*pi*R1/4;


t= 0:dt:2*pi+dt;

x = R1*cos(t);
y = R1*sin(t);


hold('on');
plot(x,y);

[tm1, tmp2, last_o] = compute_involute(R1, 0, working_path, 0, dt, 1);    
o = last_o;
n_teeth = floor(pi/last_o);
extra = (2*pi - 2*n_teeth*last_o)/n_teeth;

o_extra = (-extra:dt:extra);

X = [];
Y = [];

for i=1:n_teeth
    [x_involute1, y_involute1, tmp, reach] = compute_involute(R1, o, working_path, extra, dt, 1);    

    teeth_size = sqrt(x_involute1(end)^2 + y_involute1(end)^2) - R1;
    
    o = o + 2*last_o + extra;
    [x_involute2, y_involute2] = compute_involute(R1, o, working_path, extra, dt, -1);    
    x_involute2 = x_involute2(end:-1:1);
    y_involute2 = y_involute2(end:-1:1);
    
    x_involute3 = R1*cos(o+o_extra);
    y_involute3 = R1*sin(o+o_extra);

    
     x_involute1 = x_involute1(1:end-1);
     x_involute2 = x_involute2(2:end);
     y_involute1 = y_involute1(1:end-1);
     y_involute2 = y_involute2(2:end);
    
    
    plot([x_involute1 x_involute2 x_involute3],[y_involute1 y_involute2 y_involute3],'-*');

    X = [X x_involute1 x_involute2 x_involute3];
    Y = [Y y_involute1 y_involute2 y_involute3];
end

axis('equal');

end


function [x_involute, y_involute, last_o, reach] = compute_involute(R1, o0, working_path, extra, dt, dir)

x_involute(1) = R1*cos(o0+extra*dir);
y_involute(1) = R1*sin(o0+extra*dir);
involute_size = 0;

i = 1;
t = 0;
while involute_size<working_path
    i = i+1;
    
    t = t+dt;
    o = o0 + dir*t;
    
    dx_involute = R1*dt*t*cos(o);
    dy_involute = R1*dt*t*sin(o);
    
    x_involute = [x_involute x_involute(i-1) + dx_involute];
    y_involute = [y_involute y_involute(i-1) + dy_involute];
    reach = sqrt(x_involute(end)^2 + y_involute(end)^2);
    reach_o = atan2(y_involute(end),x_involute(end));
    
    involute_size = involute_size + sqrt(dx_involute^2 + dy_involute^2);

    if (abs((pi+reach_o-o0))>pi/8)
        involute_size = working_path+1;
    end

end

disp('---');

last_o = atan2(y_involute(end),x_involute(end));
end