% Homework Program 6
% Name:       Cohen , Thomas
% Section:    30
% Date:       10/31/2017

function check_dep(A, B, swap_flag)
%CHECK_DEP This program checks for linear dependence relations
% Step 1:
[Arow, Acol] = size(A);
[Brow, Bcol] = size(B);

if Arow == 0
    error('Matrix A cannot be empty');
elseif Brow == 0
    error('Matrix B cannot be empty');
elseif Arow ~= Brow
    error('Numbers of rows in A and B must be the same');
end
% Step 2:
[~, piv] = rref(A);
spanA = piv(end);
fprintf('The span of a''s is R^%i\n',spanA);
% Step 3:
if swap_flag == 0
    for col = 1:size(B,2)
        Augm = [A B(:,col)];
        [AugrrefA, piv] = rref(Augm);
        if piv(end) == size(A,2)+1
            fprintf('b%i is not a linear combination of a''s. \n', col);
        else
            fprintf('\n b%i = ', col);
            for ii = 1:(length(piv))
                if AugrrefA(ii,end) ~= 0
                    fprintf('%.4f a%i + ', AugrrefA(ii,end), ii);
                end
            end
            fprintf('\b\b');
        end
    end
end

if swap_flag == 1
    for col = 1:size(B,2)
        Augment = [A B(:,col)];
        [AugrrefA, piv] = rref(Augment);
        if piv(end) == size(A,2)+1
            fprintf('b%i is not a linear combination of a''s. \n',col);
            continue;
        end
            fprintf('b%i =', col);
            for ii = 1:(length(piv))
                if AugrrefA(ii,end) ~= 0
                    fprintf('%.4f a%i +', AugrrefA(ii,end), ii);
                end
            end
            fprintf('\b\b');
    end
[~, pivB] = rref(B);
spanB = pivB(end);
fprintf('\n\nThe span of b''s is R^%i\n',spanB);

    for col = 1:size(A,2)
        Augment = [B A(:,col)];
        [AugrrefB, pivB] = rref(Augment);
        if pivB(end) == size(B,2)+1
            fprintf('a%i is not a linear combination of b''s. \n',col);
        continue;
        end
            fprintf('\n a%i = ', col);
            for ii = 1:(length(pivB))
                if AugrrefB(ii,end) ~= 0
                    fprintf('%.4f b%i =', AugrrefB(ii,end), ii);
                end
            end
            fprintf('\b\b');
    end
end
    fprintf('\n');
end
%test cases:
%1: 
% The span of a's is R^3
% b1 =2.0000 a1 +3.0000 a2 +4.0000 a3
% 
% The span of b's is R^1
% a1 is not a linear combination of b's. 
% a2 is not a linear combination of b's. 
% a3 is not a linear combination of b's. 
%2:
% The span of a's is R^2
% b1 is not a linear combination of a's. 
% b2 =1.0000 a1 +2.0000 a2
% 
% The span of b's is R^2
% a1 is not a linear combination of b's. 
% a2 is not a linear combination of b's. 
%3:
% The span of a's is R^3
% b1 =2.0000 a1 +1.0000 a2 +3.0000 a3
% 
% The span of b's is R^1
% a1 is not a linear combination of b's. 
% a2 is not a linear combination of b's. 
% % a3 is not a linear combination of b's. 
% a4 is not a linear combination of b's. 
% a5 is not a linear combination of b's. 
%4:
% The span of a's is R^2
% b1 is not a linear combination of a's. 
% 
% The span of b's is R^1
% a1 is not a linear combination of b's. 
% a2 is not a linear combination of b's.
%5:
% The span of a's is R^3
% 
%  b1 = 0.3333 a1 + -0.3333 a2 + 0.3333 a3 
%6:
% The span of a's is R^3
% 
%  b1 = 1.0000 a1 
%  b2 = 1.0000 a2 
%  b3 = 1.0000 a3 
%  b4 = 0.5000 a1 + 1.0000 a3 
%7:
% The span of a's is R^3
% 
%  b1 = 1.0000 a1 
%  b2 = 1.0000 a2 
%  b3 = 1.0000 a3

