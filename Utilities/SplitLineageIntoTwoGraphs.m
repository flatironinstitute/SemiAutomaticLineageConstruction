
% split one lineages
% into multiple lineage graphs
% output as FIrstHalfGraph (nodes up to 52, edges to 53)
%          and SecondHalfGraph (nodes/edges starting at 45

clear;
close all;

graph_path = '/Users/lbrown/Documents/PosfaiLab/3DStardist/TestEval/EmbryoStats/211106_st5/';
graph_name = 'tracking_results_11_15_sox2_cdx2_again_again_again_fixed.mat';


gg = load(strcat( graph_path , graph_name));
gg = gg.G_based_on_nn;

close all;
figure;
plot(gg,'layout','layered');  

% split graph as test - all nodes and edges including frame 52 and after
FirstGraphEnd = 52;
SecondGraphStart = 45;

gg1 = graph;
gg2 = graph;
nNodes = size(gg.Nodes);
for iNode = 1:nNodes
    iframe = str2double( gg.Nodes{iNode,1}{1,1}(1:3) );
    if (iframe <= FirstGraphEnd)
        gg1 = gg1.addnode(gg.Nodes{iNode,1});
    end
    if iframe >= SecondGraphStart
        gg2 = gg2.addnode(gg.Nodes{iNode,1});
    end
end
nEdges = size(gg.Edges);
for iEdge = 1:nEdges
    % get both nodes
    %disp(gg.Edges{iEdge,1});
    node1 = gg.Edges{iEdge,1}(1,1);
    frame1 = str2double(node1{1}(1:3));
    node2 = gg.Edges{iEdge,1}(1,2);
    frame2 = str2double(node2{1}(1:3));
    % if either one has frame <= 52 add to gg1
    if (frame1 <= (FirstGraphEnd + 1)) & (frame2 <= (FirstGraphEnd + 1))
        gg1 = gg1.addedge(node1,node2);
    end
    if (frame1 >= SecondGraphStart) & (frame2 >= SecondGraphStart)
        gg2 = gg2.addedge(node1,node2);
    end
end

% show each of the new graphs
figure;
plot(gg1,'layout','layered');  

figure;
plot(gg2,'layout','layered');  

%save the two graphs
save(strcat(graph_path,'FirstHalf.mat'),'gg1');
save(strcat(graph_path,'SecondHalf.mat'),'gg2');



