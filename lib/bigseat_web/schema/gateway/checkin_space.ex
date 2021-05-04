defmodule Bigseat.Schema.Gateway.CheckinSpace do
  use Absinthe.Schema.Notation
  alias Crudry.Middlewares.TranslateErrors
  alias Bigseat.Repo
  alias Bigseat.Core.{
    Space,
    Person
  }

  object :gateway_checkin_space do
    @desc "Check-in space"
    field :checkin_space, :gateway_checkin do
      arg :space_id, non_null(:uuid)
      arg :person_id, non_null(:uuid)

      resolve &resolve/3
      middleware TranslateErrors
    end
  end

  def resolve(_parent, %{ space_id: space_id, person_id: person_id }, _resolution) do
    with %Space{} = space <- Space |> Repo.get(space_id),
         %Person{} = person <- Person |> Repo.get(person_id) do
      Bigseat.Core.Checkins.create(space, person)
    else
      nil -> {:error, "space or person not found"}
    end
  end

  def resolve(_parent, _args, _resolution) do
    {:error, "not found"}
  end
end
