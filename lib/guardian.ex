defmodule Guardian do
  @moduledoc """
  Guardian: Plug Authentication Middelware.

  This module defines a struct and the main functions for working
  with Guardian.
  """

  @type strategy             :: {atom, module}
  @type strategies           :: [strategy]
  @type after_put_user       :: [(t -> t)]
  @type after_authentication :: [(t -> t)]
  @type before_failure       :: [(t -> t)]
  @type before_logout        :: [(t -> t)]
  @type failure_app          :: mfa | fun
  @type user                 :: any

  @type t :: %Guardian{
    strategies:           strategies,
    after_put_user:       after_put_user,
    after_authentication: after_authentication,
    before_failure:       before_failure,
    before_logout:        before_logout,
    failure_app:          failure_app,
    user:                 user
  }

  defstruct strategies:           [],
            after_put_user:       [],
            after_authentication: [],
            before_failure:       [],
            before_logout:        [],
            failure_app:          nil,
            user:                 nil

  defmodule NotAuthenticated do
    defexception message: "no user is authenticated"

    @moduledoc """
    Error raised when a user is not logged in.
    """
  end

  import Plug.Conn

  def init(opts) do
    struct(Guardian, opts)
  end

  def call(conn, opts) do
    put_private(conn, :guardian, opts)
  end
end
