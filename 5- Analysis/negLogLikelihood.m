
%% Likelihood function
function negLogLikelihood = negLogLikelihood ( parameterValues , data , componentMB , componentSR , componentMF , environmentalParameters );

    model = componentMB*4 + componentSR*2 + componentMF + 1 ;

    if      model == 1
        w_MB                            = 0 ;
        w_SR                            = 0 ;
        w_MF                            = 0 ;
        beta                            = exp( parameterValues( 1 ) )       ;             
        TransitionLearningRate          = 0       ;
        RewardLearningRate              = 0       ;
        OccupancyLearningRate           = 0       ;
        MFValueLearningRate             = 0       ;
        
    elseif  model == 2
        w_MB                            = 0 ;
        w_SR                            = 0 ;
        w_MF                            = 1 ;
        beta                            = exp( parameterValues( 1 ) )       ;             
        TransitionLearningRate          = 0       ;
        RewardLearningRate              = 0       ;
        OccupancyLearningRate           = 0       ;
        MFValueLearningRate             = 1.0 / ( 1 + exp(-parameterValues( 2))) ;
    elseif  model == 3
        w_MB                            = 0 ;
        w_SR                            = 1 ;
        w_MF                            = 0 ;
        beta                            = exp( parameterValues( 1 ) )       ;             
        TransitionLearningRate          = 0       ;
        RewardLearningRate              = 1.0 / ( 1 + exp(-parameterValues( 2)))       ;
        OccupancyLearningRate           = 1.0 / ( 1 + exp(-parameterValues( 3)))       ;
        MFValueLearningRate             = 0       ;
    elseif  model == 4
        eSR                             = exp(parameterValues(1));
        eMF                             = exp(0);        
        w_MB                            = 0 ;
        w_SR                            = eSR / (eSR+eMF) ;
        w_MF                            = 1 - w_SR;
        beta                            = exp( parameterValues( 2 ) )       ;             
        TransitionLearningRate          = 0       ;
        RewardLearningRate              = 1.0 / ( 1 + exp(-parameterValues( 3)))       ;
        OccupancyLearningRate           = 1.0 / ( 1 + exp(-parameterValues( 4)))       ;
        MFValueLearningRate             = 1.0 / ( 1 + exp(-parameterValues( 5)))       ;
    elseif  model == 5
        w_MB                            = 1 ;
        w_SR                            = 0 ;
        w_MF                            = 0 ;
        beta                            = exp( parameterValues( 1 ) )       ;             
        TransitionLearningRate          = 1.0 / ( 1 + exp(-parameterValues( 2))) ;
        RewardLearningRate              = 1.0 / ( 1 + exp(-parameterValues( 3)));
        OccupancyLearningRate           = 0       ;
        MFValueLearningRate             = 0       ;   
    elseif  model == 6
        eMB                             = exp(parameterValues(1));
        eMF                             = exp(0);        
        w_MB                            = eMB / (eMB+eMF)  ;
        w_SR                            = 0 ;
        w_MF                            = 1 - w_MB;
        beta                            = exp( parameterValues( 2 ) )       ;             
        TransitionLearningRate          = 1.0 / ( 1 + exp(-parameterValues( 3))) ;
        RewardLearningRate              = 1.0 / ( 1 + exp(-parameterValues( 4)))       ;
        OccupancyLearningRate           = 0  ;
        MFValueLearningRate             = 1.0 / ( 1 + exp(-parameterValues( 5)))       ;        
    elseif  model == 7
        eMB = exp(parameterValues(1));
        eSR = exp(0);        
        w_MB                            = eMB / (eMB+eSR)  ;
        w_SR                            = 1 - w_MB  ;
        w_MF                            = 0 ;
        beta                            = exp( parameterValues( 2 ) )       ;             
        TransitionLearningRate          = 1.0 / ( 1 + exp(-parameterValues( 3))) ;
        RewardLearningRate              = 1.0 / ( 1 + exp(-parameterValues( 4)))       ;
        OccupancyLearningRate           = 1.0 / ( 1 + exp(-parameterValues( 5)))   ;
        MFValueLearningRate             = 0  ;         
    elseif  model == 8
        eMB = exp(parameterValues(1));
        eSR = exp(parameterValues(2));
        eMF = exp(0);        
        w_MB                            = eMB / (eMB+eSR+eMF)  ;
        w_SR                            = eSR / (eMB+eSR+eMF)  ;
        w_MF                            = 1 - w_MB - w_SR ;
        beta                            = exp( parameterValues( 3 ) )       ;             
        TransitionLearningRate          = 1.0 / ( 1 + exp(-parameterValues( 4))) ;
        RewardLearningRate              = 1.0 / ( 1 + exp(-parameterValues( 5)))       ;
        OccupancyLearningRate           = 1.0 / ( 1 + exp(-parameterValues( 6)))   ;
        MFValueLearningRate             = 1.0 / ( 1 + exp(-parameterValues( 7)))   ;    
    end

    %------------------------------------------------------------------
    %---------------------      For a reduced model    ----------------
    %------------------------------------------------------------------
    TransitionDriftRate         = 0 ;
    RewardDriftRate             = 0 ;
    OccupancyDriftRate          = 0 ;
    OccupancyEligibilityTrace   = 0 ;
    MFValueDriftRate            = 0 ;
    MFEligibilityTrace          = 0 ;
    motorStayBias               = 0 ;
    choiceStayBias              = 0 ;    
    
    %------------------------------------------------------------------
    %----------- Initializations                           ------------                        
    global estimatedQValues
    global estimatedTransition
    global estimatedReward
    global estimatedOccupancy    
    
    agentInitialization()       ;        
    previousChoice          = 0 ;  
    previousMotorAction     = 0 ;  
    previousTrialType       = 0 ;

    negLogLikelihood        = 0 ;
    
    %------------------------------------------------------------------
    %----------- For each trial:                           ------------                        
    trialsNum = length ( data.trial) ;
    
    for trial = 1 : trialsNum        
        
        %------------------------------------------------------------------
        %----------- Environment Evolves :
        trialType = data.level ( trial ) ;
         
        %------------------------------------------------------------------
        %----------- If starts from the first level and continues until the end :
        if trialType == 1
            
            if data.missed1(trial)
                driftQValuesL1     ( MFValueDriftRate    ) ; 
                driftQValuesL2     ( MFValueDriftRate    ) ; 
                driftOccupancyL1   ( OccupancyDriftRate  ) ; 
                driftOccupancyL2   ( OccupancyDriftRate  ) ; 
                driftTransitionL2  ( TransitionDriftRate ) ;                 
                driftReward        ( RewardDriftRate , environmentalParameters ) ;                 
                
                trialNegLLL = 0 ;
                
            else                
                %----------- Compute MB values
                valueS2 = estimatedTransition(2,1,4)*estimatedReward(4) + estimatedTransition(2,1,5)*estimatedReward(5) ;
                valueS3 = estimatedTransition(3,1,4)*estimatedReward(4) + estimatedTransition(3,1,5)*estimatedReward(5) ;            
                ValueAction1_MB = estimatedTransition(1,1,2)*valueS2 + estimatedTransition(1,1,3)*valueS3;
                ValueAction2_MB = estimatedTransition(1,2,2)*valueS2 + estimatedTransition(1,2,3)*valueS3;            
                %----------- Compute SR values
                ValueAction1_SR = estimatedOccupancy(1,1,4)*estimatedReward(4) + estimatedOccupancy(1,1,5)*estimatedReward(5) ;
                ValueAction2_SR = estimatedOccupancy(1,2,4)*estimatedReward(4) + estimatedOccupancy(1,2,5)*estimatedReward(5) ;            
                %----------- Compute MF values
                ValueAction1_MF = estimatedQValues(1,1);
                ValueAction2_MF = estimatedQValues(1,2);            
                %----------- Compute weighted average of values            
                ValueAction1 = w_MB*ValueAction1_MB + w_SR*ValueAction1_SR + w_MF*ValueAction1_MF ;
                ValueAction2 = w_MB*ValueAction2_MB + w_SR*ValueAction2_SR + w_MF*ValueAction2_MF ;

                %----------- Computing Log Likelihood            
                firstLevelAction    = data.action(trial);                        

%                if previousTrialType==2
                    trialNegLLL         = softmaxLL (ValueAction1, ValueAction2, previousChoice , choiceStayBias , previousMotorAction , data.action1Location(trial) , motorStayBias , beta , firstLevelAction );            
%                else
%                    trialNegLLL         = 0;            
%                end
                
                previousChoice      = firstLevelAction ;
                if firstLevelAction==1
                    previousMotorAction =  data.action1Location(trial) ;
                else
                    previousMotorAction = -data.action1Location(trial) + 3 ;
                end  

                %----------- The rest of the trial :                            
                if firstLevelAction==1
                    level2State = 2 ;
                    if data.transition(trial) == 0
                        level3State = 4 ;
                    else
                        level3State = 5 ;
                    end                    
                else
                    level2State = 3 ;
                    if data.transition(trial) == 0
                        level3State = 5 ;
                    else
                        level3State = 4 ;
                    end                
                end

                if level3State == 4
                    reward = data.reward4(trial) ;
                else
                    reward = data.reward5(trial) ;
                end

                %----------- Updatings :                
                if data.missed2(trial)
                    updateQValuesL1    ( firstLevelAction , level2State , 0 , MFValueLearningRate   , MFValueDriftRate   , 0 ) ; 
                    updateOccupancyL1  ( firstLevelAction , level2State , 0 , OccupancyLearningRate , OccupancyDriftRate , 0 ) ;                     
                    updateTransitionL1 ( firstLevelAction , level2State , TransitionLearningRate                             ) ;                 
                    driftQValuesL2     ( MFValueDriftRate    ) ; 
                    driftOccupancyL2   ( OccupancyDriftRate  ) ; 
                    driftTransitionL2  ( TransitionDriftRate ) ;                 
                    driftReward        ( RewardDriftRate , environmentalParameters ) ;                    
                
                elseif data.missed3(trial)                       
                    updateQValuesL1    ( firstLevelAction , level2State , 0 , MFValueLearningRate , MFValueDriftRate , 0 ) ; 
                    updateTransitionL1 ( firstLevelAction , level2State , TransitionLearningRate                                               ) ; 
                    updateTransitionL2 ( level2State      , level3State , TransitionLearningRate                                               ) ; 
                    updateOccupancyL1  ( firstLevelAction , level2State , level3State , OccupancyLearningRate , OccupancyDriftRate , OccupancyEligibilityTrace ) ; 
                    updateOccupancyL2  ( level2State      , level3State , OccupancyLearningRate , OccupancyDriftRate ) ;                 
                    driftQValuesL2     ( MFValueDriftRate    ) ; 
                    driftReward        ( RewardDriftRate , environmentalParameters ) ;                    

                else                    
                    updateQValuesL1    ( firstLevelAction , level2State , reward , MFValueLearningRate , MFValueDriftRate , MFEligibilityTrace ) ;
                    updateQValuesL2    ( level2State                    , reward , MFValueLearningRate , MFValueDriftRate                      ) ; 
                    updateReward       ( level3State                    , reward , RewardLearningRate  , environmentalParameters               ) ; 
                    updateTransitionL1 ( firstLevelAction , level2State , TransitionLearningRate                                               ) ; 
                    updateTransitionL2 ( level2State      , level3State , TransitionLearningRate                                               ) ; 
                    updateOccupancyL1  ( firstLevelAction , level2State , level3State , OccupancyLearningRate , OccupancyDriftRate , OccupancyEligibilityTrace ) ; 
                    updateOccupancyL2  ( level2State      , level3State , OccupancyLearningRate , OccupancyDriftRate ) ; 
                    
                end
            end   
            
            previousTrialType = 1 ;
            
        %------------------------------------------------------------------
        %----------- If starts from the second level and continues until the end:
        elseif trialType == 2
            
            %----------- Experienceing transition :            
            level2State      = data.L2_state (trial) ;

            if ((level2State==2)&(data.transition(trial)==0)) | ((level2State==3)&(data.transition(trial)==1))
                level3State = 4 ;
            else
                level3State = 5 ;             
            end
                                  
            %----------- Experienceing Reward :            
            if level3State == 4
                reward = data.reward4(trial) ;
            else
                reward = data.reward5(trial) ;
            end
            
            %----------- Updatings :                
            driftQValuesL1     ( MFValueDriftRate   ) ; 
            driftOccupancyL1   ( OccupancyDriftRate ) ; 

            if data.missed2(trial)                
                driftQValuesL2     ( MFValueDriftRate    ) ; 
                driftOccupancyL2   ( OccupancyDriftRate  ) ; 
                driftTransitionL2  ( TransitionDriftRate ) ;                 
                driftReward        ( RewardDriftRate , environmentalParameters ) ;                    

            elseif data.missed3(trial)     
                updateTransitionL2 ( level2State , level3State , TransitionLearningRate      ) ; 
                updateOccupancyL2  ( level2State , level3State , OccupancyLearningRate , OccupancyDriftRate ) ;                             
                driftQValuesL2     ( MFValueDriftRate    ) ; 
                driftReward        ( RewardDriftRate , environmentalParameters ) ;                    

            else                    
                updateTransitionL2 ( level2State , level3State , TransitionLearningRate      ) ; 
                updateOccupancyL2  ( level2State , level3State , OccupancyLearningRate , OccupancyDriftRate ) ;             
                updateReward       ( level3State , reward , RewardLearningRate  , environmentalParameters ) ;
                updateQValuesL2    ( level2State , reward , MFValueLearningRate , MFValueDriftRate ) ;          

            end            
            
            %----------- Computing Log Likelihood            
            trialNegLLL = 0 ;

            previousTrialType = 2 ;
            
        %------------------------------------------------------------------
        %----------- If starts from the third level:
        else
        
            driftQValuesL1     ( MFValueDriftRate    ) ; 
            driftQValuesL2     ( MFValueDriftRate    ) ; 
            driftOccupancyL1   ( OccupancyDriftRate  ) ; 
            driftOccupancyL2   ( OccupancyDriftRate  ) ; 
            driftTransitionL2  ( TransitionDriftRate ) ; 
            
            %----------- Experienceing Reward :            
            level3State      = data.L3_state (trial) ;
            if level3State == 4
                reward = data.reward4(trial) ;
            else
                reward = data.reward5(trial) ;
            end            
            
            %----------- Updatings :                
            if data.missed3(trial)                            
                driftReward        ( RewardDriftRate , environmentalParameters ) ;                    
            
            else
                updateReward       ( level3State , reward , RewardLearningRate , environmentalParameters ) ;
            
            end
            
            %----------- Computing Log Likelihood            
            trialNegLLL = 0 ;
            
            previousTrialType = 3 ;
            
        end
        
        negLogLikelihood = negLogLikelihood + trialNegLLL ;
        
    end
    
%##########################################################################
%####                    Initializing  the  Agent                      ####
%##########################################################################    
function agentInitialization(); 
   
   
    global estimatedQValues
    global estimatedTransition
    global estimatedReward
    global estimatedOccupancy
    
    estimatedQValues            = zeros (3,2);   % The Q-values of (s1,a1) , (s1,a2) , (s2,a1) , (s3,a1)
    estimatedQValues    (1,1)   = 0.06        ;
    estimatedQValues    (1,2)   = 0.06        ;
    estimatedQValues    (2,1)   = 0.06        ;
    estimatedQValues    (2,2)   = 0.06        ;
    estimatedQValues    (3,1)   = 0.06        ;
    estimatedQValues    (3,2)   = 0.06        ;
    
    estimatedTransition         = zeros(5,2,5);
    estimatedTransition(1,1,2)  = 0.5         ;
    estimatedTransition(1,1,3)  = 0.5         ;
    estimatedTransition(1,2,2)  = 0.5         ;
    estimatedTransition(1,2,3)  = 0.5         ;
    estimatedTransition(2,1,4)  = 0.5         ;
    estimatedTransition(2,1,5)  = 0.5         ;
    estimatedTransition(3,1,4)  = 0.5         ;
    estimatedTransition(3,1,5)  = 0.5         ;

    estimatedReward             = zeros(5,1)  ; 
    estimatedReward     (4,1)   = 0.06        ;
    estimatedReward     (5,1)   = 0.06        ;
    
    estimatedOccupancy          = zeros(3,2,5);       
    estimatedOccupancy(1,1,2)   = 0.5         ;
    estimatedOccupancy(1,1,3)   = 0.5         ;
    estimatedOccupancy(1,2,2)   = 0.5         ;
    estimatedOccupancy(1,2,3)   = 0.5         ;
    estimatedOccupancy(2,1,4)   = 0.5         ;
    estimatedOccupancy(2,1,5)   = 0.5         ;
    estimatedOccupancy(3,1,4)   = 0.5         ;
    estimatedOccupancy(3,1,5)   = 0.5         ;
    estimatedOccupancy(1,1,4)   = 0.5         ;
    estimatedOccupancy(1,1,5)   = 0.5         ;    
    estimatedOccupancy(1,2,4)   = 0.5         ;
    estimatedOccupancy(1,2,5)   = 0.5         ;    
    
    
%##########################################################################
%####                      Softmax Action Selection                    ####
%##########################################################################
function trialNegLLL = softmaxLL (ValueAction1, ValueAction2, previousChoice , choiceStayBias , previousMotorAction , action1Location , motorStayBias , beta , firstLevelAction )
    
    if      previousChoice   == 1
            previousChoiceIs1 = 1;
            previousChoiceIs2 = 0;
    elseif  previousChoice   == 2
            previousChoiceIs1 = 0;
            previousChoiceIs2 = 1;
    else
            previousChoiceIs1 = 0;
            previousChoiceIs2 = 0;
    end

    if      previousMotorAction   == 0
            previousMotorActionIs1 = 0;
            previousMotorActionIs2 = 0;
    elseif (previousMotorAction   == action1Location)
            previousMotorActionIs1 = 1;
            previousMotorActionIs2 = 0;
    else 
            previousMotorActionIs1 = 0;
            previousMotorActionIs2 = 1;
    end
    
    action1    = beta * ( ValueAction1 + choiceStayBias*previousChoiceIs1 + motorStayBias*previousMotorActionIs1 ) ;
    action2    = beta * ( ValueAction2 + choiceStayBias*previousChoiceIs2 + motorStayBias*previousMotorActionIs2 ) ;
    
    action1exp = exp ( action1 );
    action2exp = exp ( action2 );
    sum = action1exp + action2exp ;
       
    if (firstLevelAction==1)
        trialNegLLL = -(action1) + log(sum) ;
    else
        trialNegLLL = -(action2) + log(sum) ;
    end
    
%##########################################################################
%####               Update agent after  lack of experience             ####
%##########################################################################        
function driftQValuesL1     ( MF_DriftRate                                            ) ; 
    global estimatedQValues
    estimatedQValues (1,1) =  estimatedQValues (1,1) * (1-MF_DriftRate) ;
    estimatedQValues (1,2) =  estimatedQValues (1,2) * (1-MF_DriftRate) ;

function driftQValuesL2     ( MF_DriftRate                                            ) ; 
    global estimatedQValues
    estimatedQValues (2,1) =  estimatedQValues (2,1) * (1-MF_DriftRate) ;
    estimatedQValues (3,1) =  estimatedQValues (3,1) * (1-MF_DriftRate) ;

function driftTransitionL2  ( TransitionDriftRate                                     ) ; 
    global estimatedTransition      

    P    = estimatedTransition ( 2 , 1 , 4 );
    newP = P + TransitionDriftRate * ( 0.5 - P ) ; % drifiting toward p=0.5
        
    estimatedTransition ( 2 , 1 , 4 ) =     newP ;
    estimatedTransition ( 2 , 1 , 5 ) = 1 - newP ;
    estimatedTransition ( 3 , 1 , 5 ) =     newP ;
    estimatedTransition ( 3 , 1 , 4 ) = 1 - newP ;

function driftReward        ( RewardDriftRate , environmentalParameters               ) ; 
    global estimatedReward
    
    meanReward = ( environmentalParameters.bigReward + environmentalParameters.smallReward ) / 2 ;
    
    estimatedReward(4) = estimatedReward(4) + RewardDriftRate * ( meanReward - estimatedReward(4) ) ;
    estimatedReward(5) = estimatedReward(5) + RewardDriftRate * ( meanReward - estimatedReward(5) ) ;

function driftOccupancyL1   ( OccupancyDriftRate                                      ) ; 
    global estimatedOccupancy

    estimatedOccupancy ( 1 , 1 , 4 ) =  estimatedOccupancy ( 1 , 1 , 4 ) * (1-OccupancyDriftRate) ;
    estimatedOccupancy ( 1 , 1 , 5 ) =  estimatedOccupancy ( 1 , 1 , 5 ) * (1-OccupancyDriftRate) ;
    estimatedOccupancy ( 1 , 2 , 4 ) =  estimatedOccupancy ( 1 , 2 , 4 ) * (1-OccupancyDriftRate) ;
    estimatedOccupancy ( 1 , 2 , 5 ) =  estimatedOccupancy ( 1 , 2 , 5 ) * (1-OccupancyDriftRate) ;

function driftOccupancyL2   ( OccupancyDriftRate                                      ) ; 
    global estimatedOccupancy

    estimatedOccupancy ( 2 , 1 , 4 ) =  estimatedOccupancy ( 2 , 1 , 4 ) * (1-OccupancyDriftRate) ;
    estimatedOccupancy ( 2 , 1 , 5 ) =  estimatedOccupancy ( 2 , 1 , 5 ) * (1-OccupancyDriftRate) ;
    estimatedOccupancy ( 3 , 1 , 4 ) =  estimatedOccupancy ( 3 , 1 , 4 ) * (1-OccupancyDriftRate) ;
    estimatedOccupancy ( 3 , 1 , 5 ) =  estimatedOccupancy ( 3 , 1 , 5 ) * (1-OccupancyDriftRate) ;      
       
%##########################################################################
%####                   Update agent after experience                  ####
%##########################################################################        
function updateTransitionL1 ( firstLevelAction , level2State , TransitionLearningRate ) ; 
  
    global estimatedTransition      
    P    = estimatedTransition (1,firstLevelAction,level2State);
    newP = P + TransitionLearningRate * (1-P) ;

    if firstLevelAction==1
        otherAction = 2;
    else
        otherAction = 1;
    end
    
    if level2State==2
        otherState = 3;
    else
        otherState = 2;
    end
    
    estimatedTransition (1,firstLevelAction,level2State) = newP     ;
    estimatedTransition (1,firstLevelAction,otherState ) = 1 - newP ;
    estimatedTransition (1,otherAction     ,level2State) = 1 - newP ;
    estimatedTransition (1,otherAction     ,otherState ) = newP     ;

function updateTransitionL2 ( level2State      , level3State , TransitionLearningRate ) ; 
    
    global estimatedTransition      
    P    = estimatedTransition (level2State , 1 , level3State );
    newP = P + TransitionLearningRate * (1-P) ;

    if level2State==2
        otherLevel2State = 3;
    else
        otherLevel2State = 2;
    end

    if level3State==4
        otherLevel3State = 5;
    else
        otherLevel3State = 4;
    end
        
    estimatedTransition (      level2State , 1 ,      level3State ) =     newP ;
    estimatedTransition (      level2State , 1 , otherLevel3State ) = 1 - newP ;
    estimatedTransition ( otherLevel2State , 1 ,      level3State ) = 1 - newP ;
    estimatedTransition ( otherLevel2State , 1 , otherLevel3State ) =     newP ;
                            
function updateReward       ( level3State , reward , RewardLearningRate , environmentalParameters ) ; 

    global estimatedReward

    if level3State==4
        otherLevel3State = 5;
    else
        otherLevel3State = 4;
    end
    
    if reward == environmentalParameters.bigReward
        otherLevel3Reward = environmentalParameters.smallReward ;
    else
        otherLevel3Reward = environmentalParameters.bigReward   ;
    end
    
    error = reward - estimatedReward (level3State) ;
    estimatedReward (level3State) = estimatedReward (level3State) + RewardLearningRate * error ;

    error = otherLevel3Reward - estimatedReward (otherLevel3State) ;
    estimatedReward (otherLevel3State) = estimatedReward (otherLevel3State) + RewardLearningRate * error ;

function updateQValuesL1    ( firstLevelAction , level2State , reward , MF_LearningRate , MF_DriftRate , MF_EligibilityTrace ) ;
    
    global estimatedQValues

    %------- Update the value of the performed action
    delta = estimatedQValues (level2State,1) - estimatedQValues (1,firstLevelAction) ;
    estimatedQValues (1,firstLevelAction) =  estimatedQValues (1,firstLevelAction) + MF_LearningRate*delta ;
    
    %------- Drift the value of the other action
    if firstLevelAction==1
        otherAction = 2;
    else
        otherAction = 1;
    end
    estimatedQValues (1,otherAction) =  estimatedQValues (1,otherAction) * (1-MF_DriftRate) ;
    
    %------- Eligibility-based update of the value of the performed action
    if ~ (reward==0)    % i.e., if the reward was observed on that trial
        delta = reward - estimatedQValues (1,firstLevelAction) ;
        estimatedQValues (1,firstLevelAction) =  estimatedQValues (1,firstLevelAction) + MF_LearningRate * delta * MF_EligibilityTrace ;
    end
       
function updateQValuesL2    ( level2State , reward , MF_LearningRate , MF_DriftRate          ) ; 
    
    global estimatedQValues
    
    delta = reward - estimatedQValues (level2State,1) ;
    estimatedQValues (level2State,1) =  estimatedQValues (level2State,1) + MF_LearningRate*delta ;
    
    if level2State==2
        otherState = 3;
    else
        otherState = 2;
    end
    estimatedQValues (otherState,1) =  estimatedQValues (otherState,1) * (1-MF_DriftRate) ;
    
function updateOccupancyL1  ( firstLevelAction , level2State , level3State , OccupancyLearningRate , OccupancyDriftRate , OccupancyEligibilityTrace ) ; 
    
    global estimatedOccupancy
        
    if firstLevelAction==1
        otherAction = 2;
    else
        otherAction = 1;
    end
    
    %------- Update the occupancy of the performed action
    error = estimatedOccupancy ( level2State , 1 , 4 ) - estimatedOccupancy ( 1 , firstLevelAction , 4 ) ;
    estimatedOccupancy ( 1 , firstLevelAction , 4 ) = estimatedOccupancy ( 1 , firstLevelAction , 4 ) + OccupancyLearningRate * error  ;

    error = estimatedOccupancy ( level2State , 1 , 5 ) - estimatedOccupancy ( 1 , firstLevelAction , 5 ) ;
    estimatedOccupancy ( 1 , firstLevelAction , 5 ) = estimatedOccupancy ( 1 , firstLevelAction , 5 ) + OccupancyLearningRate * error  ;
        
    %------- Drift the occupancy of the other action
    estimatedOccupancy ( 1 , otherAction , 4 ) =  estimatedOccupancy ( 1 , otherAction , 4 ) * (1-OccupancyDriftRate) ;
    estimatedOccupancy ( 1 , otherAction , 5 ) =  estimatedOccupancy ( 1 , otherAction , 5 ) * (1-OccupancyDriftRate) ;   
    
    %------- Eligibility-based update of the occupancy of the performed action
    if ~(level3State==0)    % i.e., if the level3 state was observed on that trial
        
        if level3State == 4
            s4 = 1 ;
            s5 = 0 ;
        else
            s4 = 0 ;
            s5 = 1 ;
        end
        
        error = s4 - estimatedOccupancy ( 1 , firstLevelAction , 4 ) ;
        estimatedOccupancy ( 1 , firstLevelAction , 4 ) = estimatedOccupancy ( 1 , firstLevelAction , 4 ) + OccupancyLearningRate * error * OccupancyEligibilityTrace  ;

        error = s5 - estimatedOccupancy ( 1 , firstLevelAction , 5 ) ;
        estimatedOccupancy ( 1 , firstLevelAction , 5 ) = estimatedOccupancy ( 1 , firstLevelAction , 5 ) + OccupancyLearningRate * error * OccupancyEligibilityTrace  ;
        
    end 
        
function updateOccupancyL2  ( level2State , level3State , OccupancyLearningRate , OccupancyDriftRate ) ;   
    
    global estimatedOccupancy
    
    if level2State==2
        otherLevel2State = 3;
    else
        otherLevel2State = 2;
    end

    if level3State==4
        otherLevel3State = 5;
    else
        otherLevel3State = 4;
    end

    error = 1 - estimatedOccupancy ( level2State , 1 , level3State );
    estimatedOccupancy ( level2State , 1 , level3State ) = estimatedOccupancy ( level2State , 1 , level3State ) + OccupancyLearningRate * error ;

    error = 0 - estimatedOccupancy ( level2State , 1 , otherLevel3State );
    estimatedOccupancy ( level2State , 1 , otherLevel3State ) = estimatedOccupancy ( level2State , 1 , otherLevel3State ) + OccupancyLearningRate * error ;
    
    estimatedOccupancy ( otherLevel2State , 1 , 4 ) = estimatedOccupancy ( otherLevel2State , 1 , 4 ) * (1-OccupancyDriftRate) ;
    estimatedOccupancy ( otherLevel2State , 1 , 5 ) = estimatedOccupancy ( otherLevel2State , 1 , 5 ) * (1-OccupancyDriftRate) ;    
