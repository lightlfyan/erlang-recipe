origin: http://carpanta.dc.fi.udc.es/docs/erlang/dbg.html 

(This is fairly Unix-centric; there may be interesting debug facilities 
for the Windows user, but I don't know about them.) 

To begin with, there is a difference between knowing in advance that 
you want to debug something, and trying to find out in real-time what 
is going wrong. 

In the former case, you can prepare the code you are running in various 
ways, which will be discussed below; in the latter, you can only use 
what tools are present in the system. 

We'll begin with the latter case; i.e., assuming that you have a running 
Erlang system, which is misbehaving in some way, and you want to inspect 
it. 


* How Erlang was invoked 

In many situations when debugging, it is useful to know the exact 
way the Erlang system was invoked. If you add the option 
"-emu_args" to the "erl" command line, it will show you the full 
command line of the call to the Erlang emulator. 

* Finding out what is going on in a running system 

We assume here that you have an Erlang shell before you. If not, this 
may be because the Erlang system is running on a different computer, 
or not connected to a terminal. To gain access, read the section on 
subject further down. 

Apart from typing commands into the shell and have them executed, there 
are two other ways of getting the attention of the system. Typing ^C 
(i.e., sending SIGINT to Erlang) stops all activity [is this true?] 
and presents a number of alternatives to you: 

BREAK: (a)bort (c)ontinue (p)roc info (i)nfo (l)oaded 
       (v)ersion (k)ill (D)b-tables (d)istribution 

'a' exits the whole node. So does another ^C. 
'p' shows info about pids and ports. erlang:info(procs) does the same. 
'i' shows some general info about the system. erlang:info(info) does 
the same. 
Undocumented: 
'q' like 'a' 
'm' message info 
'o' port info 
DEBUG: 
't' timer wheel 
'b' bin check 
'C' does abort(), i.e., dumps core 

While the ^C break interaction takes place "outside" all Erlang process 
activity, there is another interaction level, which is synchronous 
with Erlang input: the ^G level. Typing ^G while an Erlang process 
is waiting for input from you presents this prompt 

User switch command 
--> 

and typing 'h' shows this command menu: 

  c [nn]   - connect to job 
  i [nn]   - interrupt job 
  k [nn]   - kill job 
  j        - list all jobs 
  s        - start local shell 
  r [node] - start remote shell 
  q        - quit erlang 
  ? | h    - this message 



What am I running? 
erlang:info(version) 
erlang:info(system_version) 
init:script_id() 
answer that question. 

* Accessing a running system 

telnet 
(kent) 

Distributed access 

** Interaction with the shell 

The usual result from a call is success and a return value; then 
the shell just presents it. 

If the call hangs, and you want to interrupt it and get back to the 
shell, use "^G i". 

If the call hangs, and you try "^G i" and it turns out that the shell 
died too, use "^G s c" to start a new one. 

Here is how to interpret the various messages that the shell may show 
you as a result of evaluating a call: 
** exited: Reason ** 
where Reason is whatever exit reason the process exited with. 

Apart from the shell's messages, there may also occur error reports, 
which either say the same thing, or give additional information (or 
are just a nuisance). See the section about error reports. 


When a function calls throw/1 and there is no active catch, the shell 
reports this as usual as: 
** exited: nocatch ** 
but it is possible to report the term which was thrown, and this may 
be done in a future Erlang version. 


** Post-mortem debugging of Erlang processes 

Usually, when an Erlang process dies, nothing can be said about it 
anymore. Other processes may have a pid which refers to it, but all 
attempts to use it either are no-ops, cause an exit, or return something 
uninformative like 'undefined'. 

Work is in progress on post-mortem debugging, which makes it possible 
to inspect the data areas of a process after it has exited. 

epmd 
Debugging epmd (has to be started debugged, but work is in progress 
to make it possible to turn on debug output when epmd is already 
running). 



* Error reports 

One classic debugging tool is trace output. If you have access to the 
source code of what you want to debug, insert calls which print out 
something interesting to the screen or a file. 

In Erlang, you can use the undocumented BIF erlang:display/1 for the 
purpose. It writes to stderr, thereby bypassing the normal I/O 
mechanisms of Erlang. Using io:format is often just as convenient but 
may hang when done in inconvenient places, since it involves message 
passing between a number of processes. 

Sometimes, calls to error_logger:error_report/[1,2] or similar 
functions are already in place, which means that an error report 
in a standardized format appears in a designated place. 

* Error handler 

The error handler handles calls to undefined functions. It is possible 
to install an error handler of your own. One exists 
(~arndt/erlang/ehan) which tries to find alternatives based on the 
assumption that there is a misspelling (or forgotten exportation). 

* Analysing crashes 

A special case is when your system has crashed. It can do this in a 
number of ways, but most will leave you with an Erlang crash dump, 
a Unix core dump, or both. (There is also something called a Mnesia 
dump, which I know nothing about, so I'll not mention it again.) 

A core dump is used for doing post-mortem debugging on the C code 
level. You need to start the debugger (gdb) and tell it the location 
of the Erlang system which produced the core dump. After this, you 
can do most of the things you can do while debugging a live system 
with gdb, with some exceptions. 

Among the exceptions are calls to debug functions; since there is 
no live process anymore, there is no context to execute the 
functions in. 

If the system seems hung, and you suspect it is looping internally, 
you may want it to produce both an Erlang crash dump and and a core 
dump. To do that, send the signal SIGUSR1 to it. 


* Debug facilities within Erlang 

Most Erlang terms which are really references to internal structures, 
such as ports, refs, funs and binaries, do not usually show much 
information when printed, but the I/O code for them can be made to 
show more: ports can be disinguished from each other, binaries are 
shown with their size, funs with their arity as well as module, and 
refs with their "unique" number. 

** BIFs 

These BIFs provide some interesting information about the system: 

processes/0 
erlang:ports/0 
registered/0 

statistics/1 
run_queue 
runtime 
wall_clock 
reductions 
garbage_collection 
* not documented: 
context_switches 
io 

process_flag/2 
trap_exit 
error_handler 
priority 
* not documented: 
pre_empt 

process_info/2 
(process_info/1 leaves out 'memory', 'binary', 'trace'; the latter two are 
undocumented) 

erlang:port_info/1 (undocumented) 
port_info/2 

erlang:info/1 
info 
procs 
loaded 
dist 
system_version 
getenv 
os_type 
os_version 
version 
machine 
garbage_collection 
instruction_counts  (BEAM only) 

erlang:db_all_tables/0 
erlang:db_info/2 

Not BIFs: 

ets:all() 
Table = {Name_or_number, Owner} 

** minor things 

The source code to the small utilities described next can be found 
in d.erl in this directory. 

** seq trace 

** The Erlang debugger/interpreter 

** pman 

** Hans Nilsson's graphic process display 

** appmon 

** proc_lib 

** process:trace 

A simple-minded but useful tracer for Erlang processes: 
c("/home/gandalf/arndt/erlang/tracer"). 
tracer:trace(Pid_to_trace). 

** Klacke's top? 

~klacke/erlang/top. 

** Message size statistics 

Work in progress. 

** Instrumented Erlang 

erl -instr 
runs a special version of the emulator, and enables the functions 
in the module 'instrument'. You can take a snapshot of the 
allocated memory blocks and see what kind of blocks they are. 

Mattias has written a program (for Windows) which collects and displays 
the memory information graphically. 

** Configuring applications 

Some applications read the values of application environment variables 
to adjust their behaviour. Some of those may be useful when debugging, 
such as adjusting timeouts upwards, or enabling trace output. 

Example:    -kernel net_ticktime 3600 

Some applications contain debugging calls in the source code, which 
are normally turned off, but can be enabled by making a small change 
to the source code and recompiling (or perhaps just define an appropriate 
macro on the compiler command line). 


* Report Browser - error logs - rb(3) 

* Command-line options 

The following command-line options are useful for debugging: 

+v   verbose (only active when compiled with DEBUG) 
(enables the "VERBOSE" C macro) 

+l   auto-load tracing 

+debug   verbose (only active when compiled with DEBUG) 
(enables the "DEBUGF" C macro) 

+#   sets amount of data to show when displaying BIF errors 
from the JAM emulator. Almost worthless, since default 
is 100. 

+p   progress messages while starting (enables the erl_progressf 
C function) 

-emu_args 

On Windows, -console is useful. 

* Environment variables 

ERLC_EMULATOR is useful to set, when you don't understand what the 'erlc' 
command is doing. 

ERL_CRASH_DUMP defines the name of the file to write an Erlang crash 
dump to. 

* C code debugging 

If you have access to the C source code, you can compile a version 
of Erlang for debugging. 

This causes some extra information to be emitted occasionally, and 
also allows you to set variables at runtime (using gdb) which will 
produce more output. 

... 


* Static analysis for Erlang 

If you have reason to believe that there is a bug somewhere in your 
Erlang program, it is probably worth while to subject the source code to 
the available static analysis tools: 

check calls for format-like functions (this tool is being written) 

compile with warnings turned on (or use erl_lint) 

exref can be helpful. 

** Type checking 


* Static analysis for C 

Turn on compiler warnings. 

* Dynamic analysis for C 

Use purify. 

* Debugging with gdb 

cerl -gdb 
r ... 

#define BIF_P  A__p 
#define BIF_ARG_1  A_1 
#define BIF_ARG_2  A_2 
#define BIF_ARG_3  A_3 

The command "show args" is useful. 

(gdb) sig 2 
sends a ^C to Erlang 

To invoke a function within Erlang, do, for example 
(gdb) p td(A_1) 

char *print_pid(Process *) 
ptd(Process *, uint32) "paranoid" 
BEAM:   pps(Process*, uint32 *stop) "paranoid" 
dbg_bt(Process*, uint32 *stop) 
dis(uint32 *address, int instructions) 

DEBUG: 
pat(uint32 atom) 
pinfo() 
pp(Process *p) 
ppi(uint32 process_no) 
td(uint32 term) 
JAM:    pba(Process *, int arity) 
ps(Process *, uint32 *stop) 
bin_check() 
check_tables() 
db_bin_check() 
p_slpq() 

HARD_DEBUG: 
check_bins 
chk_sys 
stack_dump 
heap_dump 
check_stack 
check_heap 
check_heap_before 

* Debug-compiled Erlang 

compile with these flags defined 

DEBUG 
HARDDEBUG 
MESS_DEBUG 
OPTRACE 
GC_REALLOC 
GC_HEAP_TRACE 
GC_STACK_TRACE 
OLD_HEAP_CREATION_TRACE 
... 

Only enabled when DEBUG: 

erl +v   (verbose = 1) 
       VERBOSE(erl_printf(COUT, "System halted by BIF halt(%s)\n", msg);); 

erl +debug   (debug_log = 1) 
      DEBUGF(("Using vfork\n")); 




附上erl_debug.h 里面gdb用到的常用的函数： 
void upp(byte*, int); 
void pat(Eterm); 
void pinfo(void); 
void pp(Process*); 
void ppi(Eterm); 
void pba(Process*, int); 
void td(Eterm); 
void ps(Process*, Eterm*); 
