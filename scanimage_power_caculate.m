powerFraction2PowerWattLut = [0 0.000947;1 0.3276];
powerFractions = 0:0.05:1;

powerMws = utils.interp1_extended(powerFraction2PowerWattLut(:,1),powerFraction2PowerWattLut(:,2),powerFractions,'linear','extrap')*10^3;


plot(powerFractions*100,powerMws,'o-')

xlabel("Power Fraction (%)")
ylabel("Power (mW)")






powerFraction2ModulationAngleLut = [0.00289072 71.1;0.00308303 71.7;0.00610501 72.8487;0.0123016 73.9974;0.0217338 75.1462;0.0344933 76.2949;0.0501526 77.4436;0.0684982 78.5923;0.0903541 79.741;0.113889 80.8897;0.141941 82.0385;0.17033 83.1872;0.202381 84.3359;0.234127 85.4846;0.265568 86.6333;0.306166 87.7821;0.343712 88.9308;0.382784 90.0795;0.421245 91.2282;0.461538 92.3769;0.503358 93.5256;0.542857 94.6744;0.580586 95.8231;0.6221 96.9718;0.657509 98.1205;0.698413 99.2692;0.732601 100.418;0.769231 101.567;0.799451 102.715;0.833028 103.864;0.85928 105.013;0.888278 106.162;0.909646 107.31;0.927961 108.459;0.949634 109.608;0.965812 110.756;0.983211 111.905;0.989316 113.054;0.992674 114.203;1 116];
powerFractions = 0:0.02:1;

powerMws = utils.interp1_extended(powerFraction2ModulationAngleLut(:,1), ...
    powerFraction2ModulationAngleLut(:,2),powerFractions,'linear','extrap');


plot(powerFractions*100,powerMws,'o-',powerFraction2ModulationAngleLut(:,1)*100, ...
    powerFraction2ModulationAngleLut(:,2));

xlabel("Power Fraction (%)")
ylabel("Angle (°)")

