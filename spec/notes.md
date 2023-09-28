# gui view

- maybe the gui could be composed of 3 windows:

    - left:     grid view
    - right:    island view
    - bottom:   logs

the 'island view' is just an empty canvas, which could be filled with anything, e.g.

    - a volume meter
    - a printing of the connected islands (DSP graph view)
    - a text telling us something
    - ...

then we could also define GUI elements with islands, for instance

- a specific island type to display incoming midi messages
- a specific island type to meter volume (and just any input csound island is ok)

then not each csound module would need to be able to log its data, but a csound
module could be send to a another gui csound meter island, with which we can check the
data..this makes everything even more generalized, so i think it's a very good idea.

# explicit play

in wm1 play was difficult to understand because of its implicity:
if an object was playing, the 'play' method didn't affect anything.

- maybe we can simplify this, so that the objects state doesn't matter?
- or we could make it explicity:
    - ``force-play-if-playing: bool``



# package structure


(basic question: how to retrieve global objects as csound backend, islands dict, island type dict, ...?)

should we split patch and global state?

so that we have a global audio/midi state and we can load patches as we like?

this makes things more complicated, so let's first avoid it.

but then it's still a question:
because if we can have multiple patches the csound server isn't part of the
patch but part of the global program state.

and maybe it's not really more complicated, but makes things a bit cleaner/clearer,
increases flexibility and tackles real situations:

we could drop parts of the patchs configurations settings and instead
have a dedicated "config" part, which configures the running wm2 software.

then "wm2" could start csound and more before it loads the actual patch, this
could help preventing some bugs.

so the wm2 cli would be:

    wm2 --config $config --patch $patch $patch-globals

where the globals could be used for mustache in patch.

and maybe we should indeed also move the definitions.yml to a dedicated file?

    wm2 --config $config --patch $patch --patch-globals $globals

the thing is, regarding the "one-file-approach": this approach is still true,
as all the user defined things (except of audio config) that were part of one file
in wm1 are STILL PART of only one file, because all the things like DEFINITIONS were
impossible to define in a wm1 toml file!!


    wm2 --config $CONFIG --yml-def $DEFINITION --init-patch $PATCH $PATCH_GLOBALS

and maybe $DEFINITION can either be a YML file OR a python file:

    - in case of yml file:      parse the island definitions
    - in case of python file:   load the python file

or maybe not, I think it's a bad idea :)

maybe we can add a parameter in the "config" for python extensions?

```
configure:
    sampling-rate:
    ...
    extensions:
        - my-extension
```

and then wm2 automatically loads the module "my-extension":
when loading "my-extension" this "extension" should then include
island definitions.

maybe "wm2" can log how many island types existed before "my-extension"
was loaded and how many island types exist afterwards :)

```
class WM2:
    def __init__(
        self,
        config: str | Config,
        yml_def: Optional[str | YmlDef] = None,
        patch: Optional[Patch] = None
    ):
        ...
        initialise...
        ...
        self.load_patch(patch)

    def run(self):
        ...
```

in python started wm2:

```
import wm2
wm2.WM2("config.yml", patch="patch.yml").run()
```


wm2             =>

                        => hosts global program state
                            => current patch
                            => csound backend
                            => gui
                        => gateway into wm2 open/close
                        => .load_patch(patch: Patch)
                            => can be successful or unsuccesful, but program doesn't exit,
                               only warnings are printed


patch           =>
(object)
                        => yml/mustache parser
                            => global variables (for mustache)
                            => island definitions
                        => contains patch data:
                            => defined islands


global api      =>

                        => get_island_type_dict()
                        => get_csound()


islands         =>
(abc, register)         => orchestrator (request_play, request_stop)
                           judge (judge, accept, reject)
                        => dummy
                        => csound
                        => cues
                        => sequencer



gui             =>

                        => grid view
                        => logger
                        => extra-commands (test audio, test midi, ...)
                        => volume meter


cli             =>

                        => program start => simple wrapper for "wm2.WM2.run(..parameters..)"


# yml + mustache

this really seems to be the best combination, it's also better to use mustache, instead
of defining custom logic in yml, because:

- we need a special syntax to indicate the state anyway
- the differentiation between config + logic is very clear
- it's less work and therefore less mistakes

# patching mustache

but we may need to patch mustache in order to allow some additional behaviour:

(we may do so by monkey-patching mustache parser code)

- range like functions could be added ad-hoc:
    - users could write {{#range-10}} and then in the parser, if mustache can't find it, we can patch it so that if not defined, define it and restart
- imports of files should perhaps be relative paths
- imports of files should respect the current indentation:
    - this may be the most difficult todo
    - imagine a yml like this

```
islands:
    {{>csound-modules.yml}}
    {{>cues.yml}}
```


and then `csound-modules.yml`:

```
sine:
    example:
        frequency: 440
mixer:
    master:
        audio-input-0: "sine.example"
```

and then `cues.yml`:

```
cue:
    example:
        islands:
            sine:
                example:
            mixer:
                master:
    silent:
        islands:
            mixer:
                master:
```


the final file should look like:


```
islands:
    sine:
        example:
            frequency: 440
    mixer:
        master:
            audio-input-0: "sine.example"
    cue:
        example:
            islands:
                sine:
                    example:
                mixer:
                    master:
        silent:
            islands:
                mixer:
                    master:
```

so that the 4 line spache of the mustache tag should indicate,
that the imported file must also be adjusted.




# defining islands

in wm1, users could define custom modules by defining a module in the namespace package 'walkman_modules':
the defined modules were implicitly loaded to the list of available modules.

in wm2 we should rather choose a more explicit and simpler approach:
wm2 should offer a 'register_island_type' function, with which a class could
be decorated (or called) and then this island_type would be added to the list of known
islands types.


# defining islands 2

for csound islands, the initial spec assumes that it's possible to define island types within the yml configs:


```
compressor:
    audio-input-count: 1
    audio-output-count: 1
    control-input-count: 1
    # They can be set at graph definition
    init-args:
        iRatio: 3
    # They can be set at cue definition
    runtime-args:
        iThreshold: 0
        iLowKnee: 40
        iHighKnee: 60
    csound: |
        kRatio = kInput0
        aOutput0 compress aInput0, aInput0, iThreshold, iLowKnee, iHighKnee, kRatio
    doc: |
        This module ueses the compress opcode of csound.
        You can compress your signal with this module.
```

that's indeed nice, but could this fit into the more generalized island-model which we approach here?

# yml

btw there is a problem if we define island instances like this:


```
cue:
    b_0_00:
        islands:
            convolution_reverb.b_reverb_1:
    b_0_14:
        islands:
            pitch_shifter.b_pitch_shifter:
            convolution_reverb.b_reverb_1:
```


cue:
    sine-and-noise:
        islands: ["cs.sine", "cs.mixer", "cs.noise"]
    sine-only:
        islands: ["cs.sine", "cs.mixer"]

if...

- we want to add somewhere else in the config file another 'island' to a cue    => this is impossible.
- we want to add in another file more cues                                      => this is impossible

because keys are only allowed to be defined once!

so maybe we would need a different approach.
perhaps this different approach is necessary anyway, because of the generalization of cue/module to island
and because of the single-file-approach.


1. genereally: use lists instead of plain keys, if things should be redefineable

=>

    a wm2 config file is a list of dict, and not a dict (like wm2 config file)

```
- ...
- ...
- ...
```


```
(def-cue
    (sine (sine mixer))
    (noise (noise mixer)))
```

why yaml and not scheme?
because it's too much perhaps?

```
- def-cue
```


LISTS is also ugly, because if you have a command (like 'define X')
the dict in which the command resides could also contain more commands,
it just doesn't make sense :)


=>=>

maybe it should really just be like this:


```
$ISLAND_NAME:
    $REPLICATION_KEY:
        $INIT_ARG_NAME: $INIT_ARG_VALUE
```

('grid-index' and 'offset' are also just normal init args)

and what's about global configuration and csound island type definitions?
what's about:

```
configure:
    ...

islands:
    ...

definitions:
    ...
```

```yml
configure:
    audio: "jack"
    sampling-rate: 44100
    name: "test200"

islands:
    # module definitions
    cs-sine:
        0:
            frequency: 440
    cs-noise:
        0:
    # cue definitions
    cue:
        sine:
            cs-sine.0:
            mixer.master:
        noise:
            cs-noise.0:
            mixer.master:
```


=>=>
    maybe wm2 allows to load multiple patches?

but the restrictions with no double keys are
actually not so bad, i think!
they simplify a lot of things...


=> instead of allowing multiple patches, we
   may add a special "import-file" keyword, which imports
   a file at whatever position:


```yml

islands:
    cue:
        !load section-0.yml:
        !load section-1.yml:
```


```section0.yml
section0-cue0:
section0-cue1:
```

```section1.yml
section1-cue0:
```

etc.

# curses libraries

curses is very low level and a lot of work to write something useful, why don't use

- https://github.com/urwid/urwid
    - http://urwid.org/reference/widget.html?highlight=bar#urwid.BarGraph
    => this seems to be the best, widely developed, not too big, but a sufficient amount of widgets

- https://github.com/pfalcon/picotui
- https://github.com/peterbrittain/asciimatics



- https://github.com/pfalcon/pycopy btw :)



# islands

instead of defining 'cues' and 'modules', we should simply define islands.
an island has a position in the grid. an island could be anything:

- a dsp module
- a meta island, that controls other islands (e.g. a 'cue' or a 'sequencer')
- a program which sends data to an arduino
- ...

so we generalize all of these different data types into one general data type,
which has methods of

    - play
    - stop
    - ...?

with this we also have a single interface how to control these data types in
the gui: all of them are one point in the grid and can be activated/stopped by
pressing them. easy and simple.

# sequencer as island

so a sequencer is simply an island which receives as a runtime argument a path
to a file which consists a list of events, where each event is defined of:

    - island-to-activate-name, duration, runtime-arguments-for-the-activated-island

that's it :)

# single file approach

wm1 had this very simple 'single-file-approach'.
in fact this simple approach was very helpful, because it made it extremely flexible,
as - with the help of jinja - it actually meant: an infinite/self-decided number of
files approach. we should stick to this instead of telling the user a specific
file structure.

# csound vs. pyo ('manual mode'): unit testing

in pyo we can pass the 'manual mode' to the audio server:
with this 'manual mode' we can run the DSP and control whenever
an audio cycle should be proceeded, this is extremely valuable for
unit tests, as it allows us to check if a module is playing/not playing as
expected, so it's a possibility to test audio in a unit test (which is otherwise
more or less impossible, as far as I can see..)

Does something similar exist for csound?

=> maybe the same thing can be archived, by writing the sound file to disk
   and checking if a sound exists at a certain time? but this seems to be
   less easy.. generally it'll be more difficult with csound, as we can't simply
   ask for the current sample/amplitude at a random moment..

=> actually it's also possible to control csound to only process one buffer/ one control cycle:

    https://csound.com/docs/ctcsound/ctcsound-API.html#ctcsound.Csound.performKsmps

    combined with non-realtime mode, we may indeed do unit tests with csound

=> what i'm more concered with is: in ``10.1`` i used pyo to control the timing
   to send data to my arduino.

   so there was a walkman module which, when activated, send data to the arduino:

    https://github.com/levinericzimmermann/project/blob/10.1/walkman_modules.aeolian/walkman_modules/aeolian/__init__.py#L174-L340

   this module was based on the python class "Protocol":

    https://github.com/levinericzimmermann/project/blob/10.1/walkman_modules.aeolian/walkman_modules/aeolian/__init__.py#L72-L107

   if we move timing to csound, is something like this still possible?

=> i mean a module wouldn't need csound code, would it? maybe this
   would only be a "CSModule" => a "CSoundModule".

=> but this module which played the arduino could be a "ARDModule" and "ArduinoModule"

=> the question is only: how would timing then work? because this is currently controlled
   by pyo. i think this is kind of the fundamental problem when switching to csound..

=> => csound would only be responsible for the DSP, but not for the time: another software
      would need to be responsible for this. which software would this be?

      => perhaps we **can** do this in python, we only need to have a better sleep method:

        => sleep is imprecise and will always be
        => once we slept and want to sleep the next time, we check how much time passed
           between the first sleep and if it's longer we sleep shorter to avoid the swing:
           in this way we have a higher precision.
        => not sure how the api of such a process would look like though, maybe something
           like a metro?
        => it's in fact only problem for a sequencer, and a sequencer works by
            - [playing an event, waiting], playing the next event
            - it knows the durations of the previous event and fix the drift
            - it's also a problem that the processing until the waiting takes to long,
              so we'd also actually need to wait shorter

---

# cue polyphony

- idea: we can define

    - a cue             ==  a system state
    - a cue manager     ==  a system state
    - delta cue         ==  difference between 2 system states

    => so we can understand the 'graph' as the system and the current in/active modules as a state of this system


- we may need a cue polyphony to solve multiple problems
    - sequencing should also work with the cue system to gain the advantages of
      partial de/activation of DSP modules
    - some cues should be allowed to run while another cue is started (simultaneous usage
      of two different cues

- this needs a cue polyphony:
    - so we need to have a cue manage which support multithreading
    - perhaps we need locks, so the activiation of CUE B doesn't interrupt the activation of CUE A
    - then, whenever a cue is activated it's checked:
        - is this module still needed by any cue? => if no cue exists anymore which needs this module, deactivate it
    - how would we check that two cues don't control the same modules?
        - because this certainly needs to be prohibited
        - maybe each module has a lock, and as long as one cue holds
          a module, another cue can't hold it?
        - but this would only be the-last-resort safety check, if the cue manager
          finds two cues that aim to control the same module
        - it would be better to entirely disallow the activation of two
          cues that control the same modules
        - on the other hand this seems to be unavoidable: imagine
          two different cue-families, where the first family controls
          synth A and the second cue family controls synth B, but both
          synths are outputting to the main mixer output: so both cue
          families actually want to start the main mixer. now this would
          already be a conflict, how could it be solved then?
        - perhaps the difference is between cues that change the RUNTIME
          parameters of a module and cues that don't change the RUNTIME
          parameters of a module. or maybe more precisely: **if two cues
          set a module to the same RUNTIME parameters, they can run
          simultaneously.**
        - not sure if this last point is true (what about two cues that
          want to start a sound file?), but it seems quite good, maybe
          corner cases which contradict this understanding can be ignored..
          in the end it's still the users responsibility to avoid starting
          two contradicting modules.

        - maybe it's not even problematic if two cues control the same module
          with different parameters, as it's always a sequential process: first
          cue X activates the module with parameters A, and then cue Y activates
          the module with parameters B: what's kind of problematic is that the
          system state is no longer what CUE X expects to be, so it's on, but kind
          of pointless, and it depends on wehter CUE X or CUE Y is faster, so it's
          kind of a race condition which system state is true, so in fact it
          is kind of problematic and may lead to bad bugs!

        - so maybe the "Orchestrator" should have a state:

            module_info = (module_name, module_state (runtime_args), cue_list)

            where 'cue_list' consist of all cues that asks for the activation of
            thos module.

            => it's clear than that a module can only have exactly one state/runtime
               args, which must be okay for all cues in 'cue_list', otherwise we have
               a problem

            => if a cue is activated with contradicting data, a warning is raised,
               the cue won't be added to the modules 'cue_list' and that's it :)

        - in a way, WM2 can be understood as a DPS module orchestrator, at
          least the part of the 'cue manager' (maybe it should be renamed to
          'Orchestrator').

    - i wonder if it's possible to implement this so fast to still avoid
      long delays between various cues: if we really want to make a sequencer
      with cues, so we are talking about the note-level speed, and now imagine
      two sequencers playing very fast melodies, 160 BPM, and the cue orchestrator
      needs to be run at each new note (running all the checks about which module can
      be activated etc..), this needs to be quite fast, particularly because we need
      to do some stuff with locks / not concurrently..
        
    - btw: if we talk about AUTOMATIC NOTE-LEVEL sequencing, this may be impossible
      to do with pure python, because this needs to be precise miliseconds time, and
      pythons builtin time module IS DRIFTING! therefore with pure python, MODULE
      SEQUENCING ON NOTE LEVEL WON'T WORK!


- cue playing other cues:
    - but here it seems to be important that a cue, which
      plays other cues, can't be started from lower cues:

      so cue 1 plays

        cue 2a
        cue 2b
        cue 2c

      so none of the cue2 family of cues can start/stop
      cue 1 in order to avoid strange bugs.

      so maybe there is something like a 'cue hierarchy',
      which prevents cues of the lower level to control
      cues of the higher level. cues on the same level can
      neither control each other.

      maybe it's sufficient here to specify a 'level' parameter:

cue:
    2a:
        level: 2

---

# wm2 necessities for a sane usage:

- automatic protection of too loud signals

- gui master volume setter

- option for gui view of each module input/output level (meter)! 

- audio output/input tests!

- midi output/input tests!

- allow debug messages

- visualisation of graph

---


# yml loop

- for minimal logic we should adjust to the way how ansible does it (they have yml files with additional logic like loops, if conditions, etc.)
    - see [here](https://github.com/ansible/ansible/tree/devel) for ansible repo
    - https://github.com/ansible/ansible/blob/676b731e6f7d60ce6fd48c0d1c883fc85f5c6537/lib/ansible/playbook/loop_control.py loop control
    - [this is where the loop is essentially executed](https://github.com/ansible/ansible/blob/676b731e6f7d60ce6fd48c0d1c883fc85f5c6537/lib/ansible/executor/task_executor.py#L261-L408)


=> there is real problem with loops in yml:

    if in wm2 a stream can't have infinite audio channels (as it used to be in wm1,
    because of pyo, which allowed this) & each module needs to have a static amount
    of mono audio output/inputs, LOOPS in YML (in the dsp/graph definiton) become
    extremely important, because consider:

    - we have a signal/module with 10 channels
    - we want to apply compressor on this
    - we will most likely do this with a loop

    => unfortunately, in the current examples we can always only make one
       loop per module declaration, see for instance

        ```yml
        compressor:
            {{ i }}:
                audio-input-0:
                    audio-input:
                        - {{ i }}
            loop:
                - 0
                - 1
        ```

        this is only one loop,
        yaml also doesn't allow the same key twice (e.g. we can't
        use compressor again somewhere else)


    => => => THIS MEANS: WE NEED A DIFFERENT SYNTAX FOR LOOPS, THAT ALLOWS
             MULTIPLE LOOPS FOR EACH MODULE DEFINITIOn


    => => => BTW: ``range`` is missing so far, we would certainly also need this :)


does this mean we should better use jinja2 again? i don't know...


## template languages

- https://mustache.github.io/mustache.5.html this looks minimal, but maybe not sufficient?
    - it has sections for 'logic': http://mustache.github.io/mustache.5.html (see "sections")
        - it *does* support something like "a minimal if clause"
        - it also *does* support something similar to a loop
    - https://github.com/noahmorrison/chevron
    - wenn du eine sprache benutzt, dann DEFINITIV MUSTACHE:
        - weil DAS IST IN 30 UNTERSCHIEDLICHEN SPRACHEN IMPLEMENTIERT UND
          ES GIBT EINE VON DER IMPLEMENTIERUNG GETRENNTE SPEZIFIZIERUNG
          (die sich wahrscheinlich nur selten aendern wird :)
        - https://en.wikipedia.org/wiki/Comparison_of_web_template_engines

        - leider gibts kein ranges.. :(


- https://handlebarsjs.com/ => das ist ein erweitertest mustache


=>=> bei allen templating languages wird es immer das problem sein:

    -> dass die nutzer daten in 2 unterschiedlichen sprachen geschrieben werden: yml und der darauf gelegten sprache
    -> dass es mehr dependencies gibt

=> der vorteil ist: ich muss weniger denken und programmieren :)
=> und es gibt ja auch noch andere logiken, die ich brauechte, neben loops:

    - imports (for instance to differentiate between various cue sections)
    - if/else clause
    - loops
             
=> vielleicht ist es daher doch einfacher, wenn alles am ende einfach nur eine grosse datei
   ist und die imports/ifelse/loops von einer template sprache geloest werden.

---

# consider using scheme instead of python

because it's longer available :), much simpler & smaller (better permacomputing properties)

## ncurses python alternative

gnu guile has a package for ncurses:

   https://www.gnu.org/software/guile-ncurses/manual/guile-ncurses.html 

## ctcsound alternative

we can control csound by stdin:

    https://flossmanual.csound.com/csound-language/live-events

    Using A Realtime Score
    Command Line with the -L stdin Option

    If you use any .csd with the option -L stdin (and the -odac option for realtime output), you can type any score line in realtime (sorry, this does not work for Windows). For instance, save this .csd anywhere and run it from the command line:


## strictYaml alternative

i don't know :)
