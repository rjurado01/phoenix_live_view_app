require Ecto.Query

alias Web.Controller.ParseQueryParams

defmodule Web.Controller.Query do
  def run_query(model, params) do
    parsed_params = ParseQueryParams.parse_query_params(params)

    query = model
      |> run_filters(parsed_params.filter)
      |> run_order(parsed_params.order)

    resources = query
      |> run_pagination(parsed_params.page)
      |> App.Repo.all

    meta = get_meta(resources, params, parsed_params.page)

    {:ok, Enum.slice(resources, 0, parsed_params.page.size), meta}
  end

  defp run_filters(model, nil) do
    model
  end

  defp run_filters(model, params) do
    model |> App.Repo.filter(params)
  end

  defp run_order(query, params) do
    order_params = Enum.map(params, fn {field, dir} -> {dir, field} end)
    Ecto.Query.order_by(query, ^order_params)
  end

  defp run_pagination(query, params) do
    query
      |> Ecto.Query.limit(^params.size + 1)
      |> Ecto.Query.offset(^((params.number - 1) * params.size))
  end

  defp get_meta(resources, params, page_params) do
    page_next_params = if Enum.count(resources) > page_params.size do
      Map.merge(params, %{"page" => %{"number" => page_params.number + 1}})
    end

    page_prev_params = if page_params.number > 1 do
      Map.merge(params, %{"page" => %{"number" => page_params.number - 1}})
    end

    %{
      page_prev_params: page_prev_params,
      page_next_params: page_next_params
    }
  end
end
