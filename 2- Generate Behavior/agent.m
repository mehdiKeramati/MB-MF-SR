function behavior = agent(  subjectNumber , agentParams ) ;

    w_MB                            = agentParams.wMB                               ;
    w_SR                            = agentParams.wSR                               ;    
    w_MF                            = agentParams.wMF                               ;    
    beta                            = agentParams.beta                              ;    
    TransitionLearningRate          = agentParams.TransitionLearningRate            ;    
    TransitionDriftRate             = agentParams.TransitionDriftRate               ;    
    RewardLearningRate              = agentParams.RewardLearningRate                ;    
    RewardDriftRate                 = agentParams.RewardDriftRate                   ;    
    OccupancyLearningRate           = agentParams.OccupancyLearningRate             ;    
    OccupancyDriftRate              = agentParams.OccupancyDriftRate                ;    
    OccupancyEligibilityTrace       = agentParams.OccupancyEligibilityTrace         ;    
    MFValueLearningRate             = agentParams.MFValueLearningRate               ;    
    MFValueDriftRate                = agentParams.MFValueDriftRate                  ;    
    MFEligibilityTrace              = agentParams.MFEligibilityTrace                ;    
    choiceStayBias                  = agentParams.choiceStayBias                    ;    
    motorStayBias                   = agentParams.motorStayBias                     ;    
    
    %------------------------------------------------------------------
    %----------- Initializations                           ------------                        
    global estimatedQValues
    global estimatedTransition
    global estimatedReward
    global estimatedOccupancy    
    
    agentInitialization()       ;        
    previousChoice          = 0 ;  
    previousMotorAction     = 0 ;  
   
    %------------------------------------------------------------------
    %----------- Load the environment                      ------------                        
    dataTmp = load (['../D1_Tasks/Subj',num2str(subjectNumber,'%0.4d'),'_stim.mat']);
    data = dataTmp.taskStim ;
    trialsNum = length ( data ) ;
    
    behavior = zeros ( trialsNum , 3 ) ;

    %------------------------------------------------------------------
    %----------- Set the environmental parameters          ------------                                
    environmentalParameters.bigReward   = max (data ( 1 , 3 ) , data ( 1 , 4 )) ;
    environmentalParameters.smallReward = min (data ( 1 , 3 ) , data ( 1 , 4 )) ;
    
    %------------------------------------------------------------------
    %----------- For each trial:                           ------------                               
    for trial = 1 : trialsNum        
        
        %------------------------------------------------------------------
        %----------- Environment Evolves :
        trialType = data ( trial , 7 ) ;
         
        %------------------------------------------------------------------
        %----------- If starts from the first level and continues until the end :
        if trialType == 1
                           
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

                %----------- Action selection                            
                firstLevelAction = softmax (ValueAction1, ValueAction2, previousChoice , choiceStayBias , 0 , 0 , motorStayBias , beta );                                            
                previousChoice   = firstLevelAction ;

                %----------- The rest of the trial :                            
                if firstLevelAction==1
                    level2State = 2 ;
                    if data(trial,2) == 0
                        level3State = 4 ;
                    else
                        level3State = 5 ;
                    end                    
                else
                    level2State = 3 ;
                    if data(trial,2) == 0
                        level3State = 5 ;
                    else
                        level3State = 4 ;
                    end                
                end

                if level3State == 4
                    reward = data(trial,3) ;
                else
                    reward = data(trial,4) ;
                end

                %----------- Updatings :                
                 
                updateQValuesL1    ( firstLevelAction , level2State , reward , MFValueLearningRate , MFValueDriftRate , MFEligibilityTrace ) ;
                updateQValuesL2    ( level2State                    , reward , MFValueLearningRate , MFValueDriftRate                      ) ; 
                updateReward       ( level3State                    , reward , RewardLearningRate  , environmentalParameters               ) ; 
                updateTransitionL1 ( firstLevelAction , level2State , TransitionLearningRate                                               ) ; 
                updateTransitionL2 ( level2State      , level3State , TransitionLearningRate                                               ) ; 
                updateOccupancyL1  ( firstLevelAction , level2State , level3State , OccupancyLearningRate , OccupancyDriftRate , OccupancyEligibilityTrace ) ; 
                updateOccupancyL2  ( level2State      , level3State , OccupancyLearningRate , OccupancyDriftRate ) ; 

        %------------------------------------------------------------------
        %----------- If starts from the second level and continues until the end:
        elseif trialType == 2
           
            firstLevelAction = 0 ;

            %----------- Experienceing transition :            
            level2State      = data (trial,8) ;

            if ((level2State==2)&(data(trial,2)==0)) | ((level2State==3)&(data(trial,2)==1))
                level3State = 4 ;
            else
                level3State = 5 ;             
            end
                                  
            %----------- Experienceing Reward :            
            if level3State == 4
                reward = data(trial,3) ;
            else
                reward = data(trial,4) ;
            end            
            %----------- Updatings :                
            driftQValuesL1     ( MFValueDriftRate   ) ; 
            driftOccupancyL1   ( OccupancyDriftRate ) ; 

            updateTransitionL2 ( level2State , level3State , TransitionLearningRate      ) ; 
            updateOccupancyL2  ( level2State , level3State , OccupancyLearningRate , OccupancyDriftRate ) ;             
            updateReward       ( level3State , reward , RewardLearningRate  , environmentalParameters ) ;
            updateQValuesL2    ( level2State , reward , MFValueLearningRate , MFValueDriftRate ) ;          
            
        %------------------------------------------------------------------
        %----------- If starts from the third level:
        else
        
            firstLevelAction = 0 ;

            driftQValuesL1     ( MFValueDriftRate    ) ; 
            driftQValuesL2     ( MFValueDriftRate    ) ; 
            driftOccupancyL1   ( OccupancyDriftRate  ) ; 
            driftOccupancyL2   ( OccupancyDriftRate  ) ; 
            driftTransitionL2  ( TransitionDriftRate ) ; 
            
            %----------- Experienceing Reward :            
            level3State      = data(trial,9) ;
            if level3State == 4
                reward = data(trial,3) ;
            else
                reward = data(trial,4) ;
            end             
            
            updateReward       ( level3State , reward , RewardLearningRate , environmentalParameters ) ;
                        
        end
        

        %------------------------------------------------------------------
        %----------- Log the trial :
        behavior ( trial , 1  ) = firstLevelAction        ;        
        if (trialType == 1) | (trialType == 2)
            behavior ( trial , 2 ) = level2State        ;
            behavior ( trial , 3 ) = level3State        ;
        else
            behavior ( trial , 3 ) = level3State        ;
        end
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
function action = softmax (ValueAction1, ValueAction2, previousChoice , choiceStayBias , previousMotorAction , action1Location , motorStayBias , beta )
    
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

    action1Prob = action1exp / sum ;
    
    if rand()<action1Prob
        action = 1;
    else
        action = 2;
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
 