defmodule FungusToast.SnakeCaseEncoder do
  # Note: taken from https://github.com/johnnyji/proper_case/issues/20#issue-337114809
  def encode_to_iodata!(data) do
    data
    |> Jason.encode!
    |> Jason.decode!
    |> ProperCase.to_camel_case
    |> Jason.encode_to_iodata!
  end
end
