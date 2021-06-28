 % order is: (repumpf , coolingf, VCO voltage you
    %want, where this is either c or r)

    %sympref('FloatingPointOutput',1);    
%fans = Freqq2ToV(0,-18,'b') 

function ans = Freqq2ToV(f,fc,chan)
    %sympref('FloatingPointOutput',1);       
    %coolVtoFreq(4.91)
    %digits(10);
%repump, cooling detuning

    syms V Vc
    coolV = coolFreqtoV(fc);
    repumpf = repumpVtoFreq(f,coolV);
    ans = [repumpf coolV];
    switch chan
        case 'r'
            ans=repumpf;
        case 'c'
            ans=coolV;
        otherwise
            ans= [repumpf coolV];
    end
end



function ans = coolFreqtoV(fc)
    syms Vc
    digits(10)
    eqn = fc == coolVtoFreq(Vc);
    ans = vpasolve(eqn,Vc,[0,8]);
    
end

function ans = coolVtoFreq(Vc)
         %ans = 110-211.799+2*(20.5829+6.21685*Vc-1.7251*Vc^2+0.507204*Vc^3 - 0.071243*Vc^4 + 0.00454304*Vc^5 - 0.0000968444*Vc^6);
         digits(10);
            d287 = 384230.4844865;
         f187 = 4.271676631815;
         f287 = -2.563005979089;
         d285 = 384230.406373;
         f285 = 1.77843922;
         f385 = -1.264888516;
         lockpoint=(d285+f385-0.020435+0.120640/2);
        
        % ans=378.068+28.4486*Vc-2.05918*Vc^2+2.49883*Vc^3 - 0.429482*Vc^4 + 0.0303527*Vc^5 - 0.000863543*Vc^6;
         ans = -(10^3*(d287+f287+0.1927408-0.11)-10^3*lockpoint+2*coolVCOVtoF(Vc));
         %0.11=AOM
end

function ans = coolVCOVtoF(Vc)
    digits(32);
    ans = 378.068+28.4486*Vc-2.05918*Vc^2+2.49883*Vc^3 - 0.429482*Vc^4 + 0.0303527*Vc^5 - 0.000863543*Vc^6;
end

 function ans = repumpVtoFreq(f,Vc)
 d287 = 384230.4844865;
         f187 = 4.271676631815;
         f287 = -2.563005979089;
         d285 = 384230.406373;
         f285 = 1.77843922;
         f385 = -1.264888516;
         lockpoint=(d285+f385-0.020435+0.120640/2);
         %coolingphoton = (10^3*(d287+f287+0.1927408-0.11)-10.^3*lockpoint)/2
         coolingphoton = coolVCOVtoF(Vc);
         ans = -coolingphoton-10^3*(-lockpoint+d287+f187-0.0729113-0.11)+f/2;
 end