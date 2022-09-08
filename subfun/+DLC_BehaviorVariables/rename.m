function dlc_output = rename(dlc,partsname)
%%%rename body parts

%{
%%%%%%%%%%%Input%%%%%%%%%%%
'dlc' : raw dlc csv file
'partsname': Body parts names. There are the header of csv file
%}

dlc_output = [];
strs = [];
if isfield(partsname,'body')
    body_x = eval(['dlc.', partsname.body,';']);
    body_y = eval(['dlc.', partsname.body,'_1;']);
    body_lh = eval(['dlc.', partsname.body,'_2;']);
    strs{numel(strs)+1} = ['body_x, body_y, body_lh'];
end
if isfield(partsname,'miniscope')
    miniscope_x = eval(['dlc.', partsname.miniscope,';']);
    miniscope_y = eval(['dlc.', partsname.miniscope,'_1;']);
    miniscope_lh = eval(['dlc.', partsname.miniscope,'_2;']);
    strs{numel(strs)+1} = ['miniscope_x, miniscope_y, miniscope_lh'];
end
if isfield(partsname,'ear_R')
    ear_R_x = eval(['dlc.', partsname.ear_R,';']);
    ear_R_y = eval(['dlc.', partsname.ear_R,'_1;']);
    ear_R_lh = eval(['dlc.', partsname.ear_R,'_2;']);
    strs{numel(strs)+1} = ['ear_R_x, ear_R_y, ear_R_lh'];
end
if isfield(partsname,'ear_L')
    ear_L_x = eval(['dlc.', partsname.ear_L,';']);
    ear_L_y = eval(['dlc.', partsname.ear_L,'_1;']);
    ear_L_lh = eval(['dlc.', partsname.ear_L,'_2;']);
    strs{numel(strs)+1} = ['ear_L_x, ear_L_y, ear_L_lh'];
end
if isfield(partsname,'tail_base')
    tail_base_x = eval(['dlc.', partsname.tail_base,';']);
    tail_base_y = eval(['dlc.', partsname.tail_base,'_1;']);
    tail_base_lh = eval(['dlc.', partsname.tail_base,'_2;']);
    strs{numel(strs)+1} = ['tail_base_x, tail_base_y, tail_base_lh'];
end

nametable = [];
for q = 1 : numel(strs)
    if q == 1
        nametable = strs{q};
    else
        nametable = strcat(nametable,{','},strs{q});
    end
end

eval(['dlc_output = table(',nametable{1},');'])
end