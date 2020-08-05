defmodule Spidey do
  @moduledoc """
  Spidey is a basic web crawler written in Elixir which runs through all the
  links of a same domain and outputs them in a simple text sitemap format.
  """

  alias Spidey.Core.Crawler

  @doc "Crawls a website for all the same-domain urls, returning a list."
  def crawl(url) do
    url
    |> Crawler.new()
    |> Crawler.crawl()
  end

  @doc "Saves a list of urls to file"
  def save_results(urls, path) when is_list(urls) do
    Spidey.Core.File.save(urls, path)
  end
end
