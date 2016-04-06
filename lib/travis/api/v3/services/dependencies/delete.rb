module Travis::API::V3
  class Services::Dependencies::Delete < Service
    result_type :repository
    params :dependency_id, :dependency_slug

    def run!
      raise LoginRequired unless access_control.logged_in? or access_control.full_access?
      raise NotFound.new("dependency_repo not found") unless dependency = query(:repository).find_by_slug_or_id(params["dependency_slug"], params["dependency_id"])
      raise NotFound unless dependant = find(:repository)
      raise NotFound.new(:dependency) unless relation = query(:dependency).find(dependency, dependant)
      access_control.permissions(relation).delete!
      relation.destroy
      return dependency
    end

  end
end
