module CanTango
  module Permit
    class RoleGroup < Base
      extend ClassMethods

      def name
        self.class.permit_name self.class
      end

      # creates the permit
      def initialize executor
        super
      end

      def execute!
        super
      end

      def valid_for? subject
        in_role_group? subject
      end

      def self.hash_key
        role_groups_list_meth
      end

      protected

      include CanTango::Permit::Helper::RoleMatcher

      include CanTango::Helpers::RoleMethods
      extend CanTango::Helpers::RoleMethods

      def in_role_group? subject
        has_role_group?(subject) || role_groups_of(subject).include?(role) 
      end

      def has_role_group? subject
        subject.send(has_role_group_meth, role) if subject.respond_to?(has_role_group_meth) 
      end

      def role_groups_of subject
        subject.respond_to?(role_groups_list_meth) ? subject.send(role_groups_list_meth) : []
      end
    end
  end
end
