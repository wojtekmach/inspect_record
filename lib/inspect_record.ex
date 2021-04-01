defmodule InspectRecord do
  import Inspect.Algebra

  def register_inspect_fun() do
    Inspect.Opts.default_inspect_fun(&__MODULE__.inspect(&1, &2))
  end

  def register_records(opts) do
    new_records = Record.extract_all(opts) |> Map.new()
    :persistent_term.put({__MODULE__, :records}, Map.merge(records(), new_records))
  end

  defp records() do
    :persistent_term.get({__MODULE__, :records}, %{})
  end

  def inspect(tuple, opts) when is_tuple(tuple) and tuple_size(tuple) > 1 do
    records = records()
    list = Tuple.to_list(tuple)
    [record_name | values] = list

    # TODO: Map.fetch(records, {record_name, tuple_size(tuple) - 1})
    case Map.fetch(records, record_name) do
      {:ok, fields} ->
        inspect_record(record_name, fields, values, opts)

      _ ->
        inspect_tuple(list, opts)
    end
  end

  def inspect(other, opts) do
    Inspect.inspect(other, opts)
  end

  defp inspect_tuple(list, opts) do
    inspect("{", list, "}", &to_doc/2, :flex, opts)
  end

  defp inspect_record(record_name, fields, values, opts) do
    kwlist =
      Enum.zip(fields, values)
      |> Enum.reduce([], fn
        {{_field, value}, value}, acc ->
          acc

        {{field, _default}, value}, acc ->
          [{field, value} | acc]
      end)

    kwlist = Enum.reverse(kwlist)
    inspect("##{record_name}(", kwlist, ")", &Inspect.List.keyword/2, :strict, opts)
  end

  defp inspect(open, list, close, fun, break, opts) do
    open = color(open, :tuple, opts)
    sep = color(",", :tuple, opts)
    close = color(close, :tuple, opts)
    container_opts = [separator: sep, break: break]
    container_doc(open, list, close, opts, fun, container_opts)
  end
end
