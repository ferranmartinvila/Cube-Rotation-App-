function [ e_axis,angle ] = rotm2e_axis( rotmat )

%Calculate euler axis and angle from rotation matrix
if(length(rotmat(:,1)) == length(rotmat(1,:)) && length(rotmat(:,1)) == 3)

    
    coef = rotmat(1,1)+rotmat(2,2)+rotmat(3,3);
    if(coef < -1)
        
        coef = -1;
        
    elseif (coef > 1)
        
        coef = 1;
        
    end
    
    
    angle = acosd((coef - 1)/2);
    
    x_mat_e_axis = (rotmat - rotmat')/(2 * sind(angle));
    
    if(zeros(3,3) - x_mat_e_axis == zeros(3,3))
       
        x_mat_e_axis(6) = 1;
        x_mat_e_axis(7) = 1;
        x_mat_e_axis(2) = 1;
        
    end
    
    nan_check = isnan(x_mat_e_axis);
    if(nan_check(1) ~= 1)
        
        e_axis = [x_mat_e_axis(6);x_mat_e_axis(7);x_mat_e_axis(2)];
            
        if(e_axis(1) == e_axis(2) && e_axis(2) == e_axis(3))
                
            e_axis = [1;1;1];

        end
            
        check_rotmat = e_axis2rotm(e_axis,angle);
        
    else
        
        e_axis = [0;0;0];
        
        
    end
    
else
    
    e_axis = [0;0;0];
    angle = 0;
    
end

end

