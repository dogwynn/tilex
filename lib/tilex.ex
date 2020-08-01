defmodule TilexParseError do
  defexception message: "Parsing error"
end

defmodule Tilex do
  @moduledoc """
  Documentation for `Tilex`, the Tiled map file parser
  """

  def parse_tmx(path) do
    Tilex.TmxParser.parse(path)
  end

  def parse_tmx!(path) do
    case parse_tmx(path) do
      {:ok, tmx} -> tmx
      {:error, term} -> raise TilexParseError, message: inspect(term)
    end
  end

  def parse_tsx(path) do
    Tilex.TsxParser.parse(path)
  end

  def parse_tsx!(path) do
    case parse_tsx(path) do
      {:ok, tsx} -> tsx
      {:error, term} -> raise TilexParseError, message: inspect(term)
    end
  end
end
