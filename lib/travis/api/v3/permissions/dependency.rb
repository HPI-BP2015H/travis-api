require 'travis/api/v3/permissions/generic'

module Travis::API::V3
  class Permissions::Dependency < Permissions::Generic
    def delete?
      access_control.writable? object.dependant
    end
  end
end
