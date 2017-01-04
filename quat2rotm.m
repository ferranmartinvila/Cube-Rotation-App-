function [ matrix ] = quat2rotm( quat )

%Calculate rotation matrix from quaternion
if(length(quat(1,:)) == 1 && length(quat(:,1)) == 4)
    
    if(norm(quat(2:4)) == 0)
          matrix = [1,0,0;0,1,0;0,0,1];
    else
        q_vect = quat(2:4);
    q_x_mat = [0,-q_vect(3),q_vect(2);q_vect(3),0,-q_vect(1);-q_vect(2),q_vect(1),0];
    matrix = ((quat(1)*quat(1)) - (q_vect'*q_vect)) * eye(3) + 2*(q_vect*q_vect') + 2*quat(1)*q_x_mat;
    
    end
    
else
    
    matrix = [0,0,0;0,0,0;0,0,0];
    
end


end

