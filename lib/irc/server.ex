require Logger

defmodule IRC.Server do
  @moduledoc """
    Сервер принимающий TCP соединения
  """

  use GenServer

  alias IRC.{ServerSupervisor, Reply, Command, SessionRegistry}

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok), do: {:ok, %{}}

  @doc """
    Запуск сервера на указанном порту
  """

  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port,
      [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info "Accepting connections on port #{port}"
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = start_client(client)
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  defp start_client(client) do
    Task.Supervisor.start_child(ServerSupervisor, fn -> serve(client) end)
  end

  defp serve(socket) do
    {:ok, session} = socket |> init_session

    socket
    |> read_line()
    |> Command.parse
    |> case do
         {:ok, command} ->
           case Command.run(session, command) do
             {:ok, _} -> Reply.success
             {:error, reply} -> Reply.error(reply)
           end
         {:error, reply} -> Reply.error(reply)
       end
    |> write_line(socket)

    serve(socket)
  end

  defp init_session(socket) do
    socket
    |> SessionRegistry.lookup
    |> case do
         :error ->
           SessionRegistry.create(socket)
           init_session(socket)
         msg -> msg
       end
  end

  defp read_line(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end
end
