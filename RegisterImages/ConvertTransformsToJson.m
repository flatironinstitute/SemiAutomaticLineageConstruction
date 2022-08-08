

% read in mat file
RegistrationFileName = 'transforms1_302.mat'

H = load(strcat(data_path,RegistrationFileName));

% output for python reading
jH = jsonencode(H);

%fid = fopen(strcat(data_path, '/GT_tracking_F32_to_F40.json'),'w');
fid = fopen(strcat(data_path,'transforms1_302.json'),'w');
fprintf(fid, jH)

fclose(fid)
