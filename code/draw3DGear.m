function draw3DGear(X, Y, depht, color)

   patch(X,Y,0*X,color) 
   patch(X,Y,0*X+depht,color) 
   
   for i=1:length(X)-1
       x1 = X(i);
       y1 = Y(i);
       x2 = X(i+1);
       y2 = Y(i+1);
       patch([x1 x2 x2 x1],[y1 y2 y2 y1],[0 0 depht depht], color);
   end

end