defmodule AlphaVantageApi.Utils do
  def parse_date(date) do
    cond do
      String.match?(
        date,
        ~r/[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1]) (2[0-3]|[01][0-9]):[0-5][0-9]:[0-5][0-9]/
      ) ->
        Timex.parse!(date, "%Y-%m-%d %H:%M:%S", :strftime) |> Timex.to_datetime()

      String.match?(date, ~r/\d{4}\-(0[1-9]|1[012])\-(0[1-9]|[12][0-9]|3[01])/) ->
        Timex.parse!(date, "{YYYY}-{M}-{D}") |> Timex.to_datetime()

      true ->
        date
    end
  end
end
