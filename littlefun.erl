-module(littlefun).
-compile([export_all]).

start() ->
    S = "1+2*3+4*5+6+7",
    io:fwrite("~p", [torpn(S)]).
    
torpn(S) ->
    lists:flatten(rpn(S)).
    
mrpn(L) -> [rpn(E) || E <- L].
    
rpn([A, $+, B, $*, C | D]) -> rpn([mrpn([A, B, C, $*, $+])|D]);
rpn([A, $+ , B | C]) -> rpn([mrpn([A, B, $+])|C]);
rpn([A, $+, B]) -> [A, B, $+];
rpn(A) -> [" ", A, " "].
