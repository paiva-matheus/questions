defmodule Questions.AccessControl.Guardian do
  @moduledoc "Guardian use this module to encoding and decoding tokens"

  use Guardian, otp_app: :questions
  alias Questions.Accounts.User

  @spec subject_for_token(User.t(), Map.t()) :: {:ok, String.t()}
  def subject_for_token(user, _claims) do
    sub = to_string(user.id)
    {:ok, sub}
  end

  @spec resource_from_claims(Map.t()) :: User.t()
  def resource_from_claims(claims) do
    id = claims["sub"]
    Questions.Accounts.get_user(id)
  end
end
