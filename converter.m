function[adjustedN]=converter(numberofatoms)
  if numberofatoms<1e9
      adjustedN=numberofatoms;
  elseif (numberofatoms<5.3e9) & (numberofatoms>=1e9);
      adjustedN= (numberofatoms+0.33831066967032813e9)/1.9072496416137799e9;
  elseif (numberofatoms>= 5.3e9) & (numberofatoms<7.45e9);
      adjustedN=(numberofatoms+0.8862541438377679e9)/2.09262822144999e9;
  else
      adjustedN=(numberofatoms-2.0101887826670093e9)/1.3444980036217649e9;
      
end
