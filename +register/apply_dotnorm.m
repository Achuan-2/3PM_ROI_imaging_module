function Y = apply_dotnorm(Y, cfRefImg)
    Y = Y ./ (1e-5 + abs(Y)) .* cfRefImg;
end
