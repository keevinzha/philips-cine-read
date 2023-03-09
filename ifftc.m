function res = ifftc(x, n)

fctr = size(x, n);
res = sqrt(fctr)*fftshift(ifft(ifftshift(x, n),[],n),n);


