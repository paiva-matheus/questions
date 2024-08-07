defmodule Questions.PaginationTest do
  use Questions.DataCase, async: true

  import Ecto.Query

  alias Questions.Factory
  alias Questions.Pagination
  alias Questions.Doubts.Question

  describe "paginate" do
    test "returns pagination when not exists previous page" do
      questions = Factory.insert_list(20, :question) |> Enum.sort_by(& &1.id)

      query = from(q in Question, order_by: q.id, preload: [:user])

      expected_response = %{
        pagination: %{
          total_records: 20,
          total_pages: 2,
          previous_page: nil,
          next_page: "?per_page=10&page=2"
        },
        data: Enum.slice(questions, 0, 10)
      }

      assert expected_response == Pagination.paginate(query)
    end

    test "returns pagination when not exists next page" do
      questions = Factory.insert_list(10, :question) |> Enum.sort_by(& &1.id)

      query = from(q in Question, order_by: q.id, preload: [:user])

      expected_response = %{
        pagination: %{
          total_records: 10,
          total_pages: 1,
          previous_page: nil,
          next_page: nil
        },
        data: questions
      }

      assert expected_response == Pagination.paginate(query)
    end

    test "returns pagination changing default values" do
      questions = Factory.insert_list(10, :question) |> Enum.sort_by(& &1.id)

      query = from(q in Question, order_by: q.id, preload: [:user])

      expected_response = %{
        pagination: %{
          total_records: 10,
          total_pages: 5,
          previous_page: "?per_page=2&page=1",
          next_page: "?per_page=2&page=3"
        },
        data: Enum.slice(questions, 2, 2)
      }

      page = 2
      per_page = 2
      assert expected_response == Pagination.paginate(query, page, per_page)
    end

    test "returns empty list when page is empty" do
      Factory.insert_list(3, :question)

      query = from(q in Question)

      expected_response = %{
        pagination: %{
          total_records: 3,
          total_pages: 1,
          previous_page: "?per_page=10000&page=1",
          next_page: nil
        },
        data: []
      }

      page = 2
      per_page = 10_000
      assert expected_response == Pagination.paginate(query, page, per_page)
    end

    test "returns next_page and previous_page with filters" do
      questions = Factory.insert_list(10, :question) |> Enum.sort_by(& &1.id)

      query = from(q in Question, order_by: q.id, preload: [:user])

      expected_response = %{
        pagination: %{
          total_records: 10,
          total_pages: 5,
          previous_page: "?per_page=2&page=1&q=elixir&status=open",
          next_page: "?per_page=2&page=3&q=elixir&status=open"
        },
        data: Enum.slice(questions, 2, 2)
      }

      page = 2
      per_page = 2

      assert expected_response ==
               Pagination.paginate(query, page, per_page, q: "elixir", status: "open")
    end

    test "returns next_page and previous_page with ordering" do
      questions =
        Factory.insert_list(30, :question)
        |> Enum.sort_by(&String.normalize(&1.title, :nfd), :asc)

      query = from(q in Question, preload: [:user], order_by: [asc: q.title])

      expected_response = %{
        pagination: %{
          total_records: 30,
          total_pages: 3,
          previous_page: "?per_page=10&page=1&order_by=title&order=asc",
          next_page: "?per_page=10&page=3&order_by=title&order=asc"
        },
        data: Enum.slice(questions, 10, 10)
      }

      page = 2
      per_page = 10

      assert expected_response ==
               Pagination.paginate(query, page, per_page, order_by: "title", order: "asc")
    end

    test "returns next_page and previous_page without page or per_page if they come as filters" do
      questions = Factory.insert_list(10, :question, title: "Java") |> Enum.sort_by(& &1.id)

      query = from(q in Question, order_by: q.id, preload: [:user])

      expected_response = %{
        pagination: %{
          total_records: 10,
          total_pages: 5,
          previous_page: "?per_page=2&page=1&q=Java&status=open",
          next_page: "?per_page=2&page=3&q=Java&status=open"
        },
        data: Enum.slice(questions, 2, 2)
      }

      page = 2
      per_page = 2

      assert expected_response ==
               Pagination.paginate(query, page, per_page,
                 q: "Java",
                 status: "open",
                 page: page,
                 per_page: per_page
               )
    end
  end
end
