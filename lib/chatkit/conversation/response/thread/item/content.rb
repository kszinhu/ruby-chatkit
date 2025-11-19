# frozen_string_literal: true

module ChatKit
  class Conversation
    class Response
      class Thread
        class Item
          # Represents the content of a thread item.
          class Content
            # @!attribute [rw] type
            #  @return [String, nil]
            attr_accessor :type

            # @!attribute [rw] text
            # @return [String, nil]
            attr_accessor :text

            # @param type [String, nil] - optional - The content type.
            # @param text [String, nil] - optional - The content text.
            def initialize(type: nil, text: nil)
              @type = type
              @text = text
            end
          end
        end
      end
    end
  end
end
