function setSafeValues(sq)
    
for nn = 1:sq.numChannels
    sq.channels(nn).set(0);
end

% sq.find('DDS TTL').set(1);
