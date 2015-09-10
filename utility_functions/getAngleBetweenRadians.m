function deviation = getAngleBetweenRadians(a, b)
%getAngleBetweenRadians Computes deviation between two angles.
% The deviation is returned in radian, not degrees.

aCompl = [cos(a), sin(a)];
bCompl = [cos(b), sin(b)];

cosOfLambda = dot(aCompl, bCompl) / (norm(aCompl) * norm(bCompl));
deviation = acos(cosOfLambda);

% output only real part because sometimes a complex number is created due to rounding
% inaccuracies
deviation = real(deviation);

end