function sq = initSequence
    sq = TimingSequence(32,24);
    
    %% Name digital channels

    sq.channels(1).setName('50W TTL','A0').setDefault(0);
    sq.channels(2).setName('DDS Trig','A1').setDefault(1);
    sq.channels(3).setName('50W Pilot','A2').setDefault(1);
    sq.channels(4).setName('25W TTL','A3').setDefault(0);
    sq.channels(5).setName('25W Active','A4').setDefault(1);
    sq.channels(6).setName('A5 - N/C','A5').setDefault(0);
    sq.channels(7).setName('Bragg/Raman switch','A6','Set to 1 for Bragg, 0 for Raman').setDefault(0);
    sq.channels(8).setName('A7 - N/C','A7').setDefault(0);
    sq.channels(9).setName('2D MOT Amp TTL','B0').setDefault(1);
    sq.channels(10).setName('3D MOT Amp TTL','B1').setDefault(1);
    sq.channels(11).setName('Imaging Amp TTL','B2').setDefault(0);
    sq.channels(12).setName('Push Amp TTL','B3').setDefault(1);
    sq.channels(13).setName('Repump Amp TTL','B4').setDefault(1);
    sq.channels(14).setName('Cam Trig','B5').setDefault(0);
    sq.channels(15).setName('Drop Repump','B6').setDefault(0);
    sq.channels(16).setName('Fiber Switch Repump','B7').setDefault(0);
    sq.channels(17).setName('MOT Coil TTL','C0').setDefault(1);
    sq.channels(18).setName('Stern-Gerlach Trigger','C1').setDefault(0);
    sq.channels(19).setName('C2 - N/C','C2').setDefault(0);
    sq.channels(20).setName('C3 - N/C','C3').setDefault(0);
    sq.channels(21).setName('C4 - N/C','C4').setDefault(0);
    sq.channels(22).setName('C5 - N/C','C5').setDefault(0);
    sq.channels(23).setName('C6 - N/C','C6').setDefault(0);
    sq.channels(24).setName('C7 - N/C','C7').setDefault(0);
    sq.channels(25).setName('MW Amp TTL','D0').setDefault(0);
    sq.channels(26).setName('F MOD Imaging Trigger','D1').setDefault(0);
    sq.channels(30).setName('Drop 1 Camera Trig','D5').setDefault(0);
    
    sq.digital(31).setDefault(1);
    sq.digital(32).setDefault(0);
    
    %% Name analog channels
    sq.analog(1).setName('2D MOT Freq','AO/0').setDefault(7.65);
    sq.analog(2).setName('3D MOT Freq','AO/1').setDefault(6.5);
    sq.analog(3).setName('Imaging Freq','AO/2').setDefault(8.5);
    sq.analog(4).setName('Push Freq','AO/3').setDefault(9.5);
    sq.analog(5).setName('Repump Freq','AO/4').setDefault(4.3);
    sq.analog(6).setName('50W Amp','AO/5').setDefault(5);
    sq.analog(7).setName('25W Amp','AO/6').setDefault(5);
    sq.analog(8).setName('AO7 - N/C','AO/7').setDefault(0);
    sq.analog(9).setName('Liquid crystal Bragg','B0/0').setDefault(3);
    sq.analog(10).setName('3D MOT Amp','BO/1').setDefault(5);
    sq.analog(11).setName('MW Freq','BO/2').setDefault(6.8);
    sq.analog(12).setName('MW Amp','BO/3').setDefault(0);
    sq.analog(13).setName('Repump Amp','BO/4').setDefault(9);
    sq.analog(14).setName('Liquid Crystal Repump','BO/5').setDefault(-2.22);
    sq.analog(15).setName('Drop Repump Freq','BO/6').setDefault(4.3);
    sq.analog(16).setName('RF Frequency','BO/7').setDefault(0);
    sq.analog(17).setName('Raman Amp','CO/0').setDefault(0);
    sq.analog(18).setName('CO/1 - dead','CO/1').setDefault(0);
    sq.analog(19).setName('3D Coils','CO/2').setDefault(0.42);
    sq.analog(20).setName('Bias E/W','CO/3').setDefault(0);
    sq.analog(21).setName('Bias N/S','CO/4').setDefault(0);
    sq.analog(22).setName('Bias U/D','CO/5').setDefault(0);
    sq.analog(23).setName('Raman Freq','CO/6').setDefault(9);
    sq.analog(24).setName('3D Coils Loop','CO/7').setDefault(0);

    %% DDS default
    calibData = load('aom-rf-power-10db-ch1-13db-ch2');
    sq.dds(1).setName('DDS 1').setDefault([110,0,0]);
    sq.dds(1).calibrationData = calibData.data(1);
    sq.dds(2).setName('DDS 2').setDefault([110,0,0]);
    sq.dds(2).calibrationData = calibData.data(2);

end