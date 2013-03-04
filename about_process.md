#### find which one consume memory


```erlang
	
	erlang:memory(). 
	
	spawn(fun() -> etop:start([{output, text}, {interval, 1}, {lines, 20}, {sort, memory}]) end).
	
	erlang:process_info(Pid).
	
	erlang:grabage_collect(Pid).
```
