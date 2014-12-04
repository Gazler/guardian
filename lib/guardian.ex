defmodule Guardian do
  @moduledoc """
  Guardian: Plug Authentication Middelware.
  """

  import Plug.Conn
  alias Plug.Conn

  @type conn                 :: Conn.t
  @type scope                :: atom
  @type user                 :: {scope, any}
  @type strategy             :: {atom, module}

  @type users                :: [user]
  @type strategies           :: [strategy]
  @type after_put_user       :: [(conn -> conn)]
  @type after_authentication :: [(conn -> conn)]
  @type before_failure       :: [(conn -> conn)]
  @type before_logout        :: [(conn -> conn)]
  @type failure_plug         :: mfa | fun | nil

  defmodule NotAuthenticated do
    defexception message: "no user is authenticated"

    @moduledoc """
    Error raised when a user is not logged in.
    """
  end

  @spec init(Plug.opts) :: Plug.opts
  def init(opts) do
    opts
    |> Keyword.put_new(:default_scope, :user)
  end

  @spec call(Conn.t, Plug.opts) :: Conn.t
  def call(conn, opts) do
    conn =
      conn
      |> put_private(:guardian_strategies, opts[:strategies])
      |> put_private(:guardian_default_scope, opts[:default_scope])

    if opts[:default_strategy] do
      conn = put_private(conn, :guardian_default_strategy, opts[:default_strategy])
    end

    strategy = opts[:strategy] || get_default_strategy(conn)

    if strategy.valid?(conn, conn.params) do
       strategy.authenticate!(conn, conn.params)
    else
      conn
    end
  end

  def authenticate!(conn, user, opts \\ []) do
  end

  @doc """
  Manually set the user into the connection.

  ## Options

  * `:scope` - the user scope. Defaults to `:user`
  * `:strategy` - the strategy to use. If omitted, the default strategy will be
     chosen. The default strategy can be configured when Guardian is
     initialized by setting `:default_strategy`. If this is not defined, the
     first strategy will be selected.
  """
  @spec put_user(Conn.t, user, Keyword.t) :: Conn.t
  def put_user(conn, user, opts \\ []) do
    strategy = opts[:strategy] || get_default_strategy(conn)
    scope = opts[:scope] || default_scope(conn)

    conn
    |> put_private(:guardian_users, [{scope, user}| get_users(conn)])
    |> put_session(:"guardian_#{scope}", strategy.store(user, scope))
  end

  def get_user(conn) do
    get_user(conn, default_scope(conn))
  end

  def get_user(conn, scope) do
    get_users(conn)[scope]
  end

  def get_users(conn) do
    conn.private[:guardian_users] || []
  end

  def default_scope(conn) do
    conn.private[:guardian_default_scope]
  end

  def get_strategy(conn, key) do
    conn.private[:guardian_strategies][key]
  end

  def put_default_strategy(conn, key, module) do
    put_private(conn, :guardian_default_strategy, {key, module})
  end

  def get_default_strategy(conn) do
    [{_key, mod}|_] = conn.private[:guardian_strategies]
    conn.private[:guardian_default_strategy] || mod
  end
end

