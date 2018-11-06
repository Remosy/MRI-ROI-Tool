figure; hold on;
[B,L,N,A] = bwboundaries(roi_17513174125);
colors=['b' 'g' 'r' 'c' 'm' 'y'];
for k=1:length(B),
boundary = B{k};
cidx = mod(k,length(colors))+1;
plot(boundary(:,2), boundary(:,1),...
colors(cidx),'LineWidth',2);
%randomize text position for better visibility
rndRow = ceil(length(boundary)/(mod(rand*k,7)+1));
col = boundary(rndRow,2); row = boundary(rndRow,1);
h = text(col+1, row-1, num2str(L(row,col)));
set(h,'Color',colors(cidx),'FontSize',14,'FontWeight','bold');
end



    boundary = B{k};
               if(k > N)
                 plot(axes(end),boundary(:,2), boundary(:,1),'Color',[0.4660 0.6740 0.1880], 'LineWidth', 2);
               else
                 plot(axes(end),boundary(:,2), boundary(:,1), 'Color',[0.9365 0.9683 0.4000], 'LineWidth', 2);
               end
               %randomize text position for better visibility
               rndRow = ceil(length(boundary)/(mod(rand*k,7)+1));
               col = boundary(rndRow,2); row = boundary(rndRow,1);
               h = text(col+1, row-1,id,'Parent',axes(end));
               set(h,'Color',[0.7778 0.8889 0.4000],'FontSize',14,'FontWeight','bold');