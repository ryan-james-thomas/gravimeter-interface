function BasicCallback(r)

if r.isInit()
    r.data.dipole = 0.15:-0.01:0.1;
    r.c.setup('var',r.data.dipole);
elseif r.isSet()
    r.make(20e-3,r.data.dipole(r.c(1))).upload;
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
    
    r.data.files{i1,1} = img.raw.files;
    r.data.N(i1,1) = img.get('N');
    r.data.OD(i1,1) = img.get('peakOD');

    figure(98);clf;
    plot(r.data.dipole(1:i1),r.data.OD,'o-');
    ylim([0,Inf]);
    grid on
end


end