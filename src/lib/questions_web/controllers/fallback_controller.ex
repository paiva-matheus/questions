defmodule QuestionsWeb.FallbackController do
  use QuestionsWeb, :controller

  def call(conn, {:error, :bad_request}) do
    conn
    |> put_status(400)
    |> put_view(QuestionsWeb.ErrorView)
    |> render("400.json")
  end

  def call(conn, :forbidden) do
    conn
    |> put_status(403)
    |> put_view(QuestionsWeb.ErrorView)
    |> render("403.json")
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(403)
    |> put_view(QuestionsWeb.ErrorView)
    |> render("403.json")
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(404)
    |> put_view(QuestionsWeb.ErrorView)
    |> render("404.json")
  end

  def call(conn, {:conflict, true}) do
    conn
    |> put_status(409)
    |> put_view(QuestionsWeb.ErrorView)
    |> render("409.json")
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    errors = traverse_errors(changeset)

    conn
    |> put_status(:unprocessable_entity)
    |> put_view(QuestionsWeb.ErrorView)
    |> render("unprocessable_entity.json", errors: errors)
  end

  def call(conn, {:error, _, %Ecto.Changeset{} = changeset, _}) do
    errors = traverse_errors(changeset)

    conn
    |> put_status(:unprocessable_entity)
    |> put_view(QuestionsWeb.ErrorView)
    |> render("unprocessable_entity.json", errors: errors)
  end

  defp traverse_errors(%Ecto.Changeset{} = changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
