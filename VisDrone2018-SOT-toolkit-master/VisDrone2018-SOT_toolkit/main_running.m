close all;
clear, clc;
warning off all;
addpath(genpath('.'));

datasetPath = 'D:\VisDrone2018-SOT-test-dev\'; % the dataset path
trackers = configTrackers; % the set of trackers
evalType = 'OPE'; % the evaluation type such as 'OPE','SRE','TRE'

pathAnno = fullfile(datasetPath, 'annotations'); % the annotations for sequences
if(~isdir(pathAnno)) 
    pathAnno = fullfile(datasetPath, 'initialization'); % the initialization for testing sequences
end

seqs = configSeqs(fullfile(datasetPath,'sequences')); % the set of sequences
shiftTypeSet = {'left','right','up','down','topLeft','topRight','bottomLeft','bottomRight','scale_8','scale_9','scale_11','scale_12'}; % the shift types for SRE evaluation

numSeq = length(seqs);
numTrk = length(trackers);

resultPath = ['./results/results_' evalType '/'];
if(~exist(resultPath,'dir'))
    mkdir(resultPath);
end

tmpRes_path = ['./tmp/' evalType '/'];
bSaveImage = 0;
if(~exist(tmpRes_path,'dir'))
    mkdir(tmpRes_path);
end

for idxSeq = 1:length(seqs)
    s = seqs{idxSeq};
    s.len = s.endFrame - s.startFrame + 1;
    s.s_frames = cell(s.len,1);
    nz	= strcat('img','%0',num2str(s.nz),'d'); %number of zeros in the name of image
    
%     gt_t = ['D:\VisDrone2018-SOT-test-dev\annotations\' s.name '.txt'];
%     gt_t = load(gt_t);
%     [distance_precision,PASCAL_precision,average_center_location_error] = compute_performance_measures(results{1, 1}.res,gt_t);
%     fprintf('Precision: %.3g %%\n',100*distance_precision);
        
    
%     auto = ['E:\VisDrone2018-SOT-toolkit-master\VisDrone2018-SOT_toolkit\trackers\AutoTrack_edgebox\results_OPE\VisDrone-test-dev\AutoTrack\' s.name '_AutoTrack.mat'];
%     auto = load(auto);
%     auto = auto.results{1, 1}.res;

    for i = 1:s.len
        image_no = s.startFrame + (i-1);
        id = sprintf(nz,image_no);
        s.s_frames{i} = strcat(s.path,'/',id,'.',s.ext);
    end
    
    img = imread(s.s_frames{1});
    [imgH, imgW, ~] = size(img);
    
    rect_anno = dlmread([pathAnno '\' s.name '.txt']);
    
    
    
    
    if(size(rect_anno,1)>1)
        numSeg = 20;
        [subSeqs, subAnno] = splitSeqTRE(s,numSeg,rect_anno);
    else
        s.annoBegin = 1;
        s.startFrame = 1;
        s.init_rect = rect_anno;
        subSeqs{1} = s;
        subAnno{1} = rect_anno;
    end
    
    switch evalType
        case 'SRE'
            subS = subSeqs{1};
            subA = subAnno{1};
            subSeqs = [];
            subAnno = [];
            r = subS.init_rect;
            
            for i = 1:length(shiftTypeSet)
                subSeqs{i} = subS;
                shiftType = shiftTypeSet{i};
                subSeqs{i}.init_rect = shiftInitBB(subS.init_rect,shiftType,imgH,imgW);
                subSeqs{i}.shiftType = shiftType;
                subAnno{i} = subA;
            end
            
        case 'OPE'
            subS = subSeqs{1};
            subSeqs=[];
            subSeqs{1} = subS;
            subA = subAnno{1};
            subAnno=[];
            subAnno{1} = subA;
        otherwise
    end
    
    
    for idxTrk = 1:numTrk
        t = trackers{idxTrk};
        % validate the results
        if(exist([resultPath s.name '_' t.name '.mat'], 'file'))
            load([resultPath s.name '_' t.name '.mat']);
            bfail = checkResult(results, subAnno);
            if(bfail)
                disp([s.name ' '  t.name]);
            end
            continue;
        end
        
        results = [];
        for idx = 1:length(subSeqs)
            disp([num2str(idxTrk) '_' t.name ', ' num2str(idxSeq) '_' s.name ': ' num2str(idx) '/' num2str(length(subSeqs))])
            
            rp = [tmpRes_path s.name '_' t.name '_' num2str(idx) '/'];
            if(bSaveImage && ~exist(rp,'dir'))
                mkdir(rp);
            end
            
            subS = subSeqs{idx};
            subS.name = [subS.name '_' num2str(idx)];
            subS.savename = s.name;
%             funcName = ['res=run_' t.name '(subS, rp, bSaveImage);'];
            funcName = ['res=run_' t.name '(subS, rp, bSaveImage);'];
            cd(['E:\Spatial regularization\VisDrone2018-SOT-toolkit-master\VisDrone2018-SOT_toolkit\trackers/' t.name]);
            addpath(genpath('./'))
            eval(funcName);
            rmpath(genpath('./'))
            cd('../../');
            if(isempty(res))
                results = [];
                break;
            end
            
            res.len = subS.len;
            res.annoBegin = subS.annoBegin;
            res.startFrame = subS.startFrame;
            
            switch evalType
                case 'SRE'
                    res.shiftType = shiftTypeSet{idx};
            end
            results{idx} = res;
        end
        save([resultPath s.name '_' t.name '.mat'], 'results');
       
%         save([resultPath s.name '_' t.name '.mat'], 'results');
    end
end
t = clock;
t = uint8(t(2:end));
disp([num2str(t(1)) '/' num2str(t(2)) ' ' num2str(t(3)) ':' num2str(t(4)) ':' num2str(t(5))]);
figure