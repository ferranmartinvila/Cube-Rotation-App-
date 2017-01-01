function [R] = Eaa2rotMat(u,angle)

u_norm = norm(u);

if u_norm > 1
    u = u/u_norm;
end
%%disf
if isrow(u) == 1
    u = u';
end

I = eye(3);
Ux = [0,-u(3),u(2);u(3),0,-u(1);-u(2),u(1),0];
R = I*cosd(angle)+(1-cosd(angle))*(u*u')+Ux*sind(angle);

end

