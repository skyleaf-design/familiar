#  Familiar
#### Status bar runner for LHVM-based programs

## What does this do?

It runs LHVM programs that target macOS, making available several Receptors and Perceptors that are specific to Familiar:

- Status bar UI inputs
- Status bar UI text outputs

## Wait, what does this actually do ...?

Say you author a program in the LiquidHex GUI, that runs against the macOS target within LHVM.  On the target machine, on the command line, you could immediately run that program with `lhvm myprogram.lhex`.

But wait!  There's nothing in the terminal!

That's because your program is running on the raw macOS "generic" host, which does not have access to stdin, stout, and sterr.  To make your program interactive on the command line, you'd need to change its target to macOS command line, which will give you access to command-line Receptors and Perceptors.  After inserting the Receptors and Perceptors at the appropriate places, you'd save the program, run it with `lhvm-cli myprogram.lhex`, and then interact with it, via the command line.

## ... So what does this actually do?

So far we've been talking about the command line, which has nothing to do with Familiar.  But I mention it, because it may help you understand that Familiar is one of many LHVM hosts.  And, you guessed it--the fact that Familiar is a host means that you can target it when you author your program.  After setting your LHVM host to Familiar, you will have access to GUI input and output elements, which live inside the little bird in your status bar.

## ... What... does.. this program... ... .. DO???

It's a little birdie that sits in your status bar, and allows you to run and interact with any LHVM programs you import into it.


## Sounds cool, but I don't see any evidence of LHVM in the source code...

That's because LHVM hasn't been built yet.  Familiar is a proof-of-concept that the LHVM Receptor->Transform->Perceptor model will work for a wide variety of applications.

Right now, **LHVM is faked**, and the stack is hard-coded into the source, using regular Swift constructs.

For now, Familiar waits for changes to your wifi connection, scans the git repos on your local machine, and lets you know if any of them are dirty, missing configuration, or have unpublished changes.  Maybe you enjoy this use-case... maybe you don't.  The point is that in the future, you will be able to run **any** LHVM program inside of Familiar, and you'll be able to create that program yourself, quickly and easily and reliably.

