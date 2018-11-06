x = linspace(1,4,4);
%Shimming
a = [0.54644 0.57105 0.46291 0.33384]
%MLS
b = [0.41515 0.54495 0.47663 0.25317]
%PhaseOnly
c = [0.27207 0.26399 0.26139 0.23678]

%Shimming
d = [0.51467 0.47121 0.50551 0.59943]
%MLS
e = [0.39138 0.36627 0.37314 0.37636]
%PhaseOnly
f = [1 1 1 1]

figure; plot(x,d,'ro-');hold on;plot(x,e,'bo-');hold on;plot(x,f,'ko-');hold on;