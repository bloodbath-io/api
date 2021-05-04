defmodule Bigseat.Schema.Scalars.Json do
  use Absinthe.Schema.Notation

  scalar :json do
    parse fn input ->
      case Poison.decode(input.value) do
        {:ok, result} -> result
        _ -> :error
      end
    end

    serialize &Poison.encode!/1
  end
end
