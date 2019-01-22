defmodule FungusToast.SnakeCaseEncoder do
  use ProperCase.JSONEncoder,
    transform: &ProperCase.to_camel_case/1,
    json_encoder: Jason
end
