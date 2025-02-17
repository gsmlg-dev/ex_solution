defmodule GSMLG.Solution.Utils.Mappable do
  @moduledoc """
  Convert map, struct to keyword
  Convert keyword to map, struct
  Get keys from map, keyword, struct
  """
  require Logger

  @default_options [
    keys: :atoms,
    shallow: false,
    skip_unknown_atoms: false,
    warn_unknown_atoms: true
  ]

  @type options() :: [
    keys: :atoms | :existing_atom | :strings,
    shallow: boolean(),
    skip_unknown_atoms: boolean(),
    warn_unknown_atoms: boolean()
  ]

  defp expand_options(options) do
    Keyword.merge(@default_options, options)
  end

  @doc """
  Convert a list of tuples, a map, or a struct to a map.
  Convert key with options.
  """
  @spec to_map(list() | map() | struct(), options()) :: map()
  def to_map(list, options) when is_list(list) do
    options = expand_options(options)

    list
    |> Enum.into(%{}, fn {key, val} -> {convert_key(key, options[:keys]), val} end)
  end

  def to_map(%_module{} = struct, options) do
    options = expand_options(options)
    Map.from_struct(struct) |> convert_keys(options)
  end

  def to_map(map, options) when is_map(map) do
    options = expand_options(options)
    map |> convert_keys(options)
  end

  @doc """
  Convert a map to struct.
  Map must have keys that are atoms.
  """
  @spec to_struct(nil | map(), module()) :: struct()
  def to_struct(nil, module) do
    struct(module)
  end

  def to_struct(map, module) when is_atom(module) and is_map(map) do
    map = to_map(map, keys: :strings, shallow: true)
    struct = struct(module)

    Enum.reduce(Map.to_list(struct), struct, fn {k, _}, acc ->
      case Map.fetch(map, convert_key(k, :strings)) do
        {:ok, v} -> %{acc | k => v}
        :error -> acc
      end
    end)
  end

  @doc """
  Convert a map to a list of tuples.
  """
  @spec to_list(nil | list() | map()) :: list()
  def to_list(nil) do
    []
  end

  def to_list(list) when is_list(list) do
    list
  end

  def to_list(map) when is_map(map) do
    Enum.map(map, fn {k, v} -> {to_atom(k), v} end)
  end

  defp to_atom(k) when is_atom(k), do: k
  defp to_atom(k) when is_binary(k), do: String.to_existing_atom(k)

  @doc """
  Get keys of a map, Keyword list, or struct.
  """
  @spec keys(keyword() | map() | struct()) :: list()
  def keys(%_module{} = struct) do
    Map.keys(struct) -- [:__struct__]
  end

  def keys(map) when is_map(map) do
    Map.keys(map)
  end

  def keys(list) when is_list(list) do
    Keyword.keys(list)
  end

  defp convert_keys(map, options) do
    Enum.reduce(map, %{}, fn {k, v}, acc ->
      try do
        Map.put(
          acc,
          convert_key(k, options[:keys]),
          if options[:shallow] do
            v
          else
            convert_val(v, options)
          end
        )
      rescue
        _e in ArgumentError ->
          if options[:skip_unknown_atoms] do
            if options[:warn_unknown_atoms] do
              Logger.warning(
                "[Mappable] failed to convert key #{inspect(k)} to existing atom, skipping this key entirely"
              )
            end

            acc
          else
            raise ArgumentError, "failed to convert key #{inspect(k)} to existing atom"
          end
      end
    end)
  end

  defp convert_val(val, options) when is_map(val) do
    to_map(val, options)
  end

  defp convert_val(val, options) when is_list(val) do
    val |> Enum.map(fn item -> convert_val(item, options) end)
  end

  defp convert_val(val, _) do
    val
  end

  defp convert_key(k, :atoms) when is_atom(k) do
    k
  end

  defp convert_key(k, :atoms) when is_binary(k) do
    String.to_atom(k)
  end

  defp convert_key(k, :existing_atom) when is_atom(k) do
    k
  end

  defp convert_key(k, :existing_atom) when is_binary(k) do
    String.to_existing_atom(k)
  end

  defp convert_key(k, :strings) when is_binary(k) do
    k
  end

  defp convert_key(k, :strings) when is_atom(k) do
    "#{k}"
  end
end
