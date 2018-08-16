function animate_gears(r1, r2, c1, c2, O1, O2, G1, G2, speed, handle)

% R1 : gear 1 radius
% R2 : gear 2 radius
%
% c1 = [x1; y1] : gear 1 center
% c2 = [x2; y2] : gear 2 center
%
% O1 : gear 1 phase
% O2 : gear 1 phase
%
% G1 = [x1 x2 x3 x4 ...;
%       y1 y2 y3 y4 ...]   : Gear 1 points
% G2 = [x1 x2 x3 x4 ...;
%       y1 y2 y3 y4 ...]   : Gear 2 points
% 
% speed : integration constant for the angle

o1 = O1;
o2 = O2;

C1 = repmat(c1, 1, size(G1, 2));
C2 = repmat(c2, 1, size(G2, 2));


while ishandle(handle)
    
    
    R1 = [cos(o1) sin(o1); -sin(o1) cos(o1)];
    R2 = [cos(o2) sin(o2); -sin(o2) cos(o2)];
    G1_ = R1*G1;
    G2_ = R2*G2;
    
    G1_ = G1_ + C1;
    G2_ = G2_ + C2;
    
    o1 = o1-speed;
    o2 = o2+speed*r1/r2;
    
    axis(handle);
    cla();
    hold('on');
    %plot(G1_(1,:), G1_(2,:));
    %plot(G2_(1,:), G2_(2,:));
    draw3DGear(G1_(1,:), G1_(2,:), (r1+r2)/2, 'b')
    draw3DGear(G2_(1,:), G2_(2,:), (r1+r2)/2, 'r')
    axis('equal');
    axis([-3*r1 3*(r1+r2) -3*max([r2 r1]) 3*max([r2 r1])]);
    view(-45,33);
    box('on');
    grid('on');
    camproj();
    drawnow();
    
    
end


end