defmodule AlphaVantageApi.Stocks do
  alias AlphaVantageApi.{Client, Utils}
  alias AlphaVantageApi.Stocks.{Metadata, TsData}
  alias AlphaVantageApi

  ["1min", "5min", "15min", "30min", "60min"]
  |> Enum.each(fn interval ->
    func_name = String.to_atom("intraday_#{interval}")

    def unquote(func_name)(ticker) do
      ConCache.get_or_store(:default, "intraday|#{unquote(interval)}|#{ticker}", fn ->
        fetch_intraday(ticker, unquote(interval))
      end)
    end
  end)

  def daily(ticker) do
    ConCache.get_or_store(:default, "daily|#{ticker}", fn ->
      fetch_daily(ticker)
    end)
  end

  defp fetch_intraday(symbol, interval \\ "1min", outputsize \\ "full") do
    symbol
    |> Client.build_base_request("TIME_SERIES_INTRADAY")
    |> Map.merge(%{"outputsize" => outputsize, "interval" => interval})
    |> Client.build_params()
    |> Client.request()
    |> Client.parse_responce()
    |> format_results()
  end

  defp fetch_daily(symbol, outputsize \\ "full") do
    symbol
    |> Client.build_base_request("TIME_SERIES_DAILY_ADJUSTED")
    |> Map.merge(%{"outputsize" => outputsize})
    |> Client.build_params()
    |> Client.request()
    |> Client.parse_responce()
    |> format_results()
  end


  defp format_results(results) do
    case results do
      {:ok, resp} ->
        ts_key = Map.keys(resp) -- ["Meta Data"]

        data =
          resp
          |> Map.get(List.first(ts_key))
          |> Map.to_list()
          |> Enum.map(fn {date, row_data} ->
            %TsData{
              date: Utils.parse_date(date),
              open: Map.get(row_data, "1. open", nil),
              close: Map.get(row_data, "4. close", nil),
              low: Map.get(row_data, "3. low", nil),
              high: Map.get(row_data, "2. high", nil),
              volume: Map.get(row_data, "6. volume", nil),
              adj_close: Map.get(row_data, "5. adjusted close", nil),
              dividend_amount: Map.get(row_data, "7. dividend amount", nil),
              split_coefficient: Map.get(row_data, "8. split coefficient", nil)
            }
          end)

        %Metadata{
          description: resp["Meta Data"]["1. Information"],
          ticker: resp["Meta Data"]["2. Symbol"],
          last_updated: Utils.parse_date(resp["Meta Data"]["3. Last Refreshed"]),
          timezone: resp["Meta Data"]["5. Time Zone"],
          ts_data:
            Enum.sort_by(data, fn %AlphaVantageApi.Stocks.TsData{date: date} ->
              {date.year, date.month, date.day, date.hour, date.minute, date.second}
            end)
        }

      {:error, reason} ->
        reason
    end
  end
end
