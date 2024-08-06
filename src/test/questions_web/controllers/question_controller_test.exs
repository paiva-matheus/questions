defmodule QuestionsWeb.QuestionControllerTest do
  use QuestionsWeb.ConnCase, async: true

  alias Questions.Factory
  alias Questions.Repo

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create/2" do
    test "returns 201 with created question", %{conn: conn} do
      user = Factory.insert(:user)

      params = %{
        "title" => "First question",
        "description" => "I have a question",
        "category" => "technology",
        "user_id" => user.id
      }

      conn =
        conn
        |> authorize_request!(user)
        |> post(Routes.question_path(conn, :create), params)

      response = json_response(conn, 201)["data"]

      assert response["title"] == params["title"]
      assert response["description"] == params["description"]
      assert response["category"] == params["category"]
      assert response["status"] == "open"
      assert response["answers"] == nil
    end

    test "returns 403 when user doesn't have permission", %{conn: conn} do
      user = Factory.insert(:user, role: "invalid")

      conn =
        conn
        |> authorize_request!(user)
        |> post(Routes.question_path(conn, :create), %{})

      assert json_response(conn, 403) == %{
               "errors" => %{
                 "detail" => "Forbidden"
               }
             }
    end

    test "returns 401 for unauthorized request", %{conn: conn} do
      conn = post(conn, Routes.question_path(conn, :create), %{})

      assert json_response(conn, 401) == %{
               "errors" => %{
                 "detail" => "Unauthorized"
               }
             }
    end

    test "returns 422 when required fields are missing", %{conn: conn} do
      user = Factory.insert(:user)

      conn =
        conn
        |> authorize_request!(user)
        |> post(Routes.question_path(conn, :create), %{})

      assert json_response(conn, 422) == %{
               "errors" => %{
                 "title" => ["can't be blank"],
                 "description" => ["can't be blank"],
                 "category" => ["can't be blank"],
                 "user_id" => ["can't be blank"]
               }
             }
    end
  end

  describe "show/2" do
    setup [:show_setup]

    defp show_setup(%{conn: conn}) do
      user = Factory.insert(:user)

      conn =
        conn
        |> put_req_header("accept", "application/json")
        |> authorize_request!(user)

      %{conn: conn}
    end

    test "returns 200", %{conn: conn} do
      question = Factory.insert(:question)
      answer = Factory.insert(:answer, question: question)
      conn = get(conn, Routes.question_path(conn, :show, question.id))

      assert json_response(conn, 200)["data"] == %{
               "id" => question.id,
               "title" => question.title,
               "description" => question.description,
               "category" => question.category,
               "status" => question.status,
               "answers" => [
                 %{
                   "id" => answer.id,
                   "content" => answer.content,
                   "monitor" => %{
                     "id" => answer.user.id,
                     "name" => answer.user.name,
                     "email" => answer.user.email
                   }
                 }
               ],
               "user" => %{
                 "id" => question.user.id,
                 "name" => question.user.name,
                 "email" => question.user.email,
                 "role" => question.user.role
               }
             }
    end

    test "returns 404", %{conn: conn} do
      conn = get(conn, Routes.question_path(conn, :show, Ecto.UUID.generate()))
      assert json_response(conn, 404) == %{"errors" => %{"detail" => "Not Found"}}
    end

    test "returns 401", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "")
        |> get(Routes.question_path(conn, :show, Ecto.UUID.generate()))

      assert json_response(conn, 401) == %{"errors" => %{"detail" => "Unauthorized"}}
    end
  end

  describe "complete/2" do
    setup [:complete_setup]

    defp complete_setup(%{conn: conn}) do
      user = Factory.insert(:user, role: "student")

      conn =
        conn
        |> put_req_header("accept", "application/json")
        |> authorize_request!(user)

      %{conn: conn, user: user}
    end

    test "returns 200", %{conn: conn, user: user} do
      question = Factory.insert(:question, status: "open", user: user)
      answers = Factory.insert_list(10, :answer, question: question)
      conn = patch(conn, Routes.question_question_path(conn, :complete, question.id))

      assert json_response(conn, 200)["data"] == %{
               "id" => question.id,
               "title" => question.title,
               "description" => question.description,
               "category" => question.category,
               "status" => "completed",
               "answers" =>
                 Enum.map(answers, fn answer ->
                   %{
                     "id" => answer.id,
                     "content" => answer.content,
                     "monitor" => %{
                       "id" => answer.user.id,
                       "name" => answer.user.name,
                       "email" => answer.user.email
                     }
                   }
                 end),
               "user" => %{
                 "id" => question.user.id,
                 "name" => question.user.name,
                 "email" => question.user.email,
                 "role" => question.user.role
               }
             }
    end

    test "returns 404", %{conn: conn} do
      conn = patch(conn, Routes.question_question_path(conn, :complete, Ecto.UUID.generate()))

      assert json_response(conn, 404) == %{"errors" => %{"detail" => "Not Found"}}
    end

    test "returns 401", %{conn: conn} do
      question = Factory.insert(:question, status: "open")

      conn =
        conn
        |> put_req_header("authorization", "")
        |> patch(Routes.question_question_path(conn, :complete, question.id))

      assert json_response(conn, 401) == %{"errors" => %{"detail" => "Unauthorized"}}
    end

    test "returns 403", %{conn: conn} do
      user = Factory.insert(:user, role: "monitor")
      question = Factory.insert(:question, status: "open", user: user)

      conn =
        conn
        |> authorize_request!(user)
        |> patch(Routes.question_question_path(conn, :complete, question.id))

      assert json_response(conn, 403) == %{"errors" => %{"detail" => "Forbidden"}}
    end

    test "returns 403 when student is not the owner", %{conn: conn} do
      user = Factory.insert(:user, role: "student")
      question = Factory.insert(:question)

      conn =
        conn
        |> authorize_request!(user)
        |> patch(Routes.question_question_path(conn, :complete, question.id))

      assert json_response(conn, 403) == %{"errors" => %{"detail" => "Forbidden"}}
    end
  end

  describe "index/2" do
    test "returns 200 with questions", %{conn: conn} do
      user = Factory.insert(:user)

      expected_response_data =
        Factory.insert_list(10, :question)
        |> Enum.sort_by(& &1.inserted_at, {:desc, NaiveDateTime})
        |> Repo.reload()
        |> Repo.preload([:user, answers: [:user]])
        |> Enum.map(fn question ->
          %{
            "id" => question.id,
            "title" => question.title,
            "description" => question.description,
            "category" => question.category,
            "status" => question.status,
            "answers" =>
              Enum.map(question.answers, fn answer ->
                %{
                  "id" => answer.id,
                  "content" => answer.content,
                  "monitor" => %{
                    "id" => answer.user.id,
                    "name" => answer.user.name,
                    "email" => answer.user.email
                  }
                }
              end),
            "user" => %{
              "id" => question.user.id,
              "name" => question.user.name,
              "email" => question.user.email,
              "role" => question.user.role
            }
          }
        end)

      conn =
        conn
        |> authorize_request!(user)
        |> get(Routes.question_path(conn, :index))

      assert json_response(conn, 200)["data"] == expected_response_data
    end

    test "returns 200 with paginated result", %{conn: conn} do
      user = Factory.insert(:user)
      Factory.insert_list(30, :question)

      expected_response_pagination = %{
        "next_page" => "?per_page=10&page=3",
        "previous_page" => "?per_page=10&page=1",
        "total_pages" => 3,
        "total_records" => 30
      }

      params = %{"per_page" => "10", "page" => "2"}

      conn =
        conn
        |> authorize_request!(user)
        |> get(Routes.question_path(conn, :index), params)

      assert json_response(conn, 200)["pagination"] == expected_response_pagination
    end

    test "returns 200 with data filtered by student name", %{conn: conn} do
      user = Factory.insert(:user)
      Factory.insert_list(10, :question)

      expected_question =
        Factory.insert(:question, title: "Elixir")

      params = %{"title" => "Elixir"}

      conn =
        conn
        |> authorize_request!(user)
        |> get(Routes.question_path(conn, :index), params)

      assert %{"data" => questions} = json_response(conn, 200)
      assert List.first(questions)["id"] == expected_question.id
    end

    test "returns 200 with data filtered by status", %{conn: conn} do
      user = Factory.insert(:user)

      [_, _, expected_question] =
        ["open", "in_progress", "completed"]
        |> Enum.map(
          &Factory.insert(:question,
            status: &1
          )
        )

      params = %{"status" => "completed"}

      conn =
        conn
        |> authorize_request!(user)
        |> get(Routes.question_path(conn, :index), params)

      assert %{"data" => questions} = json_response(conn, 200)
      assert List.first(questions)["id"] == expected_question.id
    end

    test "returns 200 with data filtered by category", %{conn: conn} do
      user = Factory.insert(:user)

      [_, _, expected_question] =
        ["technology", "engineering", "science"]
        |> Enum.map(
          &Factory.insert(:question,
            category: &1
          )
        )

      params = %{"category" => "science"}

      conn =
        conn
        |> authorize_request!(user)
        |> get(Routes.question_path(conn, :index), params)

      assert %{"data" => questions} = json_response(conn, 200)
      assert List.first(questions)["id"] == expected_question.id
    end

    test "returns 200 with data ordered by title", %{conn: conn} do
      user = Factory.insert(:user)

      expected_questions =
        ["React", "Java", "Elixir"]
        |> Enum.map(&Factory.insert(:question, title: &1))

      params = %{"order_by" => "title", "order" => "desc"}

      conn =
        conn
        |> authorize_request!(user)
        |> get(Routes.question_path(conn, :index), params)

      assert %{"data" => questions} = json_response(conn, 200)
      assert_lists(questions, expected_questions)
    end

    test "returns 200 with data ordered by status", %{conn: conn} do
      user = Factory.insert(:user)

      expected_questions =
        ["completed", "in_progress", "open"]
        |> Enum.map(&Factory.insert(:question, status: &1))

      params = %{"order_by" => "status", "order" => "asc"}

      conn =
        conn
        |> authorize_request!(user)
        |> get(Routes.question_path(conn, :index), params)

      assert %{"data" => questions} = json_response(conn, 200)
      assert_lists(questions, expected_questions)
    end

    test "returns 200 with data ordered by category", %{conn: conn} do
      user = Factory.insert(:user)

      expected_questions =
        ["technology", "science", "engineering"]
        |> Enum.map(&Factory.insert(:question, category: &1))

      params = %{"order_by" => "category", "order" => "desc"}

      conn =
        conn
        |> authorize_request!(user)
        |> get(Routes.question_path(conn, :index), params)

      assert %{"data" => questions} = json_response(conn, 200)
      assert_lists(questions, expected_questions)
    end
  end

  describe "delete/2" do
    test "returns 204", %{conn: conn} do
      user = Factory.insert(:user, role: "student")
      question = Factory.insert(:question, user: user)

      conn =
        conn
        |> authorize_request!(user)
        |> delete(Routes.question_path(conn, :delete, question.id))

      assert response(conn, 204) == ""
    end

    test "returns 404", %{conn: conn} do
      user = Factory.insert(:user, role: "admin")

      conn =
        conn
        |> authorize_request!(user)
        |> delete(Routes.question_path(conn, :delete, Ecto.UUID.generate()))

      assert json_response(conn, 404) == %{
               "errors" => %{
                 "detail" => "Not Found"
               }
             }
    end

    test "returns 403 when user doesn't have permission", %{conn: conn} do
      user = Factory.insert(:user, role: "monitor")
      question = Factory.insert(:question)

      conn =
        conn
        |> authorize_request!(user)
        |> delete(Routes.question_path(conn, :delete, question.id))

      assert json_response(conn, 403) == %{
               "errors" => %{
                 "detail" => "Forbidden"
               }
             }
    end

    test "returns 403 when student is not the owner", %{conn: conn} do
      user = Factory.insert(:user, role: "student")
      question = Factory.insert(:question)

      conn =
        conn
        |> authorize_request!(user)
        |> delete(Routes.question_path(conn, :delete, question.id))

      assert json_response(conn, 403) == %{
               "errors" => %{
                 "detail" => "Forbidden"
               }
             }
    end

    test "returns 401 for unauthorized request", %{conn: conn} do
      question = Factory.insert(:question)
      conn = delete(conn, Routes.question_path(conn, :delete, question.id))

      assert json_response(conn, 401) == %{
               "errors" => %{
                 "detail" => "Unauthorized"
               }
             }
    end
  end

  defp assert_lists(response_list, expected_list) do
    Enum.with_index(response_list, fn response_data, index ->
      expected_data = Enum.at(expected_list, index)
      assert response_data["id"] == expected_data.id
    end)
  end
end
