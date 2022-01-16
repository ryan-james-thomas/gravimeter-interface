function BasicCallback(r)

if r.isInit()
    r.c.setup(Inf);
elseif r.isSet()
    r.make(8.5,5e-3,2).upload;
    fprintf(1,'Run %d/%d\n',r.c.now,r.c.total);
elseif r.isAnalyze()
    i1 = r.c(1);
    pause(0.5);
    img = Abs_Analysis('last',1);
    if ~img(1).raw.status.ok()
        %
        % Checks for an error in loading the files (caused by a missed
        % image) and reruns the last sequence
        %
        r.c.decrement;
        return;
    end
    
    r.data.N(i1,1) = img.get('N');
end


end