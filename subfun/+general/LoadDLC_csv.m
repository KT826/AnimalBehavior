function [dlc,fps] = LoadDLC_csv(path_DLC,path_Video,partsname)

dlc = readtable(path_DLC);
v = VideoReader(path_Video); fps = v.FrameRate; clear v

%rename body parts
dlc = DLC_BehaviorVariables.rename(dlc,partsname);
end