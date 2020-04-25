defmodule App.QueryService do
  require Ecto.Query

  def init_params(params \\ %{}) do
    Map.merge(%{
      page_number: 1,
      page_size: 5,
      order_field: "id",
      order_dir: "desc",
      filter: %{}
    }, params)
  end

  def run(model, params) do
    query = model
            |> App.Repo.filter(params.filter)
            |> order(params)
            |> paginate(params)

    resources = App.Repo.all(query)

    meta = %{next: Enum.count(resources) > params.page_size}

    {:ok, Enum.slice(resources, 0, params.page_size), meta}
  end

  def order(query, params) do
    Ecto.Query.order_by(
      query,
      [{^String.to_atom(params.order_dir), ^String.to_atom(params.order_field)}]
    )
  end

  def paginate(query, params) do
    query
    |> Ecto.Query.limit(^params.page_size + 1)
    |> Ecto.Query.offset(^((params.page_number - 1) * params.page_size))
  end
end
