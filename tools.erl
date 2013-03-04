-module(tools).
-author("lightlfyan").

-compile(export_all).

%% @doc test1 测试
-spec test1() -> ok.
test1() ->
    % A simple Call Count Profiling
    cprof:start(),
    _Pid  = goddess_srv:start_link(),
    sleep(3000),
    cprof:pause(),
    Info = cprof:analyse(goddess_srv),
    io:format("~p~n", [Info]),
    cprof:stop(),
    ok.

%% @doc test2
-spec test2() -> ok.
test2() ->
    fprof:trace(start),
    _Pid  = goddess_srv:start_link(),
    read_normal("game.config"),
    % read_bin("game.config.bin"),
    fprof:trace(stop),
    fprof:profile(),
    % sleep(3000),
    % file:delete("fprof.profile"),
    fprof:analyse({dest, "fprof.profile"}),
    file:delete("fprof.trace").

test3() ->
    {ok, _Pid} = eprof:start(),
    Pid  = goddess_srv:start_link(),
    eprof:start_profiling([Pid]),
    sleep(3000),
    exit(Pid, kill),
    eprof:stop_profiling(),
    eprof:log("eprof_procs.profile"),
    eprof:analyze(procs),
    eprof:log("eprof_total.profile"),
    eprof:analyze(total).

test4() ->
    pp_beam_to_str("goddess_srv.beam").

%% @doc beam to source code, the beam need have debug info
-spec pp_beam_to_str(list()) -> {ok, list()} | {error, list()}.
pp_beam_to_str(F) ->
    case beam_lib:chunks(F, [abstract_code]) of
        {ok, {_, [{abstract_code,{_,AC0}}]}} ->
            AC = epp:restore_typed_record_fields(AC0),
            {ok, lists:flatten(
                io_lib:fwrite("~s~n", [lists:flatten([erl_pp:form(Form) ||Form <- AC])]))};
        Other ->
            {error, Other}
    end.

sleep(Time) when is_integer(Time) ->
    receive
    after Time ->
        ok
    end.

%% @doc read binary is faster
cover_file2bin(FileName) ->
    {ok, Context} = file:consult(FileName),
    NName = FileName ++ ".bin",
    file:write_file(NName, erlang:term_to_binary(Context)).

read_normal(FileName) ->
    {ok, Context} = file:consult(FileName),
    io:format("~p~n", [erlang:binary_to_term(Context)]).

read_bin(FileName) ->
    {ok, Context} = file:read_file(FileName),
    io:format("~p~n", [erlang:binary_to_term(Context)]).
