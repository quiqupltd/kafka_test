defmodule KafkaTestTest do
  use ExUnit.Case
  doctest KafkaTest

  test "greets the world" do
    assert KafkaTest.hello() == :world
  end
end
