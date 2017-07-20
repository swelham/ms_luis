[![Build Status](https://travis-ci.org/swelham/ms_luis.svg?branch=master)](https://travis-ci.org/swelham/ms_luis) [![Deps Status](https://beta.hexfaktor.org/badge/all/github/swelham/ms_luis.svg?branch=master)](https://beta.hexfaktor.org/github/swelham/ms_luis) [![Hex Version](https://img.shields.io/hexpm/v/ms_luis.svg)](https://hex.pm/packages/ms_luis) [![Join the chat at https://gitter.im/swelham/ms_luis](https://badges.gitter.im/swelham/ms_luis.svg)](https://gitter.im/swelham/ms_luis?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

# MsLuis

A small library that can send requests to the Microsoft LUIS service

## Installation

Add `ms_luis` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:ms_luis, "~> 2.0"}]
end
```

## Usage

Firstly setup the `:ms_luis` config in your applications config file

```elixir
config :ms_luis, :config,
  url: "https://westus.api.cognitive.microsoft.com",
  app_key: "<your-application-key>",
  sub_key: "<your-subscription-key>"
```

Then you can call the `MsLuis.get_intent/1` function with the text you wish to get the intent for.

```elixir
MsLuis.get_intent("turn off the lights")
# {:ok, %{"topScoringIntent" => "lights_off", ...}}
```

