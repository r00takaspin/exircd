defmodule IRC.ServerTest do
  use ExUnit.Case

  alias IRC.Client

  @port 7777
  @nick "voldemar"
  @login @nick
  @first_name "Voldemar"
  @last_name "Duletskiy"
  @serverhost Application.get_env(:exircd, :serverhost)

  @welcome_messages [
    ":#{@serverhost} 001 ##NICKNAME## Welcome to the Internet Relay Network #{@nick}!#{@login}@127.0.0.1",
    ":#{@serverhost} 002 ##NICKNAME## Your host is #{@serverhost}, running version 0.0.1 alpha",
    ":#{@serverhost} 003 ##NICKNAME## This server was created Sat Mar 3 2018 at 03:57:37 EDT",
    ":#{@serverhost} 004 ##NICKNAME## #{@serverhost} 0.0.1 alpha aiwroOs asdasdasdasd"
  ]

  def check_welcome(socket, nick) do
    Enum.each(@welcome_messages, fn (msg) ->
      msg = "#{msg}\r\n"
      msg = String.replace(msg, "##NICKNAME##", nick)
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
      |> check_welcome(@nick)
    end

    test "Basic registration scanario: user -> nick", %{socket: socket} do
      socket
      |> Client.user(@login, @first_name, @last_name)
      |> Client.nick(@nick)
      |> check_welcome(@nick)
    end

    test "Upsidedown: nick -> user", %{socket: socket} do
      socket
      |> Client.nick(@nick)
      |> Client.user(@login, @first_name, @last_name)
      |> check_welcome(@nick)
    end

    test "nick already exists", %{socket: socket} do
      socket
      |> Client.user(@login, @first_name, @last_name)
      |> Client.nick(@nick)
      |> check_welcome(@nick)

      somebody = Client.new(@port) |> Client.nick(@nick)

      msg = ":#{@serverhost} 433 * voldemar :Nickname is already in use\r\n"

      assert_receive {:tcp, ^somebody, ^msg}
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
      Client.write(rick, "PRIVMSG morty@#{@serverhost} :Hello!")
      received_msg = ":rick!rick@#{@serverhost} PRIVMSG morty :Hello!\r\n"

      assert_receive {:tcp, ^morty, ^received_msg}
    end

    test "Wrong server", %{rick: rick} do
      host = "fakehost"
      Client.write(rick, "PRIVMSG morty@#{host} :Hey!")
      msg = ":#{@serverhost} 402 #{host} :No such server\r\n"

      assert_receive {:tcp, ^rick, ^msg}
    end

    test "One user messages to another", %{rick: rick, morty: morty} do
      msg = "Hello morty"
      Client.write(rick, "PRIVMSG morty :#{msg}")

      received_msg = ":rick!rick@#{@serverhost} PRIVMSG morty :Hello morty\r\n"

      assert_receive {:tcp, ^morty, ^received_msg}
    end

    test "Allow messaging only for registered users" do
      client = Client.new(@port)

      Client.write(client, "PRIVMSG")
      assert_receive {:tcp, ^client, ":#{@serverhost} 451 :You have not registered\r\n"}
    end

    test "Empty text", %{rick: rick} do
      rick
      |> Client.write("PRIVMSG asdasdasdas")

      msg = ":#{@serverhost} 412 :No text to send\r\n"

      assert_receive {:tcp, ^rick, ^msg}
    end

    test "Error if there is no such user", %{rick: rick} do
      rick
      |> Client.write("PRIVMSG somebody :Hey!")

      msg = ":#{@serverhost} 401 <somebody> :No such nick/channel\r\n"

      assert_receive {:tcp, ^rick, ^msg}
    end

    test "Morty away", %{rick: rick, morty: morty} do
      away = "On date with Summer"

      morty
      |> Client.away("On date with Summer")

      msg = ":#{@serverhost} 306 morty :You have been marked as being away\r\n"

      assert_receive {:tcp, ^morty, ^msg}

      rick
      |> Client.write("PRIVMSG morty :Hi Morty!")

      away_msg = ":#{@serverhost} 301 rick morty :#{away}\r\n"

      assert_receive {:tcp, ^rick, ^away_msg}
      privmsg = ":rick!rick@#{@serverhost} PRIVMSG morty :Hi Morty!\r\n"
      assert_receive {:tcp, ^morty, ^privmsg}

      morty
      |> Client.away()

      msg = ":#{@serverhost} 305 morty :You are no longer marked as being away\r\n"

      assert_receive {:tcp, ^morty, ^msg}
    end
  end

  describe "WHOIS" do
#WHOIS r00takaspin
#:weber.freenode.net 311 r00takaspin r00takaspin ~voldemar ppp3-215.tis-dialog.ru * :Voldemar Duletskiy
#:weber.freenode.net 312 r00takaspin r00takaspin weber.freenode.net :US
#:weber.freenode.net 378 r00takaspin r00takaspin :is connecting from *@ppp3-215.tis-dialog.ru 213.149.3.215
#:weber.freenode.net 317 r00takaspin r00takaspin 13 1523642010 :seconds idle, signon time
#:weber.freenode.net 330 r00takaspin r00takaspin r00takaspin :is logged in as
#:weber.freenode.net 318 r00takaspin r00takaspin :End of /WHOIS list.

#WHOIS r00t
#:weber.freenode.net 311 r00takaspin r00t ~r00t unaffiliated/r00t * :Unknown
#:weber.freenode.net 312 r00takaspin r00t moon.freenode.net :Atlanta, GA, US
#:weber.freenode.net 671 r00takaspin r00t :is using a secure connection
#:weber.freenode.net 330 r00takaspin r00t r00t :is logged in as
#:weber.freenode.net 318 r00takaspin r00t :End of /WHOIS list.

    setup do
      morty = Client.new(@port) |> Client.register("morty", "Morty", "Smith")
      rick = Client.new(@port) |> Client.register("rick",  "Rich", "Sanchez")
      %{
        rick: rick,
        morty: morty
      }
    end

    test "empty params", %{rick: rick} do
      rick
      |> Client.write("WHOIS")

      msg = ":#{@serverhost} 431 :No nickname given\r\n"

      assert_receive {:tcp, ^rick, ^msg}
    end

    test "wrong receiped", %{rick: rick} do
      rick
      |> Client.write("WHOIS drwho")

      msg = ":#{@serverhost} 401 <drwho> :No such nick/channel\r\n"

      assert_receive {:tcp, ^rick, ^msg}
    end

    test "recepiet at wrong server", %{rick: rick} do
      rick
      |> Client.write("WHOIS morty@somehost")

      msg = ":#{@serverhost} 402 somehost :No such server\r\n"

      assert_receive {:tcp, ^rick, ^msg}
    end
  end
end
