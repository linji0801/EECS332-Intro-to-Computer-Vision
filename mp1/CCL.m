function [label_image , num] = CCL(img)
%connected component labeling via 4-point connectivity using E_table
    [r,c]= size(img);
    %build a zero vector which size is the same as the img's
    L = zeros(r,c);
    nextlabel = 1;
    %threshold = 40;
    E_table = 1 : 1 : 1000;
    %Size_filter = zeros(1000);
    
    %the first scan
    for i = 1 : r    
        for j = 1 : c
            if img(i, j) ~= 0
                %judge the beginning point and the situation where Lu = Ll
                %==0
                if (i == 1 && j ==1) || (L(i-1 , j) == 0 && L(i, j-1) == 0)
                    L(i,j) = nextlabel;
                    nextlabel = nextlabel + 1;
                %judge the first row and the situation where Ll ~= 0, Lu
                %~=0
                elseif i==1 || (L(i,j-1) ~= 0 && L(i-1,j) == 0)
                    L(i,j) = L(i,j-1);
                %judge the first column and the situation where Lu ~= 0,
                %Ll = 0
                elseif j==1 || (L(i-1,j) ~= 0 && L(i,j-1) == 0)
                    L(i,j) = L(i-1,j);
                %judge the situation where Lu = Ll and both are not zero
                elseif L(i-1, j) == L(i, j-1)
                    L(i,j) = L(i-1, j);
                %judge the situation where Lu ~= Ll
                else
                    Lu = L(i-1,j); Ll = L(i,j-1);
                    maxlabel = max(E_table(Lu), E_table(Ll));
                    minlabel = min(E_table(Lu), E_table(Ll));
                    L(i,j) = minlabel;
                    %build up the E_table and substitude the bigger label
                    for k = 1 : nextlabel 
                        if E_table(k) == maxlabel
                            E_table(k) = minlabel;
                        end
                    end
                end
            end
        end
    end
    
    %the second scan
    for i= 1:r
        for j = 1:c
            %update L(i,j) according to E_table
            if L(i,j) ~= 0 && E_table(L(i,j)) ~= L(i,j)
                L(i,j) = E_table(L(i,j));
                %count the number of the same labels
                %Size_filter(L(i,j)) = Size_filter(L(i,j)) + 1;
            end
        end
    end
    
    %size filter
   % for i= 1:r
       % for j = 1:c
           % if L(i,j) ~=0 && Size_filter(L(i,j)) <threshold
             %   L(i,j) = 0;
           % end
        %end
   % end
    
    %count the total number of different labels
    totalnum = 0;
    for i = 1 : nextlabel-1
        if E_table (i) == i
            totalnum = totalnum + 1;
        end
    end
            
    %label_image = L;
    label_image = imagesc(L);
    num = totalnum;
    
end



    
    
    
    
    
    