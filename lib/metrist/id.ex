defmodule Id do
  @moduledoc """
  Unique ids that are UUID compatible and sort nicely.

  We use 48 bits for the time (in millisecond resolution)
  then four bits for the uuid version (4), then
  the rest random data except for the two UUID variant
  bits which need to be pinned to 1 and 0.
  """

  @type t :: String.t

  def generate do
    time = :os.system_time(:millisecond)
    random1 = :crypto.strong_rand_bytes(2)
    |> :binary.decode_unsigned
    random2 = :crypto.strong_rand_bytes(8)
    |> :binary.decode_unsigned
    bytes = << time :: size(48),
      4 :: size(4),
      random1 :: size(12),
      1 :: size(1),
      0 :: size(1),
      random2 :: size(62) >>
    UUID.binary_to_string!(bytes)
  end
end
