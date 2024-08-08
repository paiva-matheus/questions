defmodule QuestionsWeb.Swagger.CommonParameters do
  @moduledoc "Common parameter declarations for phoenix swagger"

  alias PhoenixSwagger.Path.PathObject
  import PhoenixSwagger.Path

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

  def question_answer(path = %PathObject{}) do
    path
    |> parameter("content", :query, :string, "Answer content", required: false)
    |> parameter("description", :query, :string, "Question Description", required: false)
    |> parameter("category", :query, :array, "Question Category",
      items: [type: :string, enum: [:technology, :engineering, :science, :others]],
      collectionFormat: :csv
    )
    |> parameter("status", :query, :array, "Question Status",
      items: [type: :string, enum: [:open, :in_progress, :completed]],
      collectionFormat: :csv
    )
  end
end
