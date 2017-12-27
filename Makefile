build:
	mix deps.get

run:
	mix run --no-halt

check:
	mix dogma && mix credo --strict && mix dialyzer

tests:
	mix test
