defmodule GuardianTest do

  defmodule Password do
    use Guardian.SessionSerializer

    def valid?(_conn, params) do
      params["email"] && params["password"]
    end

    def get_user(_id) do
      %{id: 1, email: "test@example.com", admin: false}
    end

    def fetch(id, _scope), do: get_user(id)
    def store(user, _scope), do: user.id
  end

  defmodule FailurePlug do
    def call(conn, _params) do
      conn
    end
  end

  defmodule Router do
    use Plug.Router
    import Plug.Conn

    plug Plug.Session, store: :cookie,
                       key: "foobar",
                       encryption_salt: "encrypted cookie salt",
                       signing_salt: "signing salt"

    plug Guardian, strategies: [password: Password]

    plug :put_secret_key_base
    plug :fetch_session
    plug :match
    plug :dispatch

    get "/" do
      send_resp conn, 200, "OK"
    end

    def put_secret_key_base(conn, _opts) do
      put_in conn.secret_key_base, String.duplicate("abcdefghijk", 8)
    end
  end

  use ExUnit.Case, async: true
  use Plug.Test
  import Plug.Conn

  @user %{id: 1, email: "test@email.com", admin: false}
  @opts Guardian.init(strategies: [password: Password])

  test "default scope" do
    conn = conn(:get, "/") |> Guardian.call(@opts)
    assert conn.private[:guardian_default_scope] == :user
  end

  test "strategies" do
    conn = conn(:get, "/") |> Guardian.call(@opts)
    assert conn.private[:guardian_strategies][:password] == Password
    assert Guardian.get_default_strategy(conn) == Password
  end

  test "put_user/2 and get_user/1" do
    conn = call(Router, conn(:get, "/"))
    conn = Guardian.put_user(conn, @user)
    assert Guardian.get_user(conn) == @user
  end

  test "with scopes" do
    conn = call(Router, conn(:get, "/"))

    conn = Guardian.put_user(conn, @user)
    assert Guardian.get_user(conn) == @user
    assert get_session(conn, :guardian_user) == 1

    admin = @user |> put_in([:admin], true) |> put_in([:id], 2)

    conn = Guardian.put_user(conn, admin, scope: :admin)
    assert Guardian.get_user(conn, :admin) == admin
    assert get_session(conn, :guardian_admin) == 2
  end

  defp call(mod, conn) do
    mod.call(conn, [])
  end
end
