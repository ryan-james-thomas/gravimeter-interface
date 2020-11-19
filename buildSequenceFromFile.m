function sq = buildSequenceFromFile(filename)

[t,a,d] = readTextRun(filename);

sq = initSequence;

for nn = 1:size(d,2)
    sq.digital(nn).at(t,d(:,nn));
end

for nn = 1:size(a,2)
    sq.analog(nn).at(t,a(:,nn));
end



