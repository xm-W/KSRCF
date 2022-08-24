data2=rand(50);

Pm=[0.05,0.1,0.15,0.2,0.25];
Pc=[0.0001,0.0005,0.001,0.005,0.01];

% [m,n]=meshgrid(1:6);
% surf(m,n,0*m,data1,'linestyle',':');
% %%%%%%%%%自定义颜色%%%%%%%%%%%
% map=ones(199,3);
% c=linspace(0,1)';
% map(199:-1:100,[2,3])=[c,c];
% map(1:100,[1,3])=[c,c];
% colormap(map);
% %colorbar([-50,50]);
% colorbar;
% %%%%%%%%%%%%%%%%%%%%%%%%%%
% view(2);axis ij
% axis([1,6,1,6])
% set(gca,'xtick',1.5:5.5,'xticklabel',Pm,'ytick',1.5:5.5,'yticklabel',Pc)
% [m,n]=meshgrid(1.5:5.5);
% %%%%%%%%显示百分比%%%%%%%%%%%%
% %text(m(:),n(:),cellfun(@(x)[num2str(x),'%'],num2cell(round(A(:)*100)),'UniformOutput',false),'HorizontalAlignment','center','color','b')
% text(m(:),n(:),cellfun(@(x)[num2str(x),'%'],num2cell(data1),'UniformOutput',false),'HorizontalAlignment','center','color','b')
% xlabel('Pm'),ylabel('Pc');


[m,n]=meshgrid(1:6);
surf(data2);
%%%%%%%%%自定义颜色%%%%%%%%%%%
% map=ones(199,3);
% c=linspace(0,1)';
% map(199:-1:100,[3,3])=[c,c];
% map(1:1:100,[2,3])=[c,c];
% colormap(map);
% %colorbar([-50,50]);
colorbar;
%%%%%%%%%%%%%%%%%%%%%%%%%%
view(2);axis ij
axis([1,6,1,6])
% set(gca,'xtick',1.5:5.5,'xticklabel','ytick',1.5:5.5)
[m,n]=meshgrid(1.5:5.5);
%%%%%%%%显示百分比%%%%%%%%%%%%
%text(m(:),n(:),cellfun(@(x)[num2str(x),'%'],num2cell(round(A(:)*100)),'UniformOutput',false),'HorizontalAlignment','center','color','b')
% text(m(:),n(:),cellfun(@(x)[num2str(x)],num2cell(data2),'UniformOutput',false),'HorizontalAlignment','center','color','b')
xlabel('高变异率'),ylabel('低变异率');

