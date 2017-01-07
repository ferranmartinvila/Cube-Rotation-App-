function [ clean_output ] = check_zeros( input_data )
%This functionis for polish, it just set low values to zero and round all 
%the numbers to four decimals

columns = length(input_data(1,:));
rows = length(input_data(:,1));

array = input_data;

elements_num = columns * rows;

for k = 1:1:elements_num
     
    if(array(k) < 1E-4 && array(k) > -1E-4)
        
        array(k) = 0;
        
    else
        
        array(k) = round(array(k), 4);
    
    end
end

clean_output = array;

end

