function MMSE_filter(file,output_file)
%-------------------------------读入带噪语音文件---------------------------
[wavin,Fs]=audioread(file);
wavin=wavin';
%-------------------------------参数定义-----------------------------------
frame_len=256; %帧长
step_len=0.5*frame_len; %分帧时的步长，相当于重叠50%
wav_length=length(wavin);
R = step_len;
L = frame_len; 
f = (wav_length-mod(wav_length,frame_len))/frame_len;
k = 2*f-1; % 帧数
h = sqrt(1/101.3434)*hamming(256)'; % 汉宁窗乘以系数的原因是使其复合条件要求；
wavin = wavin(1:f*L);  % 带噪语音与纯净语音长度对齐
win = zeros(1,f*L); % 设定初始值；
enspeech = zeros(1,f*L);                         
%-------------------------------分帧---------------------------------------
for r = 1:k 
    y = wavin(1+(r-1)*R:L+(r-1)*R); % 对带噪语音帧间重叠一半取值；
    y = y.*h; % 对取得的每一帧都加窗处理；
    w = fft(y); % 对每一帧都作傅里叶变换；
    Y(1+(r-1)*L:r*L) = w(1:L); % 把傅里叶变换值放在Y中；
end
%-------------------------------估计噪声-----------------------------------
   NOISE= stationary_noise_evaluate(Y,L,k); %噪声最小值跟踪算法
%     NOISE= non_stationary_noise_evaluate(Y,L,k); % 基于统计信息的非平稳噪声自适应算法
%-------------------------------STSA_MMSE----------------------------------
%%%%%%%%%%%%%先算每一帧的第一点，每一陳的第二点，。。。把这些点依次放起来%%%%%%
for b = 1:L; 
   a = 0.98; % 系数;
   q = 0.2;  % 第k个频率分量的语音存在概率;
   A = [0.1*abs(Y(b)),zeros(1,k-1)];  % 语音幅度;
   s1 = [a*abs(Y(b)).^2/NOISE(b),zeros(1,k-1)];  % 先验信噪比;
   for t = 1:k-1                                 % 先算每一帧的第一点
       x1(t+1) = abs(Y(b+t*L)).^2;  % 带噪语音幅度;
       r(t+1) = x1(t+1)/NOISE(b+t*L); % 后验信噪比; 
       if r(t+1) >= 700
          r(t+1) = 700;
       elseif  r(t+1) < 1
           r(t+1) = 1.5 ;
       end   
       s1(t+1) = a*(A(t).^2/NOISE(b+(t-1)*L))+(1-a)*max(r(t+1)-1,0); % 先验信噪比;
       v(t+1) = (s1(t+1)/(1+s1(t+1)))*r(t+1);
       if      v(t+1) < 0.1 
               expint(t+1) = -2.31*log10(v(t+1))-0.6;
       elseif  v(t+1) >= 0.1&v(t+1) <= 1
               expint(t+1) = -1.544*log10(v(t+1))+0.166; 
       elseif  v(t+1) > 1
               expint(t+1) = 10.^(-0.52*(v(t+1))-0.26);
       end
       Gmmse(t+1) = (s1(t+1)/(1+s1(t+1)))*exp(0.5*expint(t+1));
       w(t+1) = ((1-q)/q)*(exp(v(t+1))/(1+s1(t+1)));
       A(t+1) = (w(t+1)/(1+w(t+1)))*Gmmse(t+1)*abs(Y(b+t*L));
   end    
   A1(1+(b-1)*k:b*k) = A(1:k);  
end
%%%%%%%%%%%%%作用是;把每一帧的点依次还原成原来的存放顺序%%%%%%%%%%
for     t1 = 1:k                    
    for  j = 1:L
         d(j) = A1(t1+(j-1)*k);
    end 
   A2(1+(t1-1)*L:t1*L) = d(1:L);  
 end
 for  t2 = 1:k
      S = A2(1+(t2-1)*L:t2*L);
      ang = Y(1+(t2-1)*L:t2*L)./abs(Y(1+(t2-1)*L:t2*L)); % 带噪语音的相位;
      S = S.*ang; % 因为人耳对相位的感觉不明显，所以恢复时用的是带噪语音的相位信息;
      s = ifft(S);   
      s = real(s); % 取实部;
      enspeech(1+(t2-1)*L/2:L+(t2-1)*L/2) = enspeech(1+(t2-1)*L/2:L+(t2-1)*L/2)+s; % 在实域叠接相加，把分帧后的序列恢复成原来序列的长度;
      win(1+(t2-1)*L/2:L+(t2-1)*L/2) = win(1+(t2-1)*L/2:L+(t2-1)*L/2)+h; % 窗的叠接相加;
 end    
enspeech = enspeech./win; % 去除加窗引起的增益得到增强的语音;
audiowrite(output_file,enspeech,Fs); % 写出增强语音；
