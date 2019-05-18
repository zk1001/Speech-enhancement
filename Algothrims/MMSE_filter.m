function MMSE_filter(file,output_file)
%-------------------------------������������ļ�---------------------------
[wavin,Fs]=audioread(file);
wavin=wavin';
%-------------------------------��������-----------------------------------
frame_len=256; %֡��
step_len=0.5*frame_len; %��֡ʱ�Ĳ������൱���ص�50%
wav_length=length(wavin);
R = step_len;
L = frame_len; 
f = (wav_length-mod(wav_length,frame_len))/frame_len;
k = 2*f-1; % ֡��
h = sqrt(1/101.3434)*hamming(256)'; % ����������ϵ����ԭ����ʹ�临������Ҫ��
wavin = wavin(1:f*L);  % ���������봿���������ȶ���
win = zeros(1,f*L); % �趨��ʼֵ��
enspeech = zeros(1,f*L);                         
%-------------------------------��֡---------------------------------------
for r = 1:k 
    y = wavin(1+(r-1)*R:L+(r-1)*R); % �Դ�������֡���ص�һ��ȡֵ��
    y = y.*h; % ��ȡ�õ�ÿһ֡���Ӵ�������
    w = fft(y); % ��ÿһ֡��������Ҷ�任��
    Y(1+(r-1)*L:r*L) = w(1:L); % �Ѹ���Ҷ�任ֵ����Y�У�
end
%-------------------------------��������-----------------------------------
   NOISE= stationary_noise_evaluate(Y,L,k); %������Сֵ�����㷨
%     NOISE= non_stationary_noise_evaluate(Y,L,k); % ����ͳ����Ϣ�ķ�ƽ����������Ӧ�㷨
%-------------------------------STSA_MMSE----------------------------------
%%%%%%%%%%%%%����ÿһ֡�ĵ�һ�㣬ÿһꐵĵڶ��㣬����������Щ�����η�����%%%%%%
for b = 1:L; 
   a = 0.98; % ϵ��;
   q = 0.2;  % ��k��Ƶ�ʷ������������ڸ���;
   A = [0.1*abs(Y(b)),zeros(1,k-1)];  % ��������;
   s1 = [a*abs(Y(b)).^2/NOISE(b),zeros(1,k-1)];  % ���������;
   for t = 1:k-1                                 % ����ÿһ֡�ĵ�һ��
       x1(t+1) = abs(Y(b+t*L)).^2;  % ������������;
       r(t+1) = x1(t+1)/NOISE(b+t*L); % ���������; 
       if r(t+1) >= 700
          r(t+1) = 700;
       elseif  r(t+1) < 1
           r(t+1) = 1.5 ;
       end   
       s1(t+1) = a*(A(t).^2/NOISE(b+(t-1)*L))+(1-a)*max(r(t+1)-1,0); % ���������;
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
%%%%%%%%%%%%%������;��ÿһ֡�ĵ����λ�ԭ��ԭ���Ĵ��˳��%%%%%%%%%%
for     t1 = 1:k                    
    for  j = 1:L
         d(j) = A1(t1+(j-1)*k);
    end 
   A2(1+(t1-1)*L:t1*L) = d(1:L);  
 end
 for  t2 = 1:k
      S = A2(1+(t2-1)*L:t2*L);
      ang = Y(1+(t2-1)*L:t2*L)./abs(Y(1+(t2-1)*L:t2*L)); % ������������λ;
      S = S.*ang; % ��Ϊ�˶�����λ�ĸо������ԣ����Իָ�ʱ�õ��Ǵ�����������λ��Ϣ;
      s = ifft(S);   
      s = real(s); % ȡʵ��;
      enspeech(1+(t2-1)*L/2:L+(t2-1)*L/2) = enspeech(1+(t2-1)*L/2:L+(t2-1)*L/2)+s; % ��ʵ�������ӣ��ѷ�֡������лָ���ԭ�����еĳ���;
      win(1+(t2-1)*L/2:L+(t2-1)*L/2) = win(1+(t2-1)*L/2:L+(t2-1)*L/2)+h; % ���ĵ������;
 end    
enspeech = enspeech./win; % ȥ���Ӵ����������õ���ǿ������;
audiowrite(output_file,enspeech,Fs); % д����ǿ������