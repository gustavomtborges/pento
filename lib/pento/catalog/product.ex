defmodule Pento.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :description, :string
    field :name, :string
    field :sku, :integer
    field :unit_price, :float
    field :image_upload, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :description, :unit_price, :sku, :image_upload])
    |> validate_required([:name, :description, :unit_price, :sku])
    |> unique_constraint(:sku)
    |> validate_number(:unit_price, greater_than: 0.0)
  end

  def unit_price_changeset(product, attrs) do
    product
    |> cast(attrs, [:unit_price])
    |> validate_unit_price_decrease()
  end

  defp validate_unit_price_decrease(changeset) do
    {:ok, new_price} = fetch_change(changeset, :unit_price)
    current_price = changeset.data.unit_price

    if new_price > current_price do
      add_error(
        changeset,
        :unit_price,
        "New unit price must be lower than the old one"
      )
    else
      changeset
    end
  end
end
