
# cue polyphony

- we may need a cue polyphony to solve multiple problems
    - sequencing should also work with the cue system to gain the advantages of
      partial de/activation of DSP modules
    - some cues should be allowed to run while another cue is started (simultaneous usage
      of two different cues

- this needs a cue polyphony:
    - so we need to have a cue manage which support multithreading
    - perhaps we need locks, so the activiation of CUE B doesn't interrupt the activation of CUE B

---

# wm2 necessities for a sane usage:

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
