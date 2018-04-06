require Logger

defmodule IRC.Server do
  @moduledoc """
    Сервер принимающий TCP соединения
  """

  use GenServer

  alias IRC.{ServerSupervisor, UserRegistry, Reply, Command}

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
    {:ok, user} = UserRegistry.find_or_create_by_socket(socket)

    with line <- read_line(socket),
         {:ok, command} <- Command.parse(line),
         {:ok, reply} <- Command.run(user, command) do
            reply
            |> Reply.reply()
            |> write_line(socket)
    else
      :ok -> Reply.reply |> write_line(socket)
      {:error, error} -> error |> Reply.error |> write_line(socket)
    end

    serve(socket)
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
    |> case do
      {:ok, data} ->
        debug(socket, "Request: #{data}")
        String.trim(data)

      {:error, :closed} ->
        case UserRegistry.lookup(socket) do
          {:ok, user} -> IRC.User.quit(user)
          _msg -> debug(socket, "unregistered user")
        end
        Logger.debug("Connection closed")
        Process.exit(self(), :normal)
    end
  end

  defp write_line(nil, socket) do
    debug(socket, "Empty response.")
  end

  defp write_line(line, socket) do
    debug(socket, "Response: #{line}")
    :gen_tcp.send(socket, line)
  end

  defp debug(socket, line) do
    Logger.debug("[##{client_id(socket)}] #{line}")
  end

  defp client_id(port) do
    Port.info(port)[:id]
  end
end
