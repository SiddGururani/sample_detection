function [ACMat, Instants] = FastCorrelate(Matrix1, Matrix2, ShiftedBy)

if nargin() < 3
	ShiftedBy = 0;
end

nr1 = size(Matrix1, 1);
nc1 = size(Matrix1, 2);

nr2 = size(Matrix2, 1);
nc2 = size(Matrix2, 2);

if nr1 ~= nr2 && nr1 ~= 1 && nr2 ~= 1
	ME = MException('VerifyInput:InvalidInput', ...
             'The Number of rows must be equal or atleast one must be single row');
	throw(ME);
end

expof2 = ceil(log2(nc1 + nc2));

Matrix1 = [Matrix1 zeros(nr1, 2^expof2 - nc1)];
Matrix2 = [Matrix2 zeros(nr2, 2^expof2 - nc2)];

MatFFT1 = fft(Matrix1');
MatFFT2 = fft(Matrix2');

if nr1 == 1
	MatFFTfinal = (MatFFT1*ones(1,nc1)).*conj(MatFFT2);
elseif nr2 == 1
	MatFFTfinal = (MatFFT1).*(conj(MatFFT2).*ones(1,nc2));
else
	MatFFTfinal = MatFFT1.*conj(MatFFT2);
end

MatFFTifft = ifft(MatFFTfinal);

ACMat = [MatFFTifft(end-nc2:end,:); MatFFTifft(1:nc1+1, :)]';
Instants = -nc2-ShiftedBy:nc1+1-ShiftedBy;

end
