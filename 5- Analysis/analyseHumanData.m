%% Main Code
function dataAnalysis()

    %----------------------------------------------------------------------    
    synthetic_0_human_1 = 0 ;   % set this variable to :
                                %       0 : for analysis the synthetic data
                                %       1 : for analysis human data

    plotting            = 1 ;   % set this variable to one for plotting the "correct-probability" profiles
    modeling            = 1 ;   % set this variable to one for model-fitting and model-comparison analysis

    palingFactor        = 3;   % -1,1,3: for how pale the color of the "correct-probability" bars
    
    if synthetic_0_human_1      % human data 
    else                        % synthetic data
        groupName       = 'GrpMB4_GrpSR4' ;   
        subjectsNum     = 50               ;  
    end    
    %----------------------------------------------------------------------    
    
    clc
    close all
    warning('off','all')
    
    %--------------- Set Optimization Parameters 
    fminuncMaxFunEvals      = 50000                    ;
    fminuncMaxIterationNum  = 50000                    ;
    optimizationOptions = optimoptions(@fminunc,'MaxFunctionEvaluations',fminuncMaxFunEvals,'MaxIterations',fminuncMaxIterationNum,'Display','off');
   
    %--------------- Prepare for loading data
    if synthetic_0_human_1      % human data

        %--------------- Load all subjects
        IDsData    = load ('../D3_HumanBehavior/subjectsIDs.mat')   ;
        subjectIDs = IDsData.subjectIDs                    ;

        %--------------- Filter out bad subjects
        subjectIDs = filterSubjects (subjectIDs)           ;

        %--------------- For each good subject
        subjectsNum = length (subjectIDs)                  ;
        
        for subject = 1 : subjectsNum
            subjectsFileNames (subject,:) = ['../D3_HumanBehavior/',num2str(subjectIDs(subject)),'.mat'];
        end  
        
    else                        % synthetic data        
        for subject = 1 : subjectsNum
            subjectsFileNames (subject,:) = ['../D2_SynthBehavior/',groupName,'_Sub',num2str(subject,'%0.4d'),'.mat'];
        end        
    end
    
    %--------------- Set the Parameters of the Environment
    if synthetic_0_human_1      % human data
        dd = load ([ '../D3_HumanBehavior/',num2str(subjectIDs(1)),'.mat' ]) ;
    else                        % synthetic data        
        dd = load ([ '../D2_SynthBehavior/',groupName,'_Sub0001.mat' ]) ;
    end
    rawData        = dd.data;     
    environmentalParameters.bigReward   = max (rawData(1,11) , rawData(1,12)) ;
    environmentalParameters.smallReward = min (rawData(1,11) , rawData(1,12)) ;        

    %--------------- plot Correct-probability Pattern
    if plotting                
        plotCorrectProbabilityPattern (subjectsNum,subjectsFileNames,environmentalParameters,palingFactor) ;               
    end
     
    %--------------- Model fitting
    if modeling
        modelFitting ( synthetic_0_human_1 , environmentalParameters );
    end
    
end

%% Load a Subject
function data = loadSubject ( subjectFileName ) ;        
        
        dd = load (subjectFileName) ;
        rawData = dd.data;

        data.trial          = rawData(:, 1);
        data.level          = rawData(:, 2);
        data.action         = rawData(:, 3);
        data.RT1            = rawData(:, 4);
        data.RT2            = rawData(:, 5);
        data.RT3            = rawData(:, 6);
        data.missed1        = rawData(:, 7);
        data.missed2        = rawData(:, 8);
        data.missed3        = rawData(:, 9);
        data.transition     = rawData(:,10);
        data.reward4        = rawData(:,11);
        data.reward5        = rawData(:,12);
        data.reward4P       = rawData(:,13);
        data.reward5P       = rawData(:,14);
        data.L2_state       = rawData(:,15);
        data.L3_state       = rawData(:,16);
        data.action1Location= rawData(:,17);
        
%        trialsNum           = length (data.trial); % remove this line
%        data.action1Location= ones (trialsNum,1) ; % rawData(:,17); 

end

%% Filter Out Bad Subjects
function goodSubjectsIDs = filterSubjects (rawSubjectsIDs) ;

    %---------------  Criteria for accepting participants
    minTrialsNum        =   250   ; % The minimum number of trial that subject performed
    minPerformance      =   0.60  ; % Minimum performance.
    minAverageRT1       =   300   ; % in miliseconds
    actionPersistence   =   10    ; % Accept the subkject if he changed his keyboard response, on avaerage, every X trials or less, during the last 150 trials
            
    subjectNum = length (rawSubjectsIDs) ;
    goodSunjectsCounter = 0              ;
    goodSubjectsIDs     = []             ;
    
    for subject = 1 : subjectNum
    
        data = loadSubject ( rawSubjectsIDs(subject) ) ;
        trialsNum   = length (data.trial);
        
        if trialsNum >= minTrialsNum
            goodSunjectsCounter = goodSunjectsCounter + 1 ;
            goodSubjectsIDs(goodSunjectsCounter) = rawSubjectsIDs(subject) ;
        end
    end
      
%{        
        score          = 0 ;
        potentialScore = 0 ;
        
        for trial = 1 : trialsNum
            
            if (subjectData(trial,2) == 1)        
                
                potentialScore = potentialScore + max (subjectData(trial,11),subjectData(trial,12));
                
                if     (subjectData(trial,2) == 1)  % action1

                    if     (subjectData(trial,10) == 0)  % transition type A
                        trialScore = subjectData(trial,11) ;
                    else                                 % transition type B
                        trialScore = subjectData(trial,12) ;
                    end
                    
                elseif (subjectData(trial,2) == 2)  % action2
                    
                    if     (subjectData(trial,10) == 0)  % transition type A
                        trialScore = subjectData(trial,12) ;
                    else                                 % transition type B
                        trialScore = subjectData(trial,11) ;
                    end
                    
                else
                    trialScore = 0 ;
                end
            else
                trialScore = 0 ;
            end
            
            score = score + trialScore ;
        end
        
        missed1 = 0 ;
        for trial = 1 : trialsNum
            if (subjectData(trial,2) == 1)  
                if (subjectData(trial,7) == 1)
                    missed1 = missed1 + 1 ;
                end
            elseif (subjectData(trial,2) == 2)
            else
            end
        end
        
        
        disp (['ID : ', num2str(subjectIDs(subject)) ,' -- score : ' , num2str(score/potentialScore) , ' --- Trials Num : ', num2str(trialsNum)]);
     %   missed1
        money = 5 +  (score/potentialScore - 0.5 ) * 10 
    end
%}
        
end

%% End of the Code
