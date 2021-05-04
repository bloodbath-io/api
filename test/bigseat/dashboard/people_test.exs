defmodule Bigseat.Core.PeopleTest do
  use Bigseat.DataCase
  alias Bigseat.Factory.PersonFactory

  describe "people" do
    alias Bigseat.Core.People

    test "list/0 returns all people" do
      person = PersonFactory.insert(:person)
      people_list = Enum.map(People.list, fn person -> person.id end)
      assert people_list == [person.id]
    end

    test "get/1 returns the person with given id" do
      person = PersonFactory.insert(:person)
      assert People.get(person.id).id == person.id
    end
  end
end
