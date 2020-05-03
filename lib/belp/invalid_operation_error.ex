defmodule Belp.InvalidOperationError do
  @moduledoc """
  An error that is returned or raised when a expression contains an operation
  that is invalid for the particular types.
  """

  defexception [:operation, :left, :right]

  @type t :: %__MODULE__{
          operation: atom,
          left: any,
          right: any
        }

  def message(exception) do
    "Invalid operation: #{inspect(exception.left)} " <>
      "#{exception.operation} #{inspect(exception.right)}"
  end
end
