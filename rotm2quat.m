function [ quat ] = rotm2quat( rotmat )
%Converts a rotation matrix to quaternion
if(length(rotmat(:,1)) == length(rotmat(1,:)) && length(rotmat(:,1)) == 3)

    %Qauternion components to build it
    q0 = ( rotmat(1,1) + rotmat(2,2) + rotmat(3,3) + 1) / 4;
    q1 = ( rotmat(1,1) - rotmat(2,2) - rotmat(3,3) + 1) / 4;
    q2 = (-rotmat(1,1) + rotmat(2,2) - rotmat(3,3) + 1) / 4;
    q3 = (-rotmat(1,1) - rotmat(2,2) + rotmat(3,3) + 1) / 4;
    
    %Build the corretc quaternion
    quat = zeros(4,1);
    
    if(q0 ~= 0 && q1 ~= 0 && q2 ~= 0 && q3 ~= 0)
        if(q0 >= q1 && q0 >= q2 && q0 >= q3)

            quat(1) = 0.5 * sqrt(1+rotmat(1,1) + rotmat(2,2) + rotmat(3,3));
            quat(2) = 0.5 * ((rotmat(3,2) - rotmat(2,3))/sqrt(1 + rotmat(1,1) + rotmat(2,2) + rotmat(3,3)));
            quat(3) = 0.5 * ((rotmat(1,3) - rotmat(3,1))/sqrt(1 + rotmat(1,1) + rotmat(2,2) + rotmat(3,3)));
            quat(4) = 0.5 * ((rotmat(2,1) - rotmat(1,2))/sqrt(1 + rotmat(1,1) + rotmat(2,2) + rotmat(3,3)));



        elseif(q1 >= q0 && q1 >= q2 && q1 >= q3)

            quat(1) = 0.5 * ((rotmat(3,2) - rotmat(2,3))/sqrt(1 + rotmat(1,1) - rotmat(2,2) - rotmat(3,3)));
            quat(2) = 0.5 * sqrt(1+rotmat(1,1) - rotmat(2,2) - rotmat(3,3));
            quat(3) = 0.5 * ((rotmat(2,1) + rotmat(1,2))/sqrt(1 + rotmat(1,1) - rotmat(2,2) - rotmat(3,3)));
            quat(4) = 0.5 * ((rotmat(1,3) + rotmat(3,1))/sqrt(1 + rotmat(1,1) - rotmat(2,2) - rotmat(3,3)));



        elseif(q2 >= q0 && q2 >= q1 && q2 >= q3)

            quat(1) = 0.5 * ((rotmat(1,3) - rotmat(3,1))/sqrt(1 - rotmat(1,1) + rotmat(2,2) + rotmat(3,3)));
            quat(2) = 0.5 * ((rotmat(2,1) + rotmat(1,2))/sqrt(1 - rotmat(1,1) + rotmat(2,2) + rotmat(3,3)));
            quat(3) = 0.5 * sqrt(1 - rotmat(1,1) + rotmat(2,2) + rotmat(3,3));
            quat(4) = 0.5 * ((rotmat(3,2) + rotmat(2,3))/sqrt(1 - rotmat(1,1) + rotmat(2,2) + rotmat(3,3)));



        elseif(q3 >= q0 && q3 >= q1 && q3 >= q2)

            quat(1) = 0.5 * ((rotmat(2,1) - rotmat(1,2))/sqrt(1 - rotmat(1,1) - rotmat(2,2) + rotmat(3,3)));
            quat(2) = 0.5 * ((rotmat(1,3) + rotmat(3,1))/sqrt(1 - rotmat(1,1) - rotmat(2,2) + rotmat(3,3)));
            quat(3) = 0.5 * ((rotmat(3,2) + rotmat(2,3))/sqrt(1 - rotmat(1,1) - rotmat(2,2) + rotmat(3,3)));
            quat(4) = 0.5 * sqrt(1 - rotmat(1,1) - rotmat(2,2) + rotmat(3,3));

        end
        
    else
        quat = [q0;q1;q2;q3];
        
    end

    
else 
    
    quat = [-1;-1;-1;-1];
    
end

end

