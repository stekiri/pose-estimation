function distance = euclideanDist(x, y)
%euclideanDist Compute the Euclidean distance.
% distance = euclideanDist(x, y) computes the euclidean distance between
% two datapoints x and y.

distance = sqrt(sum((x-y).^2));

end
