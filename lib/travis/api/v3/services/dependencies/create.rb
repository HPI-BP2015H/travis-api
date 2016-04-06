module Travis::API::V3
  class Services::Dependencies::Create < Service
    result_type :repository
    params :dependency_id, :dependency_slug

    def run!
      raise LoginRequired unless access_control.logged_in? or access_control.full_access?
      raise NotFound unless dependency = query(:repository).find_by_slug_or_id(params["dependency_slug"], params["dependency_id"])
      raise NotFound unless dependant = find(:repository)
      access_control.permissions(dependant).create_dependency!
      return dependency if query(:dependency).find(dependency, dependant)
      query(:dependency).create(dependency, dependant)
      return dependency
    end

  end
end
