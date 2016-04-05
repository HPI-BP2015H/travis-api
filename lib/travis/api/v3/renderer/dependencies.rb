module Travis::API::V3
  class Renderer::Dependencies < Renderer::CollectionRenderer
    type           :repositories
    collection_key :repositories
  end
end
