function generateSyntheticData( )
    
    subjectsNum            = 1  ; % How many subjects to be simulated for each case of parameters (wMB,wSR,wMF)
    
    samplesNumsPerModel    = 11   ; % How many differnt values of wMB and wSR to be simulated and estimated...    subjectsNum            = 10  ; % How many subjects to be simulated for each case of wMB and wSR            
    
    wMB_SampleNumStarts    = 1    ; % How many of the different wMBs, out of the total number samplesNumsPerModel to be simulated and estimated: the start
    wMB_SampleNumEnds      = 11   ; % How many of the different wMBs, out of the total number samplesNumsPerModel to be simulated and estimated: the end
    wSR_SampleNumStarts    = 1    ; % How many of the different wSRs, out of the total number samplesNumsPerModel to be simulated and estimated: the start
    wSR_SampleNumEnds      = 11   ; % How many of the different wSRs, out of the total number samplesNumsPerModel to be simulated and estimated: the end    
    

    
    agentParams.beta                      = 100    ;    
    agentParams.TransitionLearningRate    = 0.8    ;
    agentParams.TransitionDriftRate       = 0.00   ;
    agentParams.RewardLearningRate        = 0.8    ;
    agentParams.RewardDriftRate           = 0.00   ;
    agentParams.OccupancyLearningRate     = 0.8    ;
    agentParams.OccupancyDriftRate        = 0.00   ; 
    agentParams.OccupancyEligibilityTrace = 0.0    ;    
    agentParams.MFValueLearningRate       = 0.8    ;
    agentParams.MFValueDriftRate          = 0.00   ;
    agentParams.MFEligibilityTrace        = 0.0    ;    
    agentParams.choiceStayBias            = 0.00   ;    
    agentParams.motorStayBias             = 0      ;            
    
    
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
    %------------ Generate Synthetic Data            -------------
    %-------------------------------------------------------------
    for i = wMB_SampleNumStarts : wMB_SampleNumEnds
        for j = wSR_SampleNumStarts : min(samplesNumsPerModel-i+1,wSR_SampleNumEnds)    

            disp (['Creating synthetic data for group ',int2str(i),' - ',int2str(j) ]);        
            fileName4group = ['../D2_SynthBehavior/GrpMB',int2str(i),'_GrpSR',int2str(j) ] ;            
            
            agentParams.wMB = wMB(i,j) ;
            agentParams.wSR = wSR(i,j) ;
            agentParams.wMF = wMF(i,j) ;
            
            for subject = 1 : subjectsNum
                generateDataForOneAgent ( subject , agentParams , fileName4group );            
            end    
            
        end
    end    
end


%###################################################################################
function generateDataForOneAgent ( subjectNumber , agentParams , fileName4group );    
                
%    disp (['        Subject number ',int2str(subjectNumber) ]);
    
    dataTmp         = load (['../D1_Tasks/Subj',num2str(subjectNumber,'%0.4d'),'_stim.mat']);
    StimData        = dataTmp.taskStim ;
    trialsNum       = length ( StimData ) ;
    
    behaviorData    = agent( subjectNumber , agentParams );

    data = zeros (trialsNum,17);
    
    data (:,1)     = StimData       (:,1  ) ;             % trials Num
    data (:,2)     = StimData       (:,7  ) ;             % Level
    data (:,3)     = behaviorData   (:,1  ) ;             % Action
    data (:,4:6)   = ones           (trialsNum,3) ;       % RT1, Rt2, RT3
    data (:,10)    = StimData       (:,2  ) ;             % Transition
    data (:,11:14) = StimData       (:,3:6) ;             % Rewards
    data (:,15   ) = behaviorData   (:,2  ) ;             % L2 state       
    data (:,16   ) = behaviorData   (:,3  ) ;             % L3 state            
    
    subjectFileName = [ fileName4group , '_Sub' , num2str(subjectNumber,'%0.4d') ] ;    
    save ( [subjectFileName,'.mat'] , 'data' ) ;
    save ( [subjectFileName,'_params.mat'] , 'agentParams' ) ;        
        
end

