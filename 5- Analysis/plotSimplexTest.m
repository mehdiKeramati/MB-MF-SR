    
    samplesNumsPerModel = 11;
    
    wMB_SampleNumStarts    = 1   ; % How many of the different wMBs, out of the total number samplesNumsPerModel to be simulated and estimated: the start
    wMB_SampleNumEnds      = 11   ; % How many of the different wMBs, out of the total number samplesNumsPerModel to be simulated and estimated: the end
    wSR_SampleNumStarts    = 1   ; % How many of the different wSRs, out of the total number samplesNumsPerModel to be simulated and estimated: the start
    wSR_SampleNumEnds      = 11   ; % How many of the different wSRs, out of the total number samplesNumsPerModel to be simulated and estimated: the end

    
 
    %-------------------------------------------------------------
    %------------ Initialize weights                 -------------
    %-------------------------------------------------------------

    wMB     = zeros (samplesNumsPerModel,samplesNumsPerModel) ;
    wSR     = zeros (samplesNumsPerModel,samplesNumsPerModel) ;
    wMF     = zeros (samplesNumsPerModel,samplesNumsPerModel) ;

    for i = 1 : samplesNumsPerModel
        w_MB = (i-1)./(samplesNumsPerModel-1) ;
        for j = 1 : samplesNumsPerModel
            w_SR = (j-1)./(samplesNumsPerModel-1) ;                        
            w_MF = 1 - w_MB - w_SR ;

            if ( ( w_MB + w_SR ) > 1 )
                wMB(i,j) =  NaN ;        
                wSR(i,j) =  NaN ;        
                wMF(i,j) =  NaN ;        
            else        
                wMB(i,j) =  w_MB  ;        
                wSR(i,j) =  w_SR  ;        
                wMF(i,j) =  w_MF  ;        
            end
        end
    end
    
    %-------------------------------------------------------------
    %------------ Plot true vs. estimated weights    -------------
    %-------------------------------------------------------------
    close all
    FigHandle = figure('Position', [10, 10, 500, 430]);
    set(0,'DefaultAxesFontName', 'Arial')
    set(0,'DefaultAxesFontSize', 18)
    set(0,'DefaultAxesFontWeight', 'bold')

    wXSimplex        = zeros (samplesNumsPerModel,samplesNumsPerModel) ;
    wYSimplex        = zeros (samplesNumsPerModel,samplesNumsPerModel) ;
    wXestSimplex     = zeros (samplesNumsPerModel,samplesNumsPerModel) ;
    wYestSimplex     = zeros (samplesNumsPerModel,samplesNumsPerModel) ;
    
    for i = wMB_SampleNumStarts : wMB_SampleNumEnds
        for j = wSR_SampleNumStarts : min(samplesNumsPerModel-i+1,wSR_SampleNumEnds)    
            [x y] = transform2simplex ( wMB   (i,j) , wSR   (i,j) , wMF   (i,j) ) ;
            wXSimplex   (i,j) = x ;
            wYSimplex   (i,j) = y ;

        end
    end

    
    for i = wMB_SampleNumStarts : wMB_SampleNumEnds
        for j = wSR_SampleNumStarts : min(samplesNumsPerModel-i+1,wSR_SampleNumEnds)    
            plot(wXSimplex(i,j),wYSimplex(i,j),'-.ob','MarkerFaceColor','b','MarkerSize',9 );
            hold on
        end
    end

    xlabel('MF weight');
    axis([-0.1,1.1,-0.1,1.1])


function [x y] = transform2simplex ( w1 , w2 , w3 ) ;
    x = w1*0 + w2*0 + w3*1 ;
    y = w1*1   + w2*0 + w3*0 ; 
end