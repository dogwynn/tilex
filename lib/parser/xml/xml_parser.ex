defmodule Tilex.XmlParser do
  require Logger

  def parse(path, parse_func!) do
    Logger.info("Parsing XML path #{path}")

    with {:ok, raw_binary} <- File.read(path),
         {:ok, doc_elem} <- parse_xml(raw_binary),
         {:ok, tilex_struct} <- parse_doc(doc_elem, parse_func!) do
      {:ok, tilex_struct}
    end
  end

  def parse_xml(raw_binary) do
    try do
      parsed = SweetXml.parse(raw_binary, quiet: true)
      {:ok, parsed}
    rescue
      error -> {:error, {:xml_parsing, error}}
    catch
      :exit, error -> {:error, {:fatal_xml, error}}
    end
  end

  def parse_doc(doc_elem, parse_func!) do
    try do
      {:ok, parse_func!.(doc_elem)}
    rescue
      error -> {:error, {:element_xml_parsing, error}}
    end
  end
end
