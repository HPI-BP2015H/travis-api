require 'travis/api/v3/renderer/model_renderer'

module Travis::API::V3
  class Renderer::Dependency < Renderer::ModelRenderer
    representation(:minimal,  :id)
    representation(:standard, :id, :dependency, :dependant)
  end
end
