# Conconn

Concurrent connections benchmark fully programmed in [Elixir](https://github.com/elixir-lang/elixir).

Currently there is only a WebSockets test as it is the only one I have required to code. Feel free to add your own technology clients under *lib\client\your_client.ex* for example tcp, udp, http, etc.

To add a concurrency task just code it under *lib\conctask\your_task.ex*. For example, the task I coded for WebSockets is `EchoConcTask` (*echo.ex*), it will be completed when the received message is the same as the sent one. This would not be suitable for an http request, so it is up to your client requeriments the task you want to use.

# How to use it?

In the case of WebSockets there is already a task implemented:
```
mix bench.ws "ws://url..." --traffic <the number of messages> --clients <the number of clients>
```
The options 'clients' and 'traffic' can be omitted since they have default values

If you want multiple test through the command line utility this is the way:
```
mix bench.ws "ws://url-a..." --traffic <traffic A> --clients <clients A> -- "ws://url-b..." --traffic <traffic B> --clients <clients B> -- ...
```
The group is numerically assign starting from 1 for each task

You can manually enter `iex -S mix` with the `Conconn.Launcher` several `launch` functions to perform the benchmark. Using this technique you will be able to pick the client and the task, and even different ones per task group.

### Note

There is no configuration set yet for the output file, so every ran test results will be write down into a *./results.txt* file.