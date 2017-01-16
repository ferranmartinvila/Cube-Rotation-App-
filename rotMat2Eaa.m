function [ euler_axis, angle ] = rotMat2Eaa( rotation_matrix )
% Function to get the axis and the angle from a rotation matrix

%Trace of the function
trace = sum(diag(rotation_matrix));
%Angle of the rotation matrix
angle = acosd((trace - 1)/2);

 euler_axis = [0;0;0;];

%0 angle case
if round(angle) == 0   
   
    disp('Angle is NULL');    

%180 angle case 
elseif round(angle) == 180
   
    %Identity matrix
    I = eye(3);
    
    uut = (rotation_matrix + I ) / (1-cosd(angle));
    
    %Get euler axis from uut
    euler_axis = sqrt(diag(uut));
    
else
    
%Skew symmetric matrix
Ux = (rotation_matrix - rotation_matrix')/(2* sind(angle));

%Rotation axis from the skew symmetric matrix
euler_axis = [-Ux(2,3);Ux(1,3);-Ux(1,2);];
   
end
end

