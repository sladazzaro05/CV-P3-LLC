function [  ] = MainSuper( mainDir ,imgCount, testName, useLLC, useKer, ...
                           isSaved, dictionarySize, pyramidLevels, ...
                           numTextonImages, patchSize, gridSpacing, k)
                       

    if(useLLC==1)
        type='LLC'; 
    else
        type='';
    end

    if(isSaved==1)        
        load(strcat('../vars/',type,'trainLblVector.mat'));
        load(strcat('../vars/',type,'testLblVector.mat'));
        load(strcat('../vars/',type,'testfeatureVector.mat'));
        load(strcat('../vars/',type,'trainfeatureVector.mat'));
        load(strcat('../vars/',type,'sceneNameList.mat'));
    else
        dirContents = dir(mainDir); % all dir contents
        subFolders=[dirContents(:).isdir]; % just subfolder
        folderNames = {dirContents(subFolders).nagridSpacingme};    %subfolder names
        folderNames(ismember(folderNames,{'.','..'})) = []; %remove . & ..

        trainImgCount=0;
        testImgCount=0;
        scenceCount=0;

        for i=1:length(folderNames)
            %each folder=new scene
            oneFolder=folderNames{i};mainDir
            if strcmp(oneFolder ,'data') == 1
                continue;
            end

            if strcmp(oneFolder ,'dataLLC') == 1
                continue;
            end

            localTrainCount=0;
            localTestCount=0;
            scenceCount=scenceCount+1;
            sceneNameList{scenceCount}=oneFolder;

            display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Processing images for scence "',oneFolder,'"'));
            sceneDir = strcat(mainDir,'/',  oneFolder,'/');

            imgFiles = dir(strcat(sceneDir,'*.jpmainDirg')); 

            for k = 1:imgCount
                trainImgCount=trainImgCount+1;
                localTrainCount=localTrainCount+1;
                imgTrain{trainImgCount}=strcat(oneFolder,'/',imgFiles(k).name);
                trainLblVector(trainImgCount,1)=scenceCount;
            end

            for j=imgCount+1:length(imgFiles)
                testImgCount=testImgCount+1;
                localTestCount=localTestCount+1;
                imgTest{testImgCount}=strcat(oneFolder,'/',imgFiles(j).name);
                testLblVector(testImgCount,1)=scenceCount;
            end

            display(strcat(datestr(now,'HH:MM:SS'),' [INFO] ... Train Images :',num2str(localTrainCount)));
            display(strcat(datestr(now,'HH:MM:SS'),' [INFO] ... Test Images :',num2str(localTestCount)));
        end    

        imgTrain=cellstr(imgTrain);
        imgTest=cellstr(imgTest);
        sceneNameList=cellstr(sceneNameList);    

        %trainfeatureVector=zeros(trainImgCount,4200); %morework
        %testfeatureVector=zeros(testImgCount,4200); %morework  

        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Total scenes : ',num2str(length(folderNames))));
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Total train images : ',num2str(trainImgCount)));
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Total test images : ',num2str(testImgCount)));

        addpath('../SpatialPyramid');
        if(useLLC==1)  
            outDir=strcat(mainDir,'/dataLLC');
            mkdir(outDir);
            display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Data directory created at : ',outDir));          
            trainfeatureVector = BuildPyramidLLC(imgTrain, mainDir, outDir);
            testfeatureVector = BuildPyramidLLC(imgTest, mainDir, outDir);
        else
            outDir=strcat(mainDir,'/data');
            mkdir(outDir);
            display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Data directory created at : ',outDir));  
            trainfeatureVector = BuildPyramid(imgTrain, mainDir, outDir);
            testfeatureVector = BuildPyramid(imgTest, mainDir, outDir);
        end        
               
        rmpath('../SpatialPyramid');
        
        trainLblVector=double(trainLblVector);
        trainfeatureVector=sparse(double(trainfeatureVector));
        testLblVector=double(testLblVector);
        testfeatureVector=sparse(double(testfeatureVector));
                
        save(strcat('../vars/',type,'trainLblVector.mat'),'trainLblVector');
        save(strcat('../vars/',type,'testLblVector.mat'),'testLblVector');
        save(strcat('../vars/',type,'testfeatureVector.mat'),'testfeatureVector');
        save(strcat('../vars/',type,'trainfeatureVector.mat'),'trainfeatureVector');
        save(strcat('../vars/',type,'sceneNameList.mat'),'sceneNameList');
    end
    
    addpath('../SpatialPyramid');
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Creating training kernel')); 
    trainKernel = hist_isect(trainfeatureVector, trainfeatureVector);
    trainKernel=sparse(trainKernel);
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Creating testing kernel'));  
    testKernel = hist_isect(testfeatureVector,trainfeatureVector);
    testKernel=sparse(testKernel);
    %save(strcat('vars/',testName,'_trainKernel.mat'),'trainKernel');
    %save(strcat('vars/',testName,'_testKernel.mat'),'testKernel');
    rmpath('../SpatialPyramid');
        
    addpath('../liblinear/matlab');
    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Training model on LIBLINEAR')); 
    model = train(trainLblVector, trainKernel);  
    %model = train(trainLblVector, trainfeatureVector); 
    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Predict on LIBLINEAR'));    
    [predictLblVector1, accuracy, decision_values] = predict(testLblVector, testKernel, model);
    %[predictLblVector1, accuracy, decision_values] = predict(testLblVector, testfeatureVector, model);
    rmpath('../liblinear/matlab');
    
    accuracy
    [ mat1, order1 ] = confusionMat(testLblVector, predictLblVector1);  
    [ a1 ] = calcMeanAccuracy(15, testLblVector, predictLblVector1)
    
    save(strcat('../vars/',testName,'_predictLblVector1.mat'),'predictLblVector1');
    save(strcat('../vars/',testName,'_mat1.mat'),'mat1');
    save(strcat('../vars/',testName,'_order1.mat'),'order1');
    
    save(strcat('../vars/',testName,'_a1.mat'),'a1');
 

    predictLblVector2=1;
    mat2=0;
    order2=0;
    %deleteData(mainDir);
                       
                       
                       
end

