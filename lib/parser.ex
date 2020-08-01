defmodule Tilex.Parser do
  @callback parse(path :: String.t) :: {:ok, tilex_struct :: struct} | {:error, reason :: term}
end
