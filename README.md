# Реализация IRC сервера на Elixir

###### Реализация спецификации [RFC-2812](https://tools.ietf.org/html/rfc2812)  

Запуск: 
```bash 
mix run --no-halt
```

Подключиться:
```bash
telnet localhost 6667
```

### Реализованные операторы

#### Основные команды
- [ ] PASS
- [ ] NICK
	- [X] ERR_NONICKNAMEGIVEN
	- [X] ERR_NICKNAMEINUSE
	- [X] ERR_UNAVAILRESOURCE
	- [X] ERR_ERRONEUSNICKNAME
	- [ ] ERR_NICKCOLLISION
	- [ ] ERR_RESTRICTED
- [ ] USER
- [ ] SERVER
- [ ] OPER
- [ ] QUIT
- [ ] SQUIT

##### Команды каналов:

- [ ] JOIN
- [ ] PART
- [ ] MODE
- [ ] TOPIC
- [ ] NAMES
- [ ] LIST
- [ ] INVITE
- [ ] KICK

##### Серверные запросы и команды:

- [ ] VERSION
- [ ] STATS
- [ ] LINKS
- [ ] TIME
- [ ] CONNECT
- [ ] TRACE
- [ ] ADMIN
- [ ] INFO

##### Команды отправки сообщений:

- [ ] PRIVMSG
- [ ] NOTICE

##### Пользовательские запросы:

- [ ] WHO
- [ ] WHOIS
- [ ] WHOWAS

##### Остальные команды:

- [ ] KILL
- [ ] PING
- [ ] PONG
- [ ] ERROR

##### Опциональные сообщения:

- [ ] AWAY
- [ ] REHASH
- [ ] RESTART
- [ ] SUMMON
- [ ] USERS
- [ ] WALLOPS
- [ ] USERHOST
- [ ] ISON