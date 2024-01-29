function generateTask ( )

    subjectsNum                     =  100       ;
           
    taskParams      = struct (  'trialsNum'                             , 365       ,...
                                'bigReward'                             , 0.10      ,...
                                'smallReward'                           , 0.02      ,...
                                'rewardProbability'                     , 1.00      ,...  % the chance of observing the real reward in the visited terminal state
                                'minNumOfType1Trial'                    , 2         ,...  % minimum number of trials of starting from level 1
                                'probOfStayingType1Trial'               , 0.5       ,...  % probability of starting the next trial from level 1, when the current trial started from level 1
                                'maxNumOfType1Trial'                    , 4         ,...  % maximum number of trials of starting from level 1
                                'type3TrialProbability'                 , 0.20      ,...  % probability of starting from level 3 (rather than level 2) in a trial that didn't stated from level 1
                                'transitionSwitchProbability'           , 0.23      ,...
                                'rewardSwitchProbability'               , 0.23      ,...     
                                'transitionAndRewardSwitchProbability'  , 0.23      )  ;     
                                       
    clc
    
    for subject = 1 : subjectsNum
        
        disp (['        Subject number ',int2str(subject),'/',int2str(subjectsNum) ]);
        
        subjectName = [ 'Subj'   , num2str(subject,'%0.4d') ];

        taskStim  = environment ( taskParams ) ;
                     
        taskInfo  = [randi([0,1],1,1) ; randi([0,1],1,1) ; randi([0,1],1,1) ] ;
        
        infoFileName = [ '../D1_Tasks/' , subjectName , '_info.mat' ] ;
        stimFileName = [ '../D1_Tasks/' , subjectName , '_stim.mat' ] ;
        
        save ( infoFileName , 'taskInfo' ) ; 
        save ( stimFileName , 'taskStim' ) ; 
        
    end
    
end
    
