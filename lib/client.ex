defmodule AlphaVantageApi.Client do
  @base_url "https://www.alphavantage.co/query"
  @apikey Application.get_env(:alpha_vantage_api, :apikey)

  def build_params(params, apikey \\ @apikey) when is_map(params) do
    %{"apikey" => apikey}
    |> Map.merge(params)
    |> URI.encode_query()
  end

  def request(params) do
    "#{@base_url}?#{params}"
    |> HTTPoison.get()
  end

  def parse_responce(responce) do
    case responce do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case  Jason.decode(body) do
          {:ok, %{ "Error Message" => reason} } -> {:error, reason}
          {:ok, results} -> {:ok, results}
        end
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end


  def build_base_request(symbol, function) do
    %{
      "function" => function,
      "symbol" => symbol
    }
  end
end
