function [phi, theta, psi] = rotM2eAngles (R)

if R(3,1) == -1
    theta = pi/2;
    phi = 0;
    psi = -asind(R(1,2));
    
elseif R(3,1) == 1
    theta = -pi/2;
    phi = 0;
    psi = asind(-R(1,2));

else
    theta = asind(-R(3,1));
    phi = atan2d(R(3,2)/cosd(theta),R(3,3)/cosd(theta));
    psi = atan2d(R(2,1)/cosd(theta),R(1,1)/cosd(theta));
end

end