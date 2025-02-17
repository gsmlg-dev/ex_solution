defmodule GSMLG.Solution.Utils do
  @moduledoc """
  `GSMLG.Solution.Utils` provides utility functions for the solution.
  """

  @doc """
  Check if a directory is writable.
  """
  @spec dir_writable?(String.t()) :: boolean()
  def dir_writable?(dir) do
    if File.dir?(dir) do
      file = Path.join(dir, ".writetest")

      case File.write(file, "🤣") do
        :ok ->
          File.rm(file)
          true

        {:error, _} ->
          false
      end
    else
      false
    end
  end


end
