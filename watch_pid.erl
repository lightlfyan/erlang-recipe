-module(watch_pid).

-compile([watch/1]).

watch(Pid) ->
    error_logger:logfile({open, 'tmp.log'}),
    spawn(?MODULE, watch_pid, [Pid]).

watch_pid(Pid) ->
    receive
    after 2000 ->
        RN = erlang:process_info(Pid, registered_name),
        {message_queue_len, MQ} = erlang:process_info(Pid, message_queue_len),
        {status, ST} = erlang:process_info(Pid, status),
        {total_heap_size, TS} = erlang:process_info(Pid, total_heap_size),
        {reductions, RD} = erlang:process_info(Pid, reductions),
        case MQ > 10 of
            true ->
                error_logger:info_msg(
"Srv: -----------: ~p~n
message_queue_len: ~p~n
           status: ~p~n
  total_heap_size: ~p~n
       reductions: ~p~n", [RN, MQ, ST, TS, RD]);
            false ->
                ok
        end,
        watch_pid(Pid)
    end.