% =========================================================================
% MASTER SCRIPT: WRIST EXOSKELETON KINEMATICS & TRAJECTORY
% Author: Arafat Mahamood Shaikh (ID: 202005500)
% Module: MECH5845M Professional Project
% =========================================================================

clear; clc; close all;

%% --- SYSTEM PARAMETERS (Extracted from SolidWorks) ---
% Center of wrist is at (0,0,0). All units are in millimeters (mm).

% 1. Motor Exits on Forearm Cuff (X, Y, Z) (B_i)
B1 = [16.70;  39.17; -95.24];  % Motor 1 (Top Extensor)
B2 = [16.09;  39.17; -124.69]; % Motor 2 (Bottom Left Flexor)
B3 = [19.27;  38.17; -155.87]; % Motor 3 (Bottom Right Flexor)

% 2. Anchor Points on Hand Plate at 0 degrees (X, Y, Z) (P_i)
P1_initial = [0;      46.97; 45.00];  % Top Anchor
P2_initial = [-27.87; 37.98; 20.76];  % Left Flexor Anchor
P3_initial = [27.87;  36.47; 20.73];  % Right Flexor Anchor


%% ========================================================================
% FIGURE 1: 3D REACHABLE WORKSPACE PLOT
% Proves the physical capacity of the 3-tendon parallel mechanism.
% ========================================================================
figure('Name', 'Figure 1: 3D Reachable Workspace', 'Color', 'w');

% Define the range of motion for basic stroke therapy (plus or minus 30 degrees)
flex_ext_range = -30:2:30; % Flexion/Extension angles
rad_uln_range  = -30:2:30; % Radial/Ulnar angles

% Arrays to store the 3D points
X_workspace = []; Y_workspace = []; Z_workspace = [];

% Loop through every possible combination of angles to map the workspace
for alpha = flex_ext_range
    for beta = rad_uln_range
        % Convert degrees to radians for MATLAB trig functions
        a_rad = deg2rad(alpha);
        b_rad = deg2rad(beta);
        
        % Rotation Matrices for X and Y axes
        Rx = [1, 0, 0; 0, cos(a_rad), -sin(a_rad); 0, sin(a_rad), cos(a_rad)]; 
        Ry = [cos(b_rad), 0, sin(b_rad); 0, 1, 0; -sin(b_rad), 0, cos(b_rad)]; 
        
        % Combined Rotation Matrix
        R = Ry * Rx; 
        
        % Calculate new position of the center of the hand plate (assuming it sits at Z=45)
        Center_initial = [0; 0; 45];
        Center_new = R * Center_initial;
        
        % Store points
        X_workspace = [X_workspace, Center_new(1)];
        Y_workspace = [Y_workspace, Center_new(2)];
        Z_workspace = [Z_workspace, Center_new(3)];
    end
end

% Plotting the Workspace
scatter3(X_workspace, Y_workspace, Z_workspace, 15, Z_workspace, 'filled');
colormap(jet);
title('Figure 1: 3D Reachable Workspace of the Hand Plate');
xlabel('X-axis (Radial/Ulnar Plane) [mm]');
ylabel('Y-axis (Flexion/Extension Plane) [mm]');
zlabel('Z-axis (Vertical Distance from Wrist) [mm]');
grid on; view(45, 30);
colorbar;


%% ========================================================================
% FIGURE 2: INVERSE KINEMATICS VALIDATION (TENDON LENGTH VS. WRIST ANGLE)
% Proves the mathematical mapping between wrist angle and motor spooling.
% ========================================================================
figure('Name', 'Figure 2: Inverse Kinematics Validation', 'Color', 'w');

angles = -30:1:30; % Simulating 30 degrees Flexion to 30 degrees Extension
L1_active = zeros(1, length(angles));
L2_active = zeros(1, length(angles));
L3_active = zeros(1, length(angles));

for i = 1:length(angles)
    theta = deg2rad(angles(i));
    
    % Pure Flexion/Extension (Rotation around X-axis)
    Rx = [1, 0, 0; 0, cos(theta), -sin(theta); 0, sin(theta), cos(theta)];
    
    % Calculate new hand plate anchor positions
    P1_new = Rx * P1_initial;
    P2_new = Rx * P2_initial;
    P3_new = Rx * P3_initial;
    
    % Calculate Euclidean distance (required tendon length) between base and new anchor
    L1_active(i) = norm(P1_new - B1);
    L2_active(i) = norm(P2_new - B2);
    L3_active(i) = norm(P3_new - B3);
end

% Plotting the Tendon Lengths
plot(angles, L1_active, 'b-', 'LineWidth', 2); hold on;
plot(angles, L2_active, 'r--', 'LineWidth', 2);
plot(angles, L3_active, 'g-.', 'LineWidth', 2);
title('Figure 2: Inverse Kinematics (Tendon Length vs. Wrist Angle)');
xlabel('Wrist Angle (Degrees) [-30 Flexion to +30 Extension]');
ylabel('Active Tendon Length (mm)');
legend('Tendon 1 (Top)', 'Tendon 2 (Bottom Left)', 'Tendon 3 (Bottom Right)', 'Location', 'Best');
grid on;


%% ========================================================================
% FIGURE 3: THERAPEUTIC TRAJECTORY PROFILE (POSITION VS. TIME)
% Proves smooth, safe Continuous Passive Motion (CPM) for stroke patients.
% ========================================================================
figure('Name', 'Figure 3: Therapeutic Trajectory Profile', 'Color', 'w');

% Define Time and Frequency for the exercise
time = 0:0.1:10; % 10-second exercise session
freq = 0.1;      % 1 full flex/extend cycle every 10 seconds (slow, safe therapy)

% Target Wrist Angle Sine Wave (+/- 30 degrees)
target_angle = 30 * sin(2 * pi * freq * time);

% Convert target angle to motor displacement (Simplified proxy mapping for plotting)
% (Assuming roughly 0.5 mm of spooling per degree of movement based on geometry)
spool_ratio = 0.5; 
tendon_displacement = target_angle * spool_ratio;

% Plotting the Trajectory
plot(time, tendon_displacement, 'm-', 'LineWidth', 2.5);
title('Figure 3: Therapeutic Trajectory Profile (CPM)');
xlabel('Time (seconds)');
ylabel('Motor Command / Tendon Displacement (mm)');
grid on;

% Add baseline to show neutral position
yline(0, 'k--', 'Neutral Wrist Position (0 mm)');

% =========================================================================
% END OF SCRIPT
% =========================================================================