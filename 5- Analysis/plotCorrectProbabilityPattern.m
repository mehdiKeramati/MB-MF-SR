%% Plot Correct Probability Pattern
function plotCorrectProbabilityPattern (subjectsNum,subjectsFileNames,environmentalParameters,palingFactor) ;

    FigHandle = figure('Position', [10, 510, 300, 300]);
    set(0,'DefaultAxesFontName', 'Arial')
    set(0,'DefaultAxesFontSize', 22)
    set(0,'DefaultAxesFontWeight', 'bold')

    correctProbs = zeros (subjectsNum, 4 ) ;    
    casesCounter = zeros (subjectsNum, 4 ) ;    
    
    for subject = 1 : subjectsNum
        
        subjectFileName = subjectsFileNames (subject , :)  ;
        datas = load (subjectFileName) ;
        data = datas.data ;
    
        dataSize = size (data) ;
        trialsNum = dataSize (1,1);

        for trial = 20 : trialsNum

            if ( data ( trial , 2 ) == 1 )          % current trial started from the top level

                if     ( data ( trial-1 , 2 ) == 2 )    % and previous trial started from the second level

                    if      ( data ( trial-1 , 10 ) == 0 ) & (data ( trial-1 , 11 ) == environmentalParameters.bigReward )
                        correctAction = 1 ;
                    elseif  ( data ( trial-1 , 10 ) == 1 ) & (data ( trial-1 , 12 ) == environmentalParameters.bigReward )
                        correctAction = 1 ;
                    else
                        correctAction = 2 ;
                    end
                    
                    if      ( data ( trial-1 , 10 ) == data ( trial-2 , 10 ) ) & ( data ( trial-1 , 11 ) == data ( trial-2 , 11 ) ) % reward fixed  , transition fixed
                        correctProbs (subject,1) = correctProbs (subject,1) + (data(trial,3)==correctAction) ;
                        casesCounter (subject,1) = casesCounter (subject,1) + 1                              ;
                        
                    elseif  ( data ( trial-1 , 10 ) ~= data ( trial-2 , 10 ) ) & ( data ( trial-1 , 11 ) == data ( trial-2 , 11 ) ) % reward fixed  , transition changed
                        correctProbs (subject,2) = correctProbs (subject,2) + (data(trial,3)==correctAction) ;
                        casesCounter (subject,2) = casesCounter (subject,2) + 1                              ;                    
                    
                    elseif  ( data ( trial-1 , 10 ) == data ( trial-2 , 10 ) ) & ( data ( trial-1 , 11 ) ~= data ( trial-2 , 11 ) ) % reward changed, transition fixed
                        correctProbs (subject,3) = correctProbs (subject,3) + (data(trial,3)==correctAction) ;
                        casesCounter (subject,3) = casesCounter (subject,3) + 1                              ;                                        
                    
                    else                                                                                                            % reward changed, transition changed
                        correctProbs (subject,4) = correctProbs (subject,4) + (data(trial,3)==correctAction) ;
                        casesCounter (subject,4) = casesCounter (subject,4) + 1                              ;                                        
                    
                    end
                    
                end
            end
                    
        end
        
        for i = 1 : 4
            correctProbs (subject,i) = correctProbs (subject,i) / casesCounter (subject,i) ;
        end
    end
        
    
    means = [mean(correctProbs(:,1)); mean(correctProbs(:,2)); mean(correctProbs(:,3));mean(correctProbs(:,4))];
    STDs  = [ std(correctProbs(:,1));  std(correctProbs(:,2));  std(correctProbs(:,3)); std(correctProbs(:,4))];

    hold on
    bar(1,means(1),'FaceColor',[.4 .4 .4]+[0.1 0.1 0.1]*palingFactor,'EdgeColor',[0 0 0],'LineWidth',1.5);    
    bar(2,means(2),'FaceColor',[.0 .7 .0]+[0.0 0.1 0.0]*palingFactor,'EdgeColor',[0 0 0],'LineWidth',1.5);    
    bar(3,means(3),'FaceColor',[.7 .0 .0]+[0.1 0.0 0.0]*palingFactor,'EdgeColor',[0 0 0],'LineWidth',1.5);    
    bar(4,means(4),'FaceColor',[.0 .0 .7]+[0.0 0.0 0.1]*palingFactor,'EdgeColor',[0 0 0],'LineWidth',1.5);    

    hold on;
    h=errorbar(means,STDs,'r','color','black','linewidth',3);
    set(h,'linestyle','none');

    axis([.5,4.5,0,1])
    xlabel('previous trial');
    ylabel('correct probability') 
    xticklabel = {'Fix','T','R','TR'};    
    set(gca, 'XTick', 1:4, 'XTickLabel', xticklabel);

    
    sss = 0.27 ;
    ttt = 0.17 ;
    for o = 1 : subjectsNum
      hold on;
      plot([1-sss,1-ttt],[correctProbs(o,1),correctProbs(o,1)],'k-','LineWidth',2)    ;
      plot([2-sss,2-ttt],[correctProbs(o,2),correctProbs(o,2)],'k-','LineWidth',2)    ;
      plot([3-sss,3-ttt],[correctProbs(o,3),correctProbs(o,3)],'k-','LineWidth',2)    ;
      plot([4-sss,4-ttt],[correctProbs(o,4),correctProbs(o,4)],'k-','LineWidth',2)    ;
    end

    disp('---------------------------------------------------------------------')  ;  
    
    % MB effect : nonparametric Wilcoxon signed-rank test                 
    [p,h,stats] = signrank(correctProbs(:,1) , 1 - correctProbs(:,2) );
    disp('MB effect:  Fix + T > 1 ')  ;  
    disp(['            p-value = ',num2str(p,4),'      stat (signedrank) = ',num2str(stats.signedrank)]);
    [p,h,stats] = signrank(correctProbs(:,3) , 1 - correctProbs(:,4) );
    disp('MB effect:  R + TR > 1 ')  ;  
    disp(['            p-value = ',num2str(p,4),'      stat (signedrank) = ',num2str(stats.signedrank)]);    disp('---------------------------------------------------------------------')  ;  
    
    % SR effect : nonparametric Wilcoxon signed-rank test 
    [p,h,stats] = signrank(correctProbs(:,1) , correctProbs(:,4));
    disp('SR effect:  TR < Fix ')  ;  
    disp(['            p-value = ',num2str(p,4),'      stat (signedrank) = ',num2str(stats.signedrank)]);
    disp('---------------------------------------------------------------------')  ;  

    % MF effect : nonparametric Wilcoxon signed-rank test 
    [p,h,stats] = signrank(correctProbs(:,1) , correctProbs(:,3));
    disp('MF effect:  R < Fix ')  ;  
    disp(['            p-value = ',num2str(p,4),'      stat (signedrank) = ',num2str(stats.signedrank)]);
    disp('---------------------------------------------------------------------')  ;  
    
end