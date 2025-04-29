require 'fastlane/action'
require_relative '../helper/xccov_helper'

module Fastlane
  module Actions
    class XccovAction < Action
      def self.run(params)
        UI.user_error!("No command specified. Use :view, :diff, or :merge") unless params[:command]

        case params[:command]
        when :view
          return other_action.xccov_view(params.except(:command))
        when :diff
          return other_action.xccov_diff(params.except(:command))
        when :merge
          return other_action.xccov_merge(params.except(:command))
        else
          UI.user_error!("Unknown command: #{params[:command]}. Use :view, :diff, or :merge")
        end
      end

      def self.description
        "A fastlane plugin for xccov tool that provides code coverage functionality"
      end

      def self.authors
        ["crazymanish"]
      end

      def self.return_value
        "Returns the result of the xccov command execution"
      end

      def self.details
        "A fastlane plugin for the xccov tool that allows you to view, diff, and merge code coverage reports 🚀"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :command,
                                  env_name: "XCCOV_COMMAND",
                               description: "Which xccov command to run: view, diff, or merge",
                                  optional: false,
                                      type: Symbol,
                             verify_block: proc do |value|
                                             UI.user_error!("Command must be one of: :view, :diff, :merge") unless [:view, :diff, :merge].include?(value)
                                           end)
        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'xccov(command: :view, file_path: "coverage.xcresult", json: true)',
          'xccov(command: :diff, before_path: "before.xcresult", after_path: "after.xcresult", json: true)',
          'xccov(command: :merge, reports: ["report1.xccovreport", "report2.xccovreport"], archives: ["archive1.xccovarchive", "archive2.xccovarchive"], out_report: "merged.xccovreport")'
        ]
      end
    end
  end
end
