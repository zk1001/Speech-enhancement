load babble_test_3.mat
t1 = babble_test_3(:,1);
t2 = babble_test_3(:,2);
t3 = babble_test_3(:,3);
c = babble_test_3(:,4);

[testInput,minI,maxI] = premnmx( [t1 , t2 , t3]')  ;

load net.mat
Y = sim( net , testInput );

output_len = length(Y);

!echo babble SNR: 3dB
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
Accuracy_b_3 = 100 * hitNum / s2;
sprintf('Accuracy: %3.3f%%', Accuracy_b_3)

clear babble_test_m7 t1 t2 t3 c minI maxI Y idnex i 

