defmodule Questions.Extensions.Ecto.Schema do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema

      @derive Jason.Encoder
      @timestamps_opts [type: :naive_datetime_usec]
      @foreign_key_type :binary_id
      @primary_key {:id, :binary_id, autogenerate: true}
    end
  end
end
