defmodule Belp.UtilsTest do
  use ExUnit.Case

  alias Belp.Utils

  describe "cast_boolean/1" do
    test "nil" do
      assert Utils.cast_boolean(nil) == false
    end

    test "boolean" do
      assert Utils.cast_boolean(false) == false
      assert Utils.cast_boolean(true) == true
    end

    test "string" do
      assert Utils.cast_boolean("") == false
      assert Utils.cast_boolean("foo") == true
    end

    test "number" do
      assert Utils.cast_boolean(-1) == true
      assert Utils.cast_boolean(-1.0) == true
      assert Utils.cast_boolean(0) == true
      assert Utils.cast_boolean(0.0) == true
      assert Utils.cast_boolean(1) == true
      assert Utils.cast_boolean(1.1) == true
    end
  end
end
