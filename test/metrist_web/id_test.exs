defmodule IdTest do
  use ExUnit.Case, async: true

  test "it looks like a UUID" do
    id = Id.generate()
    {:ok, info} = UUID.info(id)
    assert Keyword.get(info, :type) == :default
    assert Keyword.get(info, :version) == 4
    assert Keyword.get(info, :variant) == :rfc4122
  end

  test "it sorts over time, roughly" do
    id1 = Id.generate()
    Process.sleep(2)
    id2 = Id.generate()
    assert id2 > id1
  end

end
