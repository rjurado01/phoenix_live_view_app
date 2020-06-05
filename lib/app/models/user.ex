defmodule App.User do
  use App.Model
  use Pow.Ecto.Schema
  use Pow.Extension.Ecto.Schema,
    extensions: [PowResetPassword, PowEmailConfirmation, PowInvitation]

  schema "users" do
    field :role, :string, default: "user"
    field :name, :string
    field :avatar_url, :string
    field :avatar_base64, :string, virtual: true

    pow_user_fields()

    timestamps()
  end

  def changeset_create(user_or_changeset, attrs) do
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

  def changeset_update(user_or_changeset, attrs) do
    user_or_changeset
    |> cast(attrs, [:name, :avatar_url, :avatar_base64])
    |> validate_required(:name)
    |> preprocess_avatar
    |> save_avatar
  end

  def preprocess_avatar(changeset) do
    avatar_base64 = get_change(changeset, :avatar_base64)

    if avatar_base64 do
      [extension, data64] = Regex.run(
        ~r/data:image\/(.+);base64,(.+)/,
        avatar_base64,
        capture: :all_but_first
      )

      if Enum.member?(["jpg", "jpeg", "png"], extension) do
        filename = "#{changeset.data.id}-#{:os.system_time(:millisecond)}.#{extension}"
        folder = "uploads/avatars/"
        path = Path.join(folder, filename)

        change(changeset, avatar_url: path, avatar_base64: data64)
      else
        add_error(changeset, :avatar_base64, "invalid")
      end
    else
      changeset
    end
  end

  def save_avatar(changeset) do
    data64 = get_change(changeset, :avatar_base64)

    if changeset.valid? && data64 do
      path = get_change(changeset, :avatar_url)
      data = Base.decode64!(data64)

      File.mkdir_p(Path.dirname(path))
      File.write(path, data, [:binary])

      change(changeset, avatar_url: path)
    else
      IO.inspect changeset.errors
      changeset
    end
  end

  def filter_by(:email, value), do: dynamic([x], x.email == ^value)
  def filter_by(:name, value), do: dynamic([x], x.name == ^value)

  def status(%{email_confirmed_at: confirmed}) when is_nil(confirmed), do: :pending
  def status(_), do: :confirmed
end
