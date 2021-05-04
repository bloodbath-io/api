defmodule Bigseat.Schema.Gateway.BookSpace do
  use Absinthe.Schema.Notation
  alias Crudry.Middlewares.TranslateErrors
  alias Bigseat.Repo
  alias Bigseat.Core.Space

  object :gateway_book_space do
    @desc "Book space"
    field :book_space, :gateway_booking do
      arg :space_id, non_null(:uuid)
      arg :person, non_null(:book_space_person_input)
      arg :start_at, non_null(:datetime)
      arg :end_at, non_null(:datetime)

      resolve &resolve/3
      middleware TranslateErrors
    end
  end

  input_object :book_space_person_input do
    field :email, non_null(:string)
    field :first_name, non_null(:string)
    field :last_name, non_null(:string)
  end

  def resolve(_parent, %{ start_at: start_at, end_at: end_at, space_id: space_id, person: book_space_person_input }, _resolution) do
    space = Space |> Repo.get(space_id)
    case space do
      %Space{} -> Bigseat.Core.Bookings.create(space, book_space_person_input, %{start_at: start_at, end_at: end_at})
      _ -> {:error, "space not found"}
    end
  end

  def resolve(_parent, _args, _resolution) do
    {:error, "not found"}
  end
end
