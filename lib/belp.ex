defmodule Belp do
  @moduledoc """
  Belp is a simple Boolean Expression Lexer and Parser.
  """

  alias Belp.AST

  alias Belp.{
    InvalidCharError,
    InvalidOperationError,
    SyntaxError,
    UndefinedVariableError
  }

  alias Belp.Utils

  @typedoc """
  A type that describes which primitives can be used as expression.
  """
  @type expr :: String.t() | charlist

  @typedoc """
  """
  @type value :: boolean | String.t()

  @doc """
  Evaluates the given expression.

  ## Examples

      iex> Belp.eval("foo and bar", foo: true, bar: false)
      {:ok, false}

      iex> Belp.eval("foo or bar", %{"foo" => true, "bar" => false})
      {:ok, true}

      iex> Belp.eval("bar", %{foo: true})
      {:error, %Belp.UndefinedVariableError{var: "bar"}}

      iex> Belp.eval("invalid expression")
      {:error, %Belp.SyntaxError{line: 1, token: "expression"}}

      iex> Belp.eval("foo || bar")
      {:error, %Belp.InvalidCharError{char: "|", line: 1}}
  """
  @spec eval(
          expr,
          Keyword.t(value) | %{optional(atom | String.t()) => value}
        ) ::
          {:ok, boolean}
          | {:error,
             InvalidCharError.t()
             | InvalidOperationError.t()
             | SyntaxError.t()
             | UndefinedVariableError.t()}
  def eval(expr, vars \\ %{}) do
    with {:ok, _tokens, ast} <- parse(expr),
         {:ok, term} <- AST.eval(ast, sanitize_vars(vars)) do
      {:ok, Utils.cast_boolean(term)}
    end
  end

  @doc """
  Evaluates the given expression. Raises when the expression is invalid or
  variables are undefined.

  ## Examples

      iex> Belp.eval!("foo and bar", foo: true, bar: false)
      false

      iex> Belp.eval!("foo or bar", %{"foo" => true, "bar" => false})
      true

      iex> Belp.eval!("bar", %{foo: true})
      ** (Belp.UndefinedVariableError) Undefined variable: bar

      iex> Belp.eval!("invalid expression")
      ** (Belp.SyntaxError) Syntax error near token "expression" on line 1

      iex> Belp.eval!("foo || bar")
      ** (Belp.InvalidCharError) Invalid character "|" on line 1
  """
  @spec eval!(
          expr,
          Keyword.t(value)
          | %{optional(atom | String.t()) => value}
        ) :: boolean | no_return
  def eval!(expr, vars \\ %{}) do
    expr |> eval(vars) |> may_bang!()
  end

  @doc """
  Checks whether the given expression is valid.

  ## Examples

      iex> Belp.valid_expression?("foo and bar")
      true

      iex> Belp.valid_expression?("invalid expression")
      false

      iex> Belp.valid_expression?("foo || bar")
      false
  """
  @spec valid_expression?(expr) :: boolean
  def valid_expression?(expr) do
    validate(expr) == :ok
  end

  @doc """
  Validates the given expression, returning an error tuple in case the
  expression is invalid.

  ## Examples

      iex> Belp.validate("foo and bar")
      :ok

      iex> Belp.validate("invalid expression")
      {:error, %Belp.SyntaxError{line: 1, token: "expression"}}

      iex> Belp.validate("foo || bar")
      {:error, %Belp.InvalidCharError{char: "|", line: 1}}
  """
  @doc since: "0.2.0"
  @spec validate(expr) :: :ok | {:error, InvalidCharError.t() | SyntaxError.t()}
  def validate(expr) do
    with {:ok, _tokens, _ast} <- parse(expr), do: :ok
  end

  @doc """
  Gets a list of variable names that are present in the given expression.

  ## Examples

      iex> Belp.variables("(foo and bar) or !foo")
      {:ok, ["foo", "bar"]}

      iex> Belp.variables("invalid expression")
      {:error, %Belp.SyntaxError{line: 1, token: "expression"}}

      iex> Belp.variables("foo || bar")
      {:error, %Belp.InvalidCharError{char: "|", line: 1}}
  """
  @spec variables(expr) ::
          {:ok, [String.t()]}
          | {:error, InvalidCharError.t() | SyntaxError.t()}
  def variables(expr) do
    with {:ok, tokens, _ast} <- parse(expr) do
      vars =
        for token <- tokens,
            match?({:var, _, _}, token),
            {:var, _, var} = token,
            uniq: true,
            do: var

      {:ok, vars}
    end
  end

  @doc """
  Gets a list of variable names that are present in the given expression. Raises
  when the expression is invalid or variables are undefined.

  ## Examples

      iex> Belp.variables!("(foo and bar) or !foo")
      ["foo", "bar"]

      iex> Belp.variables!("invalid expression")
      ** (Belp.SyntaxError) Syntax error near token "expression" on line 1

      iex> Belp.variables!("foo || bar")
      ** (Belp.InvalidCharError) Invalid character "|" on line 1
  """
  @spec variables!(expr) :: [String.t()] | no_return
  def variables!(expr) do
    expr |> variables() |> may_bang!()
  end

  defp lex(expr) do
    case :belp_lexer.string(to_charlist(expr)) do
      {:ok, tokens, _lines} ->
        {:ok, tokens}

      {:error, {line, _, {:illegal, char}}, _lines} ->
        {:error, %InvalidCharError{char: to_string(char), line: line}}
    end
  end

  defp may_bang!({:ok, value}), do: value
  defp may_bang!({:error, error}), do: raise(error)

  defp parse(expr) do
    with {:ok, tokens} <- lex(expr),
         {:ok, ast} <- do_parse(tokens) do
      {:ok, tokens, ast}
    end
  end

  defp do_parse(tokens) do
    case :belp_parser.parse(tokens) do
      {:ok, ast} ->
        {:ok, ast}

      {:error, {line, _, [_, token]}} ->
        {:error, %SyntaxError{line: line, token: to_string(token)}}
    end
  end

  defp sanitize_vars(vars) do
    for {key, value} <- vars, !is_nil(value), into: Map.new() do
      {to_string(key), value}
    end
  end
end
