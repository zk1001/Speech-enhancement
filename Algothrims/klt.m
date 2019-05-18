function klt( noisy_file, outfile)
%
%  Implements the generalized subspace algorithm with embedded pre-whitening [1].
%  Makes no assumptions about the nature of the noise (white vs. colored).
%
%  Usage:  klt(noisyFile, outputFile)
%           
%         infile - noisy speech file in .wav format
%         outputFile - enhanced output file in .wav format
%  
%  The covariance matrix estimation is done using a sine-taper method [1].
%
%  Example call:  klt('sp04_babble_sn10.wav','out_klt.wav');
%
%  References:
%   [1] Hu, Y. and Loizou, P. (2003). A generalized subspace approach for 
%       enhancing speech corrupted by colored noise. IEEE Trans. on Speech
%       and Audio Processing, 11, 334-341.
%   
% Authors: Yi Hu and Philipos C. Loizou
%
% Copyright (c) 2006 by Philipos C. Loizou
% $Revision: 0.0 $  $Date: 10/09/2006 $
%-------------------------------------------------------------------------

if nargin<2
   fprintf('Usage: klt(noisyfile.wav,outFile.wav) \n\n');
   return;
end

L=16;   %number of tapers used to estimate the covariance matrix in
        %  multi-window method  
vad_thre= 1.2; % VAD threshold value
mu_vad= 0.98; % mu to use in smoothing of the Rn matrix

% --- initialize mu values -----------------
%
mu_max=5;
mu_toplus= 1; % mu value with SNRlog>= 20dB 
mu_tominus= mu_max;   % mu value with SNRlog< -5dB
mu_slope= (mu_tominus- mu_toplus )/ 25;
mu0= mu_toplus+ 20* mu_slope;
%===========================================

[noisy_speech, Srate]= audioread( noisy_file);
subframe_dur= 4;  %subframe length is 4 ms
len= floor( Srate* subframe_dur/ 1000);    
P= len; 
frame_dur= 32;  % frame duration in msecs
N= frame_dur* Srate/ 1000; 
Nover2= N/ 2; % window overlap in 50% of frame size
K= N;
frame_window= hamming( N);
subframe_window= hamming( P); 


% ==== Esimate noise covariance matrix ------------
%
L120=floor( 120* Srate/ 1000);  % assume initial 120ms is noise only
noise= noisy_speech( 1: L120);

if L== 1
    noise_autoc= xcorr( noise, P- 1, 'biased');
    % from -(len- 1) to (len- 1)
    % obtain the autocorrelation functions
    Rn= toeplitz( noise_autoc( P: end));
    % form a Toeplitz matrix to obtain the noise signal covariance matrix
else
    
    tapers= sine_taper( L, L120); % generate sine tapers
%     [tapers, v]= dpss( L120, 4); % generate slepian tapers
    Rn= Rest_mt( noise, P, tapers);
end
iRn= inv( Rn);  % inverse Rn

% ===================================================

n_start= 1;
In= eye(len);
Nframes= floor( length( noisy_speech)/ (N/ 2))- 1;     % number of frames
x_overlap= zeros( Nover2, 1);
tapers1= sine_taper( L, N);  % generate sine tapers
% [tapers1, v]= dpss( N, 4); % generate slepian tapers

%===============================  Start Processing =====================
%
for n=1: Nframes  
    
     noisy= noisy_speech( n_start: n_start+ N- 1);  
    
    if L== 1
        noisy_autoc= xcorr( noisy, P- 1, 'biased');
        Ry= toeplitz( noisy_autoc( P: 2* P- 1));
    else
        Ry= Rest_mt( noisy, P, tapers1); % use sine tapers to estimate the cov matrix
    end
    
    % use simple VAD to update the noise cov matrix, Rn 
    vad_ratio= Ry(1,1)/ Rn(1,1); 
    if (vad_ratio<= vad_thre) % noise dominant
        Rn= mu_vad* Rn+ (1- mu_vad)* Ry;
        iRn= inv( Rn);
    end
    %================
    
    iRnRx= iRn* Ry- In;  % compute Rn^-1 Rx=Rn^-1- I
    [V, D]= eig( iRnRx); % EVD
    iV= inv( V);
    dRx= max( diag( D), 0);  % estimated eigenvalues of Rx
    SNR= sum( dRx)/ len;
    SNRlog( n)= 10* log10( SNR+ eps);
    
    if SNRlog( n)>= 20
        mu( n)= mu_toplus;  %actually this corresponds to wiener filtering
    elseif ( SNRlog( n)< 20) && ( SNRlog( n)>= -5)
        mu( n)= mu0- SNRlog( n)* mu_slope;
    else
        mu( n)= mu_tominus;
    end
    
    gain_vals= dRx./( dRx+ mu( n));   
    G= diag( gain_vals);
    H= iV'* G* V';
    
    % first step of synthesis for subframe
    sub_start= 1; 
    sub_overlap= zeros( P/2, 1);
    for m= 1: (2*N/P- 1)
        sub_noisy= noisy( sub_start: sub_start+ P- 1);
        enhanced_sub_tmp= (H* sub_noisy).* subframe_window;
        enhanced_sub( sub_start: sub_start+ P/2- 1)= ...
            enhanced_sub_tmp( 1: P/2)+ sub_overlap; 
        sub_overlap= enhanced_sub_tmp( P/2+1: P);
        sub_start= sub_start+ P/2;
    end
    enhanced_sub( sub_start: sub_start+ P/2- 1)= sub_overlap; 
    % ===============
        
    xi= enhanced_sub'.* frame_window;    
    xfinal( n_start: n_start+ Nover2- 1)= x_overlap+ xi( 1: Nover2);    
    x_overlap= xi( Nover2+ 1: N);               
        
    n_start= n_start+ Nover2;     
    
end

xfinal( n_start: n_start+ Nover2- 1)= x_overlap; 

audiowrite(outfile, xfinal, Srate);

%=========================== E N D===============================================

function tapers= sine_taper( L, N)

% this function is used to generate the sine tapers proposed by Riedel et
% al, IEEE Transactions on Signal Processing, pp. 188- 195, Jan. 1995

% there are two parameters, 'L' is the number of the sine tapers generated,
% and 'N' is the length of each sine taper; the returned value 'tapers' is
% a N-by-L matrix with each column being sine taper 

tapers= zeros( N, L);

for index= 1: L
    tapers( :, index)= sqrt( 2/ (N+ 1))* sin (pi* index* (1: N)'/ (N+ 1));
end



function R_mt= Rest_mt( x, p, W)
% multi-taper method for covariance matrix estimation, we have 'x' of
% length N, and estimate p-order covariance matrix. 
% this estimator is: 
%   1): quadratic in the data
%   2): modulation covariant
%   3): nonnegative definite Toeplitz

% 'x' must be a vector of length N,
% 'p' is the order of the covariance matrix,
% 'W' is the N-by-L taper matrix, each column of which is a taper.
%
%
% Reference:  L. T. McWhorter and L. L. Scharf, "Multiwindow estimator of correlation" 
%  IEEE Trans. on Signal processing, Vol. 46, No. 2, Feb. 1998 
%====================


x= x( :);   % make data a column vector
[N, L]= size( W);  
% tapers is a N-by-L matrix, and has the form of [w_1 w_2 ... w_L]

% first step is to compute R'= sum_{i=1}^{L}(w_i y)(w_i y)*, which is a
% multitaper method: weight x with each taper w_i, and compute outer
% product, and add them together. 
x_rep= x( :, ones( 1, L)); 
% make x repeat L times, i.e., [x x ...x] 
x_w= W.* x_rep; 
% now each column of x_w is the weighted x

R1= x_w* x_w'; % sum of outer product
for k= 1: p
    r( k)= sum( diag( R1, k- 1));
end

R_mt= toeplitz( r); 



