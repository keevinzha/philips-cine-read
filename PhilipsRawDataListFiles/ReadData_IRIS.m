%%% read philips multishot iEPI data from .data&.list to .mat
%%% 2022/11/01 qianchen
close all
clear
clc
addpath(genpath(pwd));

RawFileName = 'DWI_b500_M2_3shot_102801.list';
kspace = loadRawKspace(RawFileName);

%% check the kspace, make sure parameters:
%% aver:average, chan:channel, echo: image or nav, extr1: b-value, extra2: direction, loca: slice
for cur_prop = fieldnames(kspace)'
    if ~iscell(eval(['kspace.' cur_prop{1}])) && ~isstruct(eval(['kspace.' cur_prop{1}]))
        eval([cur_prop{1} '_unique = unique(kspace.' cur_prop{1} ');'])
        if length(eval([cur_prop{1} '_unique'])) < 50 && ~(length(eval([cur_prop{1} '_unique'])) == 1)
            eval([cur_prop{1} '_unique'])
        end
    end
end

%% make sure the size of data
selection_proper_lines = strcmp(kspace.typ,'STD');
index_vector = find(selection_proper_lines)';
data_vec = kspace.complexdata{index_vector(1)}; 
RO_numel = size(data_vec,2); % make sure the length of RO
nRead = kspace.kspace_properties.kx_range(2,2) - kspace.kspace_properties.kx_range(2,1)+1; % make sure the length of navigator

kspace_filled_IMG = zeros(...
    max(kspace.ky)-min(kspace.ky)+1,... PE size
    RO_numel,... RO
    numel(chan_unique),... channels
    numel(loca_unique),... slices 
    numel(extr1_unique),... b-value
    numel(extr2_unique),... diffusion directions
    ...numel(echo_unique),... img & nav, we only use image echo
    numel(aver_unique)... averages
);


kspace_filled_NAV = zeros(...
    max(kspace.ky)-min(kspace.ky)+1,... PE size
    nRead,... RO
    numel(chan_unique),... channels
    numel(loca_unique),... slices 
    numel(extr1_unique),... b-value
    numel(extr2_unique),... diffusion directions
    ...numel(echo_unique),... img & nav, we only use image echo
    numel(aver_unique)... averages
);


%% Filling the NAV kspace   
disp('start filling navigator kspace');
for index = index_vector 
    data_vec = kspace.complexdata{index};
    if (kspace.sign(index) == 1)
        if (kspace.echo(index)==1)
        kspace_filled_NAV( ...
            kspace.ky(index) - min(kspace.ky) + 1,                ... ky coordinate - min(ky) + 1 % start at 1
            :,                                                                   ... fill entire kx (readout dir.)
            kspace.chan(index) + 1,                                    ... coil id + 1
            kspace.loca(index) + 1,                                     ... location id + 1
            kspace.extr1(index) + 1,                                    ... b-value + 1
            kspace.extr2(index)+1,                                      ... diffusion direction id+1
            kspace.aver(index)+1)                                       ... average id + 1
            = data_vec;
        end
    else
        if (kspace.echo(index)==1)
        kspace_filled_NAV( ...
            kspace.ky(index) - min(kspace.ky) + 1,... ky coordinate - min(ky) + 1 % start at 1
            :,... fill entire kx (readout dir.)
            kspace.chan(index) + 1,... coil id + 1
            kspace.loca(index) + 1,... location id + 1
            kspace.extr1(index) + 1,... b-value + 1
            kspace.extr2(index)+1,... diffusion direction id+1
            kspace.aver(index)+1) ... average id+1
            = flip(data_vec);
        end
    end
end


%% Filling the IMG kspace   
disp('start filling image kspace');
for index = index_vector 
    data_vec = kspace.complexdata{index};
    if (kspace.sign(index) == 1)
        if (kspace.echo(index)==0)
        kspace_filled_IMG( ...
            kspace.ky(index) - min(kspace.ky) + 1,                ... ky coordinate - min(ky) + 1 % start at 1
            :,                                                                   ... fill entire kx (readout dir.)
            kspace.chan(index) + 1,                                    ... coil id + 1
            kspace.loca(index) + 1,                                     ... location id + 1
            kspace.extr1(index) + 1,                                    ... b-value + 1
            kspace.extr2(index)+1,                                      ... diffusion direction id+1
            kspace.aver(index)+1)                                       ... average id + 1
            = data_vec;
        end
    else
        if (kspace.echo(index)==0)
        kspace_filled_IMG( ...
            kspace.ky(index) - min(kspace.ky) + 1,... ky coordinate - min(ky) + 1 % start at 1
            :,... fill entire kx (readout dir.)
            kspace.chan(index) + 1,... coil id + 1
            kspace.loca(index) + 1,... location id + 1
            kspace.extr1(index) + 1,... b-value + 1
            kspace.extr2(index)+1,... diffusion direction id+1
            kspace.aver(index)+1) ... average id+1
            = flip(data_vec);
        end
    end
end

figure,imshow(rot90(sos(ifft2c(squeeze(kspace_filled_NAV(:,:,:,16,2,1,1)))),2),[])
figure,imshow(rot90(angle(ifft2c(squeeze(kspace_filled_NAV(:,:,2,16,2,1,1)))),2),[])








