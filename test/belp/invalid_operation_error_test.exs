defmodule Belp.InvalidOperationErrorTest do
  use ExUnit.Case, async: true

  alias Belp.InvalidOperationError

  describe "message/1" do
    test "get message" do
      assert Exception.message(%InvalidOperationError{
               operation: :"~",
               left: "foo",
               right: true
             }) ==
               ~s(Invalid operation: "foo" ~ true)
    end
  end
end
