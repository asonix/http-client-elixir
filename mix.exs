defmodule Client.Mixfile do
  use Mix.Project

  def project do
    [app: :http_client,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps()]
  end

  def application do
    [applications: [:httpoison]]
  end

  def description do
    """
    A wrapper around HTTPoison with Poison and HTTPoisonFormData for formatting payloads.
    """
  end

  def package do
    [# These are the default files included in the package
     name: :http_client,
     maintainers: ["Riley Trautman", "asonix.dev@gmail.com"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/asonix/http-client-elixir"}]
  end

  defp deps do
    [{:httpoison, "~> 0.9.0"},
     {:httpoison_form_data, "~> 0.1"},
     {:poison, "~> 2.0"},
     {:bypass, "~> 0.1", only: :test}]
  end
end
