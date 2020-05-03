defmodule Belp.AST do
  @moduledoc false

  alias Belp.{InvalidOperationError, UndefinedVariableError}
  alias Belp.Utils

  def eval({:binary_expr, type, a, b}, vars) do
    with {:ok, a} <- eval(a, vars),
         {:ok, b} <- eval(b, vars),
         {:ok, result} <- binary_op(type, a, b) do
      {:ok, result}
    end
  end

  def eval({:unary_expr, :not_op, a}, vars) do
    with {:ok, a} <- eval(a, vars) do
      {:ok, !Utils.cast_boolean(a)}
    end
  end

  def eval({:var, var}, vars) do
    case Map.fetch(vars, var) do
      {:ok, value} -> {:ok, value}
      :error -> {:error, %UndefinedVariableError{var: var}}
    end
  end

  def eval({:string, str}, _vars), do: {:ok, str}

  def eval(value, _vars), do: {:ok, value}

  defp binary_op({:cmp_op, :"~"}, a, b) when is_binary(a) and is_binary(b) do
    {:ok, case_insensitive_match?(a, b)}
  end

  defp binary_op({:cmp_op, :"!~"}, a, b) when is_binary(a) and is_binary(b) do
    {:ok, !case_insensitive_match?(a, b)}
  end

  defp binary_op({:cmp_op, :=}, a, b), do: {:ok, a == b}
  defp binary_op({:cmp_op, :!=}, a, b), do: {:ok, a != b}

  defp binary_op({:cmp_op, op}, a, b) do
    {:error, %InvalidOperationError{operation: op, left: a, right: b}}
  end

  defp binary_op(:and_op, a, b) when is_boolean(a) and is_boolean(b) do
    {:ok, a && b}
  end

  defp binary_op(:or_op, a, b) when is_boolean(a) and is_boolean(b) do
    {:ok, a || b}
  end

  defp binary_op(op, a, b) do
    a = Utils.cast_boolean(a)
    b = Utils.cast_boolean(b)
    binary_op(op, a, b)
  end

  defp case_insensitive_match?(a, b) do
    String.downcase(a) =~ String.downcase(b)
  end
end
