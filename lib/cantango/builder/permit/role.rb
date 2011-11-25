module CanTango::Builder
  module Permit
    class Role < Base
      include CanTango::Helpers::Debug

      # builds a list of Permits for each role of the current ability user (or account)
      # @return [Array<RoleGroupPermit::Base>] the role permits built for this ability
      def build
        if roles.empty?
          debug "Not building any RolePermit"
          return []
        end
        roles.inject([]) do |permits, role|
          debug "Building RolePermit for #{role}"
          (permits << create_permit(role)) if valid?(role.to_sym)
          permits
        end.compact
      end

      protected

      def roles
        ability.respond_to?(:roles) ? ability.roles : []
      end

      def valid? role
        filter(role).valid?
      end

      def filter role
        CanTango::Filters::RoleFilter.new role
      end
    end
  end
end
