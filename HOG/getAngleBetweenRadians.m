function angle = getAngleBetweenRadians(a, b)

aCompl = [cos(a), sin(a)];
bCompl = [cos(b), sin(b)];

cosOfLambda = dot(aCompl, bCompl) / (norm(aCompl) * norm(bCompl));
angle = acos(cosOfLambda);

% output only real part because sometimes a complex number is created due to rounding
% inaccuracies
angle = real(angle);

end