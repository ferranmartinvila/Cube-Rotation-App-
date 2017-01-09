function [ quaternion_result ] = quaternion_product( quaternion_A, quaternion_B )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if(length(quaternion_A(:,1)) == 4 && length(quaternion_B(:,1)) == 4)
    
   A_vector = quaternion_A(2:4);
   B_vector = quaternion_B(2:4);
    
    
   imaginary_part = quaternion_A(1) * quaternion_B(1) - A_vector' * B_vector;
  
   real_part = quaternion_A(1,1) * B_vector + quaternion_B(1,1) * A_vector + cross(A_vector,B_vector);
   
   if(imaginary_part < 1E-10 && imaginary_part > -1E-10)
       
      imaginary_part = 0; 
      
   end
   
   quaternion_result(1,1) = imaginary_part;
   quaternion_result(2:4) = real_part;
   
   quaternion_result = quaternion_result';
   
else 
    
    quaternion_result = Nan;
    
end


end

