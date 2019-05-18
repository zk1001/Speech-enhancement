function  NOISE= stationary_noise_evaluate(Y,L,k);  % 定义子函数；
%Y  傅里叶变换后的结果
%L  帧长
%k  帧数

%-----------------------粗略噪声功率谱密度p的计算-------------------------
for b = 1:L % 外循环开始，b表示频率分量，这里我们穷举了所有的频率分量；
    p = [0.15*abs(Y(b)).^2,zeros(1,k)]; 
    a = 0.85; 
    for  d = 1:k-1
         p(d+1) = a*p(d)+(1-a)*abs(Y(b+d*L)).^2;
    end
%-----------------------噪声方差actmin的估计----------------------------
    for  e = 1:k-95
         actmin(e) = min(p(e:95+e));
    end
    for  l = k-94:k
         m(l-(k-95)) = min(p(l:k)); 
    end
         actmin = [actmin(1:k-95),m(1:95)];  
         c(1+(b-1)*k:b*k) = actmin(1:k); 
end % 外循环结束，从外循环开始到结束中间是对某个具体的频率分量进行计算； 
   for t = 1:k
         for  j = 1:L
              d(j) = c(t+(j-1)*k);
         end 
       n(1+(t-1)*L:t*L) = d(1:L);  
   end
NOISE =n;
   

   

   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   