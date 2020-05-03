defmodule Belp.Utils do
  @moduledoc false

  @spec cast_boolean(any) :: boolean
  def cast_boolean(nil), do: false
  def cast_boolean(term) when is_boolean(term), do: term
  def cast_boolean(""), do: false
  def cast_boolean(_term), do: true
end
