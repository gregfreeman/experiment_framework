function filterExperimentDataTest
load testRunnerTest3B

[results2, paramset2]=filterExperimentData(results,paramset,'StompTheshold', 'RCL');
[results3, paramset3]=filterExperimentData(results2,paramset2,'alg', 'Basic');
[results4, paramset4]=filterExperimentData(results3,paramset3,'reconstruct', 'stomp');
compareExperiment(results2,paramset2,'delta',{'ssim', 'mse'})
compareExperiment(results3,paramset3(1:3),'delta',{'ssim', 'mse'})
compareExperiment(results3,paramset4(1:3),'delta',{'ssim', 'mse'})
