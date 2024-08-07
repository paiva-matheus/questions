defmodule Questions.Doubts.Queries.OrderQueryTest do
  use Questions.DataCase, async: true

  import Ecto.Query

  alias Questions.Doubts.Queries.OrderQuery
  alias Questions.Doubts.Question

  @q from q in Question, as: :question

  describe "by/3" do
    test "returns query ordered by title in desc order" do
      expected_response =
        from [question: q] in @q,
          order_by: [desc: q.title]

      assert inspect(OrderQuery.by(@q, "title", "desc")) == inspect(expected_response)
    end

    test "returns query ordered by title in asc order" do
      expected_response =
        from [question: q] in @q,
          order_by: [asc: q.title]

      assert inspect(OrderQuery.by(@q, "title", "asc")) == inspect(expected_response)
    end

    test "returns query ordered by category in desc order" do
      expected_response =
        from [question: q] in @q,
          order_by: [desc: q.category]

      assert inspect(OrderQuery.by(@q, "category", "desc")) == inspect(expected_response)
    end

    test "returns query ordered by category in asc order" do
      expected_response =
        from [question: q] in @q,
          order_by: [asc: q.category]

      assert inspect(OrderQuery.by(@q, "category", "asc")) == inspect(expected_response)
    end

    test "returns query ordered by status in desc order" do
      expected_response =
        from [question: q] in @q,
          order_by: [desc: q.status]

      assert inspect(OrderQuery.by(@q, "status", "desc")) == inspect(expected_response)
    end

    test "returns query ordered by status in asc order" do
      expected_response =
        from [question: q] in @q,
          order_by: [asc: q.status]

      assert inspect(OrderQuery.by(@q, "status", "asc")) == inspect(expected_response)
    end
  end
end
