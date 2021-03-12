function sq = initSequence
    sq = TimingSequence(32,24);
    
    %% Name digital channels
    sq.digital(1).setName('87 Repump TTL EOM','A0').setDefault(1);
    sq.digital(2).setName('85 Repump TTL EOM','A1').setDefault(0);
    sq.digital(3).setName('Imaging AOM TTL','A2').setDefault(0);
    sq.digital(4).setName('Camera Trigger','A3').setDefault(0);
    sq.digital(5).setName('FMI Trigger','A4').setDefault(0);
    sq.digital(6).setName('3D Coils Top TTL','A5').setDefault(0);
    sq.digital(7).setName('2D Coils TTL','A6').setDefault(0);
    sq.digital(8).setName('3D Coils Bottom TTL','A7').setDefault(0);
    sq.digital(9).setName('B0 - N/C','B0').setDefault(0);
    sq.digital(10).setName('Repump/Microwave Switch','B1').setDefault(0);
    sq.digital(11).setName('Bragg SSM Switch','B2').setDefault(0);
    sq.digital(12).setName('B3 - N/C','B3').setDefault(0);
    sq.digital(13).setName('B4 - N/C','B4').setDefault(0);
    sq.digital(14).setName('B5 - DEAD','B5','DEAD').setDefault(0);
    sq.digital(15).setName('2D Bias','B6').setDefault(0);
    sq.digital(16).setName('B7 - N/C','B7').setDefault(0);
    sq.digital(17).setName('C0 - N/C','C0').setDefault(0);
    sq.digital(18).setName('C1 - N/C','C1').setDefault(0);
    sq.digital(19).setName('C2 - N/C','C2').setDefault(0);
    sq.digital(20).setName('C3 - N/C','C3').setDefault(0);
    sq.digital(21).setName('2DMOT AOM TTL','C4','0 = ON').setDefault(1);
    sq.digital(22).setName('3DMOT AOM TTL','C5','0 = ON').setDefault(1);
    sq.digital(23).setName('C6 - DEAD','C6','DEAD').setDefault(0);
    sq.digital(24).setName('C7 - N/C','C7').setDefault(0);
    sq.digital(25).setName('H Dipole TTL','D0','Raycus 1').setDefault(0);
    sq.digital(26).setName('WG 1 TTL','D1','Raycus 2').setDefault(0);
    sq.digital(27).setName('WG 2 TTL','D2','Raycus 3').setDefault(0);
    sq.digital(28).setName('WG 3 TTL','D3','Raycus 3').setDefault(0);
    sq.digital(29).setName('DDS Channel 1 TTL','D4').setDefault(0);
    sq.digital(30).setName('ADC Trigger','D5').setDefault(1);
    
    sq.digital(31).setDefault(1);
    sq.digital(32).setDefault(0);
    
    %% Name analog channels
    sq.analog(1).setName('87 Cooling Freq EOM','AO/0').setDefault(5.5);
    sq.analog(2).setName('87 Cooling Amp EOM','AO/1').setDefault(0);
    sq.analog(3).setName('87 Repump Freq EOM','AO/2').setDefault(2.175);
    sq.analog(4).setName('87 Repump Amp EOM','AO/3').setDefault(4);
    sq.analog(5).setName('3D Coils Top','AO/4').setDefault(0.11);
    sq.analog(6).setName('E/W Bias','AO/5').setDefault(0);
    sq.analog(7).setName('85 Repump Freq EOM','AO/6').setDefault(0);
    sq.analog(8).setName('N/S Bias','AO/7').setDefault(3.2);
    sq.analog(9).setName('2D MOT Amp AOM','B0/0').setDefault(2.2);
    sq.analog(10).setName('3DHMOT Amp AOM','BO/1').setDefault(0.7);
    sq.analog(11).setName('Vertical Bias','BO/2').setDefault(-0.5);
    sq.analog(12).setName('2D MOT Freq AOM','BO/3').setDefault(8.4);
    sq.analog(13).setName('3DHMOT Freq AOM','BO/4').setDefault(8.423);
    sq.analog(14).setName('2D Coils','BO/5').setDefault(3.4);
    sq.analog(15).setName('BO/6 - DEAD','BO/6','DEAD').setDefault(0);
    sq.analog(16).setName('3D Coils Bottom','BO/7').setDefault(0.1);
    sq.analog(17).setName('3DVMOT Amp AOM','CO/0').setDefault(0);
    sq.analog(18).setName('3DVMOT Freq AOM','CO/1').setDefault(0);
    sq.analog(19).setName('CO/2 - DEAD','CO/2','DEAD').setDefault(0);
    sq.analog(20).setName('Imaging AOM Amp','CO/3').setDefault(2.4);
    sq.analog(21).setName('H Dipole AMP','CO/4','Raycus 1').setDefault(0);
    sq.analog(22).setName('WG AMP 1','CO/5','Raycus 2').setDefault(0);
    sq.analog(23).setName('WG AMP 2','CO/6','Raycus 3').setDefault(0);
    sq.analog(24).setName('WG AMP 3','CO/7','Raycus 4').setDefault(0);

    %% DDS default
    sq.dds(1).setDefault([110,0,0]);
    sq.dds(2).setDefault([110,0,0]);
    

end