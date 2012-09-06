function meanExperimentDataTest

load testRunnerTest3B

[resultsA, paramsetA]=meanExperimentData(results,paramset,'image', {'mse','mse2','ssim','fvssim'});
[resultsB, paramsetB]=filterExperimentData(resultsA,paramsetA,'StompTheshold', 'RCL');
compareExperiment(resultsA,paramsetA,'delta',{'ssim', 'mse'})
compareExperiment(resultsB,paramsetB,'delta',{'ssim', 'mse'})
figure(1)
compareExperiment(resultsB,paramsetB,'delta',{'ssim', 'mse','mse2'})
[resultsC, paramsetC]=filterExperimentData(resultsA,paramsetA,'StompTheshold', 'FAR');
figure(2)
compareExperiment(resultsC,paramsetC,'delta',{'ssim', 'mse'})
[resultsD, paramsetD]=meanExperimentData(resultsA,paramsetA,'alg', {'mse','mse2','ssim','fvssim'});
[resultsE, paramsetE]=filterExperimentData(resultsD,paramsetD,'reconstruct', 'stomp');
figure(3)
compareExperiment(resultsE,paramsetE,'delta',{'ssim', 'mse'})
