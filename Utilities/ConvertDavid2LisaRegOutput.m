
% convert David's registration output to work with Masha's tracker, Lisa's
% VisualizeSequence and MakeRegisteredImages
data_path = '/Users/lbrown/Documents/PosfaiLab/3DStardist/Eszter/stack11_hand_corrected_labels/';
RegistrationFileName = 'test_LisaCompatible.mat';

data_path = '/Users/lbrown/Documents/PosfaiLab/Registration/DavidsVersion/SemiAutomaticLineageConstruction/GM/';
RegistrationFileName = 'test_LisaCompatible_from_Rebecca.mat';
% this has data from frames 5 to 8

transforms = load(strcat(data_path,RegistrationFileName));
transforms = transforms(1,1);
nframes = 200; %size(transforms.store_registration,1);
store_registration = cell(nframes,1);

% David's store_registration = cell(size(frame_pairs, 1), 1);
% Lisa's store_registration = cell((length(valid_time_indices)-1), 1);

% david's can start at 0 (even if start frame is 50 - that's where it will
% start..)

% store char cell ?
% order of T/R (2,1,3)
% AND remove 0 so starts at 1

% get number of frames

new_transforms = cell(nframes,1);
endframe = nframes - 1;
startframe = 5;
endframe = 8-1;
for i=startframe:endframe
    R = transforms.store_registration{i - startframe + 1,1}.Rotation;
    T = transforms.store_registration{i - startframe + 1,1}.Translation;
    Q = [[0,1,0];[1,0,0];[0,0,1]]
    newR =Q*R*Q
    newT = [T(2),T(1),T(3)];
    store_registration{i,1}.Rotation = newR;
    store_registration{i,1}.Translation = newT;
end

% save as mat file
RegistrationFileName = strcat('updated_', RegistrationFileName);
save(strcat(data_path,RegistrationFileName), 'store_registration');
    

% output json 
jH = jsonencode(transforms);
n = length(RegistrationFileName);
json_RegistrationFileName = strcat(RegistrationFileName(1:n-3),'json');
fid = fopen(strcat(data_path,json_RegistrationFileName),'w');
fprintf(fid, jH);
fclose(fid)
