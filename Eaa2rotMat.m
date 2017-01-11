function [R] = Eaa2rotMat(u,angle)

u_norm = norm(u);

if u_norm > 1
    u = u/u_norm;
end

if isrow(u) == 1
    u = u';
end

Ux = [0,-u(3),u(2);u(3),0,-u(1);-u(2),u(1),0];
R = eye(3)*cosd(angle)+(1-cosd(angle))*(u*u')+Ux*sind(angle);

end

