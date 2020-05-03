defmodule BelpTest do
  use ExUnit.Case, async: true

  alias Belp.{InvalidCharError, SyntaxError, UndefinedVariableError}

  doctest Belp

  describe "eval/1" do
    test "evaluate expression" do
      assert Belp.eval("true") == {:ok, true}
      assert Belp.eval("false") == {:ok, false}
      assert Belp.eval("true and true") == {:ok, true}
      assert Belp.eval("true and false") == {:ok, false}
      assert Belp.eval("true or false") == {:ok, true}
      assert Belp.eval("false or false") == {:ok, false}
      assert Belp.eval("(true and false) or true") == {:ok, true}
      assert Belp.eval("(true and false) or false") == {:ok, false}
      assert Belp.eval("false and false or true") == {:ok, true}
      assert Belp.eval("false and (false or true)") == {:ok, false}
      assert Belp.eval("!true") == {:ok, false}
      assert Belp.eval("not true") == {:ok, false}
      assert Belp.eval("!false") == {:ok, true}
      assert Belp.eval("not false") == {:ok, true}
      assert Belp.eval("not (false or true)") == {:ok, false}
      assert Belp.eval("not false or true") == {:ok, true}
      assert Belp.eval("true = false") == {:ok, false}
      assert Belp.eval("true = true") == {:ok, true}
      assert Belp.eval("false = false") == {:ok, true}
      assert Belp.eval("true != false") == {:ok, true}
      assert Belp.eval("true != true") == {:ok, false}
      assert Belp.eval("false != false") == {:ok, false}
    end

    test "undefined variable error" do
      assert Belp.eval("foo and bar") ==
               {:error, %UndefinedVariableError{var: "foo"}}

      assert Belp.eval("true or bar") ==
               {:error, %UndefinedVariableError{var: "bar"}}
    end

    test "invalid character error" do
      assert Belp.eval("true && false") ==
               {:error, %InvalidCharError{char: "&", line: 1}}

      assert Belp.eval("\n\ntrue ? false\n\n") ==
               {:error, %InvalidCharError{char: "?", line: 3}}
    end

    test "syntax error" do
      assert Belp.eval("true Or false") ==
               {:error, %SyntaxError{token: "Or", line: 1}}

      assert Belp.eval("\n\ntrue false") ==
               {:error, %SyntaxError{token: "false", line: 3}}
    end
  end

  describe "eval/2" do
    test "evaluate boolean expression" do
      assert Belp.eval("true", []) == {:ok, true}
      assert Belp.eval("true", %{}) == {:ok, true}
      assert Belp.eval("false", %{}) == {:ok, false}
      assert Belp.eval("foo", foo: true) == {:ok, true}
      assert Belp.eval("foo", %{foo: true}) == {:ok, true}
      assert Belp.eval("foo", %{"foo" => true}) == {:ok, true}
      assert Belp.eval("foo", %{"foo" => ""}) == {:ok, true}
      assert Belp.eval("foo", %{"foo" => 0}) == {:ok, true}
      assert Belp.eval("foo", %{"foo" => false}) == {:ok, false}
      assert Belp.eval("foo", %{"foo" => nil}) == {:ok, false}
      assert Belp.eval("!foo", %{"foo" => true}) == {:ok, false}

      assert Belp.eval("(foo and bar) or baz", %{
               "foo" => true,
               "bar" => false,
               "baz" => true
             }) == {:ok, true}

      assert Belp.eval("(foo and bar) or baz", %{
               "foo" => true,
               "bar" => false,
               "baz" => false
             }) == {:ok, false}

      assert Belp.eval("not (foo or bar)", %{"foo" => false, "bar" => true}) ==
               {:ok, false}

      assert Belp.eval("not foo or bar", %{"foo" => false, "bar" => true}) ==
               {:ok, true}

      assert Belp.eval("foo = bar", %{"foo" => true, "bar" => false}) ==
               {:ok, false}

      assert Belp.eval("foo = bar", %{"foo" => true, "bar" => true}) ==
               {:ok, true}

      assert Belp.eval("foo = bar", %{"foo" => false, "bar" => false}) ==
               {:ok, true}

      assert Belp.eval("foo != bar", %{"foo" => true, "bar" => false}) ==
               {:ok, true}

      assert Belp.eval("foo != bar", %{"foo" => true, "bar" => true}) ==
               {:ok, false}

      assert Belp.eval("foo != bar", %{"foo" => false, "bar" => false}) ==
               {:ok, false}

      assert Belp.eval("foo = true", %{"foo" => true}) == {:ok, true}
      assert Belp.eval("true = foo", %{"foo" => true}) == {:ok, true}
      assert Belp.eval("foo = true", %{"foo" => false}) == {:ok, false}
      assert Belp.eval("true = foo", %{"foo" => false}) == {:ok, false}
      assert Belp.eval("foo = false", %{"foo" => false}) == {:ok, true}
      assert Belp.eval("false = foo", %{"foo" => false}) == {:ok, true}
      assert Belp.eval("foo = false", %{"foo" => true}) == {:ok, false}
      assert Belp.eval("false = foo", %{"foo" => true}) == {:ok, false}
    end

    test "undefined variable error" do
      assert Belp.eval("foo and bar", %{"foo" => true}) ==
               {:error, %UndefinedVariableError{var: "bar"}}

      assert Belp.eval("true or foo", %{"bar" => false}) ==
               {:error, %UndefinedVariableError{var: "foo"}}
    end

    test "invalid character error" do
      assert Belp.eval("foo && bar") ==
               {:error, %InvalidCharError{char: "&", line: 1}}

      assert Belp.eval("\n\nfoo ? bar\n\n") ==
               {:error, %InvalidCharError{char: "?", line: 3}}
    end

    test "syntax error" do
      assert Belp.eval("foo Or bar") ==
               {:error, %SyntaxError{token: "Or", line: 1}}

      assert Belp.eval("\n\nfoo bar") ==
               {:error, %SyntaxError{token: "bar", line: 3}}
    end
  end

  describe "eval!/1" do
    test "evaluate expression" do
      assert Belp.eval!("true and false") == false
      assert Belp.eval!("true or false") == true
    end

    test "undefined variable error" do
      assert_raise UndefinedVariableError, fn ->
        Belp.eval!("foo and bar")
      end
    end

    test "invalid character error" do
      assert_raise InvalidCharError, fn ->
        Belp.eval!("true && false")
      end
    end

    test "syntax error" do
      assert_raise SyntaxError, fn ->
        Belp.eval!("true Or false")
      end
    end
  end

  describe "eval!/2" do
    test "evaluate expression" do
      assert Belp.eval!("foo", foo: true) == true
      assert Belp.eval!("foo", %{foo: true}) == true
      assert Belp.eval!("foo", %{"foo" => true}) == true
    end

    test "undefined variable error" do
      assert_raise UndefinedVariableError, fn ->
        Belp.eval!("foo and bar", %{"foo" => true})
      end
    end

    test "invalid character error" do
      assert_raise InvalidCharError, fn ->
        Belp.eval!("foo && bar")
      end
    end

    test "syntax error" do
      assert_raise SyntaxError, fn ->
        Belp.eval!("foo Or bar")
      end
    end
  end

  describe "validate/1" do
    test "ok when expression is valid" do
      assert Belp.validate("foo and bar") == :ok
    end

    test "error when invalid character error" do
      assert Belp.validate("foo && bar") ==
               {:error, %InvalidCharError{char: "&", line: 1}}
    end

    test "error when syntax error" do
      assert Belp.validate("foo bar") ==
               {:error, %SyntaxError{line: 1, token: "bar"}}
    end
  end

  describe "valid_expression?/1" do
    test "true when expression is valid" do
      assert Belp.valid_expression?("foo and bar") == true
    end

    test "false when invalid character error" do
      assert Belp.valid_expression?("foo && bar") == false
    end

    test "false when syntax error" do
      assert Belp.valid_expression?("foo bar") == false
    end
  end

  describe "variables/1" do
    test "get vars for valid expression" do
      assert Belp.variables("(foo and bar) or (not bar and baz)") ==
               {:ok, ~w(foo bar baz)}
    end

    test "invalid character error" do
      assert Belp.variables("foo && bar") ==
               {:error, %InvalidCharError{char: "&", line: 1}}

      assert Belp.variables("\n\nfoo ? bar\n\n") ==
               {:error, %InvalidCharError{char: "?", line: 3}}
    end

    test "syntax error" do
      assert Belp.variables("foo Or bar") ==
               {:error, %SyntaxError{token: "Or", line: 1}}

      assert Belp.variables("\n\nfoo bar") ==
               {:error, %SyntaxError{token: "bar", line: 3}}
    end
  end

  describe "variables!/1" do
    test "get vars for valid expression" do
      assert Belp.variables!("(foo and bar) or (not bar and baz)") ==
               ~w(foo bar baz)
    end

    test "invalid character error" do
      assert_raise InvalidCharError, fn ->
        Belp.variables!("foo && bar")
      end
    end

    test "syntax error" do
      assert_raise SyntaxError, fn ->
        Belp.variables!("foo Or bar")
      end
    end
  end
end
