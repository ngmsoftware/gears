function gear_test()

clear();
clc();


R1 = 50;
n_teeth = 9;
adendum = 0.8;
slack = 0.1;
dedendum = 0.1;
dt = 0.001;

[X_involute, Y_involute, teeth_size] = gear(R1, n_teeth, adendum, slack, dedendum,  dt);

patch(X_involute, Y_involute, [0.9 0.9 0.9],'linewidth',1.5);
axis('equal');

o_teeth = 2*pi/n_teeth;
o_teeth2 = pi/n_teeth;



radiusMeasurement1 = [0 0];
%radiusMeasurement2 = [R1*cos(pi+o_teeth) R1*sin(pi+o_teeth)];
radiusMeasurement2 = [0 -R1];
drawStraightMeasure(radiusMeasurement1,radiusMeasurement2, 'radius', [1 1 1], 0.5);



adendumDeltaAngle = (1-adendum)*2*pi/n_teeth/2;
adendumMeasurement1 = 1.1*(R1+teeth_size)*[cos(o_teeth2+adendumDeltaAngle) sin(o_teeth2+adendumDeltaAngle)];
adendumMeasurement2 = 1.1*(R1+teeth_size)*[cos(o_teeth2-adendumDeltaAngle) sin(o_teeth2-adendumDeltaAngle)];
drawStraightMeasure(adendumMeasurement1,adendumMeasurement2, 'adendum', [1 0 0]);


dedendumMeasurement1 = [R1*cos(o_teeth) R1*sin(o_teeth)];
dedendumMeasurement2 = [R1*(1-dedendum)*cos(o_teeth) R1*(1-dedendum)*sin(o_teeth)];
drawStraightMeasure(dedendumMeasurement1,dedendumMeasurement2, 'dedendum', 'g');
drawCircle([0 0], R1, 'g:')

slackDeltaAngle = slack/2;
slackMeasurement1 = 1.1*(R1+teeth_size)*[cos(slackDeltaAngle) sin(slackDeltaAngle)];
slackMeasurement2 = 1.1*(R1+teeth_size)*[cos(-slackDeltaAngle) sin(-slackDeltaAngle)];
drawStraightMeasure(slackMeasurement1,slackMeasurement2, 'slack', [0 0 1])
line([R1*(1-dedendum) 1.1*(R1+teeth_size)],1.1*(R1+teeth_size)*[sin(slackDeltaAngle) sin(slackDeltaAngle)],'color',[0 0 1], 'linestyle',':')
line([R1*(1-dedendum) 1.1*(R1+teeth_size)],-1.1*(R1+teeth_size)*[sin(slackDeltaAngle) sin(slackDeltaAngle)],'color',[0 0 1], 'linestyle',':')


ang = o_teeth/2;
for tooth = 1:n_teeth
    text((R1+teeth_size/2)*cos(ang), (R1+teeth_size/2)*sin(ang), sprintf('%d', tooth));
    ang = ang + 2*pi/n_teeth;
end

drawAngularMeasure(0, o_teeth, R1/2, sprintf('%.2f',o_teeth), 'y');
line([1.5*R1*cos(0) 0 1.5*R1*cos(o_teeth)],[1.5*R1*sin(0) 0 1.5*R1*sin(o_teeth)], 'color','y','linestyle',':', 'linewidth',1.5);


end




function drawCircle(center, radius, linestyle)
    t = linspace(0,2*pi,128);
    
    hold('on');
    plot(center(1)+radius*cos(t), center(2)+radius*sin(t), linestyle, 'linewidth',1.5);
end




function drawStraightMeasure(x1, x2, label, color, varargin)

p = x2-x1;
d = norm(p);

if length(varargin)>0
    d = d*varargin{1};
end

tipVector = [-p(2) p(1)];
tipVector = tipVector/norm(tipVector);

line([x1(1) x2(1)],[x1(2) x2(2)], 'color', color, 'linewidth',1.5)

tip1 = x1+tipVector*0.2*d;
tip2 = x1-tipVector*0.2*d;
line([tip1(1) tip2(1)],[tip1(2) tip2(2)], 'color', color, 'linewidth',1.5)

tip1 = x2+tipVector*0.2*d;
tip2 = x2-tipVector*0.2*d;
line([tip1(1) tip2(1)],[tip1(2) tip2(2)], 'color', color, 'linewidth',1.5)


text((x1(1)+x2(1))/2, (x1(2)+x2(2))/2, label,'color',color, 'FontWeight', 'bold', 'fontsize', 13);

end



function drawAngularMeasure(o1, o2, r, label, color)

line([r*cos(o1) 0 r*cos(o2)],[r*sin(o1) 0 r*sin(o2)], 'color',color, 'linewidth',1.5);

t = linspace(o1, o2, round(128*abs(o1-o2)/(2*pi)));

hold('on');
plot(0.9*r*cos(t), 0.9*r*sin(t), 'color',color);

text(r*cos((o1+o2)/2), r*sin((o1+o2)/2), label, 'FontWeight', 'bold', 'fontsize', 13);

end
