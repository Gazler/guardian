Guardian
========

> Authentication Middleware for [Plug](https://github.com/elixir-lang/plug)

None of this is implemented yet. Still working out the API details. Most all of
the ideas will be completely stolen from [Warden](https://github.com/hassox/warden).

### Configuration

Add Guardian to your router after `Plug.Session`.

```elixir
plug Guardian, strategies: [password: PasswordStrategy],
               failure_plug: MyFailurePlug,
               serializer: PasswordStrategy
```

### Sample Password Strategy / Session Serializer

```elixir
defmodule PasswordStrategy do
  use Guardian.SessionSerializer

  @doc """
  This strategy will be used if this returns true.
  """
  def valid?(conn, params) do
    params["email"] && params["password"]
  end

  @doc """
  Authenticate the user.
  """
  def authenticate!(conn, params) do
    if user = User.authenticate!(email: params["email"], password: params["password"]) do
      success! conn, user
    else
      fail conn, "Invalid email or password."
    end
  end

  @doc """
  The value to store into the session.
  """
  def store(user), do: user.id

  @doc """
  Find the user via the database.
  """
  def fetch(id), do: Repo.one(User, id)
end
```
