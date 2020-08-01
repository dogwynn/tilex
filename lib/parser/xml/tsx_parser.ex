defmodule Tilex.TsxParser do
  @moduledoc """
  Tiled (.tsx) TileSet XML output parser
  """
  @behaviour Tilex.Parser

  require Logger

  def parse(path) do
    with {:ok, tsx} <- path |> Tilex.XmlParser.parse(&parse_doc!/1) do
      {:ok, Map.merge(tsx, %{path: Path.absname(path)})}
    end
  end

  def parse_doc!(doc_elem) do
    doc_elem |> Tilex.TileSet.Xml.parse!()
  end
end
