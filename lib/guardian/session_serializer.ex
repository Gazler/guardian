defmodule Guardian.SessionSerializer do
  use Behaviour

  defmacro __using__(_opts) do
    quote location: :keep do
      @behaviour unquote(__MODULE__)

      def success!(conn, user) do
        Guardian.put_user(conn, user)
      end

      def fail(conn, message), do: conn

    end
  end

  defcallback fetch(any, scope :: atom) :: any
  defcallback store(any, scope :: atom) :: any
end
