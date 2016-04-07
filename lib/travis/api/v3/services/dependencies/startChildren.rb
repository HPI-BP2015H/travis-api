module Travis::API::V3
  class Services::Dependencies::StartChildren < Service
    def run!
      query(:dependency).startChildren(find(:repository))
    end
  end
end
