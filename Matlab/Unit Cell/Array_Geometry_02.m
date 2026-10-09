clear; close all; clc;

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


%% 02_Array_Geometry.m (Modified)
% =========================================================================
% Reconfigurable Intelligent Surface (RIS) Research Project
% Script 2: Array Geometry Generation and Visualization
% 
% Description:
%   Generates the physical layout of the RIS array based on the parameters 
%   exported from Script 1. Generates and saves only the 2D RIS Array layout 
%   and the 3D visualization.
% =========================================================================

%% 1. Initialization and Setup


disp('==========================================================='); %[output:15cc6d4b]
disp('   RIS ARRAY GEOMETRY GENERATOR'); %[output:8124982e]
disp('==========================================================='); %[output:15344b4d]

% Define file paths
paramsFile = fullfile(DataFolder,'HFSS_Parameters.mat');

imageFile = fullfile(ProjectFolder,'UnitCell.png');

outputFile = fullfile(DataFolder,'RIS_Array.mat');

figuresDir = FigureFolder;

% Create Figures directory if it does not exist
if ~exist(figuresDir, 'dir')
    mkdir(figuresDir);
end

%% 2. Load Array Parameters
% Ensure the parameter file exists before attempting to load
if ~isfile(paramsFile)
    error('File "%s" not found! Please run Script 1 to generate it.', paramsFile);
end

% Load all variables from the MAT file
load(paramsFile);

% Handle potential unit discrepancies (assuming HFSS output is mostly mm)
if ElementSpacing < 1 
    scale_to_mm = 1000;
else
    scale_to_mm = 1; % Already in mm
end

dx = ElementSpacing * scale_to_mm;
dy = ElementSpacing * scale_to_mm;
W  = ArrayWidth * scale_to_mm;
H  = ArrayHeight * scale_to_mm;

%% 3. Geometry Generation
disp('Generating array coordinates...'); %[output:81b32626]

% Generate linear vectors for X and Y coordinates
x_linear = (0 : Nx - 1) * dx;
y_linear = (0 : Ny - 1) * dy;

% Center the array at (0,0)
x_linear = x_linear - mean(x_linear);
y_linear = y_linear - mean(y_linear);

% Reverse Y so that index 1 is at the top-left (row-wise numbering)
y_linear = fliplr(y_linear);

% Create meshgrid for coordinates
[X_grid, Y_grid] = meshgrid(x_linear, y_linear);
Z_grid = zeros(size(X_grid));

% Store coordinates in a structure
RIS.X = X_grid;
RIS.Y = Y_grid;
RIS.Z = Z_grid;

% Save the structure to a MAT file
save(outputFile, 'RIS');

%% 4. Generate Visualizations

% Common formatting parameters
figColor = 'w';
fontSize = 12;
fontName = 'Times New Roman';

% =========================================================================
% FIGURE 1: Tiled RIS Unit Cell Array (2D)
% =========================================================================
disp('Generating Figure 1: Tiled Unit Cell Array...'); %[output:57fdd458]
fig1 = figure('Name', 'RIS Unit Cell Array', 'Color', figColor, 'Position', [100, 100, 800, 800]); %[output:81566cb6]
hold on; grid on; %[output:81566cb6]

% Check if the unit cell image exists
hasImage = isfile(imageFile);
if hasImage %[output:group:32b891ad]
    [img, ~, alphaChannel] = imread(imageFile);
    disp(' -> UnitCell.png found. Tiling image over array...'); %[output:88f7569c]
else
    warning('UnitCell.png is missing. Drawing placeholder square elements instead.');
end %[output:group:32b891ad]

% Loop through each element position and draw
for row = 1:Ny
    for col = 1:Nx
        % Calculate bounding box for the current element
        xc = X_grid(row, col);
        yc = Y_grid(row, col);
        x_min = xc - dx/2; x_max = xc + dx/2;
        y_min = yc - dy/2; y_max = yc + dy/2;
        
        if hasImage
            % Flip image to correct orientation if needed for 'normal' YDir
            img_flipped = flipud(img);
            if ~isempty(alphaChannel)
                alpha_flipped = flipud(alphaChannel);
                image('XData', [x_min x_max], 'YData', [y_min y_max], 'CData', img_flipped, 'AlphaData', alpha_flipped); %[output:81566cb6]
            else
                image('XData', [x_min x_max], 'YData', [y_min y_max], 'CData', img_flipped);
            end
        else
            % Draw placeholder (patch) scaled to 90% of spacing for visual gap
            gap = 0.05 * dx;
            px = [x_min+gap, x_max-gap, x_max-gap, x_min+gap];
            py = [y_min+gap, y_min+gap, y_max-gap, y_max-gap];
            patch(px, py, [0.8 0.8 0.8], 'EdgeColor', 'k', 'LineWidth', 1);
        end
    end
end

% Set axes properties for Figure 1
axis equal tight; %[output:81566cb6]
set(gca, 'YDir', 'normal', 'FontSize', fontSize, 'FontName', fontName); %[output:81566cb6]
title('RIS Unit Cell Array', 'FontSize', fontSize+2, 'FontWeight', 'bold'); %[output:81566cb6]
xlabel('X (mm)', 'FontSize', fontSize, 'FontWeight', 'bold'); %[output:81566cb6]
ylabel('Y (mm)', 'FontSize', fontSize, 'FontWeight', 'bold'); %[output:81566cb6]
box on; %[output:81566cb6]



%% 6. Display Summary to Command Window
disp('==========================================================='); %[output:04a58355]
disp('                    RIS ARRAY SUMMARY'); %[output:0cb0e09a]
disp('==========================================================='); %[output:4fbcbde2]
fprintf('Array Size         : %d x %d\n', Nx, Ny); %[output:41f14b0a]
fprintf('Number of Elements : %d\n', TotalElements); %[output:6de3c138]
fprintf('Board Dimensions   : %.2f mm x %.2f mm\n', W, H); %[output:5715c27a]
fprintf('Spacing            : %.2f mm\n', dx); %[output:96c7009c]
fprintf('Frequency          : %.2f GHz\n', f / 1e9); %[output:30d7d75a]
fprintf('Wavelength         : %.2f mm\n', lambda * scale_to_mm); %[output:9e583ccc]
disp('==========================================================='); %[output:32f1a4e5]
disp('Script 2 Execution Completed Successfully.'); %[output:35322789]

%% ========================================================================
% LOCAL FUNCTIONS
% =========================================================================

function saveFigureStandard(figH, outDir, fName)
    basePath = fullfile(outDir, fName);
    
    % Save as FIG (For future MATLAB editing)
    %savefig(figH, [basePath, '.fig']);
    
    % Uncomment these if you also want standard image exports:
    exportgraphics(figH, [basePath, '.png'], 'Resolution', 300);
    % exportgraphics(figH, [basePath, '.pdf'], 'ContentType', 'vector');
end

function drawCuboid(cx, cy, cz, w, l, h, color, alphaLevel)
    % Helper function to draw a 3D cuboid patch
    
    x = cx + [-w/2, w/2, w/2, -w/2, -w/2, w/2, w/2, -w/2];
    y = cy + [-l/2, -l/2, l/2, l/2, -l/2, -l/2, l/2, l/2];
    z = cz + [-h/2, -h/2, -h/2, -h/2, h/2, h/2, h/2, h/2];
    
    % Define the 6 faces of the cuboid
    faces = [
        1 2 3 4; % Bottom
        5 6 7 8; % Top
        1 2 6 5; % Front
        2 3 7 6; % Right
        3 4 8 7; % Back
        4 1 5 8  % Left
    ];
    
    % Draw the patch
    patch('Vertices', [x' y' z'], 'Faces', faces, ...
          'FaceColor', color, 'EdgeColor', 'k', ...
          'FaceAlpha', alphaLevel, 'EdgeAlpha', 0.5);
end

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":38.1}
%---
%[output:15cc6d4b]
%   data: {"dataType":"text","outputData":{"text":"===========================================================\n","truncated":false}}
%---
%[output:8124982e]
%   data: {"dataType":"text","outputData":{"text":"   RIS ARRAY GEOMETRY GENERATOR\n","truncated":false}}
%---
%[output:15344b4d]
%   data: {"dataType":"text","outputData":{"text":"===========================================================\n","truncated":false}}
%---
%[output:81b32626]
%   data: {"dataType":"text","outputData":{"text":"Generating array coordinates...\n","truncated":false}}
%---
%[output:57fdd458]
%   data: {"dataType":"text","outputData":{"text":"Generating Figure 1: Tiled Unit Cell Array...\n","truncated":false}}
%---
%[output:88f7569c]
%   data: {"dataType":"text","outputData":{"text":" -> UnitCell.png found. Tiling image over array...\n","truncated":false}}
%---
%[output:81566cb6]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAgIAAAICCAYAAAC9RaXMAAAAAXNSR0IArs4c6QAAIABJREFUeF7tnQu0VdV19ydCIHwiJiRqNGKC8VEiLXk0DQ5isTZWAx+MaKkItQIBA9ZnMQYo8n5\/IokJTQIioMlASTGNMkJNY2iT6ieNX2JoiAQ0YiQhDwWURwkPvd+Y2+zrueeee\/b877PnOXvt8z9jONpw515r7t9\/zb3+Z+219+nU0tLSIvyQAAmQAAmQAAk0JYFONAJNqTtPmgRIgARIgAQiAjQCHAgkQAIkQAIk0MQEaASaWHyeOgmQAAmQAAnQCHAMkAAJkAAJkEATE6ARaGLxeeokQAIkQAIkQCPAMUACJEACJEACTUyARqCJxeepkwAJkAAJkACNAMcACZAACZAACTQxARqBJhafp04CJEACJEACNAIcAyRAAiRAAiTQxARoBJpYfJ46CZAACZAACdAIcAyQAAmQAAmQQBMToBFoYvF56iRAAiRAAiRAI8AxQAIkQAIkQAJNTIBGoInF56mTAAmQAAmQAI0AxwAJkAAJkAAJNDEBGoEmFp+nTgIkQAIkQAI0AhwDJEACJEACJNDEBGgEmlh8njoJkAAJkAAJ0AhwDJAACZAACZBAExOgEWhi8XnqJEACJEACJEAjwDFAAiRAAiRAAk1MgEagicXnqZMACZAACZAAjQDHAAmQAAmQAAk0MQEagSYWn6dOAiRAAiRAAjQCHAO5JfDss8\/K2LFjZffu3VVzfPe73y3nnHOO\/O3f\/q1cdNFF0q1bt9b4devWydSpUzs8fuHChTJixIjo7y0tLfLTn\/5UvvKVr8h\/\/ud\/yoEDB+SCCy6Qa6+9Vi6\/\/HL5r\/\/6L3nPe94j5557boftJfW3du1aGTBggBw+fFimTJkiGzZsaG3rjDPOkNWrV1dtvxqIgwcPyrx58+Rf\/uVfRM\/riiuukE6dOrU55IUXXpDvfOc7ct1118G67927Vx5++GF59NFH5cc\/\/rEcO3ZM3vGOd8iHP\/xh+eQnPykDBw6MtPr5z38ugwcPNre\/efNmGTVqVGt8\/\/795d5775Xu3bu3Y1Sql7mDPwR+73vfk7lz58rKlSvlve99L3o440mgsARoBAorbTFO7PXXX5f\/+I\/\/kFtuuUUOHToUnVQ8GRw\/flx+8YtfyIIFC+Tf\/\/3fo78NHTpU5syZIyeffHIrgCNHjsjnP\/95Wb58eeu\/3X777fKpT32q1TSoCdAJVE3D6NGj5aabbpKTTjpJXnrpJfna174mX\/7yl+XUU081TdQ6yd99992yYsWK1v50Aho5cqSccMIJrf8WGw89N52Yhw8fLl26dEkt3A9\/+MNoQtUJ+s\/+7M+inN\/+9re3tqdGYebMmdF5TJ482dyP8rvvvvvkrrvuitr++Mc\/Lrfeequcd9550rlzZ\/ntb38raoC+9KUvRX9PM1k\/\/fTT8ulPf1r27NkjsRHo1auXaN+q5wMPPNBGe3PyfwjUdqZPny7r16+XWbNmReaOHxIggTcI0AhwJOSeQPnKQPlEo99yx40bJzt37ozOpdKFvvxbZ\/zNPD75uI0ePXpE3xhPOeWUNhO2TiDLli2L\/lZtRSA+qHxloLy\/OE5Nw9KlSyNTcvrpp9ekRbUVATVNX\/ziF6P\/JkyYYDYCcZtf\/\/rXo9zUIOl\/5YZFTc33v\/99ufnmm+Uf\/\/EfW1dZrCdUqnGpEdDjFy9e3Gri0pgMbWPbtm0yZsyYyNjpisw\/\/dM\/tTFJ1jwZRwJFJEAjUERVC3ZOSUZAVwp0mf1b3\/pWdOa6KrBo0aJoaTn+JBkBPVYnuD59+kTL0uVLx\/qNUick\/VaftRH4whe+EK0I6Ddgj4\/mrqsD+o1dDYHVCOjkrrdJ7rzzzigtXQnQVQFdKan0ieP1POLbLdbz8TQCmpeauM997nNROmpi7rnnHhk0aJA1PcaRQKEJ0AgUWt5inBxqBK666qpoOblr165mI6C3BW677bYoXr+R6u2GP\/qjP2pzj13NhN4T9zYC5eerKwW6lK\/39v\/t3\/5N3vrWt0a3SnR5O\/5mXr4CEZshXXGYMWOGbNy4sd1gqGSYSoNKv0Xrv+vtDj2m2kdz1\/9K9wioEfn2t78dmZHt27dH+y4+85nPyJ\/\/+Z+38vU0Ar\/5zW+iVaKtW7e27jfR2zB6u6Z0P0l8XroXQleYtmzZEv1TvHfjne98Z7Si8s\/\/\/M\/RbQzdvzJt2rQ2+zx05UfHz5o1ayITpRyUv5rS+FbQ\/fffH93K0tsgajy1nb\/5m7+JcinvO84pXglJMrTFqHieRb0J0AjUmzj7gwkkGYHSWwP6bVX3Aujyb+kn6QJaPunpBDts2LDom7reCy\/fdJd0EsitgUorAqX3zDWXO+64Q\/76r\/86+kauk0z5t1qdZHSy\/fu\/\/\/sotfJJvnR53bIiUP4tWg2QbmTs169f0qm3+XvpLQk9B11R0fNdtWpVtG\/jE5\/4RBTvaQR0Q6aej+4niVcF9NaPcuzbt2\/F8\/nVr34l48ePj4yLGgFdUXjXu94V7SPRFZL49oXqMGnSJNm0aVPUju6lOPvss+VHP\/pRZCzjfSW6mVVvL+lmTtXwL\/7iL+S73\/2u3HjjjdEqjRq7G264IdJVb3F99rOfFd3zoR9d7dJxGI9BHRu6R0PNbqmZgoRhMAmUEKAR4HDIPYGOjIBeQHfs2BFdWPUblk7++s35T\/7kT9pN3ElGQCeKr371q9GFWtst\/ehF+x\/+4R+ib7JWQ1CrESg959KnCUrbLZ\/QS8+xViOgewN0gnvsscciFLo6ordM0H0MuhKhk1bpRsvHH388Ws0ovVfvZQT0PHR8KKt9+\/a17hPQc1JNdSKupGnpN3M9Z933cNlll0Xf2PV8LrzwQrn++uujzZGlT3\/o+NGnNV577bVoY6auSumKwMsvvxx983\/++edbJ32d8OOnYv74j\/+4zd4UZaTt622vj33sY9FqTLzxU3V+8sknK+7VyH0xM8FcEqARyKUsTKqUQNJjhLqkqku2eg+7o0+SEdDj1AB885vfjPYC6LJt6Ue\/qemTBnrhtuzsr4cR+Lu\/+7toJ3ycT5ZGoHyJunwDn2WE6iSstwD0dkbp8XGeJ554ougy+Qc\/+EG3FQH9Vv2DH\/xAJk6cKL\/\/\/e\/bTNo6+erqkX7TL\/+Un7+aCZ3gyz\/lj4Hqt\/r4FlNprN6eUDPyk5\/8RP7qr\/5KlixZIr\/+9a9bjUD5o6OlTzmUrv7oGNWVlCFDhnS4mmHRhjEkUEqARoDjIfcEKq0I6OSh35jiJwX0cTldctZvnpU+FiMQH6eTgN7r1Q1l+i6B+KMX5Pnz50eP+SWtDNTDCJR\/68\/SCOi3Z70PHi9P63K33hro3bu3ebzs2rWr9VtwRwepgdNJzWNFQCdN\/Sat9+njWwB6m0CX4eNPR\/seyo1Atac+SlcEqj3VoG3qOxZ0dUW\/6eutCb1FonlWeoeEvvdAbwno32PzoCsLmouajUr7G8ziMJAESgjQCHA45J5AJSOgGwL1nqtu1oqX8vVbny5nV\/rGnmQEdAlcl\/5Ll77VBOjz62oI4hWCD3zgA9H7AXTjWLVP6Ebg6NGj0ZJ2\/Nhgmj0CHd3eqMTNwwhom6qf3i6KJ83Sb+aaRzzB6mOjpR8PI6DtqwFQQ6W3svRxRl190pcwVTICasZ0hUHHrq6eqHHQF17pLYKkTZu5L2ommCsCNAK5koPJJE0S+vf4W1f5y2bUAOhO7UsuuaRdM0lGQE2FbiCr9EiZfrNVg6Hfjq1v\/4sfR4wTqfaNstJmQcseAc8VAc3b+u25o1GrqzU62Sm\/JCORtREo3+zYUY7xBKtvR\/Q2AvoUgt5e+p\/\/+Z9ov4W+XCreI9DRuCrVQFdOdIyrsal0O4NXDxJIS4BGIC05Hlc3AtWeGtBvePr8f7yErY9j6Tf2973vfW3ySzIC+g1ed3F39Jz8gw8+GG0Ys26ae+qpp6JXHserFR0ZAV3q1Z3mummtdKk3D0ZAv5HqMrpuXNNP0uOGGqPH6ASnb3bcv39\/dF7x8dUeP8zaCOi40Bc16ZsiS9+uqDmWPyGijwrq5Fq6kpT1ioA+2aK3Wp577rlWjr\/85S8TjUD5Cka1DY51K0h2VDgCNAKFk7R4J5T0+KBONLqEGt\/P101ds2fPltLlXosR0Emjozfn6b1c3RFe+phXNdKly7oapzvIdad86d4C\/daqKxH6b7rvoPSTByOg+ehTGfFejKQ9EroCoJOvTqpnnnlm9Mhe6QuJypfh9TG4t73tbdGz9Fkagbhf\/bZf6VXC5StJ+m1cv6Gff\/75rRJkbQRK31Px0Y9+NNrPoo8c6mbPjvYIaDKlKxtJqyrFq3yeUb0I0AjUizT7SUWg0m8N6HKzbpbSC71+Sp9VjzvRCUAnbf02aPmtgdJ7+vr0gW4A07cLav\/66ly9X64bEvXFND179jSdi\/5Ikeap94D1\/Qa6oqDvJtCXy6hR0NsHuiKgu8lL34KojZe+R0D3LeirjXWi0glLb43oRzfB6RsU1fCUv0dAJxvdiBfvZdAfCtLX\/yqra665Jnqe\/3e\/+53p7Xq6tK\/vANAfYnrLW94SvatA3xx42mmnRXnobw3o0xZ6vmqm9L0L8Uf70H515378PgQ9VnfM63P98XPwpeerxkD3ZegGxfJJW9vS\/0p\/s6FUDN3F\/8gjj0QvhFJOaj4q7RnRSVjfExB\/VFvdya8GRj+l7xHQ\/61vZdTHB8s3ieqqR+l7BPT8dYWhPL\/yW0U6HvRdAWoE9ZaBaqx7B0rZxbnFJknf4aA5lu9nMA1GBpFAFQI0AhweuSWQ9Nhg6XP05cvYelL6TU8nnfglMpVONN5voPdi9YkDfQeBvphHH2vTN9HpRy\/Aaj50IkB3auu77dVk6PP0P\/vZz6L29JudPkOvE\/JHPvKRdpNGpfPWc7n44oujHeOln3i5Xie\/8l9ZLH1kTw2AnpMuz+uz7fotv\/TNhEmDQA2RvlxHJy79Eaj4aY341wd186b++mAlPspA3yr40EMPRb+6qPfjdQVH43ViLV+tibXTY9QAlf5Co\/6toxciVfpFR40vvS3T0Zv74vPXWJ2MS98sGP+tvN+O+qt0C0UfpdRxqO3rL2Tquwj0SQY1UGou9aNPCOiegdjgxv2qdvoWxD\/90z\/lJsGkgcq\/pyJAI5AKGw8iARIggfoQUBOhhlWfikEe36xPduylCARoBIqgIs+BBEigsAT0tom+lElvM1leZlVYEDwxNwI0Am5o2TAJkAAJ4AR0g6Y+baG3qfSWgP7Ikb7jovwRR7xlHkEClQnQCHBkkAAJkECOCMRPGOi+EL0loBstdYNm+YbSHKXMVAInQCMQuIBMnwRIoFgEdHOl\/rKgblrVHzfSx1a5N6BYGuftbGgE8qYI8yEBEiABEiCBOhKgEagjbHZFAiRAAiRAAnkjQCOQN0WYDwmQAAmQAAnUkQCNQB1hsysSIAESIAESyBsBGoEqiugrTvkhARIgARIggUoEnn\/++UKAoRGoIuPO3+4shMg8CRIgARIgAR8CfU7r49NwHVulEaARqONwY1ckQAIkUCwCNALF0rPd2XBFoOAC8\/RIgARIoEYCNAI1Asz74TQCeVeI+ZEACZBAYwnQCDSWv3vvNALuiNkBCZAACQRNgEYgaPmSk6cRSGbECBIgARJoZgI0AgVXn0ag4ALz9EiABEigRgI0AjUCzPvhNAJ5V4j5kQAJkEBjCdAINJa\/e++IEdh+5dly+dSZ7jkVqYOdHxntcjp9nrrPpd2iNkod8qMstciHFogONAL50MwtCxoBN7RRw0ixIZnQCCC0qANGyzeaNeHL19o6ogONgJVqoHE0Ar7CIcWGZEIjgNCiEcBo+UazJnz5WltHdKARsFINNI5GwFc4pNiQTGgEEFo0Ahgt32jWhC9fa+uIDjQCVqqBxtEI+AqHFBuSCY0AQotGAKPlG82a8OVrbR3RgUbASjXQOBoBX+GQYkMyoRFAaNEIYLR8o1kTvnytrSM60AhYqQYaRyPgKxxSbEgmNAIILRoBjJZvNGvCl6+1dUQHGgEr1UDjaAR8hUOKDcmERgChRSOA0fKNZk348rW2juhAI2ClGmgcjYCvcEixIZnQCCC0aAQwWr7RrAlfvtbWER1oBKxUA42jEfAVDik2JBMaAYQWjQBGyzeaNeHL19o6ogONgJVqoHE0Ar7CIcWGZEIjgNCiEcBo+UazJnz5WltHdKARsFINNI5GwFc4pNiQTGgEEFo0Ahgt32jWhC9fa+uIDjQCVqqBxtEI+AqHFBuSCY0AQotGAKPlG82a8OVrbR3RgUbASjXQOBoBX+GQYkMyoRFAaNEIYLR8o1kTvnytrSM60AhYqQYaRyPgKxxSbEgmNAIILRoBjJZvNGvCl6+1dUQHGgEr1UDjaAR8hUOKDcmERgChRSOA0fKNZk348rW2juhAI2ClGmgcjYCvcEixIZnQCCC0aAQwWr7RrAlfvtbWER1oBKxUA42jEfAVDik2JBMaAYQWjQBGyzeaNeHL19o6ogONgJVqoHE0Ar7CIcWGZEIjgNCiEcBo+UazJnz5WltHdKARsFINNI5GwFc4pNiQTGgEEFo0Ahgt32jWhC9fa+uIDjQCVqqBxtEI+AqHFBuSCY0AQotGAKPlG82a8OVrbR3RgUbAShWMO3DggDzyyCPyzDPPyB133CHdu3dv18Lhw4dlzZo1smrVKjl69KhMnDhRxowZ0y7WGlcpRRoBUDgwHCk2pGkaAYQWjQBGyzeaNeHL19o6ogONgJUqELdt2zZ59tln5e6775Z+\/frJokWL2k3uR44ckYULF8qePXtkxowZ0q1bN5k1a5Z06tRJZs+eLT169Ih6tMZ1lB6NACBcilCk2JDmaQQQWjQCGC3faNaEL19r64gONAJWqmDc8ePHZe7cufLKK69UNAKbNm2SqVOnyooVK6R\/\/\/5R62ogxo8fL9OmTZPBgwdH\/2aNoxEABcooHCk2pEsaAYQWjQBGyzeaNeHL19o6ogONgJVqirjFixfL7t272xkBXeqfMmWK7Nu3T5YtWyY9e\/aMWj906FD078eOHZMlS5ZI586dTXHx6kGlFLkikEI44BCk2IBmhUYAoUUjgNHyjWZN+PK1to7oQCNgpZoiriMjsGvXLhk7dmy0ErBgwYLotoB+WlpaotsFugqwevXq6N8scb179+4wOxqBFMIBhyDFBjRLI4DAEhoBEJdrOGvCFa+5cUQHGgEzVjywIyOwY8eOaIIfNmyYTJ48uU3Desz69esjI9C1a1dTnO5D6OhDI4DrhhyBFBvSLlcEEFo0Ahgt32jWhC9fa+uIDjQCVqop4joyAps3b5ZRo0bJhAkTKhqB5cuXy9q1a6MeLXEDBgygEUihTxaHIMWG9EcjgNCiEcBo+UazJnz5WltHdKARsFJNEdeREdi6dWv0TX\/48OFVVwS0S0scVwRSiJPRIUixIV3SCCC0aAQwWr7RrAlfvtbWER1oBKxUU8Ql7REYOHCgTJ8+Xbp06RK1Hj9p8MQTT7TZI5AUxz0CKcTJ6BCk2JAuaQQQWjQCGC3faNaEL19r64gONAJWqinikp4a0KcHli5d2vrOgIMHD8qkSZOidw7ouwf0o08RJMVVellRnC73CKQQDjgEKTagWW4WRGBxsyBIyzecNeHL19o6ogONgJVqiriOjIA2tXHjRpk\/f76sXLlS+vbtG7Ve6T0C1riO0qMRSCEccAhSbECzNAIILBoBkJZvOGvCl6+1dUQHGgErVTDu1Vdfldtvv130UUF9aVD58r1++585c2b0yKC+UVDfIDhnzpzoSYHSNwta42gEQIEyCkeKDemStwYQWrw1gNHyjWZN+PK1to7oQCNgpQrErVu3LnprYOlH3w8wYsSINv+2f\/\/+6HcG9FFBfSnQuHHjZOTIke1eR2yNq5QiVwQA4VKEIsWGNE8jgNCiEcBo+UazJnz5WltHdKARsFINNI5GwFc4pNiQTGgEEFo0Ahgt32jWhC9fa+uIDjQCVqqBxtEI+AqHFBuSCY0AQotGAKPlG82a8OVrbR3RgUbASjXQOBoBX+GQYkMyoRFAaNEIYLR8o1kTvnytrSM60AhYqQYaRyPgKxxSbEgmNAIILRoBjJZvNGvCl6+1dUQHGgEr1UDjaAR8hUOKDcmERgChRSOA0fKNZk348rW2juhAI2ClGmgcjYCvcEixIZnQCCC0aAQwWr7RrAlfvtbWER1oBKxUA42jEfAVDik2JBMaAYQWjQBGyzeaNeHL19o6ogONgJVqoHE0Ar7CIcWGZEIjgNCiEcBo+UazJnz5WltHdKARsFINNI5GwFc4pNiQTGgEEFo0Ahgt32jWhC9fa+uIDjQCVqqBxtEI+AqHFBuSCY0AQotGAKPlG82a8OVrbR3RgUbASjXQOBoBX+GQYkMyoRFAaNEIYLR8o1kTvnytrSM60AhYqQYaRyPgKxxSbEgmSUagy955crzXHUiThY5tlA6Fhpry5BqlBWuirWCIDjQCKQd7KIdlbQRO+OIcef2mGR2e\/qMLZ8v533i+9e\/brzxbLp86s+G4NC\/9xLlllRdSbAiELIxAqRZZnS9yDh3FluelcbWOkYbpcNo8Of7b6oYszzXhUasN0yLBHHtdA4pQEzQCWaiY4zayNAJdz1ogr331NXlt0PQ2Z1x+oauGI2mCyxJlPfLK20XPmk89dVBNrXmlNSzW9tHxlcRJa+L47cfbmWNrPmnPFz2POL7ZaqIe55tWC+8xYm1f86cRSKtiIMdlaQQqnTIy2OLj63Hxq1deafqxDJ2kCai8jbR5oP1Yci+NqVdeaftJOh+UDzLxlPaN9pOUdyNrNS9apM3DW4t65YX0QyOQpqICOsbTCCADrRyZpxmoJa\/IHT91n1nhWvvqqKN65oD0ZQYDrALkgUEWOaQ1AfUwyLWMU7RWa+krq9XEWnNotpqgEUCubAHGehmBWgsNnXCt6LPIC7nwZdFfpXOzXoiy6t\/aXz11QMZIVhzKzw\/hkkUOSH\/11II1YaXdcVwW48OrJmgEatc31y14GIGsBjQyqC2QG5FXln2iS8VZ953VJFTrN+M0k3HWLOIcrEyy7N\/aJ2uiPYEsdUDMT5IWea8JGoEkBQP\/e9ZGIOsBnaUZyPIiYM0r6z6RCSjrvrOagBqRV9Z9NlKHrCagRtVqkbRolpqgEQh8ok9KP2sj4FHkWRSbR16WC7JHvxYT0nn7XHnumueS5If\/XqsWHpOPhUejdNDcPPquVYdG5uXBwzIG8loTjeKB9EsjAF8qwzogBCNgmXCTqCODPqktZIm+Uf3yotdWxUbp4GV88loTlrwapQVrIn1N0Aggs0KAsVkaAa+LnsXtV0PfyLx40Ut\/8UHKKekbcqN08OqXNdF+dCSNARqB9LVII4BcjQKMzdII5PWi18i8vPrmRa9tsSV9E22UDl791moEGpmXV9\/VakK\/DAy58oRc3i7z4pFlTdAIBDi5IynTCCC08G8hXkVOI0AjkDQGqo1sr3FpMShefdMI+NUEjUBt80Tuj0aMQF5Pps\/p75PZLS1y7W\/e\/A2DvOZar7zO+do5Lt9+quWvOuhn569\/Xq\/TZD8dEGBNtAfDmkhfLjQC6dkFcaSnEejzzgNBMECSXHPhx2TQhi3IIQ2JLb3oFVGHyHC8fFJD2NbSaRG1CEUH1kT6kUsjkJ5dEEfSCGAy0QhgvDyjQ5mAShnQCHiOiOpt0wikZ08jkJ5dEEfSCGAy0QhgvDyjaQQ86drbDkUHGgG7puWRNALp2QVxJI0AJhONAMbLMzqUCYgrAp6jwN42jYCdFY1AelZBHkkjgMlGI4Dx8oymEfCka287FB1oBOya0gikZxXkkTQCmGw0Ahgvz+hQJiCuCHiOAnvbNAJ2VjQC6VkFeSSNACYbjQDGyzOaRsCTrr3tUHSgEbBrSiOQnlWQR9IIYLLRCGC8PKNDmYC4IuA5Cuxt0wjYWdEIpGcV5JE0AphsNAIYL89oGgFPuva2Q9GBRsCuKY1AelZBHkkjgMlGI4Dx8owOZQLiioDnKLC3TSNgZ0UjkJ5VkEfSCGCy0QhgvDyjaQQ86drbDkUHGgG7pjQC6VkFeSSNACYbjQDGyzM6lAmIKwKeo8DeNo2AnRWNQHpWQR5JI4DJRiOA8fKMphHwpGtvOxQdaATsmtIIpGcV5JE0AphsNAIYL8\/oUCYgrgh4jgJ72zQCdlY0AulZBXkkjQAmG40AxsszmkbAk6697VB0oBGwa0ojkJ5VkEd6GIFb\/4\/I5z8rUsRfWgvNCLQcf7ec\/a6fBTk2k5IOZQLS8yhyTYSiA41AUkV1\/Hf+6FB6dkEc6WEE4hOnEWjcENCL3id2PSdfnFpMQ6ZkQ5mA1Ix16vKraDAUsSZC0YE1kf56RCOQnl0QR2ZpBG5f1Uee+c5d8q0HrqzrRe9H3T4kHzryo7rwDmVF4Nqpr8j9C99Wdx2eEZFr6qRFCBPQxMXvkB3fny6bvnVr3bWoV02EoMMlQz4vZ\/7JGNZEyqskjUBKcKEclrUR+OFDt9T9ovdktw\/JhXWafEIxApd+crl855sT6jr5qA4\/aWmRTx99ui7DP4QJqFFGoJ41EYIOagQ6v6U7ayJlZdIIpAQXymFZGoFQzpl5kgAJkAAJ2AnQCNhZBRlJIxCkbEyaBEiABOpGgEagbqgb0xGNQGO4s1cSIAESCIUAjUAoSqXMk0YgJTgeRgIkQAJNQoBGoOBC0wgUXGCeHgmQAAnUSIBGoEaAeT+cRiDvCjE\/EiABEmgsARqBxvJ3751GwB0xOyABEiCBoAnQCAQtX3LyNALJjBhBAiRAAs1MgEag4OrTCBRcYJ4eCZAACdRIgEagRoB5P5xGIO8KMT8SIAESaCwBGoHG8nfvnUbAHTE7IAESIIGgCdAIBC1fcvI0AsmMGEECJEACzUyARqDg6tMIFFxgnh4JkAAJ1EiARqBGgHk\/nEYg7woxPxIgARJoLAEagcZuY3SkAAAgAElEQVTyd++dRsAdMTsgARIggaAJ0AgELV9y8jQCyYwYQQIkQALNTIBGoODq0wgUXGCeHgmQAAnUSIBGoEaAeT+cRiDvCjE\/EiABEmgsARqBxvJ3751GwB0xOyABEiCBoAnQCAQtX3LyNALJjBhBAiRAAs1MgEag4OojRmD7lWfL5VNnFpxItqe38yOjs23wD631eeo+l3aL2ih1yI+y1CIfWiA60AjkQzO3LGgE3NBGDSPFhmRCI4DQog4YLd9o1oQvX2vriA40AlaqgcbRCPgKhxQbkgmNAEKLRgCj5RvNmvDla20d0YFGwEo10DgaAV\/hkGJDMqERQGjRCGC0fKNZE758ra0jOtAIWKk6xT3++ONy\/fXXy6FDh1p7uPvuu2Xo0KGt\/\/vw4cOyZs0aWbVqlRw9elQmTpwoY8aMke7duydmRSOQiKimAKTYkI5oBBBaNAIYLd9o1oQvX2vriA40AlaqDnEHDhyQO++8U04++WQ54YQToh569uwpV111lZx00knR\/z5y5IgsXLhQ9uzZIzNmzJBu3brJrFmzpFOnTjJ79mzp0aNH1cxoBByEK2kSKTYkExoBhBaNAEbLN5o14cvX2jqiA42AlapD3KOPPionnniiXHTRRR22vmnTJpk6daqsWLFC+vfvH8Vt27ZNxo8fL9OmTZPBgwfTCDhoY20SKTZrmxpHI4DQohHAaPlGsyZ8+VpbR3SgEbBSzTjupZdekhtvvFGef\/55ufTSS2X06NFy3nnnRd\/044\/eEpgyZYrs27dPli1bFq0W6EdvI+i\/Hzt2TJYsWVJ1VYArAhkLV9YcUmxIJjQCCC0aAYyWbzRrwpevtXVEBxoBK9WM455++ml56KGH5Mknn5SdO3dKly5dom\/5N910U+u9\/127dsnYsWOjlYAFCxZEtwX009LSEt0u0NWC1atXS+\/evTvMjkYgY+FoBHyBpmwdueghXdCQIbTeiKUWODOPIxAdaAQ8FADbfPHFF2XevHny2GOPRUZA\/1NjsGPHjsgIDBs2TCZPntym1cWLF8v69esjI9CvXz8aAZB5VuFIsSF9cgJCaHHywWj5RrMmfPlaW0d0oBGwUnWOO3jwoMycOVP0KQJ9QqBv376yefNmGTVqlEyYMKGiEVi+fLmsXbtWBgwYQCPgrE9HzSPFhqRII4DQohHAaPlGsyZ8+VpbR3SgEbBSrUPcCy+8IOPGjZNJkybJkCFDZOvWrdGKwPDhw7kiUAf+abpAig1pn0YAoUUjgNHyjWZN+PK1to7oQCNgpVqHuHhz4MUXXyxXXHGFxHsEBg4cKNOnT49uF+jn+PHjMnfuXHniiSe4R6AOulTrAik2JFUaAYQWjQBGyzeaNeHL19o6ogONgJVqHeL0aQCd4PUJAr01EBsD\/b9Lly5tfTpAbyPoqoG+UGjRokVVXyzEzYK+wiHFhmRCI4DQohHAaPlGsyZ8+VpbR3SgEbBSrUPc9u3boycJbrvtttYnBDZu3Cjz58+XlStXRuZAP3yPQB3EMHaBFJuxySiMRgChRSOA0fKNZk348rW2juhAI2ClmmGcvlHw1ltvlTPPPDN6vfCpp54qW7ZskYcfflhuuOEGOeWUU1p7izcR6iOD+kZBfdPgnDlzpGvXrnyzYIaapG0KKTakDxoBhBaNAEbLN5o14cvX2jqiA42AlWqGcXqP\/\/777xf9TQE1BRdccIFcd911ctlll7WuBJR2t3\/\/\/uh3BvRRQX2lsG4oHDlyJH9rIENN0jaFFBvSB40AQotGAKPlG82a8OVrbR3RgUbASjXQOO4R8BUOKTYkExoBhBaNAEbLN5o14cvX2jqiA42AlWqgcTQCvsIhxYZkQiOA0KIRwGj5RrMmfPlaW0d0oBGwUg00jkbAVzik2JBMaAQQWjQCGC3faNaEL19r64gONAJWqoHG0Qj4CocUG5IJjQBCi0YAo+UbzZrw5WttHdGBRsBKNdA4GgFf4ZBiQzKhEUBo0QhgtHyjWRO+fK2tIzrQCFipBhpHI+ArHFJsSCY0AggtGgGMlm80a8KXr7V1RAcaASvVQONoBHyFQ4oNyYRGAKFFI4DR8o1mTfjytbaO6EAjYKUaaByNgK9wSLEhmdAIILRoBDBavtGsCV++1tYRHWgErFQDjaMR8BUOKTYkExoBhBaNAEbLN5o14cvX2jqiA42AlWqgcTQCvsIhxYZkQiOA0KIRwGj5RrMmfPlaW0d0oBGwUg00jkbAVzik2JBMaAQQWjQCGC3faNaEL19r64gONAJWqoHG0Qj4CocUG5IJjQBCi0YAo+UbzZrw5WttHdGBRsBKNdA4GgFf4ZBiQzKhEUBo0QhgtHyjWRO+fK2tIzrQCFipBhpHI+ArHFJsSCY0AggtGgGMlm80a8KXr7V1RAcaASvVQONoBHyFQ4oNyYRGAKFFI4DR8o1mTfjytbaO6EAjYKUaaByNgK9wSLEhmdAIILRoBDBavtGsCV++1tYRHWgErFQDjaMR8BUOKTYkExoBhBaNAEbLN5o14cvX2jqiA42AlWqgcTQCvsIhxYZkQiOA0KIRwGj5RrMmfPlaW0d0oBGwUg00jkbAVzik2JBMaAQQWjQCGC3faNaEL19r64gONAJWqoHG0Qj4CocUG5IJjQBCi0YAo+UbzZrw5WttHdGBRsBKNdA4GgFf4ZBiQzKhEUBo0QhgtHyjWRO+fK2tIzrQCFipBhpHI+ArHFJsSCY0AggtGgGMlm80a8KXr7V1RAcaASvVQONoBHyFQ4oNyYRGAKFFI4DR8o1mTfjytbaO6EAjYKUaaByNgK9wSLEhmdAIILRoBDBavtGsCV++1tYRHWgErFQDjaMR8BUOKTYkExoBhBaNAEbLN5o14cvX2jqiA42AlWqgcTQCvsIhxYZkQiOA0KIRwGj5RrMmfPlaW0d0oBGwUg00jkbAVzik2JBMaAQQWjQCGC3faNaEL19r64gONAJWqoHG0Qj4CocUG5IJjQBCi0YAo+UbzZrw5WttHdGBRsBKNdA4GgFf4ZBiQzJJMgJd9s6T473uQJosdGyjdCg01JQn1ygtWBNtBUN0oBFIOdhDOYxGwFcppNiQTGgEEFpcEcBo+UazJnz5WltHdKARsFINNC5LI9DltHnS8vUWeW3Q9HY0Hl04W87\/xvNVKSVNbh6IvfNCig05vyRW1b79JOWU1DaSJxKblNf2K8+Wy6fORJpsjU1qO1WjIpLEqutZC+T47cfl9ZtmtOsiKadazjft+ehxrIn29JJ0roV3tWOTxkgteSW1XZoXjYCXwjlpN0sjUOmUkMEWH1\/L4LZitVzsyttKk1ea87ecA5pLvc7Xknt5DMoozQSJ9mE9D1QHbTdNLmn6sZ5DHFevMZLm\/C3ngjKq1\/lacq+1JtBzR8chjUAaFQM6xtMI1FLwaQa2FXuaC0Bak1ILg2rng\/Cp5\/laNYjj0vJBzUDafpLOB9EBvfhmYUST8q9VBz2+ngyKXhO11KpnTdAIWCsp0DgvI5DFhRe9wFgkqHdeWfRX6bysbGq5sMT9ohcYiw5Z5IVMQo3WoVYTkNaIWrTIgo11PGbFoZaayOJ8m60maAQslRRwjIcRyKLQPC58WU0+IU1AWWmBXOgt5ZBVXtYLclb9pf2WnmX\/WWrBmrCM1soxWeqQpUGy5oWMSRqB9OMkiCPzbgSsF3oLbGTgJ7VnzSvLPktzshR71n1b+kziluUFDzGLWbNA+s5yskVMaL21YE1YiFeOyXp8WmoV6ZNGIL22QRyZtRFABpcVkGVQJ7XVqLw8+rVMBllPPtqn9UKfRy0apYOH8bHon6RBI\/NqlBZ5rYlG5YXoQCNgqaiAY2gE0otnmRiRYkMySTJHnbfPleeueQ5p0hSb1G9SIx4XPcvE2CgdGjnhJmnhwcQyPjz6tYyBvNZEo3gg\/dIIJFVT4H\/P0gh4XeQtRV5NhkbmhRQbMpSSLri86LWl2SgdvPplTbSvFtZEWyZJPJCxSSOAXJ0DjM3SCCADC0WVNKirtdfIvLz6TuLRbEYgaXWmUTp49VurEWhkXl59V6sJ\/TIw5MoTcrlK5sUjy5qgEUBnrMDiaQRqEyxpQvYq8qR+aQS4IkBz\/CYBGoH2owG5NtEI1DZP5P5oxAjk9WT6nP4+md3SItf+pvorjPOav0de53ztHJdvP9VyVR2ie+K\/\/rnHKbFNgABroj0s1gQwgMpCm8YIrFu3TqZOndqO1MKFC2XEiBHpCeb8SE8j8L2h\/XN+9unSG7RhS7oD63hU6UWPOtQRfEJXRdQihHpQWVgT6eug8EagIwNQjqyohsDTCPR554H0Iy+nR6658GMSwoWv9KJXRB2ilYeXT8rpKOk4rSJqEYoOrIn05VJYI3D48GGZMmWKbNiwwUxn6NChsmjRIunevbv5mLwH0ghgCtEIYLw8o0OZgEoZ0Ah4jojqbdMIpGdfWCOwePFiWb58uVgm91LTMGHCBJk8eXJ6ojk7kkYAE4RGAOPlGU0j4EnX3nYoOtAI2DUtjyykEdi8ebM88MAD8Lf72BCMHDlSBgwYkJ5qjo6kEcDEoBHAeHlGhzIBcUXAcxTY26YRsLMqvBHQyfzBBx+Uq6++OtUSf63Hp5fC50gaAYwrjQDGyzOaRsCTrr3tUHSgEbBrWngjkB5FMY+kEcB0pRHAeHlGhzIBcUXAcxTY26YRsLOiEajA6r777ov2EvTq1Ss9yZweSSOACUMjgPHyjKYR8KRrbzsUHWgE7Jo2pRF49tlnZezYsbJ79+6KpPr37y\/33nsvjQA4joq4Q5pGABwEjuGhTEBcEXAcBEDTNAIArLLQQm4WLD1Hy2OENALpBhCNQDpuWRzFi14WFLNvo4g1EYohY02kH8+FNwJ79+6VcePGyZYtHb8tjkYg3QAq4kWPKwLpxoLHUaFMQFwR8FAfb5NGAGcWH1F4I6Anqu8UGDRoUGEeCUTk5h4BhJYIjQDGyzOaRsCTrr3tUHSgEbBrWh7ZFEZAVwXuueceufnmmys+UsjNgukGEFcE0nHL4ihe9LKgmH0bRawJGoHsx0naFr20aBojUO32AG8NpBuWRbzocUUg3VjwOMrroueRa+sSawF\/fyMUHWiO04\/swhsBbhbcmX50JBxJI+CGNrFhXvQSETUkoIg1QSPQkKFUsVMvLQpvBLhZMFsj8KmZr0cDdNXsE6SIF71QVgSunr9d\/tfRc+XtPTvLNxbuz8+VKsNMvC56GaYYNVX0mghFh7gminpt0rHmpUXhjUARfz8AuZB5bBb852+fKH9z2SEaAUSIjGN1RWBer1\/L1YOLqYPnRS9jKaLmilwTXpNP1jqwJtITLbwRUDS6KqA\/Rzx69OiKpLhZ0D6A9NuPOm79cEXAzi3ryEuGfF42fevWwuoQihFQHYZc9Vm5bfTRwmoRihFgTaS\/yhTeCPDWQHa3Bu5Y10f+7\/23yM4tX3pjxP3+h+lHHnDkL9764Sh6d0uLXHjkR8CReGgotwYu\/eRyee7\/3dUQHbTT99RB+xAmoGaoiRB0UBPQ+S3dWRP4Je8NA3tan5RH5uewTi0tLS0dpUMjkJ0RUMZFd92hGIGi6xDSikC8MlPUVbIQjEAzXJs8a4JGQET4+GB+XB0zIQESIAESqC+BpjAC1fYHKG7uEajvoGNvJEACJEAC+SFQeCOQH9SNycTjqYHGnAl7JQESIAES8CBAI+BBNUdt0gjkSAymQgIkQAI5JEAjwFsDORyWTIkESIAESKBeBJrCCDz77LMyduxY2b17d0Wued8sqC9FWrNmjaxatUqOHj0qEydOlDFjxlT8AaXyE+SKQL1Kif2QAAmQQJgECm8EQv+tgSNHjsjChQtlz549MmPGDOnWrZvMmjVLOnXqJLNnz5YePXpUHXk0AmEWJrMmARIggXoRKLwRCP09Aps2bZKpU6fKihUroscc9bNt2zYZP368TJs2TQYPHkwjUK9qYT8kQAIkUEAChTcCqtnixYtl0KBBMmDAgKAkjFcz9u3bJ8uWLZOePXtG+R86dEimTJkix44dkyVLllRdFeCKQFCSM1kSIAESqDuBpjACuipwzz33yM0331zxvnpe3yOwa9euaG+DrgQsWLAgui2gH32Rot4u0NWC1atXS+\/evTscODQCda8pdkgCJEACQRFoGiMwbtw42bJlS0Vx8rpZcMeOHZERGDZsmEyePLlN7rrKsX79+sgI9OvXj0YgqLJjsiRAAiSQHwKFNwIhbxbcvHmzjBo1SiZMmFDRCCxfvlzWrl1b9ZYHVwTyU2zMhARIgATySKDwRiDkzYJbt26NVgSGDx\/OFYE8Vg9zIgESIIECECi8EYhXBEaOHBncZsF4j8DAgQNl+vTp0qVLl2jIHT9+XObOnStPPPEE9wgUoAh5CiRAAiTQSAKFNwIKV1cFqv3wUF43C8YmRv\/v0qVLW58OOHjwoEyaNCna+Lho0aKqLxbirYFGlhf7JgESIIH8Eyi8EQj51oAOn40bN8r8+fNl5cqV0rdv32hE8T0C+S8sZkgCJEACoRCgERCJHs+79957pVevXrnTTb\/9z5w5M3pkUN8oqG8anDNnjnTt2pVvFsydWkyIBEiABMIjQCOQcyOgQ2r\/\/v3R7wzoo4L6SmF9FFL3POitgaQPbw0kEeLfSYAESKC5CTSFEai2P0Dlz+segSyGJo1AFhTZBgmQAAkUl0DhjIBurHvwwQfl6quvNn1jLpe21uPzNlRoBPKmCPMhARIggXwRKJwRULz6Ip4HHnggcUd9JROg7\/AP8VHDjoYVYgS2X3m2XD51Zr5GaM6z2fmR0S4Z9nnqPpd2i9oodciPstQiH1ogOhTSCKgM+gpeffPe0KFDEw1B6dsHK73FLx+ypsuCRiAdN+tRSLFZ29Q4GgGElgh1wHh5RlMLT7r2thEdCmsELK8WLkdqMQ12GfIRSSPgqwNSbEgmNAIILRoBjJZvNGvCl6+1dUSHwhqBGNa6detk6tSpiez01\/xGjBiRGBdaAI2Ar2JIsSGZ0AggtGgEMFq+0awJX77W1hEdCm8EYmjxrYJyiEU1APF50ghYyyZdHFJsSA80AggtGgGMlm80a8KXr7V1RIemMQJWeEWLoxHwVRQpNiQTGgGEFo0ARss3mjXhy9faOqIDjYCVaqBxNAK+wiHFhmRCI4DQohHAaPlGsyZ8+VpbR3SgEbBSDTSORsBXOKTYkExoBBBaNAIYLd9o1oQvX2vriA40AlaqgcbRCPgKhxQbkgmNAEKLRgCj5RvNmvDla20d0YFGwEo10DgaAV\/hkGJDMqERQGjRCGC0fKNZE758ra0jOtAIWKkGGkcj4CscUmxIJjQCCC0aAYyWbzRrwpevtXVEh8IZgb1798qPf\/xjueSSS6y8Ch1HI+ArL1JsSCY0AggtGgGMlm80a8KXr7V1RIdCGoF77rlHbr755lQ\/OmSFHEocjYCvUkixIZnQCCC0aAQwWr7RrAlfvtbWER0KaQTGjRsnL730kqxevVrOPfdcK7dCxtEI+MqKFBuSCY0AQotGAKPlG82a8OVrbR3RoZBGYMOGDdGPDakhGDBggEyePNnKrnBxNAK+kiLFhmRCI4DQohHAaPlGsyZ8+VpbR3QopBEo3SMQ\/9bA2rVrI1NQ6bNp0yb5wAc+IL169bIyDiaORsBXKqTYkExoBBBaNAIYLd9o1oQvX2vriA6FMwKVIMW\/RKh\/W7RoUbu9A\/fdd1+0gkAjcLZcPnWmdZwxTjgB5WUQIBc9JGcaMoTWG7HUAmfmcQSiQ1MYgRhyRz881L9\/f7n33ntpBK6kEUALEik2pG1OQAgtTj4YLd9o1oQvX2vriA5NYQQ6MgAxUBqBN0hspxGw1lhrHFJsSOM0AggtGgGMlm80a8KXr7V1RIfCGYHS9wjE+wOSwNEI0AgkjZGO\/o4UG9IHjQBCi0YAo+UbzZrw5WttHdGhkEZAnxbYsmVLO15nnHFGxUcKuUeARsBaXOVxSLEhfdAIILRoBDBavtGsCV++1tYRHZrGCPCpgeThw1sDyYxoBHBG9TgCuegh+dCQIbTeiKUWODOPIxAdCm8EFi5cKCNGjPDgHESbfHzQVyak2JBMOAEhtDj5YLR8o1kTvnytrSM6FNYInHXWWRUfFbRCLEocjYCvkkixIZnQCCC0aAQwWr7RrAlfvtbWER0KaQT0zYKjR4+28ip0HI2Ar7xIsSGZ0AggtGgEMFq+0awJX77W1hEdCmcErJCaJY5GwFdppNiQTGgEEFo0Ahgt32jWhC9fa+uIDjQCVqqBxtEI+AqHFBuSCY0AQotGAKPlG82a8OVrbR3RgUbASjXQOBoBX+GQYkMyoRFAaNEIYLR8o1kTvnytrSM60AhYqQYaRyPgKxxSbEgmNAIILRoBjJZvNGvCl6+1dUQHGgEr1UDjaAR8hUOKDcmERgChRSOA0fKNZk348rW2juhAI2ClGmgcjYCvcEixIZnQCCC0aAQwWr7RrAlfvtbWER1oBKxUA42jEfAVDik2JBMaAYQWjQBGyzeaNeHL19o6ogONgJVqoHE0Ar7CIcWGZEIjgNCiEcBo+UazJnz5WltHdKARsFINNI5GwFc4pNiQTGgEEFo0Ahgt32jWhC9fa+uIDjQCVqqBxtEI+AqHFBuSCY0AQotGAKPlG82a8OVrbR3RgUbASjXQOBoBX+GQYkMyoRFAaNEIYLR8o1kTvnytrSM60AhYqQYaRyPgKxxSbEgmNAIILRoBjJZvNGvCl6+1dUQHGgEr1UDjaAR8hUOKDcmERgChRSOA0fKNZk348rW2juhAI2ClGmgcjYCvcEixIZnQCCC0aAQwWr7RrAlfvtbWER1oBKxUA42jEfAVDik2JBMaAYQWjQBGyzeaNeHL19o6ogONgJVqoHE0Ar7CIcWGZEIjgNCiEcBo+UazJnz5WltHdKARsFINNI5GwFc4pNiQTGgEEFo0Ahgt32jWhC9fa+uIDjQCVqqBxtEI+AqHFBuSCY0AQotGAKPlG82a8OVrbR3RgUbASjXQOBoBX+GQYkMyoRFAaNEIYLR8o1kTvnytrSM60AhYqQYaRyPgKxxSbEgmNAIILRoBjJZvNGvCl6+1dUQHGgEr1UDjaAR8hUOKDckkyQh02TtPjve6A2my0LGN0qHQUFOeXKO0YE20FQzRgUYg5WAP5bCsjUDn782V1wZNr3j6jy6cLed\/4\/l2f9t+5dly+dSZDUPmmRdSbAiAWo1ApXNutA56\/l5aNEqHrmctkKMv\/mOH0nqdLzKWKsV65tUoLZKMQKW88lwTSdeApDGA6EAjkEQz8L9naQT0ovfaV19rZwSgAffUfXUjWo+8kD6QE0+6CFS66HV0ca\/Ub70vgAinpHOvdD5I+1nqwJpoT7MRWnQ5bZ7INmm3SobkUs+aQGpVCXvXBI0AclUIMDZLI5DVBbgeBYdcAOLzSpNXmn4swwgt\/LR5oP1Yci+NqVdeaftJOh+UD3qBj\/tH+0nKu5G1mhct0ubhrUW98kL6oRFIU1EBHeNlBNJe8ErReRRcvfNCig0ZNgibWnNA+kLOoZ551dpXR+eFsMkiB6Q\/qxasCSupN+M8dNDWax0jSF5IXzQC+BgJ6ggvI4AMsiwuslboWeSFrAxk0V+lc7MWfFb9W\/urpw7IkmhWHMrPD+GSRQ5If\/XUgjVhpd1xXBbjw6smaARq1zfXLXgYgawGNDKoLZAbkVeWfaKrJVn3ndUklMU30EazQJfss9QiKx2y+AaK6pB1n2j\/WeqAmJ+k61Pea4JGIEnBwP+etRHIstDQi201KbIuNKtJ8eDRqL6zmoCyZmK5IGfdJzI2PfrOQotG5eXRL2ui7dXPMj4QHWgEAp\/ok9JvFiOADPokZvHf8zwBdd4+V5675jnrqZjjLBeYehsyyyTgob+lX69vwLXq0Mi8GqVFXmuiUTyQfmkEzJfIMANDMAKWCTeJPjLok9pCliMb1S8vem1VbJQOHitRemZ5rQlLXo3SgjWRviZoBJBZIcDYLI2A10XP+s2rI\/yNzIsXvfQXH6Sckr4hN0oHr35ZE+1HR9IYoBFIX4s0AsjVKMDYLI1AXi96jczLq29e9NoWW9I30Ubp4NVvrUagkXl59V2tJvTLwJArT8jl7TIvHlnWBI1AgJM7kjKNAEIL\/xbiVeQ0AjQCSWOg2sj2GpcWg+LVN42AX03QCNQ2T+T+aMQI5PVk+pz+Ppnd0iLX\/qb97xjkNWfvvM752jku336q5a066Gfnr3\/ufXpsP4EAa6I9INZE+rKhEUjPLogjPY1An3ceCIIBkuSaCz8mgzZsQQ5pSGzpRa+IOkSG4+WTGsK2lk6LqEUoOrAm0o9cGoH07II4kkYAk4lGAOPlGR3KBFTKgEbAc0RUb5tGID17GoH07II4kkYAk4lGAOPlGU0j4EnX3nYoOtAI2DUtj6QRSM8uiCNpBDCZaAQwXp7RoUxAXBHwHAX2tmkE7KxoBNKzCvJIGgFMNhoBjJdnNI2AJ11726HoQCNg15RGID2rII+kEcBkoxHAeHlGhzIBcUXAcxTY26YRsLOiEUjPyuXIxx9\/XK6\/\/no5dOhQa\/t33323DB06tPV\/Hz58WNasWSOrVq2So0ePysSJE2XMmDHSvXv3xJxoBBIRtQmgEcB4eUbTCHjStbcdig40AnZNaQTSs8r8yAMHDsidd94pJ598spxwwglR+z179pSrrrpKTjrpjUenjhw5IgsXLpQ9e\/bIjBkzpFu3bjJr1izp1KmTzJ49W3r06FE1LxoBTDYaAYyXZ3QoExBXBDxHgb1tGgE7KxqB9KwyP\/LRRx+VE088US666KIO2960aZNMnTpVVqxYIf3794\/itm3bJuPHj5dp06bJ4MGDaQQyVIZGIEOYNTZFI1AjwIwOD0UHGoH0gvOpgfTsajrypZdekhtvvFGef\/55ufTSS2X06NFy3nnnRd\/0467GdmwAACAASURBVI\/eEpgyZYrs27dPli1bFq0W6EdvI+i\/Hzt2TJYsWVJ1VYArAphMNAIYL8\/oUCYgrgh4jgJ72zQCdlZcEUjPKtMjn376aXnooYfkySeflJ07d0qXLl2ib\/k33XRT673\/Xbt2ydixY6OVgAULFkS3BfTT0tIS3S7Q1YLVq1dL7969O8yNRgCTjUYA4+UZTSPgSdfedig60AjYNaURSM\/K7cgXX3xR5s2bJ4899lhkBPQ\/NQY7duyIjMCwYcNk8uTJbfpfvHixrF+\/PjIC\/fr1oxHISB0agYxAZtBMKBMQVwQyEDuDJmgE0kPkrYH07DI98uDBgzJz5kzRpwj0CYG+ffvK5s2bZdSoUTJhwoSKRmD58uWydu1aGTBgAI1ARmrQCGQEMoNmaAQygJhBE6HoQCOQXmwagfTsMj\/yhRdekHHjxsmkSZNkyJAhsnXr1mhFYPjw4VwRyJx25QZpBOoE2tBNKBMQVwQMYtYhhEYgPWQagfTsqh4Zb\/TbsGFDa9wZZ5wRLeWfe+65FY+Nj7n44ovliiuukHiPwMCBA2X69OnR7QL9HD9+XObOnStPPPEE9whkrB+NQMZAa2iORqAGeBkeGooONALpRacRSM+u6pE6Wf\/0pz8VfVdA\/NGJ\/P3vf3\/r7v\/yBvRpAJ3g9QkCvTUQGwP9v0uXLm19OkBvI+iqgb5QaNGiRVVfLOSxWfDW\/yPy+c+KFPGX1kIzAi3H3y1nv+tnTqO4sc2GMgEppSLXRCg60Aikr1cagfTsMj9y+\/bt0ZMEt912W+sTAhs3bpT58+fLypUrI3Ogn0a+R+Bdb3uP\/OaVX0R50AhkPgTMDepF798v2S+9z\/hdIXVQEKFMQDO\/1Flm\/\/1rha2JUHRgTZgvH+0CaQTSs0t9pK4S3HrrrXLmmWdGrxc+9dRTZcuWLfLwww\/LDTfcIKecckpr2\/EmQn1kUN8oqG8anDNnjnTt2rXubxa8fVUf+fmTa+WWT18ugz7yat0moF1v\/bC81NIiHzryo9TMrQeGsiLwqZmvy+j\/\/fbotMZ84pfW06sprp46hGIEGlUTP+r2oUjLetRECEbgkiGfl\/f+6c1RTfz1X7xNTnrr1prGuvXgotQEjYBV8Qzj9LbB\/fffL\/qbAmoKLrjgArnuuuvksssua10JKO1u\/\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\/XxOsW6tduppaWlpW69GTs6cOCAPPLII\/LMM8\/IHXfcId27d2935OHDh2XNmjWyatUqOXr0qEycOFHGjBnTLtYaVym1LI1AxfY\/MtpI5M2wWga3tTPLxa68rTR5IcVmzV3j0Fzqdb7IOcSxKKM0EyTah\/U8UB203TS5pOnHeg5xXL3GSJrzt5wLyqhe52vJvTwGZYSeOzoOuSKQRsWEY7Zt2ybPPvus3H333dKvXz9ZtGhRu8n9yJEjsnDhQtmzZ4\/MmDFDunXrJrNmzZJOnTrJ7NmzpUePHlEv1riOUvI0AuhgbuNAn7rPgfwbTdaSFzoJ1dJXNQBI4deSA3q+iGhpLsRpx0gtDLLSodaxh2iO6FDvvPKgRS05eNZELXmhXxCQvmgE0Ioyxh8\/flzmzp0rr7zySkUjsGnTJpk6daqsWLFC+vfvH7WqBmL8+PEybdo0GTx4cPRv1rh6GwFkkHWUm8eFr955ZdFfJT5WNrVOttq3x4Uvi7yQC1+jdah1so3HgFV342WoZmOcJq9Ga5FF\/81WEzQCSEWBsYsXL5bdu3e3MwK61D9lyhTZt2+fLFu2THr27Bm1fOjQoejfjx07JkuWLJHOnTub4uLVg0rpeawIZFFoaS4wSfgbkVeWfaLfhrOabD3MQJZcLJNjlv2hOmRlAlgT1SvcMg6yrAlLf0nXpNK\/ZzVGrSYF6Y9GAFESjO3ICOzatUvGjh0brQQsWLAgui2gH93qoLcLdBVg9erV0b9Z4nr37t1hZlkbgSwLLesLHzLwLVJaLgRZ94kwybpvy\/lauDUir6z7bKQO1gt9khaNqtUiadEsNUEjkFRNNfy9IyOwY8eOaIIfNmyYTJ48uU0Pesz69esjI9C1a1dTnO5D6OiTtRHwKPIsiq1ReXn0q1omMfG4yGc1AXkwSeLh0adFh6xXAxADknRp8mCSpIMXD4sWea2JRuWF6E8jkFRNNfy9IyOwefNmGTVqlEyYMKGiEVi+fLmsXbs26tkSN2DAgKCNQBYTEDLoEUmTLnyN6rfz9rny3DXPIadiik0636RGGsWjUf16XOSVcV5rwpJXo7RgTbStTkQHGoGkK1sNf+\/ICGzdujX6pj98+PCqKwLatSWuXisCXhc9i9uvJkMj80KKDRlKSRMyL3rpL3pZ6uClP2uivUqsibZMknggY5NGALkqiEi80W\/Dhg2tR55xxhnRUv65557bprWkPQIDBw6U6dOnS5cuXaLj4icNnnjiiTZ7BJLi6rVHABlYINbEpfBq7TUyL6++k4q82YxA0jfRRung1W+tRqCReXn1Xa0m9MvAkCtPaKpVsixrgkYAnLF0sv7pT38q+sKg+KMT+fvf\/\/7W3f\/xvyc9NaCmYunSpa3vDDh48KBMmjQpeueAvntAP\/oUQVJcpZcVxTlkuUfAq8B50eO3n6QyzPKil9RX6d+TDBlroj1NLyY0Am1ZZ1kTNALIVQGM7cgIaDMbN26U+fPny8qVK6Vv375Ry5XeI2CN6yg1xAiAp1e38D6nv09mt7TItb+p\/grjuiWUg47O+do5Lt9+qp2a6qCfnb\/+eQ4INHcKrIn2+rMm0tcEjUB6dlWPfPXVV+X2228XfVRQXxpUvnyv3\/5nzpwZPTKobxTUNwjOmTMnelKg9M2C1rhGGIE+73xzVcQJY92bXXPhx2TQhi117xftsPSiV0QdIsPx8kkolobHF1GLUHRgTaQf\/jQC6dl1eOS6deuitwaWfvT9ACNGjGjzb\/v3749+Z0D3F+hLgcaNGycjR45s9zpia1ylhDxXBIp40aMRcCiIlE2GMgGVnl4RayIUHWgEUhaaPq7MHx1KDy+EI2kEMJVoBDBentGhTEA0Ap6jwN42jYCdVXkkjUB6dkEcSSOAyUQjgPHyjKYR8KRrbzsUHWgE7JrSCKRnFeSRNAKYbDQCGC\/P6FAmIK4IeI4Ce9s0AnZWNALpWQV5JI0AJhuNAMbLM5pGwJOuve1QdKARsGtKI5CeVZBH0ghgstEIYLw8o0OZgLgi4DkK7G3TCNhZ0QikZxXkkTQCmGw0Ahgvz2gaAU+69rZD0YFGwK4pjUB6VkEeSSOAyUYjgPHyjA5lAuKKgOcosLdNI2BnRSOQnlWQR9IIYLLRCGC8PKNpBDzp2tsORQcaAbumNALpWQV5JI0AJhuNAMbLMzqUCYgrAp6jwN42jYCdFY1AelZBHkkjgMlGI4Dx8oymEfCka287FB1oBOya0gikZxXkkTQCmGw0Ahgvz+hQJiCuCHiOAnvbNAJ2VjQC6VkFeSSNACYbjQDGyzOaRsCTrr3tUHSgEbBrSiOQnlWQR9IIYLLRCGC8PKNDmYC4IuA5Cuxt0wjYWdEIpGcV5JFZG4FPzXw94rBq9glSxF9aC8UIXD1\/u\/yvo+fK23t2lm8s3B\/k2ExKOhQjUPSaCEWHuCaKem3SevHSgj86lHQ1CvzvWRsBxXFGr\/fK7r0v0Ag0cGzot58\/f3ZHYQ2Z50XPQ7Yi14TX5JO1DqyJ9ERpBNKzC+LIrI2AfvtRx60frgg0bghcMuTzsulbtxZWh1CMgOow5KrPym2jjxZWi1CMAGsi\/fWIRiA9uyCOzNII3LGuj\/zf+2+RnVu+9Ma5\/\/6HdWHwi7d+OOpnd0uLXHjkR659hnJr4NJPLpfn\/t9dDdFBO31PHbQPYQJqhpoIQQc1AZ3f0p01kfLqSCOQElwoh2VpBMrP+XtD+4eCAcpz0IYtUHyjg6lDoxV4s\/8iahFaPagaRdRBz8tLCxqB\/FxDXDLxNAIuCbNREiABEiCBuhKgEagr7vp3RiNQf+bskQRIgARCIkAjEJJaKXKlEUgBjYeQAAmQQBMRoBEouNg0AgUXmKdHAiRAAjUSoBGoEWDeD6cRyLtCzI8ESIAEGkuARqCx\/N17pxFwR8wOSIAESCBoAjQCQcuXnDyNQDIjRpAACZBAMxOgESi4+jQCBReYp0cCJEACNRKgEagRYN4PpxHIu0LMjwRIgAQaS4BGoLH83XunEXBHzA5IgARIIGgCNAJBy5ecPI1AMiNGkAAJkEAzE6ARKLj6NAIFF5inRwIkQAI1EqARqBFg3g8\/++yz854i8yMBEiABEmgggeeff76BvWfTdaeWlpaWbJpiKyRAAiRAAiRAAqERoBEITTHmSwIkQAIkQAIZEqARyBAmmyIBEiABEiCB0AjQCISmGPMlARIgARIggQwJ0AhkCJNNkQAJkAAJkEBoBGgEQlOM+ZIACZAACZBAhgRoBDKEyaZIgARIgARIIDQCNAKhKcZ8SYAESIAESCBDAjQCGcJkUyRAAiRAAiQQGgEagdAUY74kQAIkQAIkkCEBGoEMYdbS1PHjx+UHP\/iBrF27Vm655RY599xz2zWnL4H8\/ve\/L0uWLJHt27fLxz\/+cZk2bZq8+93vbhNrjasl31COfemll+TGG2+Up556qjXl4cOHy9y5c6Vbt27Rv5FXdTUPHz4sa9askVWrVsnRo0dl4sSJMmbMGOnevXsow6CueT7++ONy\/fXXy6FDh1r7vfvuu2Xo0KGt\/5tM35TkwIED8sgjj8gzzzwjd9xxR8VxZeVljavrgAigMxqBHIj08ssvy09+8hN56KGH5Mc\/\/rGsXr26ohH413\/9V\/nc5z4nCxculA984AOyfv16WbFihXz5y1+W8847r\/VMrHE5OHXXFHSCV2O1Y8cOedvb3tba15AhQ8jLSP7IkSPReNuzZ4\/MmDEjMk+zZs2STp06yezZs6VHjx7GlpojTCe1O++8U04++WQ54YQTopPu2bOnXHXVVXLSSSdF\/5tM3xwL27Ztk2effVbUKPXr108WLVrUzghYeVnjmmMkYmdJI4Dxco3etGlTdLGtZAR+9atfyac\/\/Wm58sor5VOf+lR0IT548KB85jOfkXe84x2tF2lrnOuJ5KTxF154Qb7zne\/I2LFjpUuXLhWzIq\/qYumYnDp1amQ4+\/fvHwXrxXv8+PHRatTgwYNzonY+0nj00UflxBNPlIsuuqjDhMi0LRpdDdUVuldeeaWiEbDyssblY6TkKwsagRzpsXnz5mhir2QE1q1bJ\/PmzZP7779fPvjBD7Zm\/eCDD0arBLp027dvX7HG5ei0XVLRi4t+y9AJ7KMf\/ahce+210cU5vh0Qd0peHePXZdYpU6bIvn37ZNmyZdE3W\/3okrf++7Fjx6LbVFwVeINhfBtKf43u0ksvldGjR0crT2ra4w+ZVh5vixcvlt27d7czAlZenTt35lit4UpKI1ADvKwP7cgI6H1ZXSl48sknowm\/T58+rV3r\/Uid5L74xS9GFx9LnC6NF\/2jF2U1ScpHb7fopDVgwADRC07v3r2j07dybQZelcbDrl27otUUXQlYsGBBmz0VertAv4GpaY15Fn1MJZ3f008\/Hd3e0zrduXNntAqlKyc33XRT63I3mWJGwMpLW+VYTRqhHf+dRiA9u8yP7MgIxN\/AfvnLX8q9994rvXr1au1bjxk1alS0yWbEiBGRK06K01sLzfRRfjphqVnS1ZQvfOELcuqpp7Z+syWvyqNB91boxXXYsGEyefLkNkFqqHSPinLVe7v8tCXw4osvRit4jz32WGQE9D81BmSKGQErr65du3Ks1lCENAI1wMv60I6MwN69e2XcuHFRdx0ZgQkTJsh1111niiu\/qGd9HnlsTzcO6sSl97XVNOkqipVrM\/JSDWOTqWOrkhFYvnx5tBlTV1r4aU9A9\/DMnDkzWpWKb92RKWYErLy0Vf1CxLGarhJpBNJxczmqIyOgF5RJkyZF9yCrrQjozmRLXLOtCMRi6a7i6dOnR7u558yZE90aIK+Oh\/LWrVujb1n6uCVXBNKVvG5YVROv40xvMZEpZgSsvLRVjtV0Y1SPohFIz858ZOxqSw+o5FyT9gj893\/\/d2QETj\/99Nam9D6t3ocs3SOQFFeUe95WrqXcdXOgvq9B73nrJi7dU9EsvMwD9g+B8f3ZgQMHRgYqfvIi3uX9xBNPcI9AAtR4s9vFF18sV1xxhZApZgSsvGIjwLGKVvkb8TQC6bhBR+l7An72s5+1OeaUU06R888\/v82\/JT01oDu0y+\/J6kte9L\/4SQOd6Cxx0AnkNNjKtTR93UCoKwF6a0A\/zcQLlTGexPT\/Ll26tPXpgHiFSl8oVOm5b7SfIsfr\/hR9NE6fINCnesgUMwJWXtqq7o\/iWE1XTTQC6bi5HFXNCOgSo75H4JprrmmdxCq9R8Aa53ICOW9Ued11113RRfm9731vlC15VRdt48aNMn\/+fFm5cmU0kemH7xGwD3R9A6g+SXDbbbe1PnVBpu35dfT4oEZaeVnj7Oo1TySNQE60fv3116MNRbrT+Etf+pJcdtllbZ4\/jje7feUrX4me6T777LOjb7P33XdfmzcLWuNyctpuaej7A7773e9G3xL08bff\/e530crJX\/7lX0bvFYg\/5FVdgnjDm3LSNwrqPgvdX6G7tPlmwTfZ6RsFb731VjnzzDOj1wvrUylbtmyRhx9+WG644QbRFcD4Q6Ztx9yrr74qt99+e3TbROu2\/HFUKy9rnNtFJ+CGaQRyIJ6+YlM3uugLNeKPvpe8fNlVzcK3v\/3t6PE3fWmJ3nPUx5LKf2vAGpeDU3dLQX9bQO\/\/6zcyffPi1VdfHa2klF6Q487Jq7oM+\/fvb739pC8P0s1vI0eO5G8NlGDTfRP6si99iZWaggsuuCB6ikcNfflLrPQwMn0Dnn6Z0TdXln70HRX6KHTpx8rLGud24Qm0YRqBQIVj2iRAAiRAAiSQBQEagSwosg0SIAESIAESCJQAjUCgwjFtEiABEiABEsiCAI1AFhTZBgmQAAmQAAkESoBGIFDhmDYJkAAJkAAJZEGARiALimyDBEiABEiABAIlQCMQqHBMmwRIgARIgASyIEAjkAVFtkECJEACJEACgRKgEQhUOKZNAiRAAiRAAlkQoBHIgiLbIAESIAESIIFACdAIBCoc0yYBEiABEiCBLAjQCGRBkW2QQB0IVHovu3arP6p07733Ru\/+1x9Z2rBhQ2s28d969eqVmKH+5sWCBQuiX2i0xCc2WEOA\/hKn\/iKdnlejc6nhNHgoCQRBgEYgCJmYJAm8QUAnyFGjRrXimDBhgkyePLkNntgwrF27VgYMGGBCp5OuGojVq1fLueeeazrGOyjNeXjnxPZJoIgEaASKqCrPqdAEys1A6a+1HT58OPp1Sv3lO+s36TyagFhAmoFCD2WeXE4I0AjkRAimQQIIAZ28ly9fHh1yxhlnRN\/kzzzzTJk\/f76MHj3a\/K0+NhWVVhaQfLxi9+7dG\/3ssX54m8CLMtttdgI0As0+Anj+QRLQb\/6l+wF0L8BZZ50lI0eONN8OKG2j9DaC7hUYO3as7N69O2KjKw76iX83Pt53sGfPnta42IzEtxXKVy20\/e9973ut5mXo0KGyaNEi2bJlS+utjo72M8Smp9Lv1AcpHpMmgZwRoBHImSBMhwSsBMonbPRbfTxZl0\/i2n+l2w8f+tCH2hgEncxnzpwps2fPjvYXxJO7blrUT\/nmRjUD+inf46C3MfRbv5qCansekI2PVoaMIwESEKER4CgggYAJVJpsrRsE42MrTbClRiD+Jh4v0+uEHU\/6ii5emShvpzS3eMWh1LzEk36ldmMzUWpKKhmWgKVj6iSQGwI0ArmRgomQAE6gfFUA+dYcL7mHYgSUDvIkBE6TR5BAcxKgEWhO3XnWBSCg36Tvueceufzyy+WGG25ovadvvUVAI1CAQcBTIIEMCNAIZACRTZBAvQmoCdB783qPXh8TrLQ5L+kWAY1AvVVjfySQTwI0AvnUhVmRWXAAUgAAAiVJREFUQIcEdLd\/pccEKz1SWO3lQNwjwEFGAiSgBGgEOA5IICAC8Z6Am266SUaMGNEm8\/JHCpM218VtaSPlbxQsXWGotqlPj403C5b3V7pZMN5wmLRZsNJ+hWqGJSDpmCoJ5JYAjUBupWFiJPAmgfJJPv5LvHmudOd9ObeOnr+3vkdA25s0aZJ897vfjR7xiz+DBg2K\/l99P0D8iSfyHTt2tHlMUP8+ffr06KVA8fsJ9N\/06YMXX3yxTbvljyHyPQKsBBLwJUAj4MuXrZNArgnwzYK5lofJkUBdCNAI1AUzOyGB\/BLgbw3kVxtmRgL1IEAjUA\/K7IMEck4gj2aAPziU80HD9ApDgEagMFLyREigNgK6kW\/BggVy1113mX+5sLYeOz5ab1moOeEPDXkRZrsk8CYBGgGOBhIgARIgARJoYgI0Ak0sPk+dBEiABEiABGgEOAZIgARIgARIoIkJ0Ag0sfg8dRIgARIgARKgEeAYIAESIAESIIEmJkAj0MTi89RJgARIgARIgEaAY4AESIAESIAEmpgAjUATi89TJwESIAESIAEaAY4BEiABEiABEmhiAjQCTSw+T50ESIAESIAEaAQ4BkiABEiABEigiQnQCDSx+Dx1EiABEiABEqAR4BggARIgARIggSYmQCPQxOLz1EmABEiABEiARoBjgARIgARIgASamACNQBOLz1MnARIgARIgARoBjgESIAESIAESaGIC\/x8WBGW7tQchLAAAAABJRU5ErkJggg==","height":411,"width":411}}
%---
%[output:04a58355]
%   data: {"dataType":"text","outputData":{"text":"===========================================================\n","truncated":false}}
%---
%[output:0cb0e09a]
%   data: {"dataType":"text","outputData":{"text":"                    RIS ARRAY SUMMARY\n","truncated":false}}
%---
%[output:4fbcbde2]
%   data: {"dataType":"text","outputData":{"text":"===========================================================\n","truncated":false}}
%---
%[output:41f14b0a]
%   data: {"dataType":"text","outputData":{"text":"Array Size         : 4 x 4\n","truncated":false}}
%---
%[output:6de3c138]
%   data: {"dataType":"text","outputData":{"text":"Number of Elements : 16\n","truncated":false}}
%---
%[output:5715c27a]
%   data: {"dataType":"text","outputData":{"text":"Board Dimensions   : 183.67 mm x 183.67 mm\n","truncated":false}}
%---
%[output:96c7009c]
%   data: {"dataType":"text","outputData":{"text":"Spacing            : 61.22 mm\n","truncated":false}}
%---
%[output:30d7d75a]
%   data: {"dataType":"text","outputData":{"text":"Frequency          : 2.45 GHz\n","truncated":false}}
%---
%[output:9e583ccc]
%   data: {"dataType":"text","outputData":{"text":"Wavelength         : 122.45 mm\n","truncated":false}}
%---
%[output:32f1a4e5]
%   data: {"dataType":"text","outputData":{"text":"===========================================================\n","truncated":false}}
%---
%[output:35322789]
%   data: {"dataType":"text","outputData":{"text":"Script 2 Execution Completed Successfully.\n","truncated":false}}
%---
