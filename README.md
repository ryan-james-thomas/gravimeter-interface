# Introduction

This set of MATLAB classes and functions is for creating and running sequences on the gravimeter and experiments with related control apparatuses.  It is meant to replace the run builder LabVIEW program, but it still needs the LabVIEW control program to handle writing data to the National Instruments hardware.  The idea behind this project is to replace defining sequences (or runs) using a graphical interface that needs lots of pointing and clicking with a set of MATLAB commands in text form.  This allows for easier inspection, modification, and automation of sequences.

The basic organization of this interface is as follows.  The classes
  - TimingSequence
  - TimingControllerChannel
  - DigitalChannel
  - AnalogChannel
together are used to define a *TimingSequence* object which consists of an array of *TimingControllerChannels* (the channels), each of which is an instance of either sub-class *DigitalChannel* or *AnalogChannel*.  Each channel contains an array of values and the times at which to output those values.  These channels can be programmed independently.  The TimingSequence object has a compilation function which collates all the channel times and values and creates a set of arrays that are understood by the LabVIEW control program.  

The function *makeSequence* is the default program used for creating a specific *TimingSequence* object that runs a given experiment.  The idea is that *makeSequence* has a variable argument list, and the user of the program can edit the function so that different arguments to different things.  So *makeSequence* should be called as

  > sq = makeSequence(varargin);

where *sq* is the *TimingSequence* object and *varargin* is a list of input arguments.  *makeSequence* internally calls *initSequence* which defines the names of channels and their default values.

Finally, the *RemoteControl* class is used to manage communication with the LabVIEW control program.  It uses the TCP/IP protocol to send and receive data to the LabVIEW program.  The class can also be used to automate the running of multiple sequences in series, with input parameters to *makeSequence* varying in an arbitrary way, and then the subsequent analysis of that data.

## Initializing a sequence

If one wants to create a sequence from scratch, the first thing to do is to create a *TimingSequence* object *sq* by calling

  > sq = TimingSequence(numDigitalChannels,numAnalogChannels)

where the input arguments are the number of digital and analog channels, respectively.  For the gravimeter these are 32 and 24, respectively (as of November 2020).  This command creates the *TimingSequence* object *sq* with the appropriate channels, and each channel can be accessed using

  > sq.channels(idx); %For accessing any channel - the list starts with digital channels and then goes to analog channels
  > sq.digital(idx);  %For accessing the idx'th digital channel.  Call without any arguments to get an array of all digital channels
  > sq.analog(idx);   %For accessing the idx'th analog channel.  Call without any arguments to get an array of all analog channels

Remembering the index of each channel is inconvenient, so channels can be given names, ports, and descriptions.  For instance, one might want to call the 14th channel "Cam Trig".  This can be done using

  > sq.channels(14).setName('Cam Trig','B5');

where the second number is a port number that is not used internally but may be useful for matching up the named channels to labels on breakout boards.  The function *sq = initSequence* should be used for defining all the channel names and default values (using the method setDefault()).  Once a channel is named it can be accessed using

  > ch = sq.find('Cam trig');

where the input argument for *find* is case-insensitive.  In the above command, *ch* is the *TimingControllerChannel* object corresponding to the channel with name 'Cam trig'.  

## Defining channel updates

Sequences are created by telling channels what to do and when to do it -- these are called *updates*.  The fundamental method for this process is the *at(time,value)* method with input arguments *time* and *value*.  You can also use *on(time,value)* -- it's an alias.  The values for digital channels can only be 0 or 1, while for analog values they can be anything between the *bounds* property of the channel.  Times are always in seconds.  For instance, the command

  > sq.find('cam trig').at(6.05,1);

tells the camera trigger channel to ouput a value of 1 at 6.05 s from the start of the sequence.  If a value at that time already exists, it is overwritten.  The *at* command can also be used with an array of times and values

  > sq.find('cam trig').at([1,2,3,4],[1,0,1,0]);

or with an array of times and a function handle

  > sq.find('cam trig').at([1,2,3,4],@(x) mod(x,2)+1);

A series of *at* commands for a channel do not need to be in order

  > sq.find('cam trig').at(5,0);
  > sq.find('cam trig').at(1,1);
  > sq.find('cam trig').at(2.5,0);

When the sequence is compiled the updates are placed in chronological order.  If you want to force sorting of the updates, use the *sort()* method.

An important property associated with the *TimingControllerChannel* class is the *lastTime* property.  This value is set to the most recently set update time -- note that this does not mean that it is the latest time in a chronologically ordered set of times.  For instance, in the following set of commands the *lastTime* property is set as indicated.

  > sq.find('cam trig').at(5,0);    %lastTime = 5
  > sq.find('cam trig').at(1,1);    %lastTime = 1
  > sq.find('cam trig').at(2.5,0);  %lastTime = 2.5

If you call the sort method on a channel *ch* using *ch.sort()* then the *lastTime* property will be set to the latest time in the chronologically ordered set of times.

The *lastTime* property is used for certain semantically useful methods for defining channel updates.  There are four such methods: *anchor(time)*, *set(values)*, *before(times,values)*, and *after(times,values)*.  The *anchor(time)* method sets the value of *lastTime* to the input argument *time* without adding an update.  The method *set(value)* sets the value to *value* at the time corresponding to *lastTime*.  The methods *before(times,values)* and *after(times,values)* can be used to create updates that occur either before or after *lastTime*.  The methods *set*, *before*, and *after* internally invoke *at(lastTime,values)*, *at(lastTime-times,values)* or *at(lastTime+times,values)* for the before and after methods, respectively, so they work with the same inputs as *at*, namely array inputs.  As a result, the following commands have the results indicated in the comments

  > sq.find('cam trig').at(0,0);                    %Sets the value to 0 a 0 s. lastTime is 0 s
  > sq.find('cam trig').at(3,1);                    %Sets the value to 1 at 3 s.  lastTime is 3 s.
  > sq.find('cam trig').after(50e-3,0);             %Sets the value to 0 at 3.05 s (50 ms after the last update).  lastTime is 3.05 s
  > sq.find('cam trig').anchor(10);                 %Sets lastTime to 10 s.
  > sq.find('cam trig').before(10e-3,1);            %Sets the value to 1 at 9.99 s (10 ms before 10 s). lastTime is set to 9.99 s.
  > sq.find('cam trig').after(50e-6,0);             %Sets the value to 0 at 9.99005 s (50 us after 9.99 s). lastTime is set to 9.99005 s.
  > sq.find('cam trig').at(15:20,@(x) mod(x,2)+1);  %Sets values to the output of the function at times 15 s through 20 s in 1 s steps.  lastTime is set to 20 s.
  > sq.find('cam trig').before(1e-3,1);             %Sets the value to 1 at 19.999 s (1 ms before 20 s). lastTime is set to 19.999 s.

Note that all of these commands return the channel object, which means that they can be chained together. The command

  > sq.find('cam trig').at(0,0).at(3,1).after(50e-3,0).anchor(10).before(10e-3,1).after(50e-6,0);

is equivalent to the first 6 lines of the last set of commands.  

## Building a multi-channel sequence

Updates for each channel are added independently of the others, which makes it quite easy to create parallel sets of updates.  For instance, suppose one wants to create a basic imaging sequence with digital channels named 'imaging shutter ttl', 'imaging aom ttl', 'repump aom ttl', and 'cam trig'.  The imaging AOM and the camera trigger should start at the same time of 6 s and last for 30 us.  The repump AOM should turn on for 30 us before the camera trigger and last for the same duration.  The imaging shutter should be raised 2.5 ms before the imaging pulse starts to give it time to open and should close at the same time that the camera trigger goes low.  A set of commands that would work for this purpose is below:

  > sq.find('imaging aom ttl').at(6,1).after(30e-6,0);
  > sq.find('cam trig').at(6,1).after(30e-6,0);
  > sq.find('repump aom tll').at(6,0).before(30e-6,1);
  > sq.find('imaging shutter ttl').anchor(6).before(2.5e-3,1).at(sq.find('cam trig').lastTime,1);

At the same time that these updates are occuring, one can set updates for other channels completely independently of the above set of commands.

For many experiments, however, it may be easier to consider the sequence as a set of sequential commands where the values for all relevant channels are set at each update time before a delay is added and new updates added at the delayed time.  A sequentially built process for the above behaviour might look like

  > sq.anchor(0);
  > sq.delay(6-2.5e-3);
  > sq.find('imaging shutter ttl').set(1);
  > sq.delay(2.5e-3-30e-6);
  > sq.find('repump aom ttl').set(1);
  > sq.delay(30e-6);
  > sq.find('repump aom ttl').set(0);
  > sq.find('imaging aom ttl').set(1);
  > sq.find('cam trig').set(1);
  > sq.delay(30e-6);
  > sq.find('imaging aom ttl').set(0);
  > sq.find('cam trig').set(0);

In this set of commands, I have started with the *TimingSequence.anchor(time)* command which sets the *lastTime* property for *every* channel to *time*.  Similarly, the method *TimingSequence.delay(time)* first finds the latest update time (when sorted chronologically) using *TimingSequence.latest()*, and then advances every channels' *lastTime* property by *time* (which can also be negative).

One can also mix-and-match the two paradigms (parallel and sequential) to harness the power of both.  One could write the above sequence as

  > sq.find('cam trig').at(6,1);
  > sq.find('imaging aom ttl').at(sq.find('cam trig').last,1);
  > sq.find('imaging shutter ttl').anchor(sq.find('cam trig').last).before(2.5e-3,1);
  > sq.find('repump aom ttl').at(sq.find('cam trig').last,0).before(30e-6,1);
  > sq.delay(30e-6);
  > sq.find('imaging aom ttl').set(0);
  > sq.find('imaging shutter ttl').set(0);
  > sq.find('cam trig').set(0);

## Uploading and running a sequence









