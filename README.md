# Introduction

This set of MATLAB classes and functions is for creating and running sequences on the gravimeter and experiments with related control apparatuses.  It is meant to replace the run builder LabVIEW program, but it still needs the LabVIEW control program to handle writing data to the National Instruments hardware.  The idea behind this project is to replace defining sequences (or runs) using a graphical interface that needs lots of pointing and clicking with a set of MATLAB commands in text form.  This allows for easier inspection, modification, and automation of sequences.

The basic organization of this interface is as follows.  The classes

  - TimingSequence
  - TimingControllerChannel
  - DigitalChannel
  - AnalogChannel

together are used to define a `TimingSequence` object which consists of an array of `TimingControllerChannels` (the channels), each of which is an instance of either sub-class `DigitalChannel` or `AnalogChannel`.  Each channel contains an array of values and the times at which to output those values.  These channels can be programmed independently.  The TimingSequence object has a compilation function which collates all the channel times and values and creates a set of arrays that are understood by the LabVIEW control program.  

The function `makeSequence` is the default program used for creating a specific `TimingSequence` object that runs a given experiment.  The idea is that `makeSequence` has a variable argument list, and the user of the program can edit the function so that different arguments do different things.  So `makeSequence` should be called as
```
sq = makeSequence(varargin);
```
where `sq` is the `TimingSequence` object and `varargin` is a list of input arguments.  `makeSequence` internally calls `initSequence` which defines the names of channels and their default values.

Finally, the `RemoteControl` class is used to manage communication with the LabVIEW control program.  It uses the TCP/IP protocol to send and receive data to the LabVIEW program.  The class can also be used to automate the running of multiple sequences in series, with input parameters to `makeSequence` varying in an arbitrary way, and then the subsequent analysis of that data.

# Initializing a sequence

If one wants to create a sequence from scratch, the first thing to do is to create a `TimingSequence` object `sq` by calling
```
sq = TimingSequence(numDigitalChannels,numAnalogChannels)
```
where the input arguments are the number of digital and analog channels, respectively.  For the gravimeter these are 32 and 24, respectively (as of November 2020).  The number of digital channels should not exceed 32.  This command creates the `TimingSequence` object `sq` with the appropriate channels, and each channel can be accessed using
```
sq.channels(idx); %For accessing any channel - the list starts with digital channels and then goes to analog channels
sq.digital(idx);  %For accessing the idx'th digital channel.  Call without any arguments to get an array of all digital channels
sq.analog(idx);   %For accessing the idx'th analog channel.  Call without any arguments to get an array of all analog channels
```
Remembering the index of each channel is inconvenient, so channels can be given names, ports, and descriptions.  For instance, one might want to call the 14th channel "Cam Trig".  This can be done using
```
sq.channels(14).setName('Cam Trig','B5','The camera trigger');
```
where the second number is a port number that is not used internally but may be useful for matching up the named channels to labels on breakout boards.  The function `sq = initSequence` should be used for defining all the channel names and default values (using the method setDefault()).  Once a channel is named it can be accessed using
```
ch = sq.find('Cam trig');
```
where the input argument for `find` is case-insensitive.  In the above command, `ch` is the `TimingControllerChannel` object corresponding to the channel with name 'Cam trig'.  

# Defining channel updates

Sequences are created by telling channels what to do and when to do it -- these are called *updates*.  The fundamental method for this process is the `at(time,value)` method with input arguments `time` and `value`.  You can also use `on(time,value)` -- it's an alias.  The values for digital channels can only be 0 or 1, while for analog values they can be anything between the `bounds` property of the channel.  Times are always in seconds.  For instance, the command
```
sq.find('cam trig').at(6.05,1);
```
tells the camera trigger channel to ouput a value of 1 at 6.05 s from the start of the sequence.  If a value at that time already exists, it is overwritten.  The `at` command can also be used with an array of times and values
```
sq.find('cam trig').at([1,2,3,4],[1,0,1,0]);
```
or with an array of times and a function handle
```
sq.find('cam trig').at([1,2,3,4],@(x) mod(x,2)+1);
```
A series of `at` commands for a channel do not need to be in order
```
sq.find('cam trig').at(5,0);
sq.find('cam trig').at(1,1);
sq.find('cam trig').at(2.5,0);
```
When the sequence is compiled the updates are placed in chronological order.  If you want to force sorting of the updates, use the `TimingControllerChannel.sort()` method.

An important property associated with the `TimingControllerChannel` class is the `lastTime` property.  This value is set to the most recently set update time -- note that this does not mean that it is the latest time in a chronologically ordered set of times.  For instance, in the following set of commands the `lastTime` property is set as indicated.
```
sq.find('cam trig').at(5,0);    %lastTime = 5
sq.find('cam trig').at(1,1);    %lastTime = 1
sq.find('cam trig').at(2.5,0);  %lastTime = 2.5
```
If you call the sort method on a channel `ch` using `ch.sort()` then the `lastTime` property will be set to the latest time in the chronologically ordered set of times.

The `lastTime` property is used for certain semantically useful methods for defining channel updates.  There are four such methods: `anchor(time)`, `set(values)`, `before(times,values)`, and `after(times,values)`.  The `anchor(time)` method sets the value of `lastTime` to the input argument `time` without adding an update.  The method `set(value)` sets the value to `value` at the time corresponding to `lastTime`.  The methods `before(times,values)` and `after(times,values)` can be used to create updates that occur either before or after `lastTime`.  The methods `set`, `before`, and `after` internally invoke `at(lastTime,values)`, `at(lastTime-times,values)` or `at(lastTime+times,values)` for the before and after methods, respectively, so they work with the same inputs as `at`, namely array inputs.  As a result, the following commands have the results indicated in the comments
```
sq.find('cam trig').at(0,0);                    %Sets the value to 0 a 0 s. lastTime is 0 s
sq.find('cam trig').at(3,1);                    %Sets the value to 1 at 3 s.  lastTime is 3 s.
sq.find('cam trig').after(50e-3,0);             %Sets the value to 0 at 3.05 s (50 ms after the last update).  lastTime is 3.05 s
sq.find('cam trig').anchor(10);                 %Sets lastTime to 10 s. No update is added
sq.find('cam trig').before(10e-3,1);            %Sets the value to 1 at 9.99 s (10 ms before 10 s). lastTime is set to 9.99 s.
sq.find('cam trig').after(50e-6,0);             %Sets the value to 0 at 9.99005 s (50 us after 9.99 s). lastTime is set to 9.99005 s.
sq.find('cam trig').at(15:20,@(x) mod(x,2)+1);  %Sets values to the output of the function at times 15 s through 20 s in 1 s steps.  lastTime is set to 20 s.
sq.find('cam trig').before(1e-3,1);             %Sets the value to 1 at 19.999 s (1 ms before 20 s). lastTime is set to 19.999 s.
```
Note that all of these commands return the channel object, which means that they can be chained together. The command
```
sq.find('cam trig').at(0,0).at(3,1).after(50e-3,0).anchor(10).before(10e-3,1).after(50e-6,0);
```
is equivalent to the first 6 lines of the last set of commands.  

# Building a multi-channel sequence

Updates for each channel are added independently of the others, which makes it quite easy to create parallel sets of updates.  For instance, suppose one wants to create a basic imaging sequence with digital channels named 'imaging shutter ttl', 'imaging aom ttl', 'repump aom ttl', and 'cam trig'.  The imaging AOM and the camera trigger should start at the same time of 6 s and last for 30 us.  The repump AOM should turn on for 30 us before the camera trigger and last for the same duration.  The imaging shutter should be raised 2.5 ms before the imaging pulse starts to give it time to open and should close at the same time that the camera trigger goes low.  A set of commands that would work for this purpose is below:
```
sq.find('imaging aom ttl').at(6,1).after(30e-6,0);
sq.find('cam trig').at(6,1).after(30e-6,0);
sq.find('repump aom tll').at(6,0).before(30e-6,1);
sq.find('imaging shutter ttl').anchor(6).before(2.5e-3,1).at(sq.find('cam trig').lastTime,1);
```
At the same time that these updates are occuring, one can set updates for other channels completely independently of the above set of commands.

For many experiments, however, it may be easier to consider the sequence as a set of sequential commands where the values for all relevant channels are set at each update time before a delay is added and new updates added at the delayed time.  A sequentially built process for the above behaviour might look like
```
sq.anchor(0);
sq.delay(6-2.5e-3);
sq.find('imaging shutter ttl').set(1);
sq.delay(2.5e-3-30e-6);
sq.find('repump aom ttl').set(1);
sq.delay(30e-6);
sq.find('repump aom ttl').set(0);
sq.find('imaging aom ttl').set(1);
sq.find('cam trig').set(1);
sq.delay(30e-6);
sq.find('imaging aom ttl').set(0);
sq.find('cam trig').set(0);
```
In this set of commands, I have started with the `TimingSequence.anchor(time)` command which sets the `lastTime` property for *every* channel to `time`.  Similarly, the method `TimingSequence.delay(time)` first finds the latest update time (when sorted chronologically) using `TimingSequence.latest()`, and then advances every channels' `lastTime` property by `time` (which can also be negative).

One can also mix-and-match the two paradigms (parallel and sequential) to harness the power of both.  One could write the above sequence as
```
sq.find('cam trig').at(6,1);
sq.find('imaging aom ttl').at(sq.find('cam trig').last,1);
sq.find('imaging shutter ttl').anchor(sq.find('cam trig').last).before(2.5e-3,1);
sq.find('repump aom ttl').at(sq.find('cam trig').last,0).before(30e-6,1);
sq.delay(30e-6);
sq.find('imaging aom ttl').set(0);
sq.find('imaging shutter ttl').set(0);
sq.find('cam trig').set(0);
```

# Compiling data

Once a sequence is defined it has to be transformed into a form that can be sent to the LabVIEW control program.  Use the method
```
sq.compile;
```
to compile the data.  While the updates for each channel are programmed separately, the output from the hardware is such that any time there is an update from a channel, *all* channels must provide a value.  So compilation is the process by which the independent updates from each channel are combined into a set times and values such that values for inactive channels are held constant while active channels change.  For instance, suppose we have the analog channels '3D MOT Freq' and '3D MOT Amp' that are programmed as
```
sq.find('3D MOT Freq').at(0,6.8);
sq.find('3D MOT Amp').at([0,1,2,3],[8,7,6,5]);
```
The 'Freq' channel has only one update while the 'Amp' channel has four.  During compilation, the 'Freq' channel updates are populated such that it has updates at times 0, 1, 2, and 3 seconds with all values being 6.8.

Compiled data is stored in the `TimingSequence` property `TimingSequence.data` which is a structure with fields `t`, `d`, and `a`.  The `t` field is an Nx1 array of double precision values where N is the total number of compiled updates and represents all the update times.  The `d` field is an Nx1 array of unsigned 32-bit integers that represents the output of up to 32 digital channels at each update time.  The `a` field is an NxM array of double-precision values with M the number of analog channels and represents the analog values.

The compiled data can be easily stored in a MATLAB data file and opened on a computer that does not have the interface classes and functions installed.  Additionally, the method `TimingSequence.loadCompiledData(data)` can convert a compiled data structure into a `TimingSequence`.

# Uploading and running a single sequence

The `RemoteControl` class is used for uploading sequences created with the `TimingController` class to the gravimeter control program and running it.  It can also be used to automate scanning through parameters for optimization in addition to on-line data analysis.  The `RemoteControl` class communicates with the LabVIEW control program using TCP/IP: the LabVIEW program listens for TCP/IP connections on port 6666 as the host, and the `RemoteControl` class connects to that host using the MATLAB `tcpip` class.  The `open()` and `stop()` can be used to connect to and disconnect from the LabVIEW host.  

The `RemoteControl` class has the property `sq` which is used for storing a sequence to be written to the device.  Additionally, there is a method `make()` that can be called as
```
r = RemoteControl;  %Create RemoteControl object
r.make(varargin);
```
which internally calls the function stored in `RemoteControl.makerCallback` as `r.sq = r.makerCallback(varargin)`.  If there is no callback specified in `makerCallback` then it reverts to the default function `makeSequence`.  If you wanted to specifiy a different function, say `myfunc`, then set it using
```
r.makerSequence = @myfunc;
```
The reason for specifying a separate `make()` method for the `RemoteControl` class is so that it can be chained together with the `upload` and `run` methods to enact a single-line make, compile, and run command:
```
r.make(varargin).upload.run;
```
where the `upload` method called without an input argument uses the compiled data from the internal `sq` property.  The `run` method tells the LabVIEW program to execute the currently stored program.  Alternatively, given compiled data `data` you can upload that using `r.upload(data)`.

# Executing multiple runs and parameter scans

The true power of this interface is that it allows for easy scanning of parameters in a sequence for optimization and data taking purposes.  This is accomplished by implementing a finite-state machine in the RemoteControl object with states 'initialize', 'set', and 'analyze'.  The actions undertaken in each of these states is governed by a callback function stored in the `RemoteControl.callback` property.  The callback function should have the basic structure:
```
function mycallback(r)  %r here is the RemoteControl object
  if r.isInit()
    %Initialize the set of runs. This stage is only called once.
    %Use it to specify the values of the parameter you want to change
    %and the number of runs to take
  elseif r.isSet()
    %This is called at the start of every run of the experiment.
    %Use it to create a new sequence to upload based on the current
    %parameter, and upload that sequence.  Do not use the r.run()
    %method here!
  elseif r.isAnalyze()
    %This is called after the LabVIEW control program is finished
    %Use it to analyze data generated by the experiment
    %You can store processed data in the experiment as fields in 
    %the property r.data
  end
end
```
To facilitate the automated collection of data there is the property `RemoteControl.data`, and different kinds of data can be stored as fields in this property.  For instance, one could store the number of atoms as `r.data.N` and the temperature as `r.data.T` with both `N` and `T` being vectors.

The number of runs to use is controlled by the `RemoteControl.numRuns` and `RemoteControl.currentRun` properties.  When the `RemoteControl` object is first created using `r = RemoteControl`, the value of `r.currentRun` is set to 1.  After the successful completion of each run, which is signaled by the LabVIEW programming sending a 'ready' word to MATLAB using TCP/IP, the value of `r.currentRun` is checked against `r.numRuns` and, if it is smaller, `r.currentRun` is incremented.  If `r.currentRun == r.numRuns` then the set of runs is considered finished and the `r.stop()` method is called.  

A set of runs is started by using `r.start()`.  As long as `r.currentRun == 1` it will set the internal state of `r` to 'initialize' so when the callback function is executed it will execute the case corresponding to `r.isInit() == true`.  Use this case to define the parameters of interest and also the number of runs.  Note that `r.start()` **does not** reset `r.currentRun` to 1; this behaviour is so that if you can resume a sequence of runs in case of errors.  Use `r.reset` to reset the run counter to 1 and clear the `r.data` property.  From here, the state switches to 'set' and executes the callback case `r.isSet() == true`.  Use this case to create a sequence to upload based on the current parameter.  **Do not** use the `r.run()` method in the callback, as it is automatically called once the callback returns and is in the 'set' state.  When the LabVIEW control program indicates that it is done and ready for a new sequence, `r` moves to the 'analyze' state and executes the case `r.isAnalyze() == true`.  Use this analyze the data generated by the sequence that just finished.  Pretty much anything can be placed into this section to do nearly any kind of analysis.  The data resulting from this analysis can then be stored as fields in the `r.data` property.

Let's consider an example of a very simple multiple run where we want to change the time-of-flight for the atoms to measure their temperature.  Let us suppose that we have set up our sequence creating function to be `makeSequence(tof)` where `tof` is the time of flight of the atoms.  We want to run through several times-of-flight and analyze the resulting absorption images.  Suppose that we have a function called `Abs_Analysis` that returns a structure with the *x* and *y* widths from the last absorption image.  A potential callback might look like
```
function MeasureTemperature(r)
  if r.isInit
    r.data.tof = 10e-3:2e-3:30e-3;    %Set the times of flights to scan through
    r.numRuns = numel(r.data.tof);    %Fix the number of runs
  elseif r.isSet
    r.sq = makeSequence(r.data.tof(r.currentRun));  %Create the sequence
    r.upload;                                       %Upload the sequence
    %Print something to the command line so that we know how far along we are
    fprintf(1,'Run %d/%d, TOF: %.1f ms\n',r.currentRun,r.numRuns,r.data.tof(r.currentRun)*1e3);
  elseif r.isAnalyze
    nn = r.currentRun;                      %Make a shorter variable name
    c = Abs_Analysis;                       %Analyze the absorption image, return structure c
    r.data.xw(nn,1) = c.xwidth;             %Store the x width
    r.data.yw(nn,1) = c.ywidth;             %Store the y width

    %Plot the results
    figure(1);clf;
    plot(r.data.tof(1:nn),r.data.xw,'o');
    hold on;
    plot(r.data.tof(1:nn),r.data.yw,'o');
  end
end
```
This measurement can then be started by using the commands
```
r = RemoteControl;  %Assuming that there is no variable r yet
r.callback = @MeasureTemperature;
r.reset;r.start;
```
and the program will run through all the times of flight and plot the widths on the fly.  The stored data can be saved to disk, if desired, by using
```
data = r.data;
save('path/to/file.mat','data');
```
It is recommended that you save only simple data structures and not classes to disk because then loading those data files does not require the correct class definitions to be in your path.  Additionally, other programs such as Julia, Python, and Mathematica can easily read MATLAB .mat files when the variables that are saved are simple scalars, strings, arrays, and structures, but not when they are classes.

A more complicated example might be optimizing the temperature of a cloud after PGC by changing the cooling frequency.  To do this properly several times-of-flight need to be acquired for each cooling frequency, and the widths of the clouds need to be fitted to a model of ballistic expansion to get the temperature.  Suppose `makeSequence` is set up with input arguments `makeSequence(freq,tof)`.  A callback function that would accomplish this task might be
```
function TemperatureMeasurement(r)

  if r.isInit()
    %Initialize run
    r.data.tof = 14e-3:3e-3:29e-3; 
    r.data.freq = linspace(6.5:0.1:9);
    
    r.data.idx = [0,0]; %This is a dual-counting index
    r.numRuns = numel(r.data.freq)*numel(r.data.tof);
  elseif r.isSet()
    %Increment dual counter
    if r.data.idx(1) == 0 && r.data.idx(2) == 0
        r.data.idx = [1,1];
    elseif r.data.idx(2) == numel(r.data.tof)
        r.data.idx(1) = r.data.idx(1) + 1;
        r.data.idx(2) = 1;
    else
        r.data.idx(2) = r.data.idx(2) + 1;
    end
    r.sq = makeSequence(r.data.freq(r.data.idx(1)),r.data.tof(r.data.idx(2)));
    r.upload;
    r.data.sq(r.currentRun,1) = r.sq.data;  %This stores the sequence in the data property in case you need to go back and figure out what changed.
    fprintf(1,'Run %d/%d, Freq: %.3f V, TOF: %.1f ms\n',r.currentRun,r.numRuns,...
        r.data.freq(r.data.idx(1)),r.data.tof(r.data.idx(2))*1e3);
  elseif r.isAnalyze()
    nn = r.currentRun;
    c = Abs_Analysis;
    r.data.N(nn,1) = c.N;
    r.data.xw(nn,1) = c.xwidth;
    r.data.yw(nn,1) = c.ywidth;

    Ntof = numel(r.data.tof);
    if r.data.idx(2) == Ntof;
      %After recording the desired times-of-flight, analyze data according to ballistic expansion model
      xfit = r.data.xw(nn-Ntof-1:nn);
      yfit = r.data.yw(nn-Ntof-1:nn);
      %Insert fitting routines for widths vs times of flight here to get xtemp and ytemp
      r.data.Tx(r.data.idx(1),1) = xtemp;
      r.data.Ty(r.data.idx(1),1) = ttemp;

      figure(1);clf;
      plot(r.data.freq(1:r.data.idx(1)),r.data.Tx,'o');
      hold on;
      plot(r.data.freq(1:r.data.idx(1)),r.data.Ty,'sq');
    end
  end
end
```
This example has two counters, one for the time of flight and one for the frequency, and increments them in such a way to set the frequency, run through the times of flight, analyze the data when all the times of flight have been collected, and then go to the next frequency.  You will need to insert your own method for extracting the temperature from the widths vs times of flight.  As with the previous example, you can start it by using
```
r = RemoteControl;
r.callback = @TemperatureMeasurement;
r.reset;r.start;
```
and go get yourself a coffee as it automatically runs through 156 different sequences.  





