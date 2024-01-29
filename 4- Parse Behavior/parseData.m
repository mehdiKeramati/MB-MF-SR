function parseData ()

    data           = dataExtractionXLSX('rawData/spaceshipdata_5people.xlsx');
    subjectNumbers = 0  ;
    subjectIDs     = NaN ;
    
    %% Save all data to separate txt files for each subject
    for trial = 1 : length(data.ID)
        filename = [ '../D3_HumanBehavior/',num2str(data.ID(trial)),'.txt' ]  ;
        fileID   = fopen(filename,'a') ;        
        fprintf(fileID,'%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%f,%f,%f,%f,%d,%d\n',data.trial(trial),data.level(trial),data.action(trial),data.RT1(trial),data.RT2(trial),data.RT3(trial),data.missed1(trial),data.missed2(trial),data.missed3(trial),data.transition(trial),data.reward4(trial),data.reward5(trial),data.reward4P(trial),data.reward5P(trial),data.L2_state(trial),data.L3_state(trial));
        fclose(fileID);
        
        if ~ismember (data.ID(trial) , subjectIDs )
            subjectNumbers = subjectNumbers + 1 ;
            subjectIDs(subjectNumbers) = data.ID(trial) ;
        end
        
    end
    
    %% Save all IDs in one file
    save ('../D3_HumanBehavior/subjectsIDs.mat','subjectIDs') ;
   
    %% Delete the txt file, and save one .mat files for each subject
    for subject = 1 : subjectNumbers
        fileID   = fopen([ '../D3_HumanBehavior/',num2str(subjectIDs(subject)),'.txt' ] ,'r') ;                
        dataTmp  = fscanf(fileID,'%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%f,%f,%f,%f,%d,%d\n',[16 Inf]);
        fclose(fileID);
        
        data = transpose ( dataTmp ) ;
        save  ([ '../D3_HumanBehavior/',num2str(subjectIDs(subject)),'.mat'] , 'data');
        delete  ([ '../D3_HumanBehavior/',num2str(subjectIDs(subject)),'.txt' ]) ; 
 
    end
    
    
    
end

function data = dataExtractionXLSX(fileName);

    rawData             = xlsread(fileName);
    
    data.ID             = rawData(:, 1);
    data.trial          = rawData(:, 2);
    data.level          = rawData(:, 3);
    data.action         = rawData(:, 4);
    data.RT1            = rawData(:, 5);
    data.RT2            = rawData(:, 6);
    data.RT3            = rawData(:, 7);
    data.missed1        = rawData(:, 8);
    data.missed2        = rawData(:, 9);
    data.missed3        = rawData(:,10);
    data.transition     = rawData(:,11);
    data.reward4        = rawData(:,12);
    data.reward5        = rawData(:,13);
    data.reward4P       = rawData(:,14);
    data.reward5P       = rawData(:,15);
    data.L2_state       = rawData(:,16);
    data.L3_state       = rawData(:,17);
    data.S2_subjType    = rawData(:,18);
    data.S4_subjType    = rawData(:,19);
    data.A1_subjType    = rawData(:,20);
    data.idtask         = rawData(:,21);
    data.age            = rawData(:,22);
%    data.gender         = rawData(:,23);
%    data.education      = rawData(:,24);
    
end