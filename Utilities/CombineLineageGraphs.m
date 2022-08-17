
% combine multiple lineages (FirstHalf.mat, SecondHalf.mat)
% into one lineage graph (CombinedGraph.mat)
% output as mat and json file (CombinedGraph.json)

% you can add a start/end frame for each lineage
% only that range will be used in the final graph

% in the example here: FirstHalf runs from [0,52] (w/edges to 53)
%                                   SecondHalf runs from [45 to 143]


% CombinedGraph will take 10 to 46 from FirstHalf
%                                   and 46 to 100 from SecondHalf

clear;
close all;

FirstGraphStart = 10;
FirstGraphEnd = 46;  
SecondGraphStart = 46;
SecondGraphEnd = 100;

graph_path = '/Users/lbrown/Documents/PosfaiLab/3DStardist/TestEval/EmbryoStats/211106_st5/';
graph_name1 = 'FirstHalf.mat';
graph_name2 = 'SecondHalf.mat'

gg1 = load(strcat( graph_path , graph_name1));
gg2 = load(strcat( graph_path , graph_name2));
gg1 = gg1.gg1;
gg2 = gg2.gg2;

figure;
plot(gg1,'layout','layered');  
figure;
plot(gg2,'layout','layered');  

% find range of gg1
nNodes = size(gg1.Nodes);
MaxFrame1 = 0;
MinFrame1 = 1000;
for iNode = 1:nNodes
    frame = str2double( gg1.Nodes{iNode,1}{1,1}(1:3) );
    if frame > MaxFrame1
        MaxFrame1 = frame;
    end
    if frame < MinFrame1
        MinFrame1 = frame;
    end
end
disp(MinFrame1);
disp(MaxFrame1);

% find range of given gg2
nNodes = size(gg2.Nodes);
MaxFrame2 = 0;
MinFrame2 = 1000;
for iNode = 1:nNodes
    frame = str2double( gg2.Nodes{iNode,1}{1,1}(1:3) );
    if frame > MaxFrame2
        MaxFrame2 = frame;
    end
    if frame < MinFrame2
        MinFrame2 = frame;
    end
end
disp(MinFrame2);
disp(MaxFrame2);

ggboth = graph;
nNodes = size(gg1.Nodes);
for iNode = 1:nNodes
     frame = str2double( gg1.Nodes{iNode,1}{1,1}(1:3) );
     if (frame <= FirstGraphEnd) & (frame >= FirstGraphStart)
        ggboth = ggboth.addnode(gg1.Nodes{iNode,1});
     end
end

nEdges = size(gg1.Edges);
for iEdge = 1:nEdges
    node1 = gg1.Edges{iEdge,1}(1,1);
    node2 = gg1.Edges{iEdge,1}(1,2);
    frame1 = str2double( node1{1,1}(1:3) );
    frame2 = str2double( node2{1,1}(1:3) );
    if (frame1 <= FirstGraphEnd) & (frame2 <= FirstGraphEnd) & (frame1 >= FirstGraphStart) & (frame2 >= FirstGraphStart)
        ggboth = ggboth.addedge(node1,node2);
    end
end


% show the new graphs
figure;
plot(ggboth,'layout','layered');  


nNodes = size(gg2.Nodes);
for iNode = 1:nNodes
    node = gg2.Nodes{iNode,1};
     frame = str2double( gg2.Nodes{iNode,1}{1,1}(1:3) );
    % check that not already in new graph
    k = findnode(ggboth,node);
    if (k < 1) &  (frame >= SecondGraphStart) & (frame <= SecondGraphEnd)
        ggboth = ggboth.addnode(node);
    end
end


nEdges = size(gg2.Edges);
for iEdge = 1:nEdges
    node1 = gg2.Edges{iEdge,1}(1,1);
    node2 = gg2.Edges{iEdge,1}(1,2);
    frame1 = str2double( node1{1,1}(1:3) );
    frame2 = str2double( node2{1,1}(1:3) );
    if (frame1 >= SecondGraphStart) & (frame2 >= SecondGraphStart) & (frame1 <= SecondGraphEnd) & (frame2 <= SecondGraphEnd)
        ggboth = ggboth.addedge(node1,node2);
    end
end

% show the new graphs
figure;
plot(ggboth,'layout','layered');  

%save the new graph
save(strcat(graph_path,'CombinedGraph.mat'),'ggboth');

% now make the json version
jH = jsonencode(ggboth);
json_FileName = strcat('CombinedGraph.json');
fid = fopen(strcat(graph_path,json_FileName),'w');
fprintf(fid, jH);
fclose(fid);

