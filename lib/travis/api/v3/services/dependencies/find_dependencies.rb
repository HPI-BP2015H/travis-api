module Travis::API::V3
  class Services::Dependencies::FindDependencies < Service

    def run!
      find(:repository).dependencies
    end
  end
end
