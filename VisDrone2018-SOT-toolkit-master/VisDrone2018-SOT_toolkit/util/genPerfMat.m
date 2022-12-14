function genPerfMat(datasetPath, seqs, trackers, evalType, nameTrkAll, perfMatPath)

pathAnno = fullfile(datasetPath, 'annotations');
numTrk = length(trackers);

thresholdSetOverlap = 0:0.05:1;
thresholdSetError = 0:50;

rpAll = ['./results/results_' evalType '/'];
a = [ ];aaa = [ ];aaaa = [ ];
for idxSeq=1:length(seqs)
    s = seqs{idxSeq};
    
    s.len = s.endFrame - s.startFrame + 1;
    s.s_frames = cell(s.len,1);
    nz	= strcat('img%0',num2str(s.nz),'d'); %number of zeros in the name of image
    for i = 1:s.len
        image_no = s.startFrame + (i-1);
        id = sprintf(nz,image_no);
        s.s_frames{i} = strcat(s.path,id,'.',s.ext);
    end
    
    rect_anno = dlmread([pathAnno '/' s.name '.txt']);
    numSeg = 20;
    [subSeqs, subAnno] = splitSeqTRE(s,numSeg,rect_anno);
    
    nameAll = [];
    for idxTrk = 1:numTrk       
        t = trackers{idxTrk};        
        % check the result format
        res_mat = [rpAll s.name '_' t.name '.mat'];
        if(~exist(res_mat, 'file'))
            res_txt = [rpAll s.name '.txt'];
            results = cell(1,1);
            results{1}.res = load(res_txt);
            results{1}.type = 'rect';
            results{1}.annoBegin = 1;
            results{1}.startFrame = 1;
            results{1}.len = size(results{1}.res, 1);
        else
            load(res_mat);
        end
        
        disp([s.name ' ' t.name]);
        
        
%         aa = [aa;results{1, 1}.C];
%         aaa = [aaa;results{1, 1}.HSIC_all];
%         aaaa = [aaaa;results{1, 1}.PSR_ALL];
        
        
        
        aveCoverageAll = [];
        aveErrCenterAll = [];
        errCvgAccAvgAll = 0;
        errCntAccAvgAll = 0;
        errCoverageAll = 0;
        errCenterAll = 0;
        
        lenALL = 0;
        
        switch evalType
            case 'SRE'
                idxNum = length(results);
                anno=subAnno{1};
            case 'TRE'
                idxNum = length(results);
            case 'OPE'
                idxNum = 1;
                anno=subAnno{1};
        end
        
        successNumOverlap = zeros(idxNum,length(thresholdSetOverlap));
        successNumErr = zeros(idxNum,length(thresholdSetError));
        
        for idx = 1:idxNum
            res = results{idx};            
            if strcmp(evalType, 'TRE')
                anno = subAnno{idx};
            end           
            len = size(anno,1);            
            if isempty(res.res)
                break;
            end
            
            if(~isfield(res,'type') && isfield(res,'transformType'))
                res.type = res.transformType;
                res.res = res.res';
            end
            
            [aveCoverage, aveErrCenter, errCoverage, errCenter] = calcSeqErrRobust(res, anno);
            
            a= [a;aveCoverage];

            for tIdx = 1:length(thresholdSetOverlap)
                successNumOverlap(idx,tIdx) = sum(errCoverage >thresholdSetOverlap(tIdx));
            end
            
            for tIdx = 1:length(thresholdSetError)
                successNumErr(idx,tIdx) = sum(errCenter <= thresholdSetError(tIdx));
            end
            
            lenALL = lenALL + len;
        end
                
        if strcmp(evalType, 'OPE')
            aveSuccessRatePlot(idxTrk, idxSeq,:) = successNumOverlap/(lenALL+eps);
            aveSuccessRatePlotErr(idxTrk, idxSeq,:) = successNumErr/(lenALL+eps);
        else
            aveSuccessRatePlot(idxTrk, idxSeq,:) = sum(successNumOverlap)/(lenALL+eps);
            aveSuccessRatePlotErr(idxTrk, idxSeq,:) = sum(successNumErr)/(lenALL+eps);
        end
    end
end

dataName1 = [perfMatPath 'aveSuccessRatePlot_' num2str(numTrk) 'alg_overlap_' evalType '.mat'];
save(dataName1,'aveSuccessRatePlot','nameTrkAll');

dataName2 = [perfMatPath 'aveSuccessRatePlot_' num2str(numTrk) 'alg_error_' evalType '.mat'];
aveSuccessRatePlot = aveSuccessRatePlotErr;
save(dataName2,'aveSuccessRatePlot','nameTrkAll');
