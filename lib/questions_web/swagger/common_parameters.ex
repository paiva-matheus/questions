defmodule QuestionsWeb.Swagger.CommonParameters do
  @moduledoc "Common parameter declarations for phoenix swagger"

  import PhoenixSwagger.Path

  alias PhoenixSwagger.Path.PathObject

  def question(path = %PathObject{}) do
    path
    |> parameter("title", :query, :string, "Question Title", required: true)
    |> parameter("description", :query, :string, "Question Description", required: true)
    |> parameter(
      "category",
      :query,
      :array,
      "Available values : technology, engineering, science, others",
      items: [type: :string, enum: [:technology, :engineering, :science, :others]],
      collectionFormat: :csv,
      required: true
    )
    |> parameter("status", :query, :array, "Available values : open, in_progress, completed",
      items: [type: :string, enum: [:open, :in_progress, :completed]],
      collectionFormat: :csv,
      default: :open
    )
  end

  def user(path = %PathObject{}) do
    path
    |> parameter("name", :query, :string, "User name", required: true)
    |> parameter("email", :query, :string, "User email", required: true)
    |> parameter("password", :query, :string, "User password", required: true)
    |> parameter("role", :query, :array, "Available roles : student, monitor, admin",
      items: [type: :string, enum: [:student, :monitor, :admin]],
      collectionFormat: :csv,
      required: true
    )
  end
end
