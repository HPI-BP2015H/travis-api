module Travis::API::V3
  class Services::Dependencies::Create < Service
    result_type :dependency
    params :dependency_id, :dependency_slug

    def run!
      raise LoginRequired unless access_control.logged_in? or access_control.full_access?
      raise NotFound unless dependency = query(:repository).find_by_slug_or_id(params["dependency_slug"], params["dependency_id"])
      raise NotFound unless dependant = find(:repository)
      raise WrongParams if dependency == dependant
      access_control.permissions(dependant).create_dependency!
      relation = query(:dependency).find(dependency, dependant)
      relation = query(:dependency).create(dependency, dependant) unless relation
      relation
    end
  end
end
