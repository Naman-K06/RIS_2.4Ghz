clc;
clear;
close all;
%% Project Folders

ProjectFolder = 'C:\Users\Naman\Desktop\Capstone\Matlab';

DataFolder    = fullfile(ProjectFolder,'Data');
FigureFolder  = fullfile(ProjectFolder,'Figures');
ResultFolder  = fullfile(ProjectFolder,'Results');

% Create folders if they don't exist
if ~exist(DataFolder,'dir')
    mkdir(DataFolder);
end

if ~exist(FigureFolder,'dir')
    mkdir(FigureFolder);
end

if ~exist(ResultFolder,'dir')
    mkdir(ResultFolder);
end

%% ==========================================================
%           HFSS Unit Cell Parameters
% ===========================================================

% Operating Frequency
f = 2.45e9;                 % Hz
c = 3e8;                    % Speed of light (m/s)
lambda = c/f;               % Wavelength (m)
k = 2*pi/lambda;            % Wave number

fprintf('Operating Frequency : %.2f GHz\n',f/1e9); %[output:6da7a92f]
fprintf('Wavelength          : %.2f mm\n\n',lambda*1000); %[output:4f9bc174]

%% ==========================================================
%                 HFSS RESULTS (2.45 GHz)
% ===========================================================

%---------------- ON State ----------------%
S11_ON_dB      = -1.1850;
Phase_ON_deg   = 148.9022;

%---------------- OFF State ---------------%
S11_OFF_dB     = -13.7108;
Phase_OFF_deg  = -70.2555;

%% ==========================================================
%         Convert S11(dB) to Reflection Magnitude
% ===========================================================

GammaON_mag  = 10^(S11_ON_dB/20);
GammaOFF_mag = 10^(S11_OFF_dB/20);

%% ==========================================================
%             Convert Phase to Radians
% ===========================================================

PhaseON_rad  = deg2rad(Phase_ON_deg);
PhaseOFF_rad = deg2rad(Phase_OFF_deg);

%% ==========================================================
%          Complex Reflection Coefficients
% ===========================================================

GammaON  = GammaON_mag*exp(1j*PhaseON_rad);
GammaOFF = GammaOFF_mag*exp(1j*PhaseOFF_rad);

%% ==========================================================
%          Reflection Loss
% ===========================================================

ReflectionLoss_ON  = -20*log10(GammaON_mag);
ReflectionLoss_OFF = -20*log10(GammaOFF_mag);

%% ==========================================================
%         Phase Difference
% ===========================================================

PhaseDifference = abs(Phase_ON_deg-Phase_OFF_deg);

if PhaseDifference > 180
    PhaseDifference = 360-PhaseDifference;
end

%% ==========================================================
%               RIS ARRAY CONFIGURATION
% ===========================================================

% Available RIS array sizes
AvailableArrays = [4 8 12 16 20 32];

disp(' ') %[output:96717bbd]
disp('Available RIS Arrays') %[output:33bbedc8]
disp('1 = 4 x 4') %[output:6827ab99]
disp('2 = 8 x 8') %[output:2f67d49c]
disp('3 = 12 x 12') %[output:1936a6de]
disp('4 = 16 x 16') %[output:4b39ed00]
disp('5 = 20 x 20') %[output:8694c592]
disp('6 = 32 x 32') %[output:37a15111]

ArrayChoice = 1;      % Change this value when needed

switch ArrayChoice

    case 1
        Nx = 4;
        Ny = 4;

    case 2
        Nx = 8;
        Ny = 8;

    case 3
        Nx = 12;
        Ny = 12;

    case 4
        Nx = 16;
        Ny = 16;

    case 5
        Nx = 20;
        Ny = 20;

    case 6
        Nx = 32;
        Ny = 32;

    otherwise
        error('Invalid Array Choice')

end

ElementSpacing = lambda/2;

TotalElements = Nx*Ny;

ArrayWidth = (Nx-1)*ElementSpacing;

ArrayHeight = (Ny-1)*ElementSpacing;

%% ==========================================================
%                Display Results
% ===========================================================

disp('===============================================') %[output:8fe0b87e]
disp('          HFSS UNIT CELL PARAMETERS') %[output:3bc90eed]
disp('===============================================') %[output:86731c62]

fprintf('\nON STATE\n'); %[output:459fc9a1]
fprintf('S11               = %.4f dB\n',S11_ON_dB); %[output:83d56ba7]
fprintf('Reflection Mag    = %.4f\n',GammaON_mag); %[output:200840c3]
fprintf('Reflection Phase  = %.2f deg\n',Phase_ON_deg); %[output:35dc4136]
fprintf('Reflection Loss   = %.2f dB\n',ReflectionLoss_ON); %[output:7d6a4eea]
fprintf('Complex Gamma     = %.4f + %.4fj\n',real(GammaON),imag(GammaON)); %[output:9b2c216c]

fprintf('\nOFF STATE\n'); %[output:5ef314be]
fprintf('S11               = %.4f dB\n',S11_OFF_dB); %[output:1fc065d8]
fprintf('Reflection Mag    = %.4f\n',GammaOFF_mag); %[output:99607e16]
fprintf('Reflection Phase  = %.2f deg\n',Phase_OFF_deg); %[output:5766a397]
fprintf('Reflection Loss   = %.2f dB\n',ReflectionLoss_OFF); %[output:6d80d88b]
fprintf('Complex Gamma     = %.4f + %.4fj\n',real(GammaOFF),imag(GammaOFF)); %[output:2c53a284]

fprintf('\nPhase Difference = %.2f degrees\n',PhaseDifference); %[output:84d19d37]

disp(' ') %[output:7d8a82e2]
disp('========== RIS ARRAY ==========') %[output:36675cea]

fprintf('Array Size          : %d x %d\n',Nx,Ny); %[output:480d31a1]
fprintf('Total Elements      : %d\n',TotalElements); %[output:3742a006]
fprintf('Element Spacing     : %.2f mm\n',ElementSpacing*1000); %[output:3d22ad58]
fprintf('Array Width         : %.2f mm\n',ArrayWidth*1000); %[output:8ea48915]
fprintf('Array Height        : %.2f mm\n',ArrayHeight*1000); %[output:63a01146]

disp('===============================================') %[output:91a4a35a]


%% ==========================================================
%                Save Parameters
% ===========================================================

% Data folder
DataFolder = 'C:\Users\Naman\Desktop\Capstone\Matlab\Data';

% Create folder if it doesn't exist
if ~exist(DataFolder,'dir')
    mkdir(DataFolder);
end

% Full file name
SaveFile = fullfile(DataFolder,'HFSS_Parameters.mat');

% Save variables
save(SaveFile,...
    'f','c','lambda','k',...
    'GammaON','GammaOFF',...
    'GammaON_mag','GammaOFF_mag',...
    'Phase_ON_deg','Phase_OFF_deg',...
    'ReflectionLoss_ON','ReflectionLoss_OFF',...
    'PhaseDifference',...
    'Nx','Ny','TotalElements','ElementSpacing',...
    'ArrayWidth','ArrayHeight');

fprintf('\nHFSS Parameters saved successfully.\n'); %[output:195e670e]
fprintf('Location:\n%s\n', SaveFile); %[output:19de524a]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
%[output:6da7a92f]
%   data: {"dataType":"text","outputData":{"text":"Operating Frequency : 2.45 GHz\n","truncated":false}}
%---
%[output:4f9bc174]
%   data: {"dataType":"text","outputData":{"text":"Wavelength          : 122.45 mm\n\n","truncated":false}}
%---
%[output:96717bbd]
%   data: {"dataType":"text","outputData":{"text":" \n","truncated":false}}
%---
%[output:33bbedc8]
%   data: {"dataType":"text","outputData":{"text":"Available RIS Arrays\n","truncated":false}}
%---
%[output:6827ab99]
%   data: {"dataType":"text","outputData":{"text":"1 = 4 x 4\n","truncated":false}}
%---
%[output:2f67d49c]
%   data: {"dataType":"text","outputData":{"text":"2 = 8 x 8\n","truncated":false}}
%---
%[output:1936a6de]
%   data: {"dataType":"text","outputData":{"text":"3 = 12 x 12\n","truncated":false}}
%---
%[output:4b39ed00]
%   data: {"dataType":"text","outputData":{"text":"4 = 16 x 16\n","truncated":false}}
%---
%[output:8694c592]
%   data: {"dataType":"text","outputData":{"text":"5 = 20 x 20\n","truncated":false}}
%---
%[output:37a15111]
%   data: {"dataType":"text","outputData":{"text":"6 = 32 x 32\n","truncated":false}}
%---
%[output:8fe0b87e]
%   data: {"dataType":"text","outputData":{"text":"===============================================\n","truncated":false}}
%---
%[output:3bc90eed]
%   data: {"dataType":"text","outputData":{"text":"          HFSS UNIT CELL PARAMETERS\n","truncated":false}}
%---
%[output:86731c62]
%   data: {"dataType":"text","outputData":{"text":"===============================================\n","truncated":false}}
%---
%[output:459fc9a1]
%   data: {"dataType":"text","outputData":{"text":"\nON STATE\n","truncated":false}}
%---
%[output:83d56ba7]
%   data: {"dataType":"text","outputData":{"text":"S11               = -1.1850 dB\n","truncated":false}}
%---
%[output:200840c3]
%   data: {"dataType":"text","outputData":{"text":"Reflection Mag    = 0.8725\n","truncated":false}}
%---
%[output:35dc4136]
%   data: {"dataType":"text","outputData":{"text":"Reflection Phase  = 148.90 deg\n","truncated":false}}
%---
%[output:7d6a4eea]
%   data: {"dataType":"text","outputData":{"text":"Reflection Loss   = 1.19 dB\n","truncated":false}}
%---
%[output:9b2c216c]
%   data: {"dataType":"text","outputData":{"text":"Complex Gamma     = -0.7471 + 0.4506j\n","truncated":false}}
%---
%[output:5ef314be]
%   data: {"dataType":"text","outputData":{"text":"\nOFF STATE\n","truncated":false}}
%---
%[output:1fc065d8]
%   data: {"dataType":"text","outputData":{"text":"S11               = -13.7108 dB\n","truncated":false}}
%---
%[output:99607e16]
%   data: {"dataType":"text","outputData":{"text":"Reflection Mag    = 0.2063\n","truncated":false}}
%---
%[output:5766a397]
%   data: {"dataType":"text","outputData":{"text":"Reflection Phase  = -70.26 deg\n","truncated":false}}
%---
%[output:6d80d88b]
%   data: {"dataType":"text","outputData":{"text":"Reflection Loss   = 13.71 dB\n","truncated":false}}
%---
%[output:2c53a284]
%   data: {"dataType":"text","outputData":{"text":"Complex Gamma     = 0.0697 + -0.1942j\n","truncated":false}}
%---
%[output:84d19d37]
%   data: {"dataType":"text","outputData":{"text":"\nPhase Difference = 140.84 degrees\n","truncated":false}}
%---
%[output:7d8a82e2]
%   data: {"dataType":"text","outputData":{"text":" \n","truncated":false}}
%---
%[output:36675cea]
%   data: {"dataType":"text","outputData":{"text":"========== RIS ARRAY ==========\n","truncated":false}}
%---
%[output:480d31a1]
%   data: {"dataType":"text","outputData":{"text":"Array Size          : 4 x 4\n","truncated":false}}
%---
%[output:3742a006]
%   data: {"dataType":"text","outputData":{"text":"Total Elements      : 16\n","truncated":false}}
%---
%[output:3d22ad58]
%   data: {"dataType":"text","outputData":{"text":"Element Spacing     : 61.22 mm\n","truncated":false}}
%---
%[output:8ea48915]
%   data: {"dataType":"text","outputData":{"text":"Array Width         : 183.67 mm\n","truncated":false}}
%---
%[output:63a01146]
%   data: {"dataType":"text","outputData":{"text":"Array Height        : 183.67 mm\n","truncated":false}}
%---
%[output:91a4a35a]
%   data: {"dataType":"text","outputData":{"text":"===============================================\n","truncated":false}}
%---
%[output:195e670e]
%   data: {"dataType":"text","outputData":{"text":"\nHFSS Parameters saved successfully.\n","truncated":false}}
%---
%[output:19de524a]
%   data: {"dataType":"text","outputData":{"text":"Location:\nC:\\Users\\Naman\\Desktop\\Capstone\\Matlab\\Data\\HFSS_Parameters.mat\n","truncated":false}}
%---
