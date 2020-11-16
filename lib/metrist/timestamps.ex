defmodule Metrist.Timestamps do
  @doc """
  Helper functions that make sure that internally, we always have qualified timestamps. This
  keeps knowledge of what subsystem expects what units local to the code dealing with that
  subsystem.

  Time units are a subset of the Erlang time units.
  """

  @type time_unit() :: :second | :millisecond | :microsecond | :nanosecond
  @type qualified_time :: {time_unit(), non_neg_integer()}

  @spec from(time_unit, non_neg_integer()) :: qualified_time()
  def from(time_unit, value) do
    {time_unit, value}
  end

  @spec to(qualified_time(), time_unit()) :: non_neg_integer()
  def to({time_unit, value}, time_unit) do
    value
  end
  def to({time_unit, value}, requested_time_unit) do
    :erlang.convert_time_unit(value, time_unit, requested_time_unit)
  end
end
