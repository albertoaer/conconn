# Conconn

Concurrent connections benchmark fully programmed in [Elixir](https://github.com/elixir-lang/elixir).

Currently there is only a WebSockets test as it is the only one I have required to code. Feel free to add your own technologie clients under *lib\client\your_client.ex* for example tcp, udp, http, etc.

To add a concurrency task just code it under *lib\conctask\your_task.ex*. For example, the WebSockets task is `PingPongConcTask` (*ping_pong.ex*), it will be completed when the received message is the same as the sent one. This would not be suitable for an http request, so it is up to your client requeriments.

# How to use it?

In the case of WebSockets there is already a task implemented:

```
mix bench.ws "ws://url..." --traffic <the number of messages> --clients <the number of clients>
```
The options 'clients' and 'traffic' can be omitted since they have default values.

You can manually enter `iex -S mix` with the `Conconn.Launcher` several `launch` functions to perform the benchmark. Using this technique you will be able to pick the client and the task, and even different ones per task group.