defmodule App.User do
  use App.Model
  use Pow.Ecto.Schema
  use Pow.Extension.Ecto.Schema,
    extensions: [PowResetPassword, PowEmailConfirmation, PowInvitation]

  schema "users" do
    field :role, :string, default: "user"
    field :name, :string

    pow_user_fields()

    timestamps()
  end

  def changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> cast(attrs, [:name])
    |> pow_changeset(attrs)
    |> pow_extension_changeset(attrs)
  end

  def changeset_role(user_or_changeset, attrs) do
    user_or_changeset
    |> cast(attrs, [:role])
    |> validate_inclusion(:role, ~w(user admin))
  end

  def filter_by(:email, value), do: dynamic([x], x.email == ^value)
  def filter_by(:name, value), do: dynamic([x], x.name == ^value)

  def status(%{email_confirmed_at: confirmed}) when is_nil(confirmed), do: :pending
  def status(_), do: :confirmed
end
