defmodule Algoliax.Utils do
  @moduledoc false

  alias Algoliax.Resources.Index

  def index_name(module, settings) do
    index_name_opt = Keyword.get(settings, :index_name)

    if index_name_opt do
      index_name =
        if module.__info__(:functions)
           |> Keyword.get(index_name_opt) == 0 do
          apply(module, index_name_opt, [])
        else
          index_name_opt
        end

      Index.ensure_settings(module, index_name, settings)
      index_name
    else
      raise Algoliax.MissingIndexNameError
    end
  end

  def searchable_attributes(module, settings) do
    searchable_attributes_opt =
      settings
      |> Keyword.get(:algolia)
      |> Keyword.get(:searchable_attributes)

    searchable_attributes =
      if is_atom(searchable_attributes_opt) &&
           module.__info__(:functions)
           |> Keyword.get(searchable_attributes_opt) == 0 do
        apply(module, searchable_attributes_opt, [])
      else
        searchable_attributes_opt
      end

    Index.ensure_settings(module, searchable_attributes, settings)
    searchable_attributes
  end

  def algolia_settings(settings) do
    Keyword.get(settings, :algolia, [])
  end

  def object_id_attribute(settings) do
    Keyword.get(settings, :object_id, :id)
  end

  def schemas(settings, default) do
    Keyword.get(settings, :schemas, default)
  end

  def camelize(params) when is_map(params) do
    Enum.into(params, %{}, fn {k, v} ->
      {camelize(k), v}
    end)
  end

  def camelize(key) do
    key
    |> Atom.to_string()
    |> Inflex.camelize(:lower)
  end
end
