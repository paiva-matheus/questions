defmodule Questions.Doubts.Queries.FilterQueryTest do
  use Questions.DataCase, async: true

  import Ecto.Query

  alias Questions.Doubts.Queries.FilterQuery
  alias Questions.Doubts.Question

  @q from q in Question, as: :question

  describe "by/2" do
    test "returns query filtered by title" do
      title = Faker.Person.title()

      expected_response =
        from [question: q] in @q,
          where: ilike(q.title, ^"%#{title}%")

      assert inspect(FilterQuery.by(@q, title: title)) == inspect(expected_response)
    end

    test "returns query filtered status" do
      expected_response =
        from [question: q] in @q,
          where: q.status == ^"open"

      assert inspect(FilterQuery.by(@q, status: "open")) == inspect(expected_response)
    end

    test "returns query filtered category" do
      expected_response =
        from [question: q] in @q,
          where: q.category == ^"open"

      assert inspect(FilterQuery.by(@q, category: "open")) == inspect(expected_response)
    end

    test "returns query with multiple filters" do
      title = Faker.Person.title()

      expected_response =
        from [question: q] in @q,
          where: ilike(q.title, ^"%#{title}%"),
          where: q.status == ^"open"

      filters = [title: title, status: "open"]

      assert inspect(FilterQuery.by(@q, filters)) == inspect(expected_response)
    end

    test "returns query when filter value is nil" do
      assert inspect(FilterQuery.by(@q, title: nil)) == inspect(@q)
    end
  end
end
