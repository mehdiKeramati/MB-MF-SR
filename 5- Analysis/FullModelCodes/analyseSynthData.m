%% Main Code
function dataAnalysis()

    plottingCorrectProb     = 1  ; 
        palingFactor        = 3  ;    % -1,1,3: for how pale the color of the "correct-probability" bars    
        groupName           = 'GrpMB4_GrpSR4' ;   
        subjectsNum         = 10               ;  

    modeling                = 1  ;    % set this variable to one for model-fitting and model-comparison analysis
        wMB_SampleNumStarts = 4  ;
        wMB_SampleNumEnds   = 4 ;
        wSR_SampleNumStarts = 4  ;
        wSR_SampleNumEnds   = 4 ;
        
    modelComparisoning      = 0  ;    
        
    plottingConfusionMatrix = 0  ; 
    
    %--------------------------------------------------------------------------        
    clc
    close all
    warning('off','all')

    %--------------- Set the Parameters of the Environment
    dd = load ([ '../D2_SynthBehavior/',groupName,'_Sub0001.mat' ]) ;
    rawData        = dd.data;     
    environmentalParameters.bigReward   = max (rawData(1,11) , rawData(1,12)) ;
    environmentalParameters.smallReward = min (rawData(1,11) , rawData(1,12)) ;        

    %######################################################################
    %############       Plotting Correct Probability        ###############
    %######################################################################
    if plottingCorrectProb
        for subject = 1 : subjectsNum
            subjectsFileNames (subject,:) = ['../D2_SynthBehavior/',groupName,'_Sub',num2str(subject,'%0.4d'),'.mat'];
        end        

        %--------------- plot Correct-probability Pattern
        plotCorrectProbabilityPattern (subjectsNum,subjectsFileNames,environmentalParameters,palingFactor) ;               
    end
    
    %######################################################################
    %###############             Model Fitting           ##################
    %######################################################################              
    if modeling
        modelFitting    ( subjectsNum , environmentalParameters , wMB_SampleNumStarts , wMB_SampleNumEnds , wSR_SampleNumStarts , wSR_SampleNumEnds );
    end
    if modelComparisoning
        modelComparison ( subjectsNum ) ;
    end
        
    %######################################################################
    %############        Plotting Confusion Matrix          ###############
    %######################################################################              
    if plottingConfusionMatrix    
        plotConfusionMatrix (subjectsNum);
    end
    
end

%--------------------------------------------------------------------------
%-------------------  Model Fitting And Comparision  ----------------------
%--------------------------------------------------------------------------
function modelFitting ( subjectsNum , environmentalParameters , wMB_SampleNumStarts , wMB_SampleNumEnds , wSR_SampleNumStarts , wSR_SampleNumEnds );
    
    samplesNumsPerModel = 11 ;    
    
    %--------------- Set Optimization Parameters 
    fminuncMaxFunEvals      = 50000                    ;
    fminuncMaxIterationNum  = 50000                    ;
    optimizationOptions = optimoptions(@fminunc,'MaxFunctionEvaluations',fminuncMaxFunEvals,'MaxIterations',fminuncMaxIterationNum,'Display','off');
    
    for i = wMB_SampleNumStarts : wMB_SampleNumEnds
        for j = wSR_SampleNumStarts : min(samplesNumsPerModel-i+1,wSR_SampleNumEnds)    

            disp (['Estimating parameters for group ',int2str(i),' - ',int2str(j) ]);
            
            for subject = 1 : subjectsNum
            
                subjectName = ['_Sub',num2str(subject,'%0.4d')];                
                subjectFileName = ['../D2_SynthBehavior/GrpMB',int2str(i),'_GrpSR',int2str(j),subjectName,'.mat']  ;

                disp (['     For subject ',int2str(subject),' / ',int2str(subjectsNum) ]);

                % ---------- Fit each of the 8 hybrid models
                for model = 1 : 8

                    disp (['               Fitting model number ' , num2str(model) , '.' ] ) ;

                    modelFittingResults = fitModelToData ( model , subjectFileName , environmentalParameters , optimizationOptions ) ;

                    normalizedParams     = normalizeParameters ( model , modelFittingResults ) ;
                    
                    resultsFileName     = ['../D4_SynthModelFitResult/GrpMB',int2str(i),'_GrpSR',int2str(j),subjectName,'_model',int2str(model),'.mat']  ;
                    saveResults ( resultsFileName , model , modelFittingResults , normalizedParams ) ;
                    
                end

            end
        end
    end
end

function output = fitModelToData ( model , subjectFileName , environmentalParameters , optimizationOptions ) ;

    %--------- Models' basic definition
    if      model == 1
        output.componentMB= 0  ;
        output.componentSR= 0  ;
        output.componentMF= 0  ;    
        output.freeParams = 2  ;    
    elseif  model == 2
        output.componentMB= 0  ;
        output.componentSR= 0  ;
        output.componentMF= 1  ;
        output.freeParams = 6  ;
    elseif  model == 3
        output.componentMB= 0  ;
        output.componentSR= 1  ;
        output.componentMF= 0  ;
        output.freeParams = 8  ;
    elseif  model == 4
        output.componentMB= 0  ;
        output.componentSR= 1  ;
        output.componentMF= 1  ;
        output.freeParams = 12 ;    
    elseif  model == 5
        output.componentMB= 1  ;
        output.componentSR= 0  ;
        output.componentMF= 0  ;
        output.freeParams = 7  ;    
    elseif  model == 6
        output.componentMB= 1  ;
        output.componentSR= 0  ;
        output.componentMF= 1  ;
        output.freeParams = 11 ;    
    elseif  model == 7
        output.componentMB= 1  ;
        output.componentSR= 1  ;
        output.componentMF= 0  ;
        output.freeParams = 11 ;    
    elseif  model == 8
        output.componentMB= 1  ;
        output.componentSR= 1  ;
        output.componentMF= 1  ;
        output.freeParams = 15 ;    
    end
   
    %--------- Load data
    data = loadSubject ( subjectFileName ) ;

    %--------- Fit the model to data
    initialParam = rand ( 15 , 1 );          
    negLogLikelihoodFunction = @(parameterValues) negLogLikelihood ( parameterValues , data , output.componentMB , output.componentSR , output.componentMF , environmentalParameters );
    [params,fval,exitflag,fMinuncOutput,grad,hessian] = fminunc( negLogLikelihoodFunction , initialParam , optimizationOptions );    
  
    %--------- Set the output
    dd                      = load (subjectFileName) ;
    rawData                 = dd.data ;
    trialsNum               = countCritialTrials (rawData) ;
    
    output.paramsMean       = params    ;
    output.paramsHessian    = hessian   ;
    output.negLL            = fval      ; 
    output.BIC              = 2 * fval  +  output.freeParams * log(trialsNum) ; 
    
end

function criticalTrialsNum = countCritialTrials (rawData) ;
    criticalTrialsNum = 0; 

    trialsNum = length (rawData(:,1));
    
    x=rawData(:,2);
    
    for trial = 2 : trialsNum
        if (rawData(trial,2)==2) & (rawData(trial-1,2)==1) 
            criticalTrialsNum = criticalTrialsNum + 1 ;
        end
    end
    
end

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

end

function normalizedParams  = normalizeParameters ( model , modelFittingResults ) ;

    %--------- Models' basic definition
    if      model == 1
        componentMB= 0  ;
        componentSR= 0  ;
        componentMF= 0  ;    
    elseif  model == 2
        componentMB= 0  ;
        componentSR= 0  ;
        componentMF= 1  ;
    elseif  model == 3
        componentMB= 0  ;
        componentSR= 1  ;
        componentMF= 0  ;
    elseif  model == 4
        componentMB= 0  ;
        componentSR= 1  ;
        componentMF= 1  ;
    elseif  model == 5
        componentMB= 1  ;
        componentSR= 0  ;
        componentMF= 0  ;
    elseif  model == 6
        componentMB= 1  ;
        componentSR= 0  ;
        componentMF= 1  ;
    elseif  model == 7
        componentMB= 1  ;
        componentSR= 1  ;
        componentMF= 0  ;
    elseif  model == 8
        componentMB= 1  ;
        componentSR= 1  ;
        componentMF= 1  ;
    end        
    
    %--------- Normalize all parameters    
    if componentMB  eMB = exp(modelFittingResults.paramsMean(1));  else    eMB = 0;    end    
    if componentSR  eSR = exp(modelFittingResults.paramsMean(2));  else    eSR = 0;    end    
    if componentMF  eMF = exp(1)                                ;  else    eMF = 0;    end    
    
    if  componentMB | componentSR | componentMF
        normalizer = eMB + eSR + eMF        ;   
    else
        normalizer = 1                      ;           
    end
    
    normalizedParams.w_MB                            = eMB / normalizer                                             ;
    normalizedParams.w_SR                            = eSR / normalizer                                             ;
    if componentMF             
        normalizedParams.w_MF = 1 - normalizedParams.w_MB - normalizedParams.w_SR ;   
    else
        normalizedParams.w_MF=0;    
    end       ;
    
    normalizedParams.beta                            =             exp( modelFittingResults.paramsMean( 3 ) )       ; 
    normalizedParams.TransitionLearningRate          = 1.0 / ( 1 + exp(-modelFittingResults.paramsMean( 4 )))       ;
    normalizedParams.TransitionDriftRate             = 1.0 / ( 1 + exp(-modelFittingResults.paramsMean( 5 )))       ;
    normalizedParams.RewardLearningRate              = 1.0 / ( 1 + exp(-modelFittingResults.paramsMean( 6 )))       ;
    normalizedParams.RewardDriftRate                 = 1.0 / ( 1 + exp(-modelFittingResults.paramsMean( 7 )))       ;
    normalizedParams.OccupancyLearningRate           = 1.0 / ( 1 + exp(-modelFittingResults.paramsMean( 8 )))       ;
    normalizedParams.OccupancyDriftRate              = 1.0 / ( 1 + exp(-modelFittingResults.paramsMean( 9 )))       ;
    normalizedParams.OccupancyEligibilityTrace       = 1.0 / ( 1 + exp(-modelFittingResults.paramsMean( 10)))       ;    
    normalizedParams.MFValueLearningRate             = 1.0 / ( 1 + exp(-modelFittingResults.paramsMean( 11)))       ;
    normalizedParams.MFValueDriftRate                = 1.0 / ( 1 + exp(-modelFittingResults.paramsMean( 12)))       ;        
    normalizedParams.MFEligibilityTrace              = 1.0 / ( 1 + exp(-modelFittingResults.paramsMean( 13)))       ;    
    normalizedParams.choiceStayBias                  =                  modelFittingResults.paramsMean( 14 )        ;
    normalizedParams.motorStayBias                   =                  modelFittingResults.paramsMean( 15 )        ;  
    
    %--------- Set undefined parameters to NaN    
    if ~componentMB  
        normalizedParams.TransitionLearningRate          = nan ;
        normalizedParams.TransitionDriftRate             = nan ;    
    end    
    if ~componentSR  
        normalizedParams.OccupancyLearningRate           = nan ;
        normalizedParams.OccupancyDriftRate              = nan ;
        normalizedParams.OccupancyEligibilityTrace       = nan ;    
    end    
    if ~componentMF
        normalizedParams.MFValueLearningRate             = nan ;
        normalizedParams.MFValueDriftRate                = nan ;        
        normalizedParams.MFEligibilityTrace              = nan ;            
    end  
    if (~componentMB) & (~componentSR)
        normalizedParams.RewardLearningRate              = nan ;
        normalizedParams.RewardDriftRate                 = nan ;
    end    
    
end

function saveResults ( resultsFileName , model , modelFittingResults , normalizedParams ) ;
 
    data.model                  = model          ;
    data.modelFittingResults    = modelFittingResults   ;
    data.normalizedParams       = normalizedParams      ;
    
    save (resultsFileName,'data') ;
    
end

function modelComparison ( subjectsNum ) ;
  
    samplesNumsPerModel = 11 ;

    wMB_SampleNumStarts = 1  ;
    wMB_SampleNumEnds   = 11 ;
    wSR_SampleNumStarts = 1  ;
    wSR_SampleNumEnds   = 11 ;

    for i = wMB_SampleNumStarts : wMB_SampleNumEnds
        for j = wSR_SampleNumStarts : min(samplesNumsPerModel-i+1,wSR_SampleNumEnds)    

            estimatedParamsFileName = ['../D4_SynthModelFitResult/GrpMB',int2str(i),'_GrpSR',int2str(j),'_Sub0001_model1.mat' ]  ;            
            if exist(estimatedParamsFileName, 'file') == 2    % Synthetic data for this i-j case is analyised

                %-------------- Compute Sum of BIC for each model
                
                BICs = zeros (8,subjectsNum) ;
                
                for subject = 1 : subjectsNum
                    
                    for model = 1 : 8                                        

                        subjectName         = ['_Sub',num2str(subject,'%0.4d')];                
                        resultsFileName     = ['../D4_SynthModelFitResult/GrpMB',int2str(i),'_GrpSR',int2str(j),subjectName,'_model',int2str(model),'.mat']  ;
                        resultTemp          = load (resultsFileName);
                        result              = resultTemp.data ;
                        
                        BICs(model,subject) = result.modelFittingResults.BIC ;
                                                
                    end 
                    
                end                                
                
                BIC    = zeros (8,1) ;
                for model = 1 : 8
                    BIC(model) = sum (BICs(model,:));
                end     
                
                %-------------- Find the winning model
                winningModel        = find(BIC == min(BIC(:)));                
 %               winningModel=8;
                %-------------- Save the params for the winning model
                for subject = 1 : subjectsNum
                    subjectName         = ['_Sub',num2str(subject,'%0.4d')];                
                    resultsFileName     = ['../D4_SynthModelFitResult/GrpMB',int2str(i),'_GrpSR',int2str(j),subjectName,'_model',int2str(winningModel),'.mat']  ;
                    resultTemp          = load (resultsFileName);
                    result              = resultTemp.data ;

                    wMBs (subject)      = result.normalizedParams.w_MB; 
                    wSRs (subject)      = result.normalizedParams.w_SR; 
                    wMFs (subject)      = result.normalizedParams.w_MF; 

                end 
                
                data.winningModel   = winningModel ;
                data.wMBs_normalized= wMBs         ;
                data.wSRs_normalized= wSRs         ;
                data.wMFs_normalized= wMFs         ;
                
                winningFileName     = ['../D4_SynthModelFitResult/GrpMB',int2str(i),'_GrpSR',int2str(j),'_winningModel.mat']  ;                
                save (winningFileName,'data')
                
            end
        end
    end

end

%--------------------------------------------------------------------------
%-------------------      Plot confusion Matrix      ----------------------
%--------------------------------------------------------------------------
function plotConfusionMatrix(subjectsNum);
    
    samplesNumsPerModel = 11 ;

    wMB_SampleNumStarts = 4  ;
    wMB_SampleNumEnds   = 4 ;
    wSR_SampleNumStarts = 4  ;
    wSR_SampleNumEnds   = 4 ;
    
    %------------ Plot true vs. estimated weights    -------------
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

            estimatedParamsFileName = ['../D4_SynthModelFitResult/GrpMB',int2str(i),'_GrpSR',int2str(j),'_winningModel.mat' ]  ;
            trueParamsFileName      = ['../D2_SynthBehavior/GrpMB',int2str(i),'_GrpSR',int2str(j),'_Sub0001_params.mat']  ;                        
            
            if exist(estimatedParamsFileName, 'file') == 2    % Synthetic data for this case is analyised

                %--------------- extract true weights ---------------------
                trueParamsTmp      = load (trueParamsFileName     ) ;

                trueParams      = trueParamsTmp.agentParams ;
                
                wMB   (i,j)  = trueParams.wMB;
                wSR   (i,j)  = trueParams.wSR;
                wMF   (i,j)  = trueParams.wMF;

                [x y] = transform2simplex ( wMB   (i,j) , wSR   (i,j) , wMF   (i,j) ) ;
                wXSimplex   (i,j) = x ;
                wYSimplex   (i,j) = y ;
                

                %--------------- extract estimated weights ----------------
                estimatedParamsTmp = load (estimatedParamsFileName) ;
                estimatedParams    = estimatedParamsTmp.data        ;
                
                wMBest = estimatedParams.wMBs_normalized ;
                wSRest = estimatedParams.wSRs_normalized ;
                wMFest = estimatedParams.wMFs_normalized ;
                    
                for subject = 1 : subjectsNum

                    [x y] = transform2simplex ( wMBest(subject) , wSRest(subject) , wMFest(subject) ) ;
                    
                    %--------------- plot the connecting line -----------------
                    plot([x,wXSimplex(i,j)],[y,wYSimplex(i,j)],'-black');
                    hold on
                    %--------------- plot estimated weights -------------------
                    plot(x,y,'-.or','MarkerFaceColor','r');    
                
                end
                
%{
                %--------------- plot confidence interval -----------------
                samolesNum = 100 ;

                covMatrix = inv ( estimatedParams.modelFittingResults.paramsHessian ) ;

                for sample = 1 : samolesNum


                    %--------- Take a sample [xx yy]
                    mu = [estimatedParams.modelFittingResults.paramsMean(1),estimatedParams.modelFittingResults.paramsMean(2)] ;
                    sigma= [ sqrt(covMatrix(1,1)) , sqrt(covMatrix(1,2)) ; sqrt(covMatrix(2,1)) , sqrt(covMatrix(2,2)) ] ;
                    %sigma= [ 0,0 ; 0,0 ] ;
                    sample = mvnrnd( mu , sigma , 1  ) ;
                    xx = sample(1,1);
                    yy = sample(1,2);

                    
                    %--------- Normalize xx , yy
                    if      estimatedParams.winningModel == 1
                        componentMB= 0  ;
                        componentSR= 0  ;
                        componentMF= 0  ;    
                    elseif  estimatedParams.winningModel == 2
                        componentMB= 0  ;
                        componentSR= 0  ;
                        componentMF= 1  ;
                    elseif  estimatedParams.winningModel == 3
                        componentMB= 0  ;
                        componentSR= 1  ;
                        componentMF= 0  ;
                    elseif  estimatedParams.winningModel == 4
                        componentMB= 0  ;
                        componentSR= 1  ;
                        componentMF= 1  ;
                    elseif  estimatedParams.winningModel == 5
                        componentMB= 1  ;
                        componentSR= 0  ;
                        componentMF= 0  ;
                    elseif  estimatedParams.winningModel == 6
                        componentMB= 1  ;
                        componentSR= 0  ;
                        componentMF= 1  ;
                    elseif  estimatedParams.winningModel == 7
                        componentMB= 1  ;
                        componentSR= 1  ;
                        componentMF= 0  ;
                    elseif  estimatedParams.winningModel == 8
                        componentMB= 1  ;
                        componentSR= 1  ;
                        componentMF= 1  ;
                    end        

                    if componentMB  eMB = exp(xx);  else    eMB = 0;    end    
                    if componentSR  eSR = exp(yy);  else    eSR = 0;    end    
                    if componentMF  eMF = exp(1) ;  else    eMF = 0;    end    

                    if  componentMB | componentSR | componentMF
                        normalizer = eMB + eSR + eMF        ;   
                    else
                        normalizer = 1                      ;           
                    end

                    xxNormalized                            = eMB / normalizer                                             ;
                    yyNormalized                            = eSR / normalizer                                             ;
                    if componentMF             
                        zzNormalized = 1 - xxNormalized - yyNormalized ;   
                    else
                        zzNormalized=0;    
                    end       ;

                    %--------- Pass through the simplex function
                    [xxSimplexed yySimplexed] = transform2simplex ( xxNormalized , yyNormalized , zzNormalized ) ;

                    %--------- Plot the sample
                    plot(xxSimplexed,yySimplexed,'-.or','MarkerFaceColor','r','MarkerSize',2 );    
                    hold on                        
                    
                end
%}                
                %--------------- plot true weights ------------------------
                plot(wXSimplex(i,j),wYSimplex(i,j),'-.ob','MarkerFaceColor','b','MarkerSize',9 );
                
            end
            
        end
    end

    xlabel('MF weight');
    axis([-0.1,1.1,-0.1,1.1])

end

function [x y] = transform2simplex ( w1 , w2 , w3 ) ;
    x = w1*0.5 + w2*0 + w3*1 ;
    y = w1*1   + w2*0 + w3*0 ; 
end
%% End of the Code
