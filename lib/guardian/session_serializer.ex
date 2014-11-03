defmodule Guardian.SessionSerializer do
  use Behaviour

  defmacro __using__(_opts) do
    quote location: :keep do
      @behaviour unquote(__MODULE__)
    end
  end

  defcallback fetch(any, scope :: atom) :: any
  defcallback store(any, scope :: atom) :: any
end
