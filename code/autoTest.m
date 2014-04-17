function [  ] = autoTest( mainDir ,imgCount )
%     for dictionarySize = [200 1024 2048]
%         for pyramidLevels = [2 3 4]
%             for k = [5 9 13]
    for dictionarySize = [200]
        for pyramidLevels = [3]
            for k = [5]
                for numTextonImages =[50]
                    for patchSize =[16]
                        for gridSpacing =[8]
                            for isKer = [0 1]
                            
        timeStamp=datestr(now,'HH-MM-SS');

        testName=strcat('N_D',num2str(dictionarySize), ... 
            '_P',num2str(pyramidLevels), ...
            '_k',num2str(k), ...
            '_N',num2str(numTextonImages), ...
            '_p',num2str(patchSize), ...
            '_g',num2str(gridSpacing), ...
            '_Ker',num2str(isKer), ...
            '_T',timeStamp);
                
%                     MainSuper( mainDir ,imgCount, testName, useLLC, useKer, ...
%                            delOld, dictionarySize, pyramidLevels, ...
%                            numTextonImages, patchSize, gridSpacing, k) 

%                     MainSuper('/u/s/a/saikat/public/html/Sp13/cs766/P3-LLC/scene_categories',
%                                 100,'srgtest1',0,1,
%                                 1,1024,3,
%                                 50,16,8,5);

        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] test case "',testName,'"'));
        MainSuper( mainDir ,imgCount, testName, 0, isKer, ...
                   1, dictionarySize, pyramidLevels, ...
                   numTextonImages, patchSize, gridSpacing, k);    
                       
                            end
                        end
                    end
                end
            end
        end
    end
end

