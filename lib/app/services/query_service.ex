defmodule App.QueryService do
  require Ecto.Query

  def init_params do
    %{
      page_number: 1,
      page_size: 5,
      order_field: :id,
      order_dir: :desc,
    }
  end

  def run(model, params) do
    query = model
            |> order(params)
            |> paginate(params)

    resources = App.Repo.all(query)

    meta = %{next: Enum.count(resources) > params.page_size}

    {:ok, Enum.slice(resources, 0, params.page_size), meta}
  end

  def order(query, params) do
    Ecto.Query.order_by(query, [{^params.order_dir, ^params.order_field}])
  end

  def paginate(query, params) do
    query
    |> Ecto.Query.limit(^params.page_size + 1)
    |> Ecto.Query.offset(^((params.page_number - 1) * params.page_size))
  end
end
