require Logger

defmodule IRC.Server do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok), do: {:ok, %{}}


  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port,
      [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info "Accepting connections on port #{port}"
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(IRC.ServerSupervisor, fn -> serve(client) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    socket
    |> read_line()
    |> IRC.Command.parse
    |> case do
         {:ok, command} ->
           case IRC.Command.run(command) do
             {:ok, reply} -> IRC.Reply.success(reply)
             {:error, reply} -> IRC.Reply.error(reply)
           end
         {:error, reply} -> IO.inspect(reply); IRC.Reply.error(reply)
       end
    |> write_line(socket)

    serve(socket)
  end

  defp read_line(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end
end