defmodule Questions.Doubts.Queries.OrderQuery do
  @moduledoc false
  import Ecto.Query

  @doc """
  Order questions queries by:
  * `title`
  * `category`
  * `status`

  The query will be sorted by `inserted_at` desc when *field* is any other value.
  """

  @spec by(Ecto.Query.t(), String.t(), String.t()) :: Ecto.Query.t()
  def by(%Ecto.Query{} = query, "title", direction) do
    order_direction = order_direction(direction)
    by_question_field(query, :title, order_direction)
  end

  def by(%Ecto.Query{} = query, "category", direction) do
    order_direction = order_direction(direction)
    by_question_field(query, :category, order_direction)
  end

  def by(%Ecto.Query{} = query, "status", direction) do
    order_direction = order_direction(direction)
    by_question_field(query, :status, order_direction)
  end

  def by(%Ecto.Query{} = query, _, _) do
    from [question: q] in query,
      order_by: [desc: q.inserted_at]
  end

  defp by_question_field(%Ecto.Query{} = query, field, direction)
       when is_atom(direction) do
    order_by(query, [question: q], {^direction, ^field})
  end

  defp order_direction("desc"), do: :desc
  defp order_direction(_), do: :asc
end
