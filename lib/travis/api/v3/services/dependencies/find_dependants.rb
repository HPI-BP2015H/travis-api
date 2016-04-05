module Travis::API::V3
  class Services::Dependencies::FindDependants < Service


    def run!
      find(:repository).dependants
    end
  end
end
