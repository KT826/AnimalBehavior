%%
% ORIGINAL script is from "Zong 2022, Cell, MINI2P" - 'angularHeadVelocity.m'
% Calculate animal angular head velocities
%
% Angular head velocity is calculated according to H.T. Blair and P. E. Sharp:1995 paper.
% The momentary angular velocity of the animal's head is calculated as the difference
% in the angle of head direction between successive samples.
%
%  USAGE
%   AHV = analyses.angularHeadVelocity(headDirections)
%   headDirections      Nx1 of animal's head directions in degrees.
%   ts                  Nx1 of timestamp.
%   fps                 sampling rate, frame/sec
%                       
%   AHV                 vector of calculated angular head velocities. [degrees/sec] * 1/<sample_time>
%   U_AHV               unit is  'degree/sec';

function [AHV,U_AHV] = AngularHeadVelocity_Zong2022(headDirections,ts,fps)
    t = ts;
    if length(t) < 2
        error('BNT:args:length', 'headDirections must have at least 2 samples, i.e. N >= 2.');
    end
    dt = diff(t);
    t_diff = t(1:end-1) + dt/2;

    % take derivative
    d0 = diff(headDirections) ./ dt;

    % interpolate it to the whole time range
    d1 = interp1(t_diff, d0, t(2:end, 1));

    % add last interpolated sample, so that size(v) = size(headDirections(:, 2))
    v = [d0; d1(end)]; % v units are [degrees/sec]. And actual value
            % can be seen as v * <sample_time_coefficient> [deg/sec].

    AHV = v * -1; % negative turns are clockwise
    AHV = AHV *1/fps;
    U_AHV = 'degree/sec';
end