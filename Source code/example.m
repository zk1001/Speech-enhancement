clear
clc

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

net = newff( minmax(input) , [10 10 2] , { 'logsig' 'logsig' 'logsig'} , 'traingdx' ) ; 

net.trainparam.show = 20 ;
net.trainparam.epochs = 500 ;
net.trainparam.goal = 0.01 ;
net.trainParam.lr = 0.01 ;

net = train( net, input , output' ) ;

% %¶ÁÈ¡²âÊÔÊý¾Ý
load test_sets.mat
t1 = test_sets(:,1);
t2 = test_sets(:,2);
t3 = test_sets(:,3);
c = test_sets(:,4);

% load wgn_test.mat
% t1 = wgn_test(:,1);
% t2 = wgn_test(:,2);
% t3 = wgn_test(:,3);
% c = wgn_test(:,4);

% testInput = tramnmx ( [t1,t2,t3]' , minI, maxI ) ;
[testInput,minI,maxI] = premnmx( [t1 , t2 , t3]')  ;

Y = sim( net , testInput ) 

output_len = length(Y);
for index = 1:1:output_len
    if Y(1,index) > Y(2,index)
        fprintf('Male\n')
    else
        fprintf('Female\n')
    end
end

[s1 , s2] = size( Y ) ;
hitNum = 0 ;
for i = 1 : s2
    [m , Index] = max( Y( : ,  i ) ) ;
    if( Index  == c(i)   ) 
        hitNum = hitNum + 1 ; 
    end
end
sprintf('Accuracy: %3.3f%%',100 * hitNum / s2 )
