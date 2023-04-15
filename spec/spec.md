# Specifications for wm2


## wm2

1. wm2 is a minimalistic, lightweight software for live audio programming which utilizes a graph/cue model of DSP.
2. wm2 aims to avoid obsolescence as good as possible.
3. wm2 aims to be as efficient as possible.
4. wm2 aims to be testable by an automatic test runner (this includes both the core source code and user defined patches).
5. wm2 aims to be very robust e.g. aims to never break during performance time.


## Architecture

1. wm2 MUST be used by defining a wm2 patch.
2. A wm2 patch MUST consist of a graph and a set of cues.
3. The graph describes the connection of different (DSP) modules.
4. The cue set contains cues which describe active modules at a given moment.
5. The rationale for this limiting architecture is efficiency. By splitting DSP into active and inactive modules via cues we can ensure lower CPU usage and therefore better support for weak, old hardware.


## (DSP) module

1. A (DSP) module is a small program.
2. A (DSP) module MUST be active (proceeding) or inactive (don't use CPU).
3. A (DSP) module CAN be configured by receiving configuration parameters at initialization time (init time parameters) and by receiving runtime configuration parameters during run time (runtime parameters).
4. The runtime configuration parameters MUST have default values which CAN be configured at initialization time.
5. The configuration parameters of runtime configuration and init time configuration MUST differ and never share any attribute.
6. A (DSP) module MUST have N inputs and N outputs where 1000 > N >= 0.
7. An input MUST point to the output of another (DSP) module.
8. An output CAN point to the input of one ore more other (DSP) modules.
9. An input or an output MUST be explicit or implicit.
10. An explicit input or output MUST be only active if a cue explicitly states that this (DSP) module is active.
11. An implicit input or output MUST be active if either a cue explicitly states that this (DSP) module is active or if the (DSP) module which point to this (DSP) module has been explicitly or implicitly activated.
12. The purpose of implicit modules is to simplify cue programming, so that users only need to specify relevant active parts within their cue and not the whole DSP chain.
13. The purpose of explicit modules is to avoid accidental activation of (DSP) modules which aren't needed.


## Inputs and outputs

1. An input or an output MUST be either an audio input or output or a control signal.

XXX: is this really necessary? With pyo we didn't need this, but Csound specifies two different types. Are we then
     relying too much on our audio backend? On the other hand Csound can improve efficeny by using a lower rate for
     control signals than for audio signals, so this might be good for efficeny.

2. A input or output MUST have multiple streams or only one stream.

XXX: So this is again pyo specific: a pyo object could have multiple inputs/outputs and effects always work no matter
     how many channels our audio signal has. Because of this, old walkman modules only had exactly one output, because of this
     one output could have had multiple audio streams. But with this new definition we can have multiple inputs/outputs.
     So for instance a module could have two audio outputs and a control signal output.
     I think for programming patches it's much simpler to only think in N-stream audio signals.
     On the other hand it gives a higher flexibility to think that we *could* pass the second stream of an audio channel
     to a different effect than the first stream of an audio channel (but I don't know if it ever helps in practice).
     Hint: Csound uses "chnset" and "chnget" to send/receive inputs/outputs between instruments.



## (DSP) module definition

1. A (DSP) module MUST be defined by using YAML.
2. This makes the public API very clear: all parts which can be user defined MUST be written in yaml. Those yaml files MUST support the same format as long as possible and they shouldn't break. The python part on the other hand can change because it's not part of the public API.
3. Some special module classes are excluded from (1). They are predefined and can't be changed by the user.

Hint: yaml supports multiline strings, so we can write csound code within yaml. This sounds much better
      than using external text files or python strings to write the csound code. Then this csound code can assume
      that there are some predefined variables as { aInput0, aInput1, kInput0, ... }, depending on the provided values
      to other arguments of the module definition (audio-input-count, ...). This csound code also needs to define
      specific variables as { aOutput0, aOutput1, ... }, otherwise the code is considered to be malicious and won't
      be executed.


## Cue

1. A cue MUST be active or inactive.
2. A cue MUST describe which modules of the graph are active if the given cue itself is active.
3. A cue MUST be automatically testable.


## Cue testing

1. A cue must be tested by checking whether it produces the expected results.


## Cue grid


## TUI

1. wm2 runs in a terminal user interface (TUI) like htop, vim, etc.
2. Within this TUI the user can select cues to be played and run basic input/output tests. The TUI also provides logging.


## Sequencing



## Configuration

1. A wm2 patch is defined by four YAML files.
2. The first YAML file is a definition of global constants. They are accessible from all other configuration files.
3. The second YAML file is a set of (DSP) module definitions.
4. The third YAML file is the definition of the (DSP) module chain e.g. the graph part.
5. The fourth and last YAML file is the definition of cues.
6. Only a wm2 patch which provides all four files is considered to be complete and usable.
7. To simplify this requirement wm2 provides default files for global constants and (DSP) module definitions.


## Dependencies

1. wm2 aims to use as few dependencies as possible.
2. The used dependencies must already exist for a long time and must be likely to continue to exist for a long time in the future.
3. We therefore want to use Csound for audio programming part, ncurses for TUI part and python with ctcsound and StrictYaml as the glue/logical top layer part.


