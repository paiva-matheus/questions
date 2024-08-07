defmodule Questions.Doubts.Queries.FilterQuery do
  @moduledoc false
  import Ecto.Query

  @spec by(Ecto.Query.t(), keyword()) :: Ecto.Query.t()
  def by(%Ecto.Query{} = query, filters) do
    Enum.reduce(filters, query, fn {key, value}, query ->
      filter_by(query, key, value)
    end)
  end

  defp filter_by(%Ecto.Query{} = query, _, nil), do: query

  defp filter_by(%Ecto.Query{} = query, :title, value) do
    where(query, [question: q], ilike(q.title, ^"%#{value}%"))
  end

  defp filter_by(%Ecto.Query{} = query, :status, value) do
    where(query, [question: q], q.status == ^value)
  end

  defp filter_by(%Ecto.Query{} = query, :category, value) do
    where(query, [question: q], q.category == ^value)
  end
end
