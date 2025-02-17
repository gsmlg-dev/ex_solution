defmodule GSMLG.Solution do
  @moduledoc """
  Documentation for `GSMLG.Solution`.
  """

  @doc """
  This is a macro that will be called when `use GSMLG.Solution` is used in a module.

  """
  defmacro __using__(_method) do
    quote do
      use GenServer
    end
  end
end
