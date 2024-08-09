defmodule QuestionsWeb.QuestionSubscribersSwagger do
  @moduledoc false
  use PhoenixSwagger

  defmacro __using__(_opts) do
    quote do
      swagger_path :create do
        post("/question_subscribers")
        description("Add a new question subscriber")

        parameters do
          tracker(
            :body,
            Schema.ref(:CreateQuestionSubscriberBody),
            "Question object that needs to create",
            required: true
          )
        end

        response(201, "Created", Schema.ref(:QuestionSubscriber))
        response(403, "Forbidden")
        response(401, "Unauthorized")
      end

      ## Schemas
      def swagger_definitions do
        %{
          QuestionSubscriber:
            swagger_schema do
              title("Question Subscriber")
              description("A single question subscriber")

              properties do
                id(:string, "Unique identifier")
                category(:string, "Question category", required: true)

                user(
                  Schema.new do
                    properties do
                      id(:string, "Unique identifier", required: true)
                      name(:string, "User name")
                      email(:string, "User email")
                      role(:string, "User role")
                    end
                  end
                )

                answers(:list, "List of answers")
              end

              example(%{
                id: "uuid",
                category: "technology",
                user: %{
                  id: "uuid",
                  name: "Dwight",
                  email: "dwight@mail.com",
                  role: "admin"
                }
              })
            end,
          CreateQuestionSubscriberBody:
            swagger_schema do
              title("Create Question Subscriber Model")
              description("Template for creating question subscriber")

              properties do
                user_id(:string, "Unique identifier")
                category(:string, "Question category", required: true)
              end
            end
        }
      end
    end
  end
end
