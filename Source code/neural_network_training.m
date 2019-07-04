clear
clc

addpath(genpath('\Source code\nnet1'))

load train_sets.mat
f1 = train_sets(:,1);
f2 = train_sets(:,2);
f3 = train_sets(:,3);
class = train_sets(:,4);

[input,minI,maxI] = premnmx( [f1 , f2 , f3 ]')  ;
s = length(class) ;
output = zeros( s , 2  ) ;
for i = 1 : s 
   output( i , class( i )  ) = 1 ;
end
% build a neural network
net = newff( minmax(input) , [10 10 2] , { 'logsig' 'logsig' 'logsig'} , 'traingdx' ) ; 

% train the neural network
net.trainparam.show = 20 ;
net.trainparam.epochs = 500 ;
net.trainparam.goal = 0.01 ;
net.trainParam.lr = 0.01 ;

net = train( net, input , output' );