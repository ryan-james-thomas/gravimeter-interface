%FreqToV(0,-8,'c') % order is: (repumpf , coolingf, VCO voltage you
    %want, where this is either c or r)

%freqsans=FreqtoVCOV(0,0) %repump, cooling detuning
function ans = FreqToV(f,fc,chan)
    syms V Vc
    coolV = coolFreqtoV(fc);
    eqnr = f == repumpVtoFreq(V,coolV);
    repumpV = vpasolve(eqnr,V,[0,4]);
    %ans = [repumpV coolV];
    switch chan
        case 'r'
            ans=repumpV;
        case 'c'
            ans=coolV;
    end
end



function ans = coolFreqtoV(fc)
    syms Vc
    eqn = fc == coolVtoFreq(Vc);
    ans = vpasolve(eqn,Vc,[0,8]);
    
end

function ans = coolVtoFreq(Vc)
         ans = 110-211.799+2*(20.5829+6.21685*Vc-1.7251*Vc^2+0.507204*Vc^3 - 0.071243*Vc^4 + 0.00454304*Vc^5 - 0.0000968444*Vc^6);
end



function ans = repumpVtoFreq(V,Vc)
         coolrawfreq= (-110+211.799+coolVtoFreq(Vc))/2;
         ans = 110+ coolrawfreq-6779.78+6444.03 + 97.7928*V - 15.4765*V^2 + 5.85305*V^3 - 0.720756*V^4 - 0.0261323*V^5 + 0.00626057*V^6;
end