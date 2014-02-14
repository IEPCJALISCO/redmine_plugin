require_dependency 'my_controller'

module Iepc
  module MyControllerPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development

        def page
          iepc_page
        end
      end
    end

    module ClassMethods

    end

    module InstanceMethods
      DEFAULT_LAYOUT = {  'top' => ['issuesassignedtome'],
                          'left' => ['issuesreportedbyme'],
                          'right' => ['issueswatched']
                        }.freeze

      # Show user's page
      def iepc_page
        @user = User.current
        @blocks = @user.pref[:my_page_layout] || DEFAULT_LAYOUT
      end

    end
  end
end

MyController.send(:include, Iepc::MyControllerPatch) unless MyController.included_modules.include? Iepc::MyControllerPatch
