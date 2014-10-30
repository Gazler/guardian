Guardian
========

> Authentication Middelware for [Plug](https://github.com/elixir-lang/plug)

None of this is implemented yet. Still working out the API details. Most all of
the ideas will be completely stolen from [Warden](https://github.com/hassox/warden).

### Configuration

Add Guardian to your router after `Plug.Session`.

```elixir
plug Guardian, strategies: [password: PasswordStrategy],
               failure_app: MyFailureApp,
               serialize_into_session: fn(user) -> user.id end,
               serialize_from_session: fn(id) -> User.get(id) end
```

### Sample Password Strategy

```elixir
defmodule PasswordStrategy do
  def valid?(conn, params) do
    params["email"] && params["password"]
  end

  def authenticate!(conn, params) do
    if user = User.authenticate!(email: params["email"], password: params["password"]) do
      success! conn, user
    else
      fail conn, "Invalid email or password."
    end
  end
end
```
