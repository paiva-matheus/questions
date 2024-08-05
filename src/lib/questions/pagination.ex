defmodule Questions.Pagination do
  @moduledoc false
  import Ecto.Query

  alias Questions.Repo

  @type t :: %{
          total_records: non_neg_integer(),
          total_pages: non_neg_integer(),
          previous_page: nil | String.t(),
          next_page: nil | String.t()
        }

  @spec paginate(Ecto.Query.t(), integer(), integer(), keyword(), keyword()) :: %{
          data: list(),
          pagination: t()
        }
  def paginate(%Ecto.Query{} = q, page \\ 1, per_page \\ 10, filters \\ [], ordering \\ []) do
    offset = (page - 1) * per_page
    results = query(q, offset, per_page)
    query_without_preloads = Ecto.Query.exclude(q, :preload) |> Ecto.Query.exclude(:select)
    total_records = Repo.one(from(t in subquery(query_without_preloads), select: count("t.id")))
    total_pages = ceil(total_records / per_page)
    filters = get_query_params(filters)
    ordering = get_query_params(ordering)

    %{
      pagination: %{
        total_records: total_records,
        total_pages: total_pages,
        previous_page: get_previous_page(per_page, page, filters, ordering),
        next_page: get_next_page(per_page, page, total_pages, filters, ordering)
      },
      data: results
    }
  end

  defp query(%Ecto.Query{} = q, offset, limit) do
    q
    |> limit(^limit)
    |> offset(^offset)
    |> Repo.all()
  end

  defp get_previous_page(per_page, page, filters, ordering) do
    page_value = page - 1

    previous_page =
      if page_value < 1,
        do: nil,
        else: "?per_page=#{per_page}&page=#{page_value}#{filters}#{ordering}"

    previous_page
  end

  defp get_next_page(per_page, page, total_pages, filters, ordering) do
    page_value = page + 1

    next_page =
      if page_value > total_pages,
        do: nil,
        else: "?per_page=#{per_page}&page=#{page_value}#{filters}#{ordering}"

    next_page
  end

  defp get_query_params(list) do
    list
    |> Keyword.drop([:page, :per_page])
    |> Enum.map_join(fn {k, v} ->
      if is_nil(v), do: ~c"", else: "&#{k}=#{v}"
    end)
  end
end
