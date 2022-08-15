
% combine multiple lineages (FirstHalf.mat, SecondHalf.mat)
% into one lineage graph (CombinedGraph.mat)
% output as mat and json file (CombinedGraph.json)

graph_path = '/Users/lbrown/Documents/PosfaiLab/3DStardist/TestEval/EmbryoStats/211106_st5/';
graph_name1 = 'FirstHalf.mat';
graph_name2 = 'SecondHalf.mat';


gg1 = load(strcat( graph_path , graph_name1));
gg2 = load(strcat( graph_path , graph_name2));
gg1 = gg1.gg1;
gg2 = gg2.gg2;

close all;
figure;
plot(gg1,'layout','layered');  
figure;
plot(gg2,'layout','layered');  

ggboth = graph;
nNodes = size(gg1.Nodes);
for iNode = 1:nNodes
    ggboth = ggboth.addnode(gg1.Nodes{iNode,1});
end

nNodes = size(gg2.Nodes);
for iNode = 1:nNodes
    node = gg2.Nodes{iNode,1};
    % check that not already in new graph
    k = findnode(ggboth,node);
    if (k < 1)
        ggboth = ggboth.addnode(node);
    end
end


nEdges = size(gg1.Edges);
for iEdge = 1:nEdges
    node1 = gg1.Edges{iEdge,1}(1,1);
    node2 = gg1.Edges{iEdge,1}(1,2);
    ggboth = ggboth.addedge(node1,node2);
end

nEdges = size(gg2.Edges);
for iEdge = 1:nEdges
    node1 = gg2.Edges{iEdge,1}(1,1);
    node2 = gg2.Edges{iEdge,1}(1,2);
    ggboth = ggboth.addedge(node1,node2);
end

% show each of the new graphs
figure;
plot(ggboth,'layout','layered');  

%save the new graph
save(strcat(graph_path,'CombinedGraph.mat'),'ggboth');

% now make the json version
jH = jsonencode(ggboth);
json_FileName = strcat('CombinedGraph.json');
fid = fopen(strcat(data_path,json_FileName),'w');
fprintf(fid, jH);
fclose(fid);

