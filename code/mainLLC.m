function [ trainfeatureVector, testfeatureVector, trainLblVector, testLblVector, mat, order] = mainLLC( mainDir ,imgCount)

    dirContents = dir(mainDir); % all dir contents
    subFolders=[dirContents(:).isdir]; % just subfolder
    folderNames = {dirContents(subFolders).name};    %subfolder names
    folderNames(ismember(folderNames,{'.','..'})) = []; %remove . & ..
    
    trainImgCount=0;
    testImgCount=0;
    sceneCount=0;
    
    for i=1:length(folderNames)
        %each folder=new scene
        oneFolder=folderNames{i};
        if strcmp(oneFolder ,'dataLLC') == 1
            continue;
        end
        
        localTrainCount=0;
        localTestCount=0;
        sceneCount=sceneCount+1;
        sceneNameList{sceneCount}=oneFolder;
        
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Processing images for scene "',oneFolder,'"'));
        sceneDir = strcat(mainDir,'/',  oneFolder,'/');
        
        imgFiles = dir(strcat(sceneDir,'*.jpg')); 
        
        for k = 1:imgCount
            trainImgCount=trainImgCount+1;
            localTrainCount=localTrainCount+1;
            imgTrain{trainImgCount}=strcat(oneFolder,'/',imgFiles(k).name);
            trainLblVector(trainImgCount,1)=sceneCount;
        end
        
        for j=imgCount+1:length(imgFiles)
            testImgCount=testImgCount+1;
            localTestCount=localTestCount+1;
            imgTest{testImgCount}=strcat(oneFolder,'/',imgFiles(j).name);
            testLblVector(testImgCount,1)=sceneCount;
        end
        
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] ... Train Images :',num2str(localTrainCount)));
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] ... Test Images :',num2str(localTestCount)));
    end    
    
    imgTrain=cellstr(imgTrain);
    imgTest=cellstr(imgTest);
    sceneNameList=cellstr(sceneNameList);    
        
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Total scenes : ',num2str(length(folderNames))));
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Total train images : ',num2str(trainImgCount)));
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Total test images : ',num2str(testImgCount)));
    
    outDir=strcat(mainDir,'/dataLLC');
    mkdir(outDir);
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Data directory created at : ',outDir));
    addpath('../SpatialPyramid');
    trainfeatureVector = BuildPyramidLLC(imgTrain, mainDir, outDir);
    testfeatureVector = BuildPyramidLLC(imgTest, mainDir, outDir);
    rmpath('../SpatialPyramid');
    
    addpath('../liblinear/matlab');
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Training model'));
   
    trainLblVector=double(trainLblVector);
    trainfeatureVector=sparse(double(trainfeatureVector));
    testLblVector=double(testLblVector);
    testfeatureVector=sparse(double(testfeatureVector));
    
    model = train(trainLblVector, trainfeatureVector );    
    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Predict'));    
    [predictLblVector, accuracy, decision_values] = predict(testLblVector, testfeatureVector, model);
    rmpath('../liblinear/matlab');
    display(accuracy);
    
    meanAccuracy = calcMeanAccuracy(sceneCount, testLblVector, predictLblVector);
    display(strcat('Mean accuracy:', num2str(meanAccuracy),'%'));
    
    [ mat, order ] = confusionMat(testLblVector, predictLblVector)
end
