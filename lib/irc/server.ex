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
    session = socket |> init_session

    with line <- read_line(socket),
         {:ok, command} <- Command.parse(line),
         {:ok, reply} <- Command.run(session, command) do
            reply
            |> Reply.reply()
            |> write_line(socket)
    else
      :ok -> Reply.reply |> write_line(socket)
      {:error, error} -> error |> Reply.error |> write_line(socket)
    end

    serve(socket)
  end

  defp init_session(socket) do
    socket
    |> SessionRegistry.lookup
    |> case do
         :error ->
           SessionRegistry.create(socket)
           init_session(socket)
         {:ok, session} -> session
       end
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
    |> case do
      {:ok, data} ->
        Logger.debug("Request: #{data}")
        data

      {:error, :closed} ->
        Logger.debug("Connection closed")
        Process.exit(self(), :normal)
    end
  end

  defp write_line(line, socket) do
    Logger.debug("Response: #{line}")

    :gen_tcp.send(socket, line)
  end
end
