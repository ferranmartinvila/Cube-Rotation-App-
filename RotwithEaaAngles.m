function [R] = RotwithEaaAngles(X, Y, Z)


R = [cosd(Y)*cosd(Z), cosd(Z)*sind(Y)*sind(X)-cosd(X)*sind(Z), cosd(Z)*cosd(X)*sind(Y)+sind(Z)*sind(X);
            cosd(Y)*sind(Z), sind(Z)*sind(Y)*sind(X)+cosd(X)*cosd(Z), sind(Z)*sind(Y)*cosd(X)-cosd(Z)*sind(X);
            -sind(Y),    cosd(Y)*sind(X),  cosd(Y)*cosd(X)];


end