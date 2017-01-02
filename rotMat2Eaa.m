function [axis, angle] = rotMat2Eaa (R)

angle = acos((trace(R)-1)/2);

if round(angle, 6) == 0
    angle = 0;
end

Ux = ((R - R.')/(2*sin(angle)));

if angle == 0    
    axis = [0;0;0];
    
elseif angle == pi
    
    Ux1 = sqrt((R(1,1)+1)*0.5);
    Ux2 = (0.5*R(1,2))/Ux1;
    if Ux2 ~= 0
        Ux3 = (0.5*R(1,3))/Ux2;
    else
        Ux3 = (0.5*R(1,3))
    
    end
    axis = [Ux1;Ux2;Ux3];

else
    axis = [Ux(3,2);Ux(1,3);Ux(2,1)];
end

end