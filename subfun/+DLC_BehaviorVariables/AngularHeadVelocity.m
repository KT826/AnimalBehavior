function [AHV,U_AHV] = AngularHeadVelocity(AHC,Config_AHC)

%anglar head velocity
AHV = AHC.*(1000/Config_AHC.bin_ms); %deg/sec
U_AHV = 'degree/sec';

end
