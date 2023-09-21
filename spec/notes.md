- for minimal logic we should adjust to the way how ansible does it (they have yml files with additional logic like loops, if conditions, etc.)
    - see [here](https://github.com/ansible/ansible/tree/devel) for ansible repo
    - https://github.com/ansible/ansible/blob/676b731e6f7d60ce6fd48c0d1c883fc85f5c6537/lib/ansible/playbook/loop_control.py loop control
    - [this is where the loop is essentially executed](https://github.com/ansible/ansible/blob/676b731e6f7d60ce6fd48c0d1c883fc85f5c6537/lib/ansible/executor/task_executor.py#L261-L408)

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
