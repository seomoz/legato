module Legato
  module Management
    module Finder

      def base_uri
        "https://www.googleapis.com/analytics/v3/management"
      end

      def all(user, path=default_path)
        uri = if user.api_key
          # oauth + api_key
          base_uri + path + "?key=#{user.api_key}"
        else
          # oauth 2
          base_uri + path
        end

        collect_items(user, uri).map do |item|
          new(item, user)
        end
      end

      private
        def items_key; "items"; end
        def next_link_key; "nextLink"; end

        def collect_items(user, base_uri)
          next_uri = base_uri
          item_collection = []

          while next_uri
            url_result = url_fetch_for_user(user, next_uri)
            item_collection.concat(url_result.fetch(items_key, []))
            next_uri = url_result.fetch(next_link_key, nil)
          end

          item_collection
        end

        def url_fetch_for_user(user, path)
          MultiJson.decode(user.access_token.get(path).body)
        end
    end
  end
end
