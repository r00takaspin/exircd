defmodule IRC.ServerTest do
  use ExUnit.Case

  alias IRC.Client

  @port 7777
  @nick "voldemar"
  @login @nick
  @first_name "Voldemar"
  @last_name "Duletskiy"
  @servername Application.get_env(:exircd, :servername)

  @welcome_messages [
    "001 Welcome to the Internet Relay Network #{@nick}!#{@login}@127.0.0.1",
    "002 Your host is Ironclad, running version 0.0.1 alpha",
    "003 This server was created Sat Mar 3 2018 at 03:57:37 EDT",
    "004 Ironclad 0.0.1 alpha aiwroOs asdasdasdasd"
  ]

  def check_welcome(socket) do
    Enum.each(@welcome_messages, fn (msg) ->
      msg = "#{msg}\r\n"
      assert_receive {:tcp, ^socket, ^msg}
    end)
  end

  setup_all do
    {:ok, _pid} = ExIRCd.start([], [port: @port])
    :ok
  end

  describe "Registration" do
    setup do
      socket = Client.new(@port)
      %{socket: socket}
    end

    test "Without last name", %{socket: socket} do
      socket
      |> Client.nick(@nick)
      |> Client.user(@login, "Voldemar")
      |> check_welcome
    end

    test "Basic registration scanario: user -> nick", %{socket: socket} do
      socket
      |> Client.user(@login, @first_name, @last_name)
      |> Client.nick(@nick)
      |> check_welcome
    end

    test "Upsidedown: nick -> user", %{socket: socket} do
      socket
      |> Client.nick(@nick)
      |> Client.user(@login, @first_name, @last_name)
      |> check_welcome
    end

    test "nick already exists", %{socket: socket} do
      socket
      |> Client.user(@login, @first_name, @last_name)
      |> Client.nick(@nick)
      |> check_welcome

      somebody = Client.new(@port) |> Client.nick(@nick)

      assert_receive {:tcp, ^somebody, "433 " <> _}
    end
  end

  describe "Messaging between users" do
    setup do
      morty = Client.new(@port) |> Client.register("morty", "Morty", "Smith")
      rick = Client.new(@port) |> Client.register("rick",  "Rich", "Sanchez")
      %{
        rick: rick,
        morty: morty
      }
    end

    test "Message to user with server difinition", %{rick: rick, morty: morty} do
      Client.write(rick, "PRIVMSG morty@#{@servername} :Hello!")
      received_msg = ":rick!rick@#{@servername} PRIVMSG morty :Hello!\r\n"

      assert_receive {:tcp, ^morty, ^received_msg}
    end

    test "Wrong server", %{rick: rick} do
      host = "fakehost"
      Client.write(rick, "PRIVMSG morty@#{host} :Hey!")
      msg = "402 #{host} :No such server\r\n"

      assert_receive {:tcp, ^rick, ^msg}
    end

    test "One user messages to another", %{rick: rick, morty: morty} do
      msg = "Hello morty"
      Client.write(rick, "PRIVMSG morty :#{msg}")

      received_msg = ":rick!rick@#{@servername} PRIVMSG morty :Hello morty\r\n"

      assert_receive {:tcp, ^morty, ^received_msg}
    end

    test "Allow messaging only for registered users" do
      client = Client.new(@port)

      Client.write(client, "PRIVMSG")
      assert_receive {:tcp, ^client, "451 :You have not registered\r\n"}
    end

    test "Empty text", %{rick: rick} do
      rick
      |> Client.write("PRIVMSG asdasdasdas")

      assert_receive {:tcp, ^rick, "412 :No text to send\r\n"}
    end

    test "Error if there is no such user", %{rick: rick} do
      rick
      |> Client.write("PRIVMSG somebody :Hey!")

      assert_receive {:tcp, ^rick, "401 <somebody> :No such nick/channel\r\n"}
    end

    test "Morty away", %{rick: rick, morty: morty} do
      away = "On date with Summer"

      morty
      |> Client.away("On date with Summer")

      assert_receive {:tcp, ^morty, "306 :You have been marked as being away\r\n"}

      rick
      |> Client.write("PRIVMSG morty :Hi Morty!")

      away_msg = "301 morty :#{away}\r\n"

      assert_receive {:tcp, ^rick, ^away_msg}
      privmsg = ":rick!rick@#{@servername} PRIVMSG morty :Hi Morty!\r\n"
      assert_receive {:tcp, ^morty, ^privmsg}

      morty
      |> Client.away()

      assert_receive {:tcp, ^morty, "305 :You are no longer marked as being away\r\n"}
    end
  end
end
