defmodule Tilex.TmxParser do
  @moduledoc """
  Tiled (.tmx) Map XML output parser
  """
  @behaviour Tilex.Parser

  require Logger

  def parse(path) do
    with {:ok, tmx} <- path |> Tilex.XmlParser.parse(&parse_doc!/1) do
      {:ok, Map.merge(tmx, %{path: Path.absname(path)})}
    end
  end

  def parse_doc!(doc_elem) do
    doc_elem |> Tilex.Map.Xml.parse!()
  end
end
