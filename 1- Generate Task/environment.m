% trialType =
%             1 : Start from Level 1, continue until the end : no switching
%             2 : Start from Level 2, continue until the end : no switching
%             3 : Start from Level 2, continue until the end : transition switch
%             4 : Start from Level 2, continue until the end : reward switch
%             5 : Start from Level 2, continue until the end : transition-reward switch
%             6 : Start from Level 3, continue until the end : no switching
%             7 : Start from Level 3, continue until the end : reward switch

function events = environment ( taskParams ) ;
                                       
    %------------------------------------------------------------------
    global transition
    global reward
    
    events = zeros ( taskParams.trialsNum , 9 ) ;
    
    %------------------------------------------------------------------
    %----------- Initializations                           ------------                        
    environmentInitialization( taskParams );        
    trialType                = 2 ;
    numOfPreviousType1Trials = 0 ;
    
    %------------------------------------------------------------------
    %----------- For each trial:                           ------------                        
    for trial = 1 : taskParams.trialsNum        
        
        %----------- Environment Evolves :
        [ trialType , numOfPreviousType1Trials ] = decideNextTrialType ( trialType , numOfPreviousType1Trials , taskParams , trial ) ;
        environmentEvolving ( trialType , taskParams );
         
        %----------- Starting point :
        if     trialType == 1
            level            = 1              ;
            level2State      = 0              ;
            level3State      = 0              ;
        elseif ( trialType > 1 ) & ( trialType < 6 )
            level            = 2              ;
            level2State      = randi( [2,3] ) ;                                    
            level3State      = 0              ;
        else
            level            = 3              ;
            level2State      = 0              ;                                    
            level3State      = randi( [4,5] ) ;                                    
        end

        %------------------------------------------------------------------
        %----------- Log the trial :
        events ( trial , 1  ) = trial                   ;       % Trial number
        events ( trial , 2  ) = transition (2,1,5)      ;       % Transition type

        if rand() < taskParams.rewardProbability
            rewardS4 = reward(4) ;
            rewardS5 = reward(5) ;
        else
            rewardS4 = reward(5) ;
            rewardS5 = reward(4) ;
        end
        
        events ( trial , 3  ) = rewardS4 ;
        events ( trial , 4  ) = rewardS5 ;
        events ( trial , 5  ) = taskParams.rewardProbability ;
        events ( trial , 6  ) = taskParams.rewardProbability ;
        events ( trial , 7  ) = level ;
        events ( trial , 8  ) = level2State ;
        events ( trial , 9  ) = level3State ;
                               
    end
           
    
%##########################################################################
%####                 Initializing  the  Environment                   ####
%##########################################################################    
function environmentInitialization( taskParams );        

    global transition
    global reward
    
    transition= zeros(5,2,5);
    transition(1,1,2) = 1   ;
    transition(1,2,3) = 1   ;
    transition(2,1,4) = 1   ;
    transition(3,1,5) = 1   ;
    
    reward    = zeros (5,1) ; 
    reward(4) = taskParams.bigReward   ;
    reward(5) = taskParams.smallReward ;

%##########################################################################
%####                     Decide the next trial type                   ####
%##########################################################################
function [ trialType , numOfPreviousType1Trials ] = decideNextTrialType ( previousTrialType , previousNumOfPreviousType1Trials , taskParams , trial ) ; 

    if previousTrialType > 1
        trialType                = 1 ;
        numOfPreviousType1Trials = 1 ;
    
    elseif previousNumOfPreviousType1Trials < taskParams.minNumOfType1Trial
        trialType                = 1 ;
        numOfPreviousType1Trials = previousNumOfPreviousType1Trials + 1 ;        
   
    else
        
        if ( rand () < taskParams.probOfStayingType1Trial ) & ( previousNumOfPreviousType1Trials < taskParams.maxNumOfType1Trial )
            trialType                = 1 ;
            numOfPreviousType1Trials = previousNumOfPreviousType1Trials + 1 ;        
        
        else
            
            numOfPreviousType1Trials = 0 ;

            if trial < 65
                type3TrialProbability = 0.5 ;
            else
                type3TrialProbability = taskParams.type3TrialProbability ;
            end
            
            if rand() < type3TrialProbability                
                
                rewardSwitchRand = rand() ;
                if rewardSwitchRand < 0.5
                    trialType = 7 ;                
                else
                    trialType = 6 ;                    
                end
                
            else
                
                switchingRand     = rand() ;
                                
                if     (switchingRand < taskParams.transitionAndRewardSwitchProbability)
                    trialType = 5 ;
                elseif (switchingRand < taskParams.rewardSwitchProbability + taskParams.transitionAndRewardSwitchProbability )
                    trialType = 4 ;
                elseif (switchingRand < taskParams.rewardSwitchProbability + taskParams.transitionAndRewardSwitchProbability + taskParams.transitionSwitchProbability)
                    trialType = 3 ;
                else
                    trialType = 2 ;                    
                end
                
            end
        end
        
    end
    
%##########################################################################
%####                    Environment Evolving                          ####
%##########################################################################    
function environmentEvolving ( trialType , taskParams );
    
    global transition
    global reward
    
    if     ( trialType == 1 ) | ( trialType == 2 ) | ( trialType == 6 )     % no switching

    elseif   trialType == 3                                                 % switch transition
            if transition(2,1,4) == 1
                transition(2,1,4) = 0   ;
                transition(3,1,5) = 0   ;
                transition(2,1,5) = 1   ;
                transition(3,1,4) = 1   ;
            else
                transition(2,1,5) = 0   ;
                transition(3,1,4) = 0   ;            
                transition(2,1,4) = 1   ;
                transition(3,1,5) = 1   ;
            end            
       
    elseif  ( trialType == 4 ) | ( trialType == 7 )                         % switch reward
            if reward(4) == taskParams.bigReward
                reward(4) = taskParams.smallReward ;
                reward(5) = taskParams.bigReward   ;
            else
                reward(4) = taskParams.bigReward   ;
                reward(5) = taskParams.smallReward ;
            end
       
    elseif    trialType == 5                                                % switch transition and reward
        
            if transition(2,1,4) == 1
                transition(2,1,4) = 0   ;
                transition(3,1,5) = 0   ;
                transition(2,1,5) = 1   ;
                transition(3,1,4) = 1   ;
            else
                transition(2,1,5) = 0   ;
                transition(3,1,4) = 0   ;            
                transition(2,1,4) = 1   ;
                transition(3,1,5) = 1   ;
            end   
            
            if reward(4) == taskParams.bigReward
                reward(4) = taskParams.smallReward ;
                reward(5) = taskParams.bigReward   ;
            else
                reward(4) = taskParams.bigReward   ;
                reward(5) = taskParams.smallReward ;
            end            
            
    end  