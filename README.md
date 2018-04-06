# Реализация IRC сервера на Elixir

###### Реализация спецификации [RFC-2812](https://tools.ietf.org/html/rfc2812)  

Сервер является учебной имплементацией протокола IRC. Побочной целью проекта является получение опыта написания реализации открытого протокола по спецификации.

Зависимости:
* Elixir

Установка:

```bash
mix deps.get
```

Запуск: 
```bash 
mix run --no-halt
```

Запуск в интерактивном режиме:
```bash 
iex -S mix
```


Подключение:
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
- [X] USER
	- [X] ERR_ALREADYREGISTRED
	- [X] ERR_NEEDMOREPARAMS
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
	- [ ] ERR_NORECIPIENT
	- [ ] ERR_CANNOTSENDTOCHAN
	- [ ] ERR_WILDTOPLEVEL
  - [ ] ERR_NOSUCHNICK
  - [ ] RPL_AWAY
  - [ ] ERR_NOTEXTTOSEND
  - [ ] ERR_NOTOPLEVEL
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
