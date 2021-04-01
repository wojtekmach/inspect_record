defmodule InspectRecordTest do
  use ExUnit.Case

  test "it works" do
    InspectRecord.register_inspect_fun()
    InspectRecord.register_records(from_lib: "xmerl/include/xmerl.hrl")

    doc = :xmerl_scan.string('<?xml version="1.0"?><point x="1"/>') |> elem(0)

    IO.inspect(doc)
  end
end
