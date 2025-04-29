require 'fastlane_core/ui/ui'
require 'open3'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)

  module Helper
    class XccovHelper
      # Executes a shell command and returns the output
      def self.run_command(command)
        UI.verbose("Running command: #{command}")
        
        stdout, stderr, status = Open3.capture3(command)
        
        if status.success?
          return stdout.strip
        else
          UI.error("Command failed: #{command}")
          UI.error("Error: #{stderr}")
          UI.user_error!("Failed to execute xccov command")
        end
      end

      # class methods that you define here become available in your action
      # as `Helper::XccovHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the xccov plugin helper!")
      end
    end
  end
end
