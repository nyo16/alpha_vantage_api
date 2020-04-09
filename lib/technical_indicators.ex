defmodule AlphaVantageApi.TechnicalIndicators do
  alias AlphaVantageApi.{Client, Utils}

  def sma(symbol, interval \\ "daily", time_period \\ "50", series_type \\ "close") do
    ConCache.get_or_store(
      :default,
      "indicator|sma|#{interval}|#{symbol}|#{time_period}|#{series_type}",
      fn ->
        fetch_indicator(symbol, "SMA", interval, time_period, series_type)
      end
    )
  end

  def ema(symbol, interval \\ "daily", time_period \\ "50", series_type \\ "close") do
    ConCache.get_or_store(
      :default,
      "indicator|ema|#{interval}|#{symbol}|#{time_period}|#{series_type}",
      fn ->
        fetch_indicator(symbol, "EMA", interval, time_period, series_type)
      end
    )
  end

  def wma(symbol, interval \\ "daily", time_period \\ "50", series_type \\ "close") do
    ConCache.get_or_store(
      :default,
      "indicator|wma|#{interval}|#{symbol}|#{time_period}|#{series_type}",
      fn ->
        fetch_indicator(symbol, "WMA", interval, time_period, series_type)
      end
    )
  end

  def dema(symbol, interval \\ "daily", time_period \\ "50", series_type \\ "close") do
    ConCache.get_or_store(
      :default,
      "indicator|dema|#{interval}|#{symbol}|#{time_period}|#{series_type}",
      fn ->
        fetch_indicator(symbol, "DEMA", interval, time_period, series_type)
      end
    )
  end

  def rsi(symbol, interval \\ "daily", time_period \\ "50", series_type \\ "close") do
    ConCache.get_or_store(
      :default,
      "indicator|rsi|#{interval}|#{symbol}|#{time_period}|#{series_type}",
      fn ->
        fetch_indicator(symbol, "RSI", interval, time_period, series_type)
      end
    )
  end

  def adx(symbol, interval \\ "daily", time_period \\ "50", series_type \\ "close") do
    ConCache.get_or_store(
      :default,
      "indicator|adx|#{interval}|#{symbol}|#{time_period}|#{series_type}",
      fn ->
        fetch_indicator(symbol, "ADX", interval, time_period, series_type)
      end
    )
  end

  def bbands(symbol, interval \\ "daily", time_period \\ "50", series_type \\ "close") do
    ConCache.get_or_store(
      :default,
      "indicator|bbands|#{interval}|#{symbol}|#{time_period}|#{series_type}",
      fn ->
        fetch_indicator(symbol, "BBANDS", interval, time_period, series_type)
      end
    )
  end

  def macd(symbol, interval \\ "daily", time_period \\ "50", series_type \\ "close") do
    ConCache.get_or_store(
      :default,
      "indicator|macd|#{interval}|#{symbol}|#{time_period}|#{series_type}",
      fn ->
        fetch_indicator(symbol, "MACD", interval, time_period, series_type)
      end
    )
  end

  def sector() do
    ConCache.get_or_store(
      :default,
      "sector|results",
      fn ->
        %{"function" => "SECTOR"}
        |> Client.build_params()
        |> Client.request()
        |> Client.parse_responce()
        |> elem(1)
        |> Map.to_list()
      end
    )
  end

  def fetch_indicator(symbol, indicator, interval, time_period, series_type, extra_params \\ %{}) do
    symbol
    |> Client.build_base_request(indicator)
    |> Map.merge(%{
      "time_period" => time_period,
      "series_type" => series_type,
      "interval" => interval
    })
    |> Map.merge(extra_params)
    |> Client.build_params()
    |> Client.request()
    |> Client.parse_responce()
    |> elem(1)
    |> Map.get("Technical Analysis: #{indicator}")
    |> Map.to_list()
    |> Enum.map(fn row -> parse_row(row) end)
    |> Enum.sort_by(fn %{date: date} ->
      {date.year, date.month, date.day, date.hour, date.minute, date.second}
    end)
  end

  def parse_row(
        {date,
         %{"Real Middle Band" => middle, "Real Upper Band" => upper, "Real Lower Band" => lower}}
      ) do
    %{date: Utils.parse_date(date), middle: middle, upper: upper, lower: lower}
  end

  def parse_row({date, %{"MACD" => macd, "MACD_Hist" => macd_hist, "MACD_Signal" => macd_signal}}) do
    %{date: Utils.parse_date(date), macd: macd, macd_hist: macd_hist, macd_signal: macd_signal}
  end

  def parse_row({date, %{"EMA" => value}}) do
    %{date: Utils.parse_date(date), ema: value}
  end

  def parse_row({date, %{"SMA" => value}}) do
    %{date: Utils.parse_date(date), sma: value}
  end

  def parse_row({date, %{"WMA" => value}}) do
    %{date: Utils.parse_date(date), wma: value}
  end

  def parse_row({date, %{"DEMA" => value}}) do
    %{date: Utils.parse_date(date), dema: value}
  end

  def parse_row({date, %{"RSI" => value}}) do
    %{date: Utils.parse_date(date), rsi: value}
  end

  def parse_row({date, %{"ADX" => value}}) do
    %{date: Utils.parse_date(date), adx: value}
  end
end
