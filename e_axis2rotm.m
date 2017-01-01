function [ rotmat ] = e_axis2rotm( axis,angle )
%Build a rotation matrix from the axis and euler angle

if(axis(1) ~= 0 || axis(2) ~= 0 || axis(3) ~= 0)
c = cosd(angle);
s = sind(angle);
t = 1-c;

axis = axis/norm(axis);
x = axis(1);
y = axis(2);
z = axis(3);

rotmat = [t*x*x + c, t*x*y - z*s, t*x*z + y*s ;
          t*x*y + z*s,t*y*y + c, t*y*z - x*s;
          t*x*z - y*s, t*y*z + x*s,t*z*z + c];
      
else
    
    rotmat = [1,0,0;0,1,0;0,0,1];
      
end

end

