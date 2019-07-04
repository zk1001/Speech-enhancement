load awgn_test_0.mat
t1 = awgn_test_0(:,1);
t2 = awgn_test_0(:,2);
t3 = awgn_test_0(:,3);
c = awgn_test_0(:,4);

[testInput,minI,maxI] = premnmx( [t1 , t2 , t3]')  ;

load net.mat
Y = sim( net , testInput );

output_len = length(Y);

!echo AWGN SNR: 0dB
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
Accuracy_0 = 100 * hitNum / s2;
sprintf('Accuracy: %3.3f%%', Accuracy_0)

clear awgn_test_m7 t1 t2 t3 c minI maxI Y idnex i 

