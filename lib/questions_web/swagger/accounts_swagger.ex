defmodule QuestionsWeb.AccountsSwagger do
  @moduledoc false
  use PhoenixSwagger

  alias QuestionsWeb.Swagger.CommonParameters

  defmacro __using__(_opts) do
    quote do
      swagger_path :index do
        get("/admin/accounts")
        description("List Users")
        CommonParameters.user()
        response(200, "OK", Schema.ref(:Users))
        response(403, "Forbidden")
        response(401, "Unauthorized")
      end

      swagger_path :create do
        post("/admin/accounts")
        description("Add a new user")

        parameters do
          tracker(
            :body,
            Schema.ref(:User),
            "User object that needs to create",
            required: true
          )
        end

        response(201, "Created", Schema.ref(:User))
        response(403, "Forbidden")
        response(401, "Unauthorized")
      end

      ## Schemas
      def swagger_definitions do
        %{
          User:
            swagger_schema do
              title("User")
              description("A single user")

              properties do
                id(:string, "Unique identifier", required: true)
                name(:string, "User name")
                email(:string, "User email")
                role(:string, "User role")
              end

              example(%{
                id: "uuid",
                name: "Dwight",
                email: "dwight@mail.com",
                role: "admin"
              })
            end,
          Users:
            swagger_schema do
              title("Users")
              description("A collection of Users")
              type(:array)
              items(Schema.ref(:User))
            end
        }
      end
    end
  end
end
