defmodule QuestionsWeb.StudentsSwagger do
  @moduledoc false
  use PhoenixSwagger

  defmacro __using__(_opts) do
    quote do
      swagger_path :create do
        post("/students")
        description("Add a new student")

        parameters do
          tracker(
            :body,
            Schema.ref(:Student),
            "Student object that needs to create",
            required: true
          )
        end

        response(201, "Created", Schema.ref(:Student))
      end

      ## Schemas
      def swagger_definitions do
        %{
          Student:
            swagger_schema do
              title("User")
              description("A single user")

              properties do
                id(:string, "Unique identifier", required: true)
                name(:string, "User name")
                email(:string, "User email")
                role(:string, "Student")
              end

              example(%{
                id: "uuid",
                name: "Dwight",
                email: "dwight@mail.com",
                role: "student"
              })
            end
        }
      end
    end
  end
end
