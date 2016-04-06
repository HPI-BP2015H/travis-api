module Travis::API::V3
  class Renderer::Dependencies < Renderer::CollectionRenderer
    type           :repositories
    collection_key :repositories

    def representation
      :minimal
    end
  end
end
